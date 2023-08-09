module Date exposing (..)

import Time exposing (..)
import List exposing (..)

millisInDay : number
millisInDay = 86400000

dateCompare: Date -> Date -> Int
dateCompare a b =
    (toMillis utc (toPosix a)) - (toMillis utc (toPosix b))

addDay: Date -> Int -> Date
addDay d add =
    d
        |> toPosix
        |> posixToMillis
        |> (+) (add * millisInDay)
        |> millisToPosix
        |> fromPosix

type Date =
    Date Int Month Int

--To be a leap year, the year number must be divisible by four
--except for end-of-century years, which must be divisible by 400.
isLeapYear : Int -> Bool
isLeapYear y =
    modBy 4 y == 0 && modBy 100 y /= 0 || modBy 400 y == 0

toPosix: Date -> Posix
toPosix (Date y m d) =
    let
        days = (y * 365) + (countLeapYears (y - 1)) + (daysBeforeMonth m y) + (d - 1)
        epoch = (days - 719050) * millisInDay
    in
        millisToPosix epoch

fromPosix: Posix -> Date
fromPosix posix =
    Date (toYear utc posix) (toMonth utc posix) (toDay utc posix)

-- Count all years divisable by 4 as leap years
-- and subtract the false positives (centuries that is not a leap year)
countLeapYears: Int -> Int
countLeapYears year =
    let
        -- 492 leap year before 1970.
        max = year // 4 - 492
        -- centuries that is not a leap year
        false = year // 400 - 4
        -- 19 centuries before 1970.
        century = year // 100 - 19
    in
        max - (century - false)


daysBeforeMonth : Month ->Int -> Int
daysBeforeMonth m y =
    let
        addLeap = if isLeapYear y then 1 else 0
    in
    case m of
        Jan ->
            0

        Feb ->
            31

        Mar ->
            59 + addLeap

        Apr ->
            90 + addLeap

        May ->
            120 + addLeap

        Jun ->
            151 + addLeap

        Jul ->
            181 + addLeap

        Aug ->
            212 + addLeap

        Sep ->
            243 + addLeap

        Oct ->
            273 + addLeap

        Nov ->
            304 + addLeap

        Dec ->
            334 + addLeap


-- returns the date of the given weekday of the given week number
dateForWeek : Weekday -> Int -> Int -> Int
dateForWeek weekday weekNumber year =
    2


-- returns the day-of-week of the 1/1 of the year passed

firstDateOfWeekZero: Int -> Date
firstDateOfWeekZero year =
    let
        janFirst: Date
        janFirst = Date year Jan 1
        dowJanFirst: Weekday
        dowJanFirst = janFirst |> toPosix |> toWeekday Time.utc
    in
    case dowJanFirst of
        Mon ->
            janFirst
        Tue ->
            addDay janFirst -1
        Wed ->
            addDay janFirst -2
        Thu ->
            addDay janFirst -2
        Fri ->
            addDay janFirst -2
        Sat ->
            addDay janFirst -2
        Sun ->
            addDay janFirst -2
