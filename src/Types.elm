module Types exposing (Msg(..), FieldBeingEdited(..), Event, Model)

import Date exposing (Date(..))

type Msg
    = UserClickedOnDate Date
    | UserDeletedEvent Event
    | UserTypedInNewTitle Event String
    | UserRemovedNewTitleFocus Event
    | UserClickedTitle Event
    | UserClickedDuration Event
    | UserTypedInNewDuration Event String
    | UserRemovedNewDurationFocus Event


type FieldBeingEdited
    = None
    | Title String
    | Duration String


type alias EventId = Int


type alias Event =
    { id : EventId
    , start: Date
    , duration: Int
    , title: String
    , editing: FieldBeingEdited
    }


type alias Model =
    { today: Date
    , events: List Event
    }
