module WxApp.Model.UserGender exposing (Type, parse, decode, decoder, unknown, male, female, encode)

import Json.Decode exposing (int, string, float, nullable, Decoder, succeed, andThen)
import Json.Decode.Pipeline exposing (decode, required, optional, hardcoded)

type alias Type =
    Int

unknown : Type
unknown = 0

male : Type
male = 1

female : Type
female = 2


encode : Type -> Int
encode =
    identity


parse : Int -> Type
parse gender =
    case gender of
        1 -> male
        2 -> female
        _ -> unknown


decode : Int -> Decoder Type
decode gender = succeed (parse gender)


decoder : Decoder Type
decoder =
   int
        |> andThen decode

