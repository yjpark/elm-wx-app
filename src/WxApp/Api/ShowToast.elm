module WxApp.Api.ShowToast exposing (Icon(..), Toast, Msg, call, cmd
    , loadingToast)

import WxApp.Types exposing (..)
import WxApp.Util exposing (..)
import WxApp.Internal.Wx as Wx

import Task exposing (..)


type Icon
    = Success
    | Loading


encodeIcon : Icon -> String
encodeIcon icon =
    case icon of
        Success ->
            "success"
        Loading ->
            "loading"


type alias Toast =
    { title : String
    , icon : Maybe Icon
    , duration : Maybe Int
    , mask : Maybe Bool
    }


loadingToast title mask =
    { title = title
    , icon = Just Loading
    , duration = Just 10000
    , mask = Just mask
    }


type alias Msg = Res

onSucceed : Res -> Task Error Msg
onSucceed res =
    succeed res


encodeData : Toast -> Data
encodeData toast =
    empty
        |> insertString "title" toast.title
        |> (case toast.icon of
            Nothing ->
                identity
            Just icon ->
                insertString "icon" (encodeIcon icon))
        |> (case toast.duration of
            Nothing ->
                identity
            Just duration ->
                insertInt "duration" duration)
        |> (case toast.mask of
            Nothing ->
                identity
            Just mask ->
                insertBool "mask" mask)
        |> dictToData


call : Toast -> Task Error Msg
call toast =
    Wx.call "showToast" (encodeData toast) onSucceed


cmd : Toast -> (Result Error Msg -> msg) -> Cmd msg
cmd toast msg =
    call toast
        |> attempt msg
