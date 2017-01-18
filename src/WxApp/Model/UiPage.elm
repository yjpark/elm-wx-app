module WxApp.Model.UiPage exposing (..)

import Json.Decode exposing (int, string, float, nullable, Decoder, succeed, andThen)
import Json.Decode.Pipeline exposing (decode, required, optional, hardcoded)

type alias Key = String

type alias Type =
    { key : Key
    , url : String
    }


null : Type
null =
    { key = ""
    , url = ""
    }


new key url =
    { key = key
    , url = url
    }


decoder : Decoder Type
decoder =
    decode Type
        |> required "key" string
        |> optional "url" string ""

