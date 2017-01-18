module WxApp.Api.GetUserInfo exposing (Msg, call, cmd, decode, decoder)

import WxApp.Types exposing (..)
import WxApp.Util exposing (..)
import WxApp.Internal.Wx as Wx
import WxApp.Model.UserInfo as UserInfo
import WxApp.Model.UserSecret as UserSecret

import Task exposing (..)
import Json.Decode exposing (decodeValue, Decoder, string, field)


type alias Msg = (UserInfo.Type, UserSecret.Type)


decode : Res -> Decoder Msg
decode res =
    let
        userInfoResult = decodeValue (field "userInfo" UserInfo.decoder) res
        userSecretResult = decodeValue UserSecret.decoder res
    in
        case userInfoResult of
            Ok userInfo ->
                case userSecretResult of
                    Ok userSecret ->
                        Json.Decode.succeed (userInfo, userSecret)
                    Err err ->
                        Json.Decode.fail ("UserSecret:" ++ err)
            Err err ->
                Json.Decode.fail ("UserInfo:" ++ err)


decoder : Decoder Msg
decoder =
    Json.Decode.value
        |> Json.Decode.andThen decode


onSucceed : Res -> Task Error Msg
onSucceed res =
    case decodeValue decoder res of
        Ok (userInfo, userSecret) ->
            succeed (userInfo, userSecret)
        Err err ->
            fail (DecodeError res err)


call : Task Error Msg
call =
    Wx.call "getUserInfo" none onSucceed

cmd : (Result Error Msg -> msg) -> Cmd msg
cmd msg =
    call
        |> attempt msg
