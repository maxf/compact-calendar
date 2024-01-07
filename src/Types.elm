module Types exposing (Msg(..), FieldBeingEdited(..), Event, Model, BankHoliday)

import Date exposing (Date(..))
import Time exposing (Posix(..))
import Http exposing (Error)

type Msg
    = UserClickedOnDate Date
    | UserDeletedEvent Event
    | UserTypedInNewTitle Event String
    | UserRemovedNewTitleFocus Event
    | UserClickedTitle Event
    | UserClickedDuration Event
    | UserTypedInNewDuration Event String
    | UserRemovedNewDurationFocus Event
    | SetEventUpdateTime Event Time.Posix
    | GotBankHolidays (Result Http.Error (List BankHoliday))
    | NoOp


type FieldBeingEdited
    = None
    | Title String
    | Duration String


type alias EventId = Int

type alias BankHoliday =
    { title : String
    , date : Date
    , notes : String
    }

type alias Event =
    { id : EventId
    , start: Date
    , duration: Int
    , title: String
    , lastUpdated: Time.Posix
    , editing: FieldBeingEdited
    }


type alias Model =
    { today : Date
    , events : List Event
    , bankHolidays : List BankHoliday
    }
