module Stylesheets (..) where

import Css.File exposing (..)
import Css.ElmHub


port files : CssFileStructure
port files =
  toFileStructure
    [ ( "style.css", compile Css.ElmHub.css ) ]
