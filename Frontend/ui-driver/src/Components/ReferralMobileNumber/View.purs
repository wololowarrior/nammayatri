{-
 
  Copyright 2022-23, Juspay India Pvt Ltd
 
  This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License
 
  as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version. This program
 
  is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
 
  or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License for more details. You should have received a copy of
 
  the GNU Affero General Public License along with this program. If not, see <https://www.gnu.org/licenses/>.
-}

module Components.ReferralMobileNumber.View where

import Prelude
import Effect (Effect)
import Components.ReferralMobileNumber.Controller (Action(..), Config(..))
import PrestoDOM (Gravity(..), Length(..), PrestoDOM(..), Margin(..), Orientation(..), Padding(..), Visibility(..), linearLayout, textView, editText, onBackPressed, onClick, imageView, imageWithFallback)
import PrestoDOM.Properties(alpha, background, clickable, color, cornerRadii, fontStyle, gravity, height, hint, id, imageUrl, margin, orientation, padding, pattern, sheetState, stroke, text, textSize, visibility, weight, width, cornerRadius)
import PrestoDOM.Types.DomAttributes (Corners(..))
import Styles.Colors as Color
import Language.Strings (getString)
import Language.Types (STR(..))
import Engineering.Helpers.Commons (getNewIDWithTag)
import Font.Style as FontStyle
import Font.Size as FontSize
import Components.PrimaryEditText as PrimaryEditText
import Components.PrimaryButton as PrimaryButton
import Data.String.CodeUnits (charAt)
import Data.String (length)
import Data.Maybe
import Common.Types.App


view :: forall w .(Action -> Effect Unit) -> Config -> PrestoDOM (Effect Unit) w
view push state = 
    linearLayout
    [ height MATCH_PARENT
    , width MATCH_PARENT
    , gravity BOTTOM
    , orientation VERTICAL
    , background Color.black9000
    , onBackPressed push (const OnBackClick)
    , clickable true
    ][  linearLayout
        [ height WRAP_CONTENT
        , width MATCH_PARENT
        , gravity CENTER
        , background Color.white900
        , padding (Padding 0 20 0 0)
        , cornerRadii $ Corners 20.0 true true false false
        , orientation VERTICAL
        ][  linearLayout
            [ height WRAP_CONTENT
            , width MATCH_PARENT
            , gravity LEFT
            , orientation HORIZONTAL
            ][  imageView
                [ width (V 25)
                , height (V 25)
                , imageWithFallback "ny_ic_chevron_left,https://assets.juspay.in/nammayatri/images/common/ny_ic_chevron_left.png"
                , margin (MarginLeft 14)
                , onClick push (const OnBackClick)
                ]
              , textView (
                [ width WRAP_CONTENT
                , height WRAP_CONTENT
                , text (getString ENTER_REFERRAL_MOBILE_NUMBER)
                , color Color.black800
                , margin (MarginLeft 15)
                ] <> FontStyle.h3 TypoGraphy
                )
            ]
            , textEditView push state
            , PrimaryButton.view (push <<< PrimaryButtonActionController) (primaryButtonConfig state)
        ]
    ]

textEditView :: forall w . (Action -> Effect Unit) -> Config -> PrestoDOM (Effect Unit) w
textEditView push state =
    linearLayout
    [ width MATCH_PARENT
    , height WRAP_CONTENT
    , orientation VERTICAL
    ][ PrimaryEditText.view (push <<< PrimaryEditTextActionController) (primaryEditTextConfig state)
    ]

primaryEditTextConfig :: Config -> PrimaryEditText.Config
primaryEditTextConfig state = let 
    config = PrimaryEditText.config
    primaryEditTextConfig' = config
        {   editText
            {   singleLine = true
                , pattern = Just "[0-9]*,10"
                , fontStyle = FontStyle.bold LanguageStyle
                , textSize = FontSize.a_16
                , color = Color.black800
                , text = state.referralNumber
            }
            , type = "number"
            , margin = (Margin 16 0 16 40)}
    in primaryEditTextConfig'

primaryButtonConfig :: Config -> PrimaryButton.Config 
primaryButtonConfig state = let 
    config = PrimaryButton.config
    primaryButtonConfig' = config
      { textConfig
      { text = (getString APPLY)
      , color = Color.primaryButtonColor
      , textSize = FontSize.a_18}
      , margin = (Margin 16 0 16 10)
      , cornerRadius = 8.0
      , background = Color.black900
      , height = (V 60)
      , alpha = if (state.isApplyButtonActive) then 1.0 else 0.7
      , isClickable = state.isApplyButtonActive
      }
  in primaryButtonConfig'
