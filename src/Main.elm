module Main exposing (..)

import Browser
import Html exposing (Html, button, div, text, table, thead, tbody, tr, th, td, ul, li, details, summary, span, button, input)
import Html.Attributes exposing (title, class, style, value)
import Html.Events exposing (onClick, onInput, onBlur, keyCode, on)
import Html.Events.Extra exposing (onEnter)
import Time exposing (Posix, Weekday(..), Month(..), millisToPosix, utc, toMillis)
import Date exposing (Date(..), firstDateOfWeekZero, addDay, fromMonth, format, getDay, getMonthNumber, getDow, getYear, monthFromNum, dateCompare, toPosix, formatShort, millisInDay)


-- MAIN


main =
  Browser.document
      { init = init
      , update = update
      , view = view
      , subscriptions = \model -> Sub.none
      }


-- MODEL


type alias Event =
    { start: Date
    , durationInDays: Int
    , title: String
    , editing: Bool
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


init : { day: Int, month: Int, year: Int } -> (Model, Cmd Msg)
init date =
    let
        initialModel =
            { today = (Date date.year (monthFromNum date.month) date.day)
            , events =
                  [
                   { start = Date 2023 Aug 15
                   , durationInDays = 1
                   , title = "event1"
                   , editing = False
                   }
                  , { start = Date 2023 Aug 16
                    , durationInDays = 1
                    , title = "event1.5"
                    , editing = False
                    }
                  , { start = Date 2023 Sep 1
                    , durationInDays = 1
                    , title = "event2"
                    , editing = False
                    }
                  ]
            }
    in
    (initialModel, Cmd.none)


-- UPDATE


type Msg
    = UserClickedOnDate Date
    | UserDeletedEvent Event
    | UserTypedInNewEvent Event String
    | UserRemovedNewEventFocus Event
    | UserClickedEventTitle Event


modifyModelEventEditing : Model -> Event -> Bool -> Model
modifyModelEventEditing model event newValue =
    let
        updatedEvents =
            List.append
                (List.filter (\e -> e /= event) model.events)
                [{ event | editing = newValue }]
    in
        { model | events = updatedEvents }


update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
        UserClickedOnDate date ->
            let
                newEvent: Event
                newEvent = { start = date, durationInDays = 1, title = "new event", editing = True }
            in
            ({model | events = List.append [newEvent] model.events}, Cmd.none)

        UserDeletedEvent eventToDelete ->
            ( { model | events = List.filter (\e -> e /= eventToDelete) model.events }
            , Cmd.none
            )
        UserTypedInNewEvent event input ->
            let
                updatedEvents =
                    List.append
                        (List.filter (\e -> e /= event) model.events)
                        [{ event | title = input }]
            in
            ({ model | events = updatedEvents }, Cmd.none )

        UserRemovedNewEventFocus event ->
            ( modifyModelEventEditing model event False, Cmd.none )

        UserClickedEventTitle event ->
            ( modifyModelEventEditing model event True, Cmd.none )
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
        html =
            if event.editing then
                input
                    [ onEnter (UserRemovedNewEventFocus event)
                    , onInput (UserTypedInNewEvent event)
                    , onBlur (UserRemovedNewEventFocus event)
                    , value event.title
                    ]
                    []
            else
                span
                  [ onClick (UserClickedEventTitle event) ]
                  [ event.title |> text ]
    in
    li []
        [ span [] [ (formatShort event.start) ++ ": " |> text ]
        , html
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
