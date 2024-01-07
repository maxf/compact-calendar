module Sync exposing (eventsDecoder, eventsEncode, bankHolidaysDecoder)

import Json.Decode as JD
import Json.Encode as JE
import Types exposing (Event, BankHoliday, FieldBeingEdited(..))
import Date exposing (Date(..), fromPosix, toPosix)
import Dict exposing (..)
import Time exposing (posixToMillis, millisToPosix)


eventsDecoder : JD.Decoder (List Event)
eventsDecoder =
    JD.list eventDecoder


eventDecoder : JD.Decoder Event
eventDecoder =
    JD.map6 Event
        (JD.field "id" JD.int)
        (JD.field "start" dateDecoder)
        (JD.field "duration" JD.int)
        (JD.field "title" JD.string)
        (JD.field "last_updated" (JD.map millisToPosix JD.int))
        (JD.succeed None)


dateDecoder : JD.Decoder Date
dateDecoder =
    JD.map (fromPosix << millisToPosix) JD.int


slashDateDecoder : JD.Decoder Date
slashDateDecoder =
    JD.string |> JD.andThen (
                             \dateString ->
                                 case Date.fromString dateString of
                                     Just d -> JD.succeed d
                                     Nothing -> JD.fail ("failed to parse '" ++ dateString ++ "' as a date")
                            )


bankHolidayDecoder : JD.Decoder BankHoliday
bankHolidayDecoder =
    (JD.map3 BankHoliday
         (JD.field "title" JD.string)
         (JD.field "date" slashDateDecoder)
         (JD.field "notes" JD.string)
    )


tryDecodeBankHolidaysList : JD.Decoder (Maybe (List BankHoliday))
tryDecodeBankHolidaysList =
    JD.oneOf [ JD.map Just (JD.list bankHolidayDecoder)
             , JD.succeed Nothing
             ]


bankHolidayRegionDecoder : JD.Decoder (List BankHoliday)
bankHolidayRegionDecoder =
    JD.keyValuePairs tryDecodeBankHolidaysList
        |> JD.map (List.filterMap Tuple.second) -- take the value only
        |> JD.map List.concat -- concatenate the bank holiday lists


bankHolidaysDecoder : JD.Decoder (List BankHoliday)
bankHolidaysDecoder =
    JD.at [ "divisions", "england-and-wales" ] bankHolidayRegionDecoder


dateEncode : Date -> JE.Value
dateEncode date =
    JE.int (date |> toPosix |> posixToMillis)


eventsEncode : List Event -> JE.Value
eventsEncode events =
    JE.list eventEncode events


posixEncode : Time.Posix -> JE.Value
posixEncode timestamp =
    JE.int (timestamp |> posixToMillis)


eventEncode : Event -> JE.Value
eventEncode event =
    JE.object
        [ ("start", dateEncode event.start)
        , ("duration", JE.int event.duration)
        , ("title", JE.string event.title)
        , ("id", JE.int event.id)
        , ("last_updated", posixEncode event.lastUpdated)
        ]
