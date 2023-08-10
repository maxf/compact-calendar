module Date exposing (..)

import Time exposing (..)
import List exposing (..)

millisInDay : number
millisInDay = 86400000

dateCompare: Date -> Date -> Int
dateCompare a b =
    (posixToMillis (toPosix a)) - (posixToMillis (toPosix b))

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
        janFirst = Date year Jan 1
    in
    case getDow janFirst of
        Mon -> janFirst
        Tue -> addDay janFirst -1
        Wed -> addDay janFirst -2
        Thu -> addDay janFirst -3
        Fri -> addDay janFirst -4
        Sat -> addDay janFirst -5
        Sun -> addDay janFirst -6

getDow: Date -> Weekday
getDow date =
    date |> toPosix |> toWeekday Time.utc


format: Date -> String
format (Date y m d) =
    let
        monthString = fromMonth m
        weekdayString = getDow (Date y m d) |> fromWeekday
    in
        String.join " "
            [ weekdayString
            , String.fromInt d
            , monthString
            , String.fromInt y
            ]


getDay (Date _ _ d) = d

getYear (Date y _ _) = y

monthFromNum n =
    case n of
        0 -> Jan
        1 -> Feb
        2 -> Mar
        3 -> Apr
        4 -> May
        5 -> Jun
        6 -> Jul
        7 -> Aug
        8 -> Sep
        9 -> Oct
        10 -> Nov
        _ -> Dec

getMonthNumber: Date -> Int
getMonthNumber (Date y m d) =
    case m of
        Jan -> 1
        Feb -> 2
        Mar -> 3
        Apr -> 4
        May -> 5
        Jun -> 6
        Jul -> 7
        Aug -> 8
        Sep -> 9
        Oct -> 10
        Nov -> 11
        Dec -> 12


fromMonth: Month -> String
fromMonth month =
    case month of
        Jan -> "January"
        Feb -> "February"
        Mar -> "March"
        Apr -> "April"
        May -> "May"
        Jun -> "June"
        Jul -> "July"
        Aug -> "August"
        Sep -> "September"
        Oct -> "October"
        Nov -> "November"
        Dec -> "December"


fromWeekday: Weekday -> String
fromWeekday weekday =
    case weekday of
        Mon -> "Monday"
        Tue -> "Tuesday"
        Wed -> "Wednesday"
        Thu -> "Thursday"
        Fri -> "Friday"
        Sat -> "Saturday"
        Sun -> "Sunday"
