module Simple exposing (main)

import Browser
import Date exposing (Date, day, month, weekday, year)
import DatePicker exposing (DateEvent(..), defaultSettings)
import Html exposing (Html, div, h1, text)
import Time exposing (Weekday(..))


type Msg
    = ToDatePicker DatePicker.Msg


type alias Model =
    { date : Maybe Date
    , datePicker : DatePicker.DatePicker
    }


settings : DatePicker.Settings
settings =
    let
        isDisabled date =
            [ Sat, Sun ]
                |> List.member (weekday date)
    in
    { defaultSettings | isDisabled = isDisabled }


init : ( Model, Cmd Msg )
init =
    let
        ( datePicker, datePickerFx ) =
            DatePicker.init
    in
    ( { date = Nothing
      , datePicker = datePicker
      }
    , Cmd.map ToDatePicker datePickerFx
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg ({ date, datePicker } as model) =
    case msg of
        ToDatePicker subMsg ->
            let
                ( newDatePicker, dateEvent ) =
                    DatePicker.update settings subMsg datePicker

                newDate =
                    case dateEvent of
                        Picked changedDate ->
                            Just changedDate

                        _ ->
                            date
            in
            ( { model
                | date = newDate
                , datePicker = newDatePicker
              }
            , Cmd.none
            )


view : Model -> Html Msg
view model =
    div []
        [ case model.date of
            Nothing ->
                h1 [] [ text "Pick a date" ]

            Just date ->
                h1 [] [ text <| Date.format "MMM d, yyyy" date ]
        , DatePicker.view model.date settings model.datePicker
            |> Html.map ToDatePicker
        ]


main : Program () Model Msg
main =
    Browser.element
        { init = \_ -> init
        , view = view
        , update = update
        , subscriptions = \_ -> Sub.none
        }
