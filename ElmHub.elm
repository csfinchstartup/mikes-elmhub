module ElmHub (..) where

import Http
import Html exposing (..)
import Html.Attributes exposing (class, href, selected, value, name, property, style, for)
import Html.Events exposing (..)
import Signal exposing (Address)
import StartApp.Simple as StartApp
import Json.Decode as Json
import Task exposing (Task)
import Effects exposing (Effects)
import String
import Set
import Json.Decode exposing (Decoder, (:=), int, string, bool)
import Json.Decode.Pipeline exposing (..)
import Json.Encode
import Maybe exposing (..)


repoFeed userName =
  let
    url =
      "http://127.0.0.1:3000/api/repos/" ++ userName

    task =
      performAction
        HandleRepoResponse
        HandleRepoError
        (Http.get responseDecoder url)
  in
    Effects.task task


performAction : (a -> b) -> (y -> b) -> Task y a -> Task x b
performAction successToAction errorToAction task =
  let
    successTask =
      Task.map successToAction task
  in
    Task.onError successTask (\err -> Task.succeed (errorToAction err))


type alias Model =
  { userName : String
  , filterStr : String
  , pageNum : Int
  , responses : List RepoResult
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


decodeResults : String -> List RepoResult
decodeResults json =
  case Json.Decode.decodeString responseDecoder json of
    Ok responses ->
      responses

    Err err ->
      []


responseDecoder : Decoder (List RepoResult)
responseDecoder =
  "results" := Json.Decode.list serverResponseDecoder


serverResponseDecoder : Decoder RepoResult
serverResponseDecoder =
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


initialModel : Model
initialModel =
  { userName = "library"
  , filterStr = ""
  , pageNum = 1
  , responses = []
  , error = Nothing
  , reposPerPage = 10
  }



-- Model "" 1 (decodeResults sampleJson)


type Action
  = FilterByName String
  | PreviousPage
  | NextPage
  | HandleRepoResponse (List RepoResult)
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

    HandleRepoResponse responses ->
      ( { model
          | responses = responses
          , error = Nothing
        }
      , Effects.none
      )

    Search ->
      ( { model | responses = [] }, repoFeed model.userName )

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
                -- if (filteredLength model) <= (model.pageNum * model.reposPerPage) then
                model.pageNum
              else
                model.pageNum + 1
        }
      , Effects.none
      )


maxPageNum model =
  let
    length =
      toFloat (filteredLength model)

    reposPerPage =
      (toFloat model.reposPerPage)
  in
    ceiling (length / reposPerPage)


onMaxPage model =
  (maxPageNum model) <= model.pageNum


filteredLength model =
  if String.isEmpty model.filterStr then
    List.length model.responses
  else
    model.responses
      |> List.filter
          (\r ->
            (model.filterStr == r.namespace)
              || (String.isEmpty model.filterStr == True)
          )
      |> List.length


view : Address Action -> Model -> Html
view address model =
  div
    [ class "content" ]
    [ (viewHeader address model)
    , (viewResponses address model)
    , (viewPaginator address model)
    ]


onInput address wrap =
  on "input" targetValue (\val -> Signal.message address (wrap val))


onChange address wrap =
  on "change" targetValue (\val -> Signal.message address (wrap val))


viewHeader : Address Action -> Model -> Html
viewHeader address model =
  header
    []
    [ (viewSearchUser address model)
    , (viewFilter address model)
    , (viewError model.error)
    ]


viewError : Maybe String -> Html
viewError error =
  case error of
    Just message ->
      span [ class "error" ] [ text message ]

    Nothing ->
      text ""


viewSearchUser : Address Action -> Model -> Html
viewSearchUser address model =
  div
    [ class "user-name-search" ]
    [ input
        [ onInput address SetUserName
        , defaultValue model.userName
        ]
        []
    , button [ onClick address Search ] [ text "Search by username" ]
    ]


viewFilter : Address Action -> Model -> Html
viewFilter address model =
  div
    []
    [ label [ for "namespace-filter" ] [ text "Filter by " ]
    , select
        [ class "namespace-filter", name "namespace-filter", onChange address FilterByName ]
        (option [ value "", selected True ] [ text "All Accounts" ]
          :: (model.responses
                |> List.map .namespace
                |> Set.fromList
                |> Set.toList
                |> List.map viewFilterOption
             )
        )
    , hr [] []
    ]


defaultValue str =
  property "defaultValue" (Json.Encode.string str)


viewFilterOption : String -> Html
viewFilterOption namespace =
  option [] [ text namespace ]


viewResponses : Address Action -> Model -> Html
viewResponses address { filterStr, pageNum, responses, reposPerPage } =
  ul
    [ class "repo-items-container", style [ ( "list-style", "none" ), ( "-webkit-padding-start", "0" ) ] ]
    (responses
      |> List.filter
          (\r ->
            (String.startsWith filterStr r.namespace)
              || (String.isEmpty filterStr == True)
          )
      |> List.drop ((pageNum - 1) * reposPerPage)
      |> List.take reposPerPage
      |> List.map viewResponse
    )


viewResponse : RepoResult -> Html
viewResponse response =
  let
    namespaceTitle =
      span [ class "repo-namespace-title" ] [ text response.namespace ]

    seperator =
      span [] [ text " / " ]

    nameTitle =
      span [ class "repo-name-title" ] [ text response.name ]

    privateMarker =
      (if response.is_private then
        small [] [ span [ class "is-private" ] [ text "private" ] ]
       else
        text ""
      )

    description =
      (if String.isEmpty response.description then
        text ""
       else
        small [] [ p [ class "repo-description" ] [ text response.description ] ]
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
