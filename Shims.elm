module Shims (..) where
-- Shims until Elm 0.17 is released

import Task exposing (Task)
import Signal
import Html.Events exposing (..)


performAction : (a -> b) -> (y -> b) -> Task y a -> Task x b
performAction successToAction errorToAction task =
  let
    successTask =
      Task.map successToAction task
  in
    Task.onError successTask (\err -> Task.succeed (errorToAction err))


onInput address wrap =
  on "input" targetValue (\val -> Signal.message address (wrap val))


onChange address wrap =
  on "change" targetValue (\val -> Signal.message address (wrap val))
