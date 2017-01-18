module WxApp.Api.SwitchTab exposing (Msg, call, cmd)

import WxApp.Types exposing (..)
import WxApp.Util exposing (..)
import WxApp.Internal.Wx as Wx

import Task exposing (..)


type alias Msg = Res


onSucceed : Res -> Task Error Msg
onSucceed res =
    succeed res


encodeData : String -> Data
encodeData url =
    empty
        |> insertString "url" url
        |> dictToData


call : String -> Task Error Msg
call url =
    Wx.call "switchTab" (encodeData url) onSucceed


cmd : String -> (Result Error Msg -> msg) -> Cmd msg
cmd url msg =
    call url
        |> attempt msg
