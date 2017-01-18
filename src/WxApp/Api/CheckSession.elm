module WxApp.Api.CheckSession exposing (Msg, call, cmd)

import WxApp.Types exposing (..)
import WxApp.Internal.Wx as Wx

import Task exposing (..)
import Json.Decode exposing (decodeValue, string, field)


type alias Msg = Res


onSucceed : Res -> Task Error Msg
onSucceed res =
    succeed res


call : Task Error Msg
call =
    Wx.call "checkSession" none onSucceed


cmd : (Result Error Msg -> msg) -> Cmd msg
cmd msg =
    call
        |> attempt msg
