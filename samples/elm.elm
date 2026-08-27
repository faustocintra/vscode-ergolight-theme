module Main exposing (Model, Msg(..), init, update, view)

import Html exposing (Html, button, div, text)
import Html.Events exposing (onClick)


type alias Model =
    { count : Int
    , status : String
    }


type Msg
    = Increment
    | Reset String


init : Model
init =
    { count = 0, status = "draft" }


update : Msg -> Model -> Model
update msg model =
    case msg of
        Increment ->
            { model | count = model.count + 1 }

        Reset value ->
            { model | count = 0, status = value }


view : Model -> Html Msg
view model =
    div [] [ button [ onClick Increment ] [ text ("Count " ++ String.fromInt model.count) ] ]

