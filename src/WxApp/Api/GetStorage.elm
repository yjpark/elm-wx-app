module WxApp.Api.GetStorage exposing (Msg, call, cmd)

import WxApp.Types exposing (..)
import WxApp.Util exposing (..)
import WxApp.Internal.Wx as Wx

import Task exposing (..)
import Json.Decode exposing (Decoder, decodeValue, string, field, value)


type alias Key = String

type alias Msg = Res


encodeData : Key -> Data
encodeData key =
    empty
        |> insertString "key" key
        |> dictToData


onSucceed : (Decoder msg) -> Res -> Task Error msg
onSucceed decoder res =
    let
        dataResult = decodeValue (field "data" value) res
    in
        case dataResult of
            Ok data ->
                case decodeValue decoder data of
                    Ok msg ->
                        succeed msg
                    Err err ->
                        fail <| DecodeError res err
            Err err ->
                fail <| ApiError res ("BadData:" ++ err)


call : Key -> (Decoder msg) -> Task Error msg
call key decoder =
    Wx.call "getStorage" (encodeData key) (onSucceed decoder)


cmd : Key -> (Decoder msg) -> (Result Error msg -> msg2) -> Cmd msg2
cmd key decoder msg =
    call key decoder
        |> attempt msg
