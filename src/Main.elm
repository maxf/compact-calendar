module Main exposing (..)

import Browser
import Html exposing (Html, button, div, text, table, tr, th, td)
import Html.Attributes exposing (title, class)
import Html.Events exposing (onClick)
import Time exposing (Posix, Weekday(..), millisToPosix)
import Date exposing (Date(..), dateForWeek, firstDateOfWeekZero, addDay, fromMonth, format, getDay, getMonthNumber, getDow)


-- MAIN


main =
  Browser.document
      { init = init
      , update = update
      , view = view
      , subscriptions = \model -> Sub.none
      }



-- MODEL

type alias Model =
    { date: Int
    , month: Int
    , year: Int
    }


init : { date: Int, month: Int, year: Int } -> (Model, Cmd Msg)
init today =
    (today, Cmd.none)


-- UPDATE

type Msg = Increment | Decrement

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
        Increment ->
            (model, Cmd.none)

        Decrement ->
            (model, Cmd.none)



-- VIEW

viewCalendarCell: Date -> Html Msg
viewCalendarCell date =
    let
--        monthClass = if modBy 2 (getMonthNumber date) == 0 then "oddMonth" else "evenMonth"
        dow = getDow date

        firstDayOfMonthClass = if getDay date == 1 then "first-day" else ""

        dayClass = if dow == Sat || dow == Sun then "weekend" else ""

        nextWeekDay = addDay date 7

        monthClass =
            if getDay nextWeekDay < getDay date then
                "delimiterBottom"
            else
                ""

        cellClass = firstDayOfMonthClass ++ " " ++ dayClass ++ " " ++ monthClass


    in
    td
        [ title (format date)
        , class cellClass
        ]
        [ date |> getDay |> String.fromInt |> text ]



viewWeek : Int -> Int -> Html Msg
viewWeek year weekNumber =
    let
        firstDateOf0 = firstDateOfWeekZero year

        firstDateOfWeek = addDay firstDateOf0 (weekNumber * 7)

        lastDateOfWeek = addDay firstDateOf0 (weekNumber * 7 + 6)

        (Date _ m _) = lastDateOfWeek

        cellHtml: Int -> Html Msg
        cellHtml i =
            viewCalendarCell (addDay firstDateOf0 (weekNumber * 7 + i))

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
        (List.append
             [ td monthColAttribs  monthColContent ]
             (List.map cellHtml (List.range 0 6))
        )


viewYear : Int -> Html Msg
viewYear year =
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
             (List.map (viewWeek year) (List.range 0 52))
        )


view : Model -> Browser.Document Msg
view model =
    let
        body = [ viewYear model.year ]
    in
        Browser.Document "Compact calendar" body
