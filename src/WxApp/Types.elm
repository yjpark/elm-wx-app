module WxApp.Types exposing (DataDict, empty, Data, none, Res, Error(..))

import Json.Encode
import Dict

type alias DataDict = (Dict.Dict String Data)

empty : DataDict
empty =
    Dict.empty


type alias Data = Json.Encode.Value
none = Json.Encode.null

type alias Res = Json.Encode.Value

type Error
    = BadEnvironment
    | ApiNotFound
    | ApiException Res
    | ApiFailed Res
    | ApiError Res String
    | DecodeError Res String
