module WxApp.Api.GetSystemInfo exposing (Msg, call, cmd)

import WxApp.Types exposing (..)
import WxApp.Internal.Wx as Wx
import WxApp.Model.SystemInfo as SystemInfo

import Task exposing (..)
import Json.Decode exposing (decodeValue, string, field)


type alias Msg = SystemInfo.Type


onSucceed : Res -> Task Error Msg
onSucceed res =
    case decodeValue SystemInfo.decoder res of
        Ok systemInfo ->
            succeed systemInfo
        Err err ->
            fail <| ApiError res err


call : Task Error Msg
call =
    Wx.call "getSystemInfo" none onSucceed

cmd : (Result Error Msg -> msg) -> Cmd msg
cmd msg =
    call
        |> attempt msg
