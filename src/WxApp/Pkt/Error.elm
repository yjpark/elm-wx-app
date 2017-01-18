module WxApp.Pkt.Error exposing (Type, null, decoder)

import Json.Decode exposing (int, string, float, nullable, Decoder, succeed, andThen)
import Json.Decode.Pipeline exposing (decode, required, optional, hardcoded)

type alias Type =
    { errcode : Int
    , errmsg : String
    }


null : Type
null =
    { errcode = -1
    , errmsg = ""
    }


decoder : Decoder Type
decoder =
    decode Type
        |> optional "errcode" int -1
        |> optional "errmsg" string ""

