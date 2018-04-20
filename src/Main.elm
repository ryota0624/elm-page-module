module Main exposing (..)

import Html exposing (Html, text, div, h1, img)
import Html.Attributes exposing (src)
import Html.Events as Events
import Page
import Task
import Process
---- MODEL ----


type Page = Page String
type alias PageState = Page.PageState Page

type alias Model =
    {pageState: PageState }


init : ( Model, Cmd Msg )
init =
    ( Model <| Page.Loaded <| Page "Hello", Cmd.none )


type Error = Error String

---- UPDATE ----


type Msg
    = StartLoading
    | EndLoading String
    | ReceiveError Error

loadString: Task.Task Error String
loadString = Process.sleep 3000 |> Task.andThen (\_ -> Task.succeed "load")


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        StartLoading -> ( {model | pageState = Page.TransitioningFrom (Page.getPage model.pageState)}, loadString |> handleTask EndLoading)
        EndLoading str -> ({model | pageState = Page.Loaded (Page str)} , Cmd.none)
        ReceiveError error -> Debug.crash (error |> toString)



---- VIEW ----


view : Model -> Html Msg
view model =
    let
        h2Text = case model.pageState of
            Page.Loaded (Page page) -> page
            Page.TransitioningFrom (Page page) -> page ++ "...Loading"
    in
    div []
        [ img [ src "/logo.svg" ] []
        , h1 [] [ text "Your Elm App is working!" ]
        , Html.h2 [Events.onClick StartLoading] [ text h2Text ]

        ]



---- PROGRAM ----


main : Program Never Model Msg
main =
    Html.program
        { view = view
        , init = init
        , update = update
        , subscriptions = always Sub.none
        }
