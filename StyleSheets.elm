module Stylesheets (..) where

import Css.File exposing (..)
import Css.StyleSheet


port files : CssFileStructure
port files =
  toFileStructure
    [ ( "built/style.css", compile Css.StyleSheet.css ) ]
