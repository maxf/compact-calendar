port module Main exposing (..)

import Browser
import Json.Encode
import Json.Decode
import Date exposing (Date(..), monthFromNum)
import View exposing (view)
import Types exposing (Msg(..), FieldBeingEdited(..), Event, Model)
import Sync exposing (eventsEncode, eventsDecoder)


main =
  Browser.document
      { init = init
      , update = updateWithStorage
      , view = view
      , subscriptions = \model -> Sub.none
      }


port setStorage : Json.Encode.Value -> Cmd msg


init : { day: Int, month: Int, year: Int, events: Json.Encode.Value } -> ( Model, Cmd Msg )
init flags =
    let
        initialModel =
            { today = (Date flags.year (monthFromNum flags.month) flags.day)
            , events =
                case Json.Decode.decodeValue eventsDecoder flags.events of
                    Ok events -> events
                    Err x ->
                        let
                            _ = Debug.log "Error decoding events" x
                        in
                        []
            }
    in
    (initialModel, Cmd.none)



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
