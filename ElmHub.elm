module ElmHub (..) where

import StartApp.Simple as StartApp
import Http
import Html exposing (..)
import Html.Events exposing (..)
import Html.Attributes exposing (class, href, selected, value, name, property, style, for)
import VirtualDom
import Signal exposing (Address)
import Task exposing (Task)
import Effects exposing (Effects)
import Json.Decode exposing (Decoder, (:=), int, string, bool)
import Json.Decode.Pipeline exposing (..)
import Json.Encode
import Maybe exposing (..)
import String
import Set
import Shims exposing (performAction, onInput, onChange)


-- MODEL


type alias Model =
  { userName : String
  , filterStr : String
  , pageNum : Int
  , results : List RepoResult
  , error : Maybe String
  , reposPerPage : Int
  }


type alias RepoResult =
  { user : String
  , name : String
  , namespace : String
  , status : Int
  , description : String
  , is_private : Bool
  , is_automated : Bool
  , can_edit : Bool
  , star_count : Int
  , pull_count : Int
  , last_updated : String
  }


initialModel : Model
initialModel =
  { userName = "library"
  , filterStr = ""
  , pageNum = 1
  , results = []
  , error = Nothing
  , reposPerPage = 10
  }



-- FETCH/PARSE DATA


repoFeed userName =
  let
    url =
      "http://127.0.0.1:3000/api/repos/" ++ userName

    task =
      performAction
        HandleRepoResult
        HandleRepoError
        (Http.get resultsDecoder url)
  in
    Effects.task task


decodeResults : String -> List RepoResult
decodeResults json =
  case Json.Decode.decodeString resultsDecoder json of
    Ok results ->
      results

    Err err ->
      []


resultsDecoder : Decoder (List RepoResult)
resultsDecoder =
  "results" := Json.Decode.list repoResultDecoder


repoResultDecoder : Decoder RepoResult
repoResultDecoder =
  decode RepoResult
    |> required "user" string
    |> required "name" string
    |> required "namespace" string
    |> optional "status" int 1
    |> optional "description" string ""
    |> required "is_private" bool
    |> optional "is_automated" bool True
    |> required "can_edit" bool
    |> optional "star_count" int 0
    |> optional "pull_count" int 0
    |> required "last_updated" string



-- UPDATE/ACTIONS


type Action
  = FilterByName String
  | PreviousPage
  | NextPage
  | HandleRepoResult (List RepoResult)
  | HandleRepoError Http.Error
  | Search
  | SetUserName String
  | JumpToPage Int


update : Action -> Model -> ( Model, Effects Action )
update action model =
  case action of
    JumpToPage page ->
      ( { model | pageNum = page }, Effects.none )

    SetUserName name ->
      ( { model | userName = name }, Effects.none )

    HandleRepoError error ->
      case error of
        Http.UnexpectedPayload error ->
          ( { model
              | error = Just error
            }
          , Effects.none
          )

        _ ->
          ( { model
              | error = Just "There was an error communicating with Elm Hub. Take a look at your username..."
            }
          , Effects.none
          )

    HandleRepoResult results ->
      ( { model
          | results = results
          , error = Nothing
        }
      , Effects.none
      )

    Search ->
      ( { model | results = [] }, repoFeed model.userName )

    FilterByName str ->
      ( { model
          | filterStr = str
          , pageNum = 1
        }
      , Effects.none
      )

    PreviousPage ->
      ( { model
          | pageNum =
              if model.pageNum <= 1 then
                1
              else
                model.pageNum - 1
        }
      , Effects.none
      )

    NextPage ->
      ( { model
          | pageNum =
              if onMaxPage model then
                model.pageNum
              else
                model.pageNum + 1
        }
      , Effects.none
      )


onMaxPage : Model -> Bool
onMaxPage model =
  (maxPageNum model) <= model.pageNum


maxPageNum : Model -> Int
maxPageNum model =
  let
    length =
      toFloat (filteredLength model)

    reposPerPage =
      (toFloat model.reposPerPage)
  in
    ceiling (length / reposPerPage)


filteredLength : Model -> Int
filteredLength model =
  if String.isEmpty model.filterStr then
    List.length model.results
  else
    model.results
      |> List.filter
          (\r ->
            (model.filterStr == r.namespace)
              || (String.isEmpty model.filterStr == True)
          )
      |> List.length



