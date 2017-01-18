module WxApp.Model.SystemInfo exposing (Type, null, decoder)

import Json.Decode exposing (int, string, float, nullable, Decoder, succeed, andThen)
import Json.Decode.Pipeline exposing (decode, required, optional, hardcoded)

type alias Type =
    { model : String
    , pixelRatio : Float
    , windowWidth : Int
    , windowHeight : Int
    , language : String
    , version : String
    , system : String
    , platform : String
    }


null : Type
null =
    { model = ""
    , pixelRatio = 1
    , windowWidth = 720
    , windowHeight = 1280
    , language = ""
    , version = ""
    , system = ""
    , platform = ""
    }


decoder : Decoder Type
decoder =
    decode Type
        |> required "model" string
        |> required "pixelRatio" float
        |> required "windowWidth" int
        |> required "windowHeight" int
        |> optional "language" string ""
        |> optional "version" string ""
        |> optional "system" string ""
        |> optional "platform" string ""

