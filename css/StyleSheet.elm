module Css.StyleSheet (..) where

import Css exposing (..)
import Css.Elements exposing (..)


css =
  stylesheet
    [ (.)
        "content"
        [ margin2 zero auto
        , padding (em 2)
        , fontFamilies [ "Helvetica", "Arial", "serif" ]
        ]
    , select
        [ marginBottom (em 1.5)
        ]
    , (.)
        "is-private"
        [ color privateColor
        , borderColor privateColor
        , borderStyle solid
        , paddingTop (em 0.25)
        , paddingBottom (em 0.25)
        , paddingLeft (em 0.5)
        , paddingRight (em 0.5)
        , marginLeft (em 0.5)
        ]
    , (.)
        "repo-item"
        [ paddingTop (em 0.5)
        , paddingBottom (em 0.5)
        , children
            [ a
                [ color darkGray, textDecoration none ]
            ]
        ]
    , (.)
        "repo-description"
        [ color gray ]
    , (.)
        "repo-name-title"
        [ color black ]
    ]


privateColor =
  orange


pColor =
  gray


filterColor =
  gray


black =
  hex "000000"


gray =
  hex "A9A9A9"


darkGray =
  hex "757575"


orange =
  hex "FF6600"
