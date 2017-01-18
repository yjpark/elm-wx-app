module WxApp.Mod exposing
    ( Data, none, Res, Model, null, Msg(..), update )


import WxApp.Types exposing (..)
import WxApp.Internal.Wx as Wx
import WxApp.Model.Mod as WxModel
import WxApp.Api.CheckSession as CheckSession
import WxApp.Api.Login as Login
import WxApp.Api.GetUserInfo as GetUserInfo
import WxApp.Api.GetSystemInfo as GetSystemInfo
import WxApp.Api.GetStorage as GetStorage
import WxApp.Api.SetStorage as SetStorage
import WxApp.Api.RemoveStorage as RemoveStorage

import Task exposing (..)
import Json.Encode

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


cmd : msg -> Cmd msg
cmd msg =
  perform identity (succeed msg)


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
            ( model
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
            ( model
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
        _ ->
            (model, Cmd.none)
