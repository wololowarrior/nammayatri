{-
 Copyright 2022-23, Juspay India Pvt Ltd

 This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License

 as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version. This program

 is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY

 or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License for more details. You should have received a copy of

 the GNU Affero General Public License along with this program. If not, see <https://www.gnu.org/licenses/>.
-}
{-# OPTIONS_GHC -Wno-unused-matches #-}

module Beckn.ACL.Select (buildSelectReq) where

import qualified Beckn.Types.Core.Taxi.Common.ItemCode as Common
import qualified Beckn.Types.Core.Taxi.Select as Select
import qualified Domain.Action.UI.Select as DSelect
import Domain.Types.VehicleVariant
import Environment
import qualified Kernel.External.Maps as Maps
import Kernel.Prelude
import qualified Kernel.Types.Beckn.Context as Context
import Kernel.Types.Beckn.ReqTypes
import Kernel.Types.Common
import Kernel.Utils.Common

buildSelectReq ::
  (HasFlowEnv m r ["bapSelfIds" ::: BAPs Text, "bapSelfURIs" ::: BAPs BaseUrl]) =>
  DSelect.DSelectRes ->
  Bool ->
  m (BecknReq Select.SelectMessage)
buildSelectReq dSelectReq autoAssignEnabled = do
  let messageId = dSelectReq.estimateId.getId
  let transactionId = dSelectReq.searchRequest.id.getId
  bapURIs <- asks (.bapSelfURIs)
  bapIDs <- asks (.bapSelfIds)
  context <- buildTaxiContext Context.SELECT messageId (Just transactionId) bapIDs.cabs bapURIs.cabs (Just dSelectReq.providerId) (Just dSelectReq.providerUrl) dSelectReq.city
  let order = mkOrder dSelectReq autoAssignEnabled dSelectReq.customerLanguage
  pure $ BecknReq context $ Select.SelectMessage order

castVariant :: VehicleVariant -> Common.VehicleVariant
castVariant AUTO_RICKSHAW = Common.AUTO_RICKSHAW
castVariant HATCHBACK = Common.HATCHBACK
castVariant SEDAN = Common.SEDAN
castVariant SUV = Common.SUV

mkOrder :: DSelect.DSelectRes -> Bool -> Maybe Maps.Language -> Select.Order
mkOrder req autoAssignEnabled customerLanguage = do
  let from = req.searchRequest.fromLocation
      mbTo = req.searchRequest.toLocation
      items =
        (: []) $
          Select.OrderItem
            { id = Nothing,
              descriptor =
                Select.Descriptor
                  { code =
                      Select.ItemCode
                        { fareProductType = Common.DRIVER_OFFER_ESTIMATE,
                          vehicleVariant = castVariant req.variant,
                          distance = Nothing,
                          duration = Nothing
                        }
                  }
            }
  Select.Order
    { items,
      fulfillment =
        Select.FulfillmentInfo
          { tags =
              Select.Tags
                { auto_assign_enabled = autoAssignEnabled,
                  customer_language = customerLanguage
                },
            start =
              Select.StartInfo
                { location =
                    Select.Location
                      { gps = Select.Gps {lat = from.lat, lon = from.lon},
                        address =
                          Just
                            Select.Address
                              { locality = from.address.area,
                                state = from.address.state,
                                country = from.address.country,
                                building = from.address.building,
                                street = from.address.street,
                                city = from.address.city,
                                area_code = from.address.areaCode,
                                door = from.address.door,
                                ward = from.address.ward
                              }
                      },
                  time = Select.TimeTimestamp req.searchRequest.startTime
                },
            end =
              mbTo <&> \to ->
                Select.StopInfo
                  { location =
                      Select.Location
                        { gps = Select.Gps {lat = to.lat, lon = to.lon},
                          address =
                            Just
                              Select.Address
                                { locality = to.address.area,
                                  state = to.address.state,
                                  country = to.address.country,
                                  building = to.address.building,
                                  street = to.address.street,
                                  city = to.address.city,
                                  area_code = to.address.areaCode,
                                  door = to.address.door,
                                  ward = to.address.ward
                                }
                        }
                  }
          }
    }
