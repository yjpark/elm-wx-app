module WxApp.Api.ClearStorage exposing (Msg, call, cmd)

import WxApp.Types exposing (..)
import WxApp.Util exposing (..)
import WxApp.Internal.Wx as Wx

import Task exposing (..)
import Json.Decode exposing (decodeValue, string, field)

type alias Msg = Res


onSucceed : Res -> Task Error Msg
onSucceed res =
    succeed res


call : Task Error Msg
call =
    Wx.call "clearStorage" none onSucceed


cmd : (Result Error Msg -> msg) -> Cmd msg
cmd msg =
    call
        |> attempt msg
