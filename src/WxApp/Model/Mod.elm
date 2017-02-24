module WxApp.Model.Mod exposing (..)

import WxApp.Model.SystemInfo as SystemInfo
import WxApp.Model.UserInfo as UserInfo
import WxApp.Model.UserSecret as UserSecret
import WxApp.Model.UiTab as UiTab
import WxApp.Model.UiPage as UiPage

import WxApp.Types exposing (..)
import WxApp.Util exposing (..)

import Json.Decode exposing (int, string, float, nullable, Decoder, succeed, andThen)
import Json.Decode.Pipeline exposing (decode, required, optional, hardcoded)


type alias Type =
    { systemInfo : SystemInfo.Type
    , userCode : String
    , userInfo : UserInfo.Type
    , userSecret : UserSecret.Type
    , tabs : List UiTab.Type
    , currentTabKey : UiTab.Key
    , pages : List UiPage.Type
    }

null : Type
null =
    { systemInfo = SystemInfo.null
    , userCode = ""
    , userInfo = UserInfo.null
    , userSecret = UserSecret.null
    , tabs = []
    , currentTabKey = ""
    , pages = []
    }


resetSession : Type -> Type
resetSession model =
    { model
    | userCode = ""
    , userInfo = UserInfo.null
    , userSecret = UserSecret.null
    }


mergeSaved : Type -> Type -> Type
mergeSaved saved model =
    { model
    | userCode = saved.userCode
    , userInfo = saved.userInfo
    , userSecret = saved.userSecret
    }


decoder : Decoder Type
decoder =
    decode Type
        |> hardcoded SystemInfo.null
        |> required "userCode" string
        |> required "userInfo" UserInfo.decoder
        |> required "userSecret" UserSecret.decoder
        |> hardcoded []
        |> hardcoded ""
        |> hardcoded []


encode : Type -> Data
encode model =
    empty
        |> insertString "userCode" model.userCode
        |> insertData "userInfo" (UserInfo.encode model.userInfo)
        |> insertData "userSecret" (UserSecret.encode model.userSecret)
        |> dictToData


getTab : UiTab.Key -> Type -> Maybe UiTab.Type
getTab key model =
    model.tabs
        |> List.filter (\tab -> tab.key == key)
        |> List.head


getPage : UiPage.Key -> Type -> Maybe UiPage.Type
getPage key model =
    model.pages
        |> List.filter (\tab -> tab.key == key)
        |> List.head


getPageIndex : UiPage.Key -> Type -> Maybe Int
getPageIndex key model =
    let
        filter = (\index page ->
            if page.key == key then
                index
            else
                -1
        )
    in
        model.pages
            |> List.indexedMap filter
            |> List.filter (\index -> index >= 0)
            |> List.head
