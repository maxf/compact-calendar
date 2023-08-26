port module Main exposing (..)

import Browser
import Json.Encode
import Json.Decode
import Date exposing (Date(..), monthFromNum)
import View exposing (view)
import Types exposing (Msg(..), FieldBeingEdited(..), Event, Model)
import Sync exposing (eventsEncode, eventsDecoder)
import Time exposing (Posix(..), now)
import Task exposing (perform)

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


replaceEvent : Model -> Event -> Event -> Model
replaceEvent model oldEvent newEvent =
    let
        newEvents =
            List.append
                (List.filter (\e -> e.id /= oldEvent.id) model.events)
                [ newEvent ]
    in
        { model | events = newEvents }


setEventEditing : Model -> Event -> FieldBeingEdited -> Model
setEventEditing model event field =
    let
        newEvent =
            { event | editing = field }
    in
        replaceEvent model event newEvent


clearEventEditing : Model -> Event -> (Model, Cmd Msg)
clearEventEditing model event =
    case event.editing of
        Title tmpTitle ->
            let
                updatedEvent = { event | title = tmpTitle, editing = None }
            in
            ( model, Task.perform (SetEventUpdateTime updatedEvent) Time.now )

        Duration tmpDuration ->
            let
                newDuration =
                    case String.toInt tmpDuration of
                        Just val -> val
                        Nothing -> 1
                updatedEvent = { event | duration = newDuration, editing = None }
            in
            ( model, Task.perform (SetEventUpdateTime updatedEvent) Time.now )

        None ->
            ( model, Cmd.none )


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


newEventId : List Event -> Int
newEventId events =
    let
        maxId =
            List.foldl
                max
                0
                (List.map .id events)
    in
        maxId + 1


update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
        UserClickedOnDate date ->
            let
                newEvent: Event
                newEvent =
                    { id = newEventId model.events
                    , start = date
                    , duration = 1
                    , title = "new event"
                    , editing = None
                    , lastUpdated = (Time.millisToPosix 0)
                    }
            in
            ( model, Task.perform (SetEventUpdateTime newEvent) Time.now )

        SetEventUpdateTime event time ->
            let
                updatedEvents =
                    List.append
                        (List.filter(\e -> e.id /= event.id) model.events)
                        [{ event | lastUpdated = time }]
            in
            ( { model | events = updatedEvents }, Cmd.none )

        UserDeletedEvent eventToDelete ->
            ( { model | events = List.filter (\e -> e.id /= eventToDelete.id) model.events }
            , Cmd.none
            )

        UserTypedInNewTitle event input ->
            let
                updatedEvents =
                    List.append
                        (List.filter (\e -> e.id /= event.id) model.events)
                        [{ event | editing = Title input }]
            in
            ({ model | events = updatedEvents }, Cmd.none )

        UserRemovedNewTitleFocus event ->
            clearEventEditing model event

        UserRemovedNewDurationFocus event ->
            clearEventEditing model event

        UserClickedTitle event ->
            ( setEventEditing
                  model
                  event
                  (Title event.title)
            , Cmd.none
            )

        UserTypedInNewDuration event newDurationString ->
            let
                newDuration =
                    case String.toInt newDurationString of
                        Just value -> value
                        Nothing -> 1

                updatedEvents =
                    List.append
                        (List.filter (\e -> e.id /= event.id) model.events)
                        [{ event | editing = Duration newDurationString }]
            in
            ({ model | events = updatedEvents }, Cmd.none )

        UserClickedDuration event ->
            ( setEventEditing
                  model
                  event
                  (Duration (String.fromInt event.duration))
            , Cmd.none
            )
