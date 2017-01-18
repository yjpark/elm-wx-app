module WxApp.Api.RemoveStorage exposing (Msg, call, cmd)

import WxApp.Types exposing (..)
import WxApp.Util exposing (..)
import WxApp.Internal.Wx as Wx

import Task exposing (..)
import Json.Decode exposing (decodeValue, string, field)

type alias Key = String

type alias Msg = Res


onSucceed : Res -> Task Error Msg
onSucceed res =
    succeed res

encodeData : Key -> Data
encodeData key =
    empty
        |> insertString "key" key
        |> dictToData

call : Key -> Task Error Msg
call key =
    Wx.call "removeStorage" (encodeData key) onSucceed

cmd : Key -> (Result Error Msg -> msg) -> Cmd msg
cmd key msg =
    call key
        |> attempt msg
