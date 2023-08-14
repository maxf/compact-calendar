module Sync exposing (eventsDecoder, eventsEncode)

import Json.Decode
import Json.Encode
import Types exposing (Event, FieldBeingEdited(..))
import Date exposing (Date(..), fromPosix, toPosix)
import Time exposing (posixToMillis, millisToPosix)


eventsDecoder : Json.Decode.Decoder (List Event)
eventsDecoder =
    Json.Decode.list eventDecoder


eventDecoder : Json.Decode.Decoder Event
eventDecoder =
    Json.Decode.map4 Event
        (Json.Decode.field "start" dateDecoder)
        (Json.Decode.field "durationInDays" Json.Decode.int)
        (Json.Decode.field "title" Json.Decode.string)
        (Json.Decode.field "editing" Json.Decode.string |> Json.Decode.andThen editingDecoder)


dateDecoder : Json.Decode.Decoder Date
dateDecoder =
    Json.Decode.map (fromPosix << millisToPosix) Json.Decode.int


dateEncode : Date -> Json.Encode.Value
dateEncode date =
    Json.Encode.int (date |> toPosix |> posixToMillis)


editingDecoder : String -> Json.Decode.Decoder FieldBeingEdited
editingDecoder tag =
    case tag of
        "none" -> Json.Decode.succeed None
        "title" -> Json.Decode.succeed Title
        "duration" -> Json.Decode.succeed Duration
        _ -> Json.Decode.fail ( tag ++ " is not a recognise tag for FieldBeingEdited.")


editingEncode : FieldBeingEdited -> Json.Encode.Value
editingEncode editing =
    case editing of
        None -> Json.Encode.string "none"
        Title -> Json.Encode.string "title"
        Duration -> Json.Encode.string "duration"


eventsEncode : List Event -> Json.Encode.Value
eventsEncode events =
    Json.Encode.list eventEncode events


eventEncode : Event -> Json.Encode.Value
eventEncode event =
    Json.Encode.object
        [ ("start", dateEncode event.start)
        , ("durationInDays", Json.Encode.int event.durationInDays)
        , ("title", Json.Encode.string event.title)
        , ("editing", editingEncode event.editing)
        ]
