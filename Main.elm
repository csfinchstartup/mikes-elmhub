module Main (..) where

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Signal exposing (Address)
import StartApp.Simple as StartApp
import Json.Decode as Json
import Task exposing (Task)
import Effects exposing (Effects)
import String
import Set


type alias Model =
  { filterStr : String
  , pageNum : Int
  , responses : List ServerResponse
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



-- initialModel : Model


initialModel =
  { filterStr = ""
  , pageNum = 1
  , responses =
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
        , name = "another-project"
        , namespace = "kevinspacey"
        , description = "if you didn't believe... you will!"
        , is_private = False
        }
      , { id = 4
        , user = "outcoldman"
        , name = "splunk"
        , namespace = "outcoldman"
        , description = "if you didn't believe... you will!"
        , is_private = False
        }
      , { id = 5
        , user = "mikesi2"
        , name = "primeroProyecto"
        , namespace = "nombreEspacio"
        , description = "some really cool stuff is gonna happen"
        , is_private = True
        }
      , { id = 6
        , user = "mikesi2"
        , name = "segundoProyecto"
        , namespace = "nombreEspacio"
        , description = "if you didn't believe... you will!"
        , is_private = False
        }
      , { id = 7
        , user = "mikesi2"
        , name = "another-project"
        , namespace = "kevinspacey"
        , description = "if you didn't believe... you will!"
        , is_private = False
        }
      , { id = 8
        , user = "outcoldman"
        , name = "splunk"
        , namespace = "outcoldman"
        , description = "if you didn't believe... you will!"
        , is_private = False
        }
      , { id = 9
        , user = "mikesi2"
        , name = "primeroProyecto"
        , namespace = "nombreEspacio"
        , description = "some really cool stuff is gonna happen"
        , is_private = True
        }
      , { id = 10
        , user = "mikesi2"
        , name = "segundoProyecto"
        , namespace = "nombreEspacio"
        , description = "if you didn't believe... you will!"
        , is_private = False
        }
      , { id = 11
        , user = "mikesi2"
        , name = "another-project"
        , namespace = "kevinspacey"
        , description = "if you didn't believe... you will!"
        , is_private = False
        }
      , { id = 12
        , user = "outcoldman"
        , name = "splunk"
        , namespace = "outcoldman"
        , description = "if you didn't believe... you will!"
        , is_private = False
        }
      ]
  }


type Action
  = FilterByName String
  | PreviousPage
  | NextPage


update : Action -> Model -> Model
update action model =
  case action of
    FilterByName str ->
      { model | filterStr = str }

    PreviousPage ->
      { model
        | pageNum =
            if model.pageNum == 1 then
              1
            else
              model.pageNum - 1
      }

    NextPage ->
      { model
        | pageNum =
            if List.length model.responses < (model.pageNum * 10) then
              model.pageNum
            else
              model.pageNum + 1
      }


view : Address Action -> Model -> Html
view address model =
  div
    [ class "content" ]
    [ (viewHeader)
    , (viewFilter address model)
    , (viewResponses address model)
    , (viewPaginator address model)
    ]


onInput address wrap =
  on "input" targetValue (\val -> Signal.message address (wrap val))


onChange address wrap =
  on "change" targetValue (\val -> Signal.message address (wrap val))


viewHeader : Html
viewHeader =
  header
    []
    [ h1 [] [ text "like Docker Hub, but in Elm" ] ]


viewFilter : Address Action -> Model -> Html
viewFilter address model =
  select
    [ name "filter", onChange address FilterByName ]
    (option [ value "", selected True ] [ text "All Accounts" ]
      :: (model.responses
            |> List.map .namespace
            |> Set.fromList
            |> Set.toList
            |> List.map viewFilterOption
         )
    )


viewFilterOption : String -> Html
viewFilterOption namespace =
  option [] [ text namespace ]


viewResponses : Address Action -> Model -> Html
viewResponses address { filterStr, pageNum, responses } =
  ul
    []
    (responses
      |> List.filter
          (\r ->
            (String.startsWith filterStr r.namespace)
              || (String.isEmpty filterStr == True)
          )
      |> List.drop ((pageNum - 1) * 10)
      |> List.take 10
      |> List.map viewResponse
    )


viewResponse : ServerResponse -> Html
viewResponse response =
  li
    []
    [ span [] [ text (response.namespace ++ " / " ++ response.name) ]
    , (if response.is_private then
        span [] [ text "  private" ]
       else
        span [] []
      )
    ]


viewPaginator : Address Action -> Model -> Html
viewPaginator address model =
  div
    []
    [ button [ onClick address PreviousPage ] [ text "<" ]
    , span [ class "current-page" ] [ text (toString model.pageNum) ]
    , button [ onClick address NextPage ] [ text ">" ]
    ]


main =
  StartApp.start
    { view = view
    , update = update
    , model = initialModel
    }
