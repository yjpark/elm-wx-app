module WxApp.Api.ShowModal exposing (Modal, Msg, call, cmd
    , okModal)

import WxApp.Types exposing (..)
import WxApp.Util exposing (..)
import WxApp.Internal.Wx as Wx

import Task exposing (..)


type alias Modal =
    { title : String
    , content : String
    , confirm: String
    , cancel: Maybe String
    }


okModal title content =
    { title = title
    , content = content
    , confirm = "OK"
    , cancel = Nothing
    }


type alias Msg = Res

onSucceed : Res -> Task Error Msg
onSucceed res =
    succeed res


encodeData : Modal -> Data
encodeData modal =
    empty
        |> insertString "title" modal.title
        |> insertString "content" modal.content
        |> insertString "confirmText" modal.confirm
        |> (case modal.cancel of
            Nothing ->
                insertBool "showCancel" False
            Just cancel ->
                insertBool "showCancel" True)
        |> (case modal.cancel of
            Nothing ->
                identity
            Just cancel ->
                insertString "cancelText" cancel)
        |> dictToData


call : Modal -> Task Error Msg
call modal =
    Wx.call "showModal" (encodeData modal) onSucceed


cmd : Modal -> (Result Error Msg -> msg) -> Cmd msg
cmd modal msg =
    call modal
        |> attempt msg
