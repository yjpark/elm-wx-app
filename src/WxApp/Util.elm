module WxApp.Util exposing (..)

import WxApp.Types exposing (..)

import Json.Decode exposing (int, float, bool, string, value, decodeValue, field, dict)
import Json.Encode
import Dict


type WxDataType
    = WxBool
    | WxInt
    | WxFloat
    | WxString
    | WxData


insertBool : String -> Bool -> DataDict -> DataDict
insertBool key val =
    Dict.insert key (Json.Encode.bool val)


insertInt : String -> Int -> DataDict -> DataDict
insertInt key val =
    Dict.insert key (Json.Encode.int val)


insertFloat : String -> Float -> DataDict -> DataDict
insertFloat key val =
    Dict.insert key (Json.Encode.float val)


insertString : String -> String -> DataDict -> DataDict
insertString key str =
    Dict.insert key (Json.Encode.string str)


insertData : String -> Data -> DataDict -> DataDict
insertData key data =
    Dict.insert key data


insertOptionalString : String -> String -> DataDict -> DataDict
insertOptionalString key str =
    if (str /= "") then
        insertString key str
    else
        identity


insertOptionalData : String -> Data -> DataDict -> DataDict
insertOptionalData key data =
    if (data /= none) then
        insertData key data
    else
        identity


{--
insert : String -> (WxDataType, a) -> DataDict -> DataDict
insert key (type_, value) =
    case type_ of
        WxBool ->
            insertBool key value
        WxInt ->
            insertInt key value
        WxFloat ->
            insertFloat key value
        WxString ->
            insertString key value
        WxData ->
            insertData key value
--}


dictToData : DataDict -> Data
dictToData data =
    Dict.toList data
        |> Json.Encode.object


dataToDict : Data -> DataDict
dataToDict data =
    if data == none then
        empty
    else
        case decodeValue (dict value) data of
            Ok result ->
                result
            Err err ->
                Debug.log ("dataToDict: Decode Failed: " ++ err) empty


stringToData : String -> Data
stringToData str =
    Json.Encode.string str


listToData : List Data -> Data
listToData data =
    data
        |> Json.Encode.list


asString : Data -> String
asString data =
    case (decodeValue (string) data) of
        Ok val ->
            val
        Err err ->
            err


getStringWithDefault : String -> String -> Data -> String
getStringWithDefault key default data =
    case (decodeValue (field key string) data) of
        Ok val ->
            val
        Err err ->
            default


getString : String -> Data -> String
getString key data =
    getStringWithDefault key "" data


getIntWithDefault : String -> Int -> Data -> Int
getIntWithDefault key default data =
    case (decodeValue (field key int) data) of
        Ok val ->
            val
        Err err ->
            default


getInt : String -> Data -> Int
getInt key data =
    getIntWithDefault key 0 data


getFloatWithDefault : String -> Float -> Data -> Float
getFloatWithDefault key default data =
    case (decodeValue (field key float) data) of
        Ok val ->
            val
        Err err ->
            default


getFloat : String -> Data -> Float
getFloat key data =
    getFloatWithDefault key 0 data


getBoolWithDefault : String -> Bool -> Data -> Bool
getBoolWithDefault key default data =
    case (decodeValue (field key bool) data) of
        Ok val ->
            val
        Err err ->
            default


getBool : String -> Data -> Bool
getBool key data =
    getBoolWithDefault key False data


getDataWithDefault : String -> Data -> Data -> Data
getDataWithDefault key default data =
    case (decodeValue (field key value) data) of
        Ok val ->
            val
        Err err ->
            default


getData : String -> Data -> Data
getData key data =
    getDataWithDefault key none data
