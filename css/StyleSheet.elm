module Css.StyleSheet (..) where

import Css exposing (..)
import Css.Elements exposing (..)


css =
  stylesheet
    [ (.)
        "content"
        [ padding (em 2)
        , fontFamilies [ "Helvetica", "Arial", "serif" ]
        ]
    , (.)
        "user-name-search"
        [ margin2 (em 1) (em 0)
        , children [ input [ marginRight (em 1) ] ]
        ]
    , (.)
        "namespace-filter"
        [ marginBottom (em 1.5) ]
    , (.)
        "is-private"
        [ color privateColor
        , borderColor privateColor
        , borderStyle solid
        , padding2 (em 0.1) (em 0.5)
        , marginLeft (em 0.5)
        ]
    , (.)
        "repo-items-container"
        [ margin (em 0)
        ]
    , (.)
        "repo-item"
        [ children
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
    , (.)
        "error"
        [ color red ]
    , (.) "active-page" [color blue, fontWeight bold]
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


red =
  hex "B0171F"

blue = hex "1874CD"
