module Main exposing (..)

import Browser
import Html exposing (Html, button, div, text, table, tr, th, td)
import Html.Attributes exposing (title, class)
import Html.Events exposing (onClick)
import Time exposing (Posix, Weekday(..), millisToPosix)
import Date exposing (Date(..), dateForWeek, firstDateOfWeekZero, addDay, fromMonth, format, getDay, getMonthNumber)


-- MAIN


main =
  Browser.document
      { init = init
      , update = update
      , view = view
      , subscriptions = \model -> Sub.none
      }



-- MODEL

type alias Model = Int

init : Int -> (Model, Cmd Msg)
init flags =
    (0, Cmd.none)


-- UPDATE

type Msg = Increment | Decrement

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
        Increment ->
            (model + 1, Cmd.none)

        Decrement ->
            (model - 1, Cmd.none)



-- VIEW

viewCalendarCell: Date -> Html Msg
viewCalendarCell date =
    let
        monthClass = if modBy 2 (getMonthNumber date) == 0 then "oddMonth" else "evenMonth"
    in
    td
        [ title (format date)
        , class monthClass
        ]
        [ date |> getDay |> String.fromInt |> text ]



viewWeek : Int -> Int -> Html Msg
viewWeek year weekNumber =
    let
        firstDateOf0 = firstDateOfWeekZero year
        cellHtml: Int -> Html Msg
        cellHtml i =
            viewCalendarCell (addDay firstDateOf0 (weekNumber * 7 + i))
    in
    tr []
        (List.map cellHtml (List.range 0 7))


viewWeeks : Int -> Html Msg
viewWeeks year =
    table []
    (List.map (viewWeek year) (List.range 0 52))

view : Model -> Browser.Document Msg
view model =
    let
        body =
            [ div []
                  [ button [ onClick Decrement ] [ text "-" ]
                  , div [] [ text (String.fromInt model) ]
                  , button [ onClick Increment ] [ text "+" ]
                  ]
            , viewWeeks 2023
            ]
    in
        Browser.Document "Compact calendar" body