-- VIEWS


view : Address Action -> Model -> Html
view address model =
  div
    [ class "content" ]
    [ (viewHeader address model)
    , (viewResults address model)
    , (viewPaginator address model)
    ]


viewHeader : Address Action -> Model -> Html
viewHeader address model =
  header
    []
    [ (viewSearchUser address model)
    , (viewFilter address model)
    , (viewError model.error)
    ]


viewSearchUser : Address Action -> Model -> Html
viewSearchUser address model =
  div
    [ class "user-name-search" ]
    [ label [ for "user-name"] [ text "User "]
    , input
        [ name "user-name"
        , onInput address SetUserName
        , defaultValue model.userName
        ]
        []
    , button [ onClick address Search ] [ text "Search" ]
    ]


viewFilter : Address Action -> Model -> Html
viewFilter address model =
  div
    []
    [ label [ for "namespace-filter" ] [ text "Filter by " ]
    , select
        [ class "namespace-filter", name "namespace-filter", onChange address FilterByName ]
        (option [ value "", selected True ] [ text "All Accounts" ]
          :: (model.results
                |> List.map .namespace
                |> Set.fromList
                |> Set.toList
                |> List.map viewFilterOption
             )
        )
    , hr [] []
    ]


viewFilterOption : String -> Html
viewFilterOption namespace =
  option [] [ text namespace ]


viewResults : Address Action -> Model -> Html
viewResults address { filterStr, pageNum, results, reposPerPage } =
  ul
    [ class "repo-items-container", style [ ( "list-style", "none" ), ( "-webkit-padding-start", "0" ) ] ]
    (results
      |> List.filter
          (\r ->
            (String.startsWith filterStr r.namespace)
              || (String.isEmpty filterStr == True)
          )
      |> List.drop ((pageNum - 1) * reposPerPage)
      |> List.take reposPerPage
      |> List.map viewResult
    )


viewResult : RepoResult -> Html
viewResult results =
  let
    namespaceTitle =
      span [ class "repo-namespace-title" ] [ text results.namespace ]

    seperator =
      span [] [ text " / " ]

    nameTitle =
      span [ class "repo-name-title" ] [ text results.name ]

    privateMarker =
      (if results.is_private then
        small [] [ span [ class "is-private" ] [ text "private" ] ]
       else
        text ""
      )

    description =
      (if String.isEmpty results.description then
        text ""
       else
        small [] [ p [ class "repo-description" ] [ text results.description ] ]
      )
  in
    li
      [ class "repo-item" ]
      [ a
          [ href "#" ]
          [ namespaceTitle
          , seperator
          , nameTitle
          , privateMarker
          , description
          ]
      , hr [] []
      ]


viewPaginator : Address Action -> Model -> Html
viewPaginator address model =
  let
    { pageNum, reposPerPage } =
      model

    remainder =
      pageNum `rem` reposPerPage

    lowerBound =
      if remainder == 0 then
        pageNum - reposPerPage + 1
      else
        pageNum - remainder + 1

    maxUpperBound =
      pageNum + reposPerPage - remainder

    upperBound =
      if remainder == 0 then
        pageNum
      else if (maxPageNum model) < maxUpperBound then
        maxPageNum model
      else
        maxUpperBound
  in
    div
      []
      (List.append
        (button [ onClick address PreviousPage ] [ text "<" ]
          :: (viewPageLink address model lowerBound upperBound)
        )
        [ button [ onClick address NextPage ] [ text ">" ] ]
      )


viewPageLink : Address Action -> Model -> Int -> Int -> List Html
viewPageLink address model lower upper =
  List.map
    (\page ->
      button
        [ onClick address (JumpToPage page)
        , class
            (if page == model.pageNum then
              "active-page"
             else
              "just-another-page"
            )
        ]
        [ text (toString page) ]
    )
    [lower..upper]


viewError : Maybe String -> Html
viewError error =
  case error of
    Just message ->
      span [ class "error" ] [ text message ]

    Nothing ->
      text ""


defaultValue : String -> VirtualDom.Property
defaultValue str =
  property "defaultValue" (Json.Encode.string str)
