module Main (..) where

import Html exposing (..)


type alias Model =
  Int


model =
  3


view model =
  div [] [ text "hi mike" ]


main =
  view model
