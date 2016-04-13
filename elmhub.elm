module ElmHub (..) where

import Http
import Html exposing (..)
import Html.Attributes exposing (class, href, selected, value, name, property, style)
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
  }



-- Model "" 1 (decodeResults sampleJson)


type Action
  = FilterByName String
  | PreviousPage
  | NextPage
  | HandleRepoResponse (List RepoResult)
  | HandleRepoError Http.Error
  | Search


update : Action -> Model -> ( Model, Effects Action )
update action model =
  case action of
    HandleRepoError error ->
      case error of
        Http.UnexpectedPayload error ->
          ( { model | error = Just error }, Effects.none )

        _ ->
          ( { model | error = Just "There was an error communicating with Docker Hub" }, Effects.none )

    HandleRepoResponse responses ->
      ( { model | responses = responses }, Effects.none )

    Search ->
      ( model, repoFeed model.userName )

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
      let
        count =
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
      in
        ( { model
            | pageNum =
                if count <= (model.pageNum * 10) then
                  model.pageNum
                else
                  model.pageNum + 1
          }
        , Effects.none
        )


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
  div
    []
    [ select
        [ name "filter", onChange address FilterByName ]
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
viewResponses address { filterStr, pageNum, responses } =
  ul
    [ style [ ( "list-style", "none" ), ( "-webkit-padding-start", "0" ) ] ]
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


viewResponse : RepoResult -> Html
viewResponse response =
  let
    namespaceTitle = span [ class "repo-namespace-title" ] [ text response.namespace ]
    seperator = span [] [ text " / " ]
    nameTitle = span [ class "repo-name-title" ] [ text response.name ]
    privateMarker = (if response.is_private then
        span [ class "is-private" ] [ text "private" ]
       else
        span [] []
      )
    description = (if String.isEmpty response.description then
        p [] []
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
  div
    []
    [ button [ onClick address PreviousPage ] [ text "<" ]
    , span [ class "current-page" ] [ text (toString model.pageNum) ]
    , button [ onClick address NextPage ] [ text ">" ]
    ]
