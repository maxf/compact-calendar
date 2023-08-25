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
    Json.Decode.map5 Event
        (Json.Decode.field "id" Json.Decode.int)
        (Json.Decode.field "start" dateDecoder)
        (Json.Decode.field "duration" Json.Decode.int)
        (Json.Decode.field "title" Json.Decode.string)
        (Json.Decode.succeed None)


dateDecoder : Json.Decode.Decoder Date
dateDecoder =
    Json.Decode.map (fromPosix << millisToPosix) Json.Decode.int


dateEncode : Date -> Json.Encode.Value
dateEncode date =
    Json.Encode.int (date |> toPosix |> posixToMillis)


eventsEncode : List Event -> Json.Encode.Value
eventsEncode events =
    Json.Encode.list eventEncode events


eventEncode : Event -> Json.Encode.Value
eventEncode event =
    Json.Encode.object
        [ ("start", dateEncode event.start)
        , ("duration", Json.Encode.int event.duration)
        , ("title", Json.Encode.string event.title)
        , ("id", Json.Encode.int event.id)
        ]
