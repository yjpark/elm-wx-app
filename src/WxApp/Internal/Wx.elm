module WxApp.Internal.Wx exposing (call)
import Native.WxApp
import WxApp.Types exposing (..)

import Json.Encode

import Task exposing (..)
import Dict


logFailed : String -> Data -> Error -> Error
logFailed api data error =
    let
        (err, res) = case error of
            BadEnvironment ->
                ("BadEnvironment", none)
            ApiNotFound ->
                ("ApiNotFound", none)
            ApiException res ->
                ("ApiException", res)
            ApiFailed res ->
                ("ApiFailed", res)
            ApiError res str ->
                ("ApiError:" ++ str, res)
            DecodeError res str ->
                ("DecodeError:" ++ str, res)
        _ = Native.WxApp.logFailed api data err res
    in
        error


logSucceed : String -> Data -> msg -> Task Error msg
logSucceed api data msg =
    let
        _ = Native.WxApp.logSucceed api data msg
    in
        succeed msg

call : String -> Data -> (Res -> Task Error msg) -> Task Error msg
call api data onSucceed =
    Native.WxApp.call api data
        |> andThen onSucceed
        |> andThen (logSucceed api data)
        |> mapError (logFailed api data)

