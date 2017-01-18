module WxApp.Api.SetStorage exposing (Msg, call, cmd)

import WxApp.Types exposing (..)
import WxApp.Util exposing (..)
import WxApp.Internal.Wx as Wx

import Task exposing (..)


type alias Msg = Res


onSucceed : Res -> Task Error Msg
onSucceed res =
    succeed res


encodeData : Int -> Data
encodeData delta =
    empty
        |> insertInt "delta" delta
        |> dictToData


call : Int -> Task Error Msg
call delta =
    Wx.call "navigateBack" (encodeData delta) onSucceed


cmd : Int -> (Result Error Msg -> msg) -> Cmd msg
cmd delta msg =
    call delta
        |> attempt msg
