{-
 
  Copyright 2022-23, Juspay India Pvt Ltd
 
  This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License
 
  as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version. This program
 
  is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
 
  or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License for more details. You should have received a copy of
 
  the GNU Affero General Public License along with this program. If not, see <https://www.gnu.org/licenses/>.
-}

module Screens.RideHistoryScreen.ScreenData where

import Screens.Types (AnimationState(..), RideHistoryScreenState, BottomNavBarState)
import PrestoDOM.Types.Core (toPropValue)

initData :: RideHistoryScreenState
initData = {
  shimmerLoader : AnimatingIn,
  recievedResponse: false,
  prestoListArrayItems : [],
  rideList: [],
  currentTab: "COMPLETED",
  loadMoreDisabled: false,
  selectedItem: {
    date : "",
    time : "",
    total_amount : 0,
    card_visibility : "",
    shimmer_visibility : "",
    rideDistance : "",
    status : "",
    vehicleModel : "",
    shortRideId : "",
    vehicleNumber : "",
    driverName : "",
    driverSelectedFare : 0,
    vehicleColor : "",
    id : "",
    updatedAt : "",
    source : "",
    destination : ""
  },
  offsetValue: 0,
  loaderButtonVisibility: false
}
navbarData :: BottomNavBarState
navbarData = {
   activeIndex: 1,
   screenName: "RideHistoryScreen",
   navButton: [
    {
      defaultIcon: "ny_ic_home_inactive,https://assets.juspay.in/nammayatri/images/driver/ny_ic_home_inactive.png",
      activeIcon: "ny_ic_home_active,https://assets.juspay.in/nammayatri/images/driver/ny_ic_home_active.png",
      text: "Home"
    },
    {
      defaultIcon: "ny_ic_cab_inactive,https://assets.juspay.in/nammayatri/images/driver/ny_ic_cab_inactive.png",
      activeIcon: "ny_ic_cab_active,https://assets.juspay.in/nammayatri/images/driver/ny_ic_cab_active.png",
      text: "Rides"
    },
    {
      defaultIcon: "ny_ic_account_inactive,https://assets.juspay.in/nammayatri/images/driver/ny_ic_account_inactive.png",
      activeIcon: "ny_ic_account_active,https://assets.juspay.in/nammayatri/images/driver/ny_ic_account_active.png",
      text: "Profile"
    }
  ]
}