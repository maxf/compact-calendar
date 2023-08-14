port module Main exposing (..)

import Browser
import Html exposing (Html, button, div, text, table, thead, tbody, tr, th, td, ul, li, details, summary, span, button, input)
import Html.Attributes exposing (title, class, style, value)
import Html.Events exposing (onClick, onInput, onBlur, keyCode, on)
import Html.Events.Extra exposing (onEnter)
import Time exposing (Posix, Weekday(..), Month(..), millisToPosix, utc, toMillis, posixToMillis)
import Json.Decode as D
import Json.Encode as E
import Date exposing (Date(..), firstDateOfWeekZero, addDay, fromMonth, format, getDay, getMonthNumber, getDow, getYear, monthFromNum, dateCompare, toPosix, formatShort, millisInDay, fromPosix)


-- MAIN


main =
  Browser.document
      { init = init
      , update = updateWithStorage
      , view = view
      , subscriptions = \model -> Sub.none
      }

port setStorage : E.Value -> Cmd msg

-- MODEL

type FieldBeingEdited =
    None | Title | Duration

type alias Event =
    { start: Date
    , durationInDays: Int
    , title: String
    , editing: FieldBeingEdited
    }


eventSortCompare: Event -> Event -> Order
eventSortCompare a b =
    let
        diff = dateCompare a.start b.start
    in
        if diff < 0 then LT else if diff == 0 then EQ else GT


type alias Model =
    { today: Date
    , events: List Event
    }


init : { day: Int, month: Int, year: Int, events: E.Value } -> ( Model, Cmd Msg )
init flags =
    let
        initialModel =
            { today = (Date flags.year (monthFromNum flags.month) flags.day)
            , events =
                case D.decodeValue eventsDecoder flags.events of
                    Ok events -> events
                    Err x ->
                        let
                            _ = Debug.log "Error decoding events" x
                        in
                        []
            }
    in
    (initialModel, Cmd.none)


eventsDecoder : D.Decoder (List Event)
eventsDecoder =
    D.list eventDecoder


eventDecoder : D.Decoder Event
eventDecoder =
    D.map4 Event
        (D.field "start" dateDecoder)
        (D.field "durationInDays" D.int)
        (D.field "title" D.string)
        (D.field "editing" D.string |> D.andThen editingDecoder)


dateDecoder : D.Decoder Date
dateDecoder =
    D.map (fromPosix << millisToPosix) D.int


dateEncode : Date -> E.Value
dateEncode date =
    E.int (date |> toPosix |> posixToMillis)


editingDecoder : String -> D.Decoder FieldBeingEdited
editingDecoder tag =
    case tag of
        "none" -> D.succeed None
        "title" -> D.succeed Title
        "duration" -> D.succeed Duration
        _ -> D.fail ( tag ++ " is not a recognise tag for FieldBeingEdited.")

editingEncode : FieldBeingEdited -> E.Value
editingEncode editing =
    case editing of
        None -> E.string "none"
        Title -> E.string "title"
        Duration -> E.string "duration"


eventsEncode : List Event -> E.Value
eventsEncode events =
    E.list eventEncode events


eventEncode : Event -> E.Value
eventEncode event =
    E.object
        [ ("start", dateEncode event.start)
        , ("durationInDays", E.int event.durationInDays)
        , ("title", E.string event.title)
        , ("editing", editingEncode event.editing)
        ]


-- UPDATE


type Msg
    = UserClickedOnDate Date
    | UserDeletedEvent Event
    | UserTypedInNewTitle Event String
    | UserRemovedNewTitleFocus Event
    | UserClickedTitle Event
    | UserClickedDuration Event
    | UserTypedInNewDuration Event String
    | UserRemovedNewDurationFocus Event


eventsNotEqual : Event -> Event -> Bool
eventsNotEqual a b =
    ( a.start, a.title, a.durationInDays ) /= ( b.start, b.title, b.durationInDays )


modifyModelEventEditing : Model -> Event -> FieldBeingEdited -> Model
modifyModelEventEditing model event newValue =
    let
        updatedEvents =
            List.append
                (List.filter (\e -> eventsNotEqual e event) model.events)
                [{ event | editing = newValue }]
    in
        { model | events = updatedEvents }


-- We want to `setStorage` on every update, so this function adds
-- the setStorage command on each step of the update function.
--
-- Check out index.html to see how this is handled on the JS side.
--
updateWithStorage : Msg -> Model -> ( Model, Cmd Msg )
updateWithStorage msg oldModel =
    let
        ( newModel, cmds ) = update msg oldModel
    in
        ( newModel
        , Cmd.batch [ setStorage (eventsEncode newModel.events), cmds ]
        )


update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
        UserClickedOnDate date ->
            let
                newEvent: Event
                newEvent =
                    { start = date
                    , durationInDays = 1
                    , title = "new event"
                    , editing = None
                    }
            in
            ({model | events = List.append [newEvent] model.events}, Cmd.none)

        UserDeletedEvent eventToDelete ->
            ( { model | events = List.filter (\e -> eventsNotEqual e eventToDelete) model.events }
            , Cmd.none
            )

        UserTypedInNewTitle event input ->
            let
                updatedEvents =
                    List.append
                        (List.filter (\e -> eventsNotEqual e event) model.events)
                        [{ event | title = input }]
            in
            ({ model | events = updatedEvents }, Cmd.none )

        UserRemovedNewTitleFocus event ->
            ( modifyModelEventEditing model event None, Cmd.none )

        UserRemovedNewDurationFocus event ->
            ( modifyModelEventEditing model event None, Cmd.none )

        UserClickedTitle event ->
            ( modifyModelEventEditing model event Title, Cmd.none )

        UserTypedInNewDuration event newDurationString ->
            let
                newDuration =
                    case String.toInt newDurationString of
                        Just value -> value
                        Nothing -> 1

                updatedEvents =
                    List.append
                        (List.filter (\e -> eventsNotEqual e event) model.events)
                        [{ event | durationInDays = newDuration }]
            in
            ({ model | events = updatedEvents }, Cmd.none )


        UserClickedDuration event ->
            ( modifyModelEventEditing model event Duration, Cmd.none )


