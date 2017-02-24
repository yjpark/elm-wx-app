module WxApp.Mod exposing
    ( Data, none, Res, Model, null, Msg(..), update )


import WxApp.Types exposing (..)
import WxApp.Internal.Wx as Wx

import WxApp.Model.Mod as WxModel
import WxApp.Model.UiTab as UiTab
import WxApp.Model.UiPage as UiPage

import WxApp.Api.CheckSession as CheckSession
import WxApp.Api.Login as Login
import WxApp.Api.GetUserInfo as GetUserInfo
import WxApp.Api.GetSystemInfo as GetSystemInfo
import WxApp.Api.GetStorage as GetStorage
import WxApp.Api.SetStorage as SetStorage
import WxApp.Api.RemoveStorage as RemoveStorage
import WxApp.Api.SwitchTab as SwitchTab
import WxApp.Api.NavigateTo as NavigateTo
import WxApp.Api.NavigateBack as NavigateBack

import Task exposing (..)
import Json.Encode
import Json.Decode as JsonDecode


type alias Data = WxApp.Types.Data
none = WxApp.Types.none

type alias Res = WxApp.Types.Res

type alias Model = WxModel.Type

null = WxModel.null


type Msg
    = DoInit
    | DoGetSystemInfo
    | DoCheckSession
    | DoLogin
    | DoLoadWxModel
    | DoGetUserInfo
    | GetSystemInfoMsg (Result Error GetSystemInfo.Msg)
    | CheckSessionMsg (Result Error CheckSession.Msg)
    | LoginMsg (Result Error Login.Msg)
    | LoadWxModelMsg (Result Error WxModel.Type)
    | RemoveWxModelMsg (Result Error Res)
    | SaveWxModelMsg (Result Error Res)
    | GetUserInfoMsg (Result Error GetUserInfo.Msg)
    | SetTabs (List UiTab.Type)
    | SwitchTab UiTab.Key
    | SetCurrentTab UiTab.Key
    | SetPageStack Data
    | SwitchTabMsg UiTab.Key (Result Error SwitchTab.Msg)
    | PushPage UiPage.Type
    | PushPageMsg UiPage.Type (Result Error NavigateTo.Msg)
    | PopPage UiPage.Key
    | PopPageMsg UiPage.Key (Result Error NavigateBack.Msg)


cmd : msg -> Cmd msg
cmd msg =
  perform identity (succeed msg)


setCurrentTab key switch model =
    case WxModel.getTab key model of
        Nothing ->
            let _ = Debug.log ("Tab Not Exist: " ++ key) model.tabs in
            (model, Cmd.none)
        Just tab ->
            let
                new_model =
                    { model
                    | currentTabKey = key
                    }
                new_cmd = if switch then
                        SwitchTab.cmd tab.url <| SwitchTabMsg key
                    else
                        Cmd.none
            in
                (new_model, new_cmd)


setPageStack data model =
    let
        dataResult = JsonDecode.decodeValue (JsonDecode.list UiPage.decoder) data
    in
        case dataResult of
            Ok stack ->
                let
                    pages = List.reverse stack
                    new_model =
                        { model
                        | pages = pages
                        }
                in
                    (new_model, Cmd.none)
            Err err ->
                let _ = Debug.log ("setPageStack failed: " ++ (toString err)) data in
                (model, Cmd.none)


update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
        DoInit ->
            ( model
            , cmd DoGetSystemInfo
            )
        DoGetSystemInfo ->
            ( model
            , GetSystemInfo.cmd GetSystemInfoMsg
            )
        DoCheckSession ->
            ( model
            , CheckSession.cmd CheckSessionMsg
            )
        DoLogin ->
            let
                new_model = WxModel.resetSession model
            in
                ( new_model
                , Login.cmd LoginMsg
                )
        DoLoadWxModel ->
            ( model
            , GetStorage.cmd "_WxApp.WxModel" WxModel.decoder LoadWxModelMsg
            )
        DoGetUserInfo ->
            ( model
            , GetUserInfo.cmd GetUserInfoMsg
            )
        GetSystemInfoMsg (Ok systemInfo) ->
            ( { model
                | systemInfo = systemInfo
              }
            , cmd DoCheckSession
            )
        CheckSessionMsg (Ok _) ->
            ( model
            , cmd DoLoadWxModel
            )
        CheckSessionMsg (Err _) ->
            let
                new_model = WxModel.resetSession model
            in
                ( new_model
                , cmd DoLogin
                )
        LoginMsg (Ok code) ->
            ( { model
                | userCode = code
              }
            , cmd DoGetUserInfo
            )
        LoadWxModelMsg (Ok saved_model) ->
            let
                new_model = model
                    |> WxModel.mergeSaved saved_model
            in
                ( new_model
                , Cmd.none
                )
        LoadWxModelMsg (Err (DecodeError _ _)) ->
            ( model
            , RemoveStorage.cmd "_WxApp.WxModel" RemoveWxModelMsg
            )
        LoadWxModelMsg (Err _) ->
            ( model
            , cmd DoLogin
            )
        RemoveWxModelMsg _ ->
            ( model
            , cmd DoLogin
            )
        GetUserInfoMsg (Ok (userInfo, userSecret)) ->
            let
                new_model =
                    { model
                    | userInfo = userInfo
                    , userSecret = userSecret
                    }
            in
                ( new_model
                , SetStorage.cmd "_WxApp.WxModel" (WxModel.encode new_model) SaveWxModelMsg
                )
        SetTabs tabs ->
            let
                new_model =
                    { model
                    | tabs = tabs
                    }
            in
                (new_model, Cmd.none)
        SetPageStack data ->
            setPageStack data model
        SetCurrentTab tabKey ->
            setCurrentTab tabKey False model
        SwitchTab tabKey ->
            setCurrentTab tabKey True model
        PushPage page ->
            case WxModel.getPage page.key model of
                Nothing ->
                    let
                        new_model =
                            { model
                            | pages = page :: model.pages
                            }
                        new_cmd = NavigateTo.cmd page.url <| PushPageMsg page
                    in
                        (new_model, new_cmd)
                Just oldPage ->
                    let _ = Debug.log ("Page already shown " ++ (toString oldPage)) page in
                    (model, cmd <| PushPageMsg page (Err <| ApiError none "Already Shown"))
        PopPage pageKey ->
            case WxModel.getPageIndex pageKey model of
                Nothing ->
                    let _ = Debug.log ("Page not shown " ++ pageKey) model.pages in
                    (model, cmd <| PopPageMsg pageKey (Err <| ApiError none "Not Shown"))
                Just index ->
                    let
                        count = index + 1
                        new_model =
                            { model
                            | pages = List.drop count model.pages
                            }
                        new_cmd = NavigateBack.cmd count <| PopPageMsg pageKey
                    in
                        (new_model, new_cmd)
        _ ->
            (model, Cmd.none)
