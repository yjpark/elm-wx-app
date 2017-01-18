module WxApp.Api.Request exposing (Method(..), Request, Msg, call, cmd)

import WxApp.Types exposing (..)
import WxApp.Util exposing (..)
import WxApp.Internal.Wx as Wx

import Task exposing (..)
import Json.Decode exposing (Decoder, decodeValue, string, int, value, field)


type Method
    = Get
    | Post

{-- Other valid methods, that not currently supported
    | HEAD
    | PUT
    | DELETE
    | OPTIONS
    | TRACE
    | CONNECT 
--}

type alias Request =
    { url : String
    , method : Maybe Method
    , data : Maybe Data
    }

encodeData : Request -> Data
encodeData req =
    empty
        |> insertString "url" req.url
        |> (case req.method of
            Nothing ->
                identity
            Just Get ->
                identity
            Just Post ->
                insertString "method" "POST")
        |> (case req.data of
            Nothing ->
                identity
            Just d ->
                insertData "data" d)
        |> dictToData

type alias Msg
    = Res


decodeStatusCode res =
    case decodeValue (field "statusCode" int) res of
        Ok val ->
            Ok val
        Err err ->
            decodeValue (field "statusCode" string) res
                |> Result.andThen String.toInt


onSucceed : (Decoder msg) -> Res -> Task Error msg
onSucceed decoder res =
    let
        statusCodeResult = decodeStatusCode res
        dataResult = decodeValue (field "data" value) res
    in
        case statusCodeResult of
            Ok 200 ->
                case dataResult of
                    Ok data ->
                        case decodeValue decoder data of
                            Ok msg ->
                                succeed msg
                            Err err ->
                                fail <| DecodeError res err
                    Err err ->
                        fail <| ApiError res ("BadData:" ++ err)
            Ok statusCode ->
                fail <| ApiError res ("InvalidStatusCode:" ++ (toString statusCode))
            Err err ->
                fail <| ApiError res ("BadStatusCode:" ++ err)


call : Request -> (Decoder msg) -> Task Error msg
call req decoder =
    Wx.call "request" (encodeData req) (onSucceed decoder)

cmd : Request -> (Decoder msg) -> (Result Error msg -> msg2) -> Cmd msg2
cmd req decoder msg =
    call req decoder
        |> attempt msg

