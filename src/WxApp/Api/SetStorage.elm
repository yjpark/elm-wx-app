module WxApp.Api.SetStorage exposing (Msg, call, cmd)

import WxApp.Types exposing (..)
import WxApp.Util exposing (..)
import WxApp.Internal.Wx as Wx

import Task exposing (..)


type alias Key = String

type alias Msg = Res


onSucceed : Res -> Task Error Msg
onSucceed res =
    succeed res


encodeData : Key -> Data -> Data
encodeData key data =
    empty
        |> insertString "key" key
        |> insertData "data" data
        |> dictToData


call : Key -> Data -> Task Error Msg
call key data =
    Wx.call "setStorage" (encodeData key data) onSucceed


cmd : Key -> Data -> (Result Error Msg -> msg) -> Cmd msg
cmd key data msg =
    call key data
        |> attempt msg
