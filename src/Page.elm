module Page exposing (..)
import Task

type PageState page = Loaded page
                     | TransitioningFrom page


getPage : PageState page -> page
getPage pageState =
    case pageState of
        Loaded page ->
            page

        TransitioningFrom page ->
            page

isLoading : PageState page -> Bool
isLoading pageState = case pageState of
    TransitioningFrom _ -> True
    _ -> False

transition : {p | pageState: PageState m} -> (Result e s -> msg) -> Task.Task e s -> ({p|  pageState : PageState m }, Cmd msg)
transition model toMsg task =
    ({ model | pageState = TransitioningFrom (getPage model.pageState) }, Task.attempt toMsg task)


toPage: {p | pageState: PageState model} -> (subModel -> model) -> (subMsg -> msg) -> (subMsg -> subModel -> (subModel, Cmd subMsg)) -> subMsg -> subModel -> ({p | pageState: PageState model}, Cmd msg)
toPage model toModel toMsg subUpdate subMsg subModel =
     let
         ( newModel, newCmd ) =
             subUpdate subMsg subModel
     in
     ( { model | pageState = Loaded (toModel newModel) }, Cmd.map toMsg newCmd )