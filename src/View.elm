module View exposing (view)

import Browser
import Html exposing (Html, button, div, text, table, thead, tbody, tr, th, td, ul, li, details, summary, span, button, input)
import Html.Attributes exposing (title, class, style, value)
import Html.Events exposing (onClick, onInput, onBlur, keyCode, on)
import Html.Events.Extra exposing (onEnter)
import Time exposing (Month(..), Weekday(..))
import Date exposing (Date(..), getYear, getDow, firstDateOfWeekZero, addDay, getDay, dateCompare, millisInDay, format, fromMonth, formatShort)
import Types exposing (Msg(..), FieldBeingEdited(..), Event, Model)


eventSortCompare: Event -> Event -> Order
eventSortCompare a b =
    let
        diff = dateCompare a.start b.start
    in
        if diff < 0 then LT else if diff == 0 then EQ else GT


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