-- VIEW


viewCalendarCell: Model -> Date -> Html Msg
viewCalendarCell model date =
    let
        dow = getDow date

        firstDayOfMonthClass = if getDay date == 1 then "first-day" else ""

        dayClass = if dow == Sat || dow == Sun then "weekend" else ""

        nextWeekDay = addDay date 7

        dayIsPastClass =
            if dateCompare model.today date > 0 then "past" else ""

        monthClass =
            if getDay nextWeekDay < getDay date then
                "delimiterBottom"
            else
                ""

        eventsOnThisDaysClass =
            if List.length (List.filter (\e -> e.start == date) model.events) > 0 then "events" else ""

        cellClass =
            String.join " "
                [ firstDayOfMonthClass
                , dayClass
                , monthClass
                , dayIsPastClass
                ]


    in
    td
        [ title (format date)
        , class cellClass
        , onClick (UserClickedOnDate date)
        ]
        [ div
              [ class eventsOnThisDaysClass ]
              [ date |> getDay |> String.fromInt |> text ]
        ]



viewWeek : Model -> Int -> Html Msg
viewWeek model weekNumber =
    let
        firstDateOf0 = firstDateOfWeekZero (getYear model.today)

        firstDateOfWeek = addDay firstDateOf0 (weekNumber * 7)

        lastDateOfWeek = addDay firstDateOf0 (weekNumber * 7 + 6)

        ( Date _ m _ ) = lastDateOfWeek

        cellHtml: Int -> Html Msg
        cellHtml i =
            viewCalendarCell model (addDay firstDateOf0 (weekNumber * 7 + i))

        diffDays =
            (getDay lastDateOfWeek) - (getDay firstDateOfWeek)

        monthColContent =
            if diffDays < 0 || (getDay firstDateOfWeek) == 1 then
                [ m |> fromMonth |> text ]
            else
                [ ]

        monthColAttribs =
            if diffDays < 0 || (getDay firstDateOfWeek) == 1 then
                [ class "monthName" ]
            else
                [ ]

    in
    tr []
        (List.concat
             [ [td monthColAttribs  monthColContent]
             , List.map cellHtml (List.range 0 6)
             ]
        )


viewYear : Model -> Html Msg
viewYear model =
    table []
        (List.append
             [ tr []
                   [ th [] [ text "Month" ]
                   , th [] [ text "M" ]
                   , th [] [ text "T" ]
                   , th [] [ text "W" ]
                   , th [] [ text "T" ]
                   , th [] [ text "F" ]
                   , th [] [ text "S" ]
                   , th [] [ text "S" ]
                   ]
             ]
             (List.map (viewWeek model) (List.range 0 52))
        )


viewEvent : Event -> Html Msg
viewEvent event =
    let
        titleHtml =
            case event.editing of
                Title ->
                    input
                        [ value event.title
                        , onInput (UserTypedInNewTitle event)
                        , onEnter (UserRemovedNewTitleFocus event)
                        , onBlur (UserRemovedNewTitleFocus event)
                        ]
                        []
                _ ->
                    span
                    [ onClick (UserClickedTitle event) ]
                    [ event.title |> text ]

        durationHtml =
            case event.editing of
                Duration ->
                    input
                    [ value (String.fromInt event.durationInDays)
                    , onInput (UserTypedInNewDuration event)
                    , onEnter (UserRemovedNewDurationFocus event)
                    , onBlur (UserRemovedNewDurationFocus event)
                    ]
                    []
                _ ->
                    event.durationInDays |> String.fromInt |> text
    in
    li []
        [ span [] [ formatShort event.start |> text]
        , span
              [ onClick (UserClickedDuration event) ]
              [ " (" |> text
              , durationHtml
              , " days): " |> text
              ]
        , titleHtml
        , button [ onClick (UserDeletedEvent event) ] [ text "X" ]
        ]



isEventPast : Date -> Event -> Bool
isEventPast today event =
    dateCompare event.start today < 0


isEventFuture : Date -> Event -> Bool
isEventFuture today event =
    dateCompare event.start today >= 0


viewEvents : Model -> Html Msg
viewEvents model =
    let
        pastEvents = List.filter (isEventPast model.today) model.events |> List.sortWith eventSortCompare
        presentFutureEvents = List.filter (isEventFuture model.today) model.events  |> List.sortWith eventSortCompare
        offset = dateCompare model.today (Date (getYear model.today) Jan 1) // millisInDay // 7 * 28 |> String.fromInt
    in
        div [ class "events-pane", style "top" (offset ++ "px") ]
            [ details []
                  [ summary []
                        [ (String.fromInt (List.length pastEvents)) ++ " past events" |> text ]
                  , ul [] (List.map viewEvent pastEvents)
                  ]

        , ul []
            (List.map viewEvent presentFutureEvents)
        ]


view : Model -> Browser.Document Msg
view model =
    let
        body =
            [ div [ class "columns" ]
                  [ viewYear model
                  , viewEvents model
                  ]
            ]
    in
        Browser.Document "Compact calendar" body
