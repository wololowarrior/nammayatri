{-
 
  Copyright 2022-23, Juspay India Pvt Ltd
 
  This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License
 
  as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version. This program
 
  is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
 
  or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License for more details. You should have received a copy of
 
  the GNU Affero General Public License along with this program. If not, see <https://www.gnu.org/licenses/>.
-}

module Screens.AppUpdatePopUpScreen.Handler where

import Prelude (bind, pure, ($), (<$>))
import Presto.Core.Types.Language.Flow (doAff)
import Screens.AppUpdatePopUpScreen.Controller as CD
import Screens.AppUpdatePopUpScreen.View as AppUpdatePopUpScreen
import PrestoDOM.Core.Types.Language.Flow(runScreenWithNameSpace, initUIWithNameSpace)
import Types.App (FlowBT, GlobalState(..))
import Control.Monad.Except.Trans (lift)
import Effect.Class (liftEffect)
import Control.Transformers.Back.Trans (BackT(..), FailBack(..)) as App
import Engineering.Helpers.BackTrack (getState)
import Data.Maybe (Maybe(..))
import PrestoDOM.Core2 (terminateUI)


handleAppUpdatePopUp :: FlowBT String String 
handleAppUpdatePopUp  = do
  (GlobalState state) ← getState
  _ <- lift $ lift $ doAff $ liftEffect $ initUIWithNameSpace "AppUpdatePopUpScreen" Nothing 
  act <- lift $ lift $ runScreenWithNameSpace ( AppUpdatePopUpScreen.screen state.appUpdatePopUpScreen)
  _ <- lift $ lift $ doAff $ liftEffect $ terminateUI $ Just "AppUpdatePopUpScreen"
  case act of
    CD.Decline -> App.BackT $ App.NoBack <$> pure "Decline" --pure $ GOTO $ REGISTER_SCREEN RegisterScreenData.initData --pure $ GOBACK "HOME_SCREEN"
    CD.Accept  -> App.BackT $ App.NoBack <$> pure "Accept"
