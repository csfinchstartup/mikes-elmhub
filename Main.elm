module Main (..) where

import Html exposing (..)
import Html.Attributes exposing (..)


type alias Model =
  { responses : List ServerResponse
  }


type alias ServerResponse =
  { id : Int
  , user : String
  , name : String
  , namespace :
      String
      -- , status : Int
  , description : String
  , is_private :
      Bool
      -- , is_automated : Bool
      -- , can_edit : Bool
      -- , star_count : Int
      -- , pull_count : Int
      -- , last_updated : String
  }


model : Model
model =
  { responses =
      [ { id = 1
        , user = "mikesi2"
        , name = "primeroProyecto"
        , namespace = "nombreEspacio"
        , description = "some really cool stuff is gonna happen"
        , is_private = True
        }
      , { id = 2
        , user = "mikesi2"
        , name = "segundoProyecto"
        , namespace = "nombreEspacio"
        , description = "if you didn't believe... you will!"
        , is_private = False
        }
      , { id = 3
        , user = "mikesi2"
        , name = "another project"
        , namespace = "kevinspacey"
        , description = "if you didn't believe... you will!"
        , is_private = False
        }
      ]
  }


view : Model -> Html
view model =
  div
    [ class "content" ]
    [ header
        []
        [ h1 [] [ text "like Docker Hub, but in Elm" ]
        , (viewFilter model.responses)
        ]
    , ul
        []
        (List.map viewResponse model.responses)
    ]


viewFilter responses =
  select
    []
    (List.map viewOption responses)


viewOption response =
  option [] [ text response.namespace ]


viewResponse : ServerResponse -> Html
viewResponse response =
  li
    []
    [ a
        [ href "something" ]
        [ span [] [ text (response.namespace ++ " / " ++ response.name) ]
        , (if response.is_private then
            span [] [ text "  private" ]
           else
            span [] []
          )
        ]
    ]


main =
  view model
