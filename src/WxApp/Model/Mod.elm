module WxApp.Model.Mod exposing (..)

import WxApp.Model.SystemInfo as SystemInfo
import WxApp.Model.UserInfo as UserInfo
import WxApp.Model.UserSecret as UserSecret

import WxApp.Types exposing (..)
import WxApp.Util exposing (..)

import Json.Decode exposing (int, string, float, nullable, Decoder, succeed, andThen)
import Json.Decode.Pipeline exposing (decode, required, optional, hardcoded)


type alias Type =
    { systemInfo : SystemInfo.Type
    , userCode : String
    , userInfo : UserInfo.Type
    , userSecret : UserSecret.Type
    }

null : Type
null =
    { systemInfo = SystemInfo.null
    , userCode = ""
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


encode : Type -> Data
encode model =
    empty
        |> insertString "userCode" model.userCode
        |> insertData "userInfo" (UserInfo.encode model.userInfo)
        |> insertData "userSecret" (UserSecret.encode model.userSecret)
        |> dictToData



