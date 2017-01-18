module WxApp.Api.Login exposing (Msg, call, cmd)

import WxApp.Types exposing (..)
import WxApp.Internal.Wx as Wx

import Task exposing (..)
import Json.Decode exposing (decodeValue, string, field)


type alias Msg = String


onSucceed : Res -> Task Error Msg
onSucceed res =
    case decodeValue (field "code" string) res of
        Ok code ->
            succeed code
        Err err ->
            fail <| ApiError res err


call : Task Error Msg
call =
    Wx.call "login" none onSucceed

cmd : (Result Error Msg -> msg) -> Cmd msg
cmd msg =
    call
        |> attempt msg
