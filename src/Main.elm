module Main exposing (..)

import Browser
import Html exposing (Html, button, div, text, table, tr, th, td)
import Html.Events exposing (onClick)
import Time exposing (Posix, Weekday(..), millisToPosix)
import Date exposing (Date(..), dateForWeek, firstDateOfWeekZero)


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

-- we need to know the dow of the first of the year

viewWeek : Int -> Int -> Html Msg
viewWeek year weekNumber =
    let
        (Date y m d) = firstDateOfWeekZero year
    in
    tr []
        [ th [] [ d |> String.fromInt |> text ]
        , th [] [ d |> String.fromInt |> text ]
        , th [] [ d |> String.fromInt |> text ]
        , th [] [ d |> String.fromInt |> text ]
        , th [] [ d |> String.fromInt |> text ]
        , th [] [ d |> String.fromInt |> text ]
        , th [] [ d |> String.fromInt |> text ]
        ]

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
