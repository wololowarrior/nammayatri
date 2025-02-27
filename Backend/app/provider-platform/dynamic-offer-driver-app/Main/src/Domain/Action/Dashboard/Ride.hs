{-
 Copyright 2022-23, Juspay India Pvt Ltd

 This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License

 as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version. This program

 is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY

 or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License for more details. You should have received a copy of

 the GNU Affero General Public License along with this program. If not, see <https://www.gnu.org/licenses/>.
-}
{-# LANGUAGE TypeApplications #-}

module Domain.Action.Dashboard.Ride
  ( rideList,
    rideInfo,
    rideSync,
    rideRoute,
  )
where

import qualified "dashboard-helper-api" Dashboard.ProviderPlatform.Ride as Common
import Data.Coerce (coerce)
import qualified Data.Text as T
import qualified Domain.Types.Booking as DBooking
import qualified Domain.Types.Booking.BookingLocation as DBLoc
import qualified Domain.Types.BookingCancellationReason as DBCReason
import qualified Domain.Types.CancellationReason as DCReason
import qualified Domain.Types.Merchant as DM
import qualified Domain.Types.Person as DP
import qualified Domain.Types.Ride as DRide
import Environment
import EulerHS.Prelude (whenNothing_)
import Kernel.External.Encryption (decrypt, getDbHash)
import Kernel.External.Maps.HasCoordinates
import Kernel.External.Maps.Types
import Kernel.Prelude
import Kernel.Storage.Clickhouse.Operators
import qualified Kernel.Storage.Clickhouse.Queries as CH
import qualified Kernel.Storage.Clickhouse.Types as CH
import Kernel.Storage.Esqueleto.Transactionable (runInReplica)
import Kernel.Types.Id
import Kernel.Utils.Common
import Kernel.Utils.Error.BaseError.HTTPError.BecknAPIError
import qualified SharedLogic.CallBAP as CallBAP
import SharedLogic.Merchant (findMerchantByShortId)
import qualified Storage.Queries.Booking as QBooking
import qualified Storage.Queries.BookingCancellationReason as QBCReason
import qualified Storage.Queries.CallStatus as QCallStatus
import qualified Storage.Queries.DriverLocation as QDrLoc
import qualified Storage.Queries.DriverQuote as DQ
import qualified Storage.Queries.FareParameters as QFareParams
import qualified Storage.Queries.Ride as QRide
import qualified Storage.Queries.RideDetails as QRideDetails
import qualified Storage.Queries.RiderDetails as QRiderDetails
import Tools.Error

---------------------------------------------------------------------
rideList ::
  ShortId DM.Merchant ->
  Maybe Int ->
  Maybe Int ->
  Maybe Common.BookingStatus ->
  Maybe (ShortId Common.Ride) ->
  Maybe Text ->
  Maybe Text ->
  Maybe Money ->
  Flow Common.RideListRes
rideList merchantShortId mbLimit mbOffset mbBookingStatus mbReqShortRideId mbCustomerPhone mbDriverPhone mbFareDiff = do
  merchant <- findMerchantByShortId merchantShortId
  let limit = min maxLimit . fromMaybe defaultLimit $ mbLimit -- TODO move to common code
      offset = fromMaybe 0 mbOffset
  let mbShortRideId = coerce @(ShortId Common.Ride) @(ShortId DRide.Ride) <$> mbReqShortRideId
  mbCustomerPhoneDBHash <- getDbHash `traverse` mbCustomerPhone
  mbDriverPhoneDBHash <- getDbHash `traverse` mbDriverPhone
  now <- getCurrentTime
  rideItems <- runInReplica $ QRide.findAllRideItems merchant.id limit offset mbBookingStatus mbShortRideId mbCustomerPhoneDBHash mbDriverPhoneDBHash mbFareDiff now
  rideListItems <- traverse buildRideListItem rideItems
  let count = length rideListItems
  -- should we consider filters in totalCount, e.g. count all canceled rides?
  totalCount <- runInReplica $ QRide.countRides merchant.id
  let summary = Common.Summary {totalCount, count}
  pure Common.RideListRes {totalItems = count, summary, rides = rideListItems}
  where
    maxLimit = 20
    defaultLimit = 10

buildRideListItem :: EncFlow m r => QRide.RideItem -> m Common.RideListItem
buildRideListItem QRide.RideItem {..} = do
  customerPhoneNo <- decrypt riderDetails.mobileNumber
  driverPhoneNo <- mapM decrypt rideDetails.driverNumber
  pure
    Common.RideListItem
      { rideId = cast @DRide.Ride @Common.Ride rideDetails.id,
        rideShortId = coerce @(ShortId DRide.Ride) @(ShortId Common.Ride) rideShortId,
        customerName,
        customerPhoneNo,
        driverName = rideDetails.driverName,
        driverPhoneNo,
        vehicleNo = rideDetails.vehicleNumber,
        fareDiff,
        bookingStatus,
        rideCreatedAt = rideCreatedAt
      }

---------------------------------------------------------------------------------------------------

getLatLong :: MonadFlow m => Common.DriverEdaKafka -> m LatLong
getLatLong Common.DriverEdaKafka {..} =
  case (lat, lon) of
    (Just lat_, Just lon_) -> do
      lat' <- readMaybe lat_ & fromMaybeM (InvalidRequest "Couldn't find driver's location.")
      lon' <- readMaybe lon_ & fromMaybeM (InvalidRequest "Couldn't find driver's location.")
      pure $ LatLong lat' lon'
    _ -> throwError $ InvalidRequest "Couldn't find driver's location."

rideRoute :: ShortId DM.Merchant -> Id Common.Ride -> Flow Common.RideRouteRes
rideRoute merchantShortId reqRideId = do
  merchant <- findMerchantByShortId merchantShortId
  let rideId = cast @Common.Ride @DRide.Ride reqRideId
  ride <- runInReplica $ QRide.findById rideId >>= fromMaybeM (RideDoesNotExist rideId.getId)
  booking <- runInReplica $ QBooking.findById ride.bookingId >>= fromMaybeM (BookingDoesNotExist ride.bookingId.getId)
  unless (merchant.id == booking.providerId) $ throwError (RideDoesNotExist rideId.getId)
  let rideQId = T.unpack rideId.getId
      driverQId = T.unpack ride.driverId.getId
  (rQStart, rQEnd) <- case (ride.tripStartTime, ride.tripEndTime) of
    (Just x, Just y) -> pure (fetchDate $ show x, fetchDate $ show y)
    _ -> throwError $ InvalidRequest "The ride has not ended yet."
  ckhTbl <- CH.findAll (Proxy @Common.DriverEdaKafka) ((("partition_date" =.= rQStart) |.| ("partition_date" =.= rQEnd)) &.& ("driver_id" =.= driverQId) &.& ("rid" =.= rideQId)) Nothing Nothing (Just $ CH.Desc "created_at")
  actualRoute <- case ckhTbl of
    Left err -> do
      logError $ "Clickhouse error: " <> show err
      pure []
    Right y -> mapM getLatLong y
  when (null actualRoute) $ throwError $ InvalidRequest "No route found for this ride."
  pure
    Common.RideRouteRes
      { actualRoute
      }
  where
    fetchDate dateTime = T.unpack $ T.take 10 dateTime

---------------------------------------------------------------------
rideInfo :: ShortId DM.Merchant -> Id Common.Ride -> Flow Common.RideInfoRes
rideInfo merchantShortId reqRideId = do
  merchant <- findMerchantByShortId merchantShortId
  let rideId = cast @Common.Ride @DRide.Ride reqRideId
  ride <- runInReplica $ QRide.findById rideId >>= fromMaybeM (RideDoesNotExist rideId.getId)
  rideDetails <- runInReplica $ QRideDetails.findById rideId >>= fromMaybeM (RideNotFound rideId.getId) -- FIXME RideDetailsNotFound
  booking <- runInReplica $ QBooking.findById ride.bookingId >>= fromMaybeM (BookingNotFound rideId.getId)
  quote <- runInReplica $ DQ.findById (Id booking.quoteId) >>= fromMaybeM (QuoteNotFound booking.quoteId)
  let driverId = ride.driverId

  -- merchant access checking
  unless (merchant.id == booking.providerId) $ throwError (RideDoesNotExist rideId.getId)

  riderId <- booking.riderId & fromMaybeM (BookingFieldNotPresent "rider_id")
  riderDetails <- runInReplica $ QRiderDetails.findById riderId >>= fromMaybeM (RiderDetailsNotFound rideId.getId)
  driverLocation <- runInReplica $ QDrLoc.findById driverId >>= fromMaybeM LocationNotFound

  mbBCReason <-
    if ride.status == DRide.CANCELLED
      then runInReplica $ QBCReason.findByRideId rideId -- it can be Nothing if cancelled by user
      else pure Nothing
  driverInitiatedCallCount <- runInReplica $ QCallStatus.countCallsByRideId rideId
  let cancellationReason =
        (coerce @DCReason.CancellationReasonCode @Common.CancellationReasonCode <$>) . join $ mbBCReason <&> (.reasonCode)
  let cancelledBy = castCancellationSource <$> (mbBCReason <&> (.source))
  let cancelledTime = case ride.status of
        DRide.CANCELLED -> Just ride.updatedAt
        _ -> Nothing
  customerPhoneNo <- decrypt riderDetails.mobileNumber
  driverPhoneNo <- mapM decrypt rideDetails.driverNumber
  now <- getCurrentTime
  pure
    Common.RideInfoRes
      { rideId = cast @DRide.Ride @Common.Ride ride.id,
        customerName = booking.riderName,
        customerPhoneNo,
        rideOtp = ride.otp,
        customerPickupLocation = mkLocationAPIEntity booking.fromLocation,
        customerDropLocation = Just $ mkLocationAPIEntity booking.toLocation,
        actualDropLocation = ride.tripEndPos,
        driverId = cast @DP.Person @Common.Driver driverId,
        driverName = rideDetails.driverName,
        driverPhoneNo,
        vehicleNo = rideDetails.vehicleNumber,
        driverStartLocation = ride.tripStartPos,
        driverCurrentLocation = getCoordinates driverLocation,
        rideBookingTime = booking.createdAt,
        estimatedDriverArrivalTime = realToFrac quote.durationToPickup `addUTCTime` ride.createdAt,
        actualDriverArrivalTime = ride.driverArrivalTime,
        rideStartTime = ride.tripStartTime,
        rideEndTime = ride.tripEndTime,
        rideDistanceEstimated = Just booking.estimatedDistance,
        rideDistanceActual = roundToIntegral ride.traveledDistance,
        chargeableDistance = ride.chargeableDistance,
        estimatedRideDuration = Just $ secondsToMinutes booking.estimatedDuration,
        estimatedFare = booking.estimatedFare,
        actualFare = ride.fare,
        driverOfferedFare = quote.fareParams.driverSelectedFare,
        pickupDuration = timeDiffInMinutes <$> ride.tripStartTime <*> (Just ride.createdAt),
        rideDuration = timeDiffInMinutes <$> ride.tripEndTime <*> ride.tripStartTime,
        bookingStatus = mkBookingStatus ride now,
        cancelledTime,
        cancelledBy,
        cancellationReason,
        driverInitiatedCallCount,
        bookingToRideStartDuration = timeDiffInMinutes <$> ride.tripStartTime <*> (Just booking.createdAt)
      }

mkLocationAPIEntity :: DBLoc.BookingLocation -> Common.LocationAPIEntity
mkLocationAPIEntity DBLoc.BookingLocation {..} = do
  let DBLoc.LocationAddress {..} = address
  Common.LocationAPIEntity {..}

castCancellationSource :: DBCReason.CancellationSource -> Common.CancellationSource
castCancellationSource = \case
  DBCReason.ByUser -> Common.ByUser
  DBCReason.ByDriver -> Common.ByDriver
  DBCReason.ByMerchant -> Common.ByMerchant
  DBCReason.ByAllocator -> Common.ByAllocator
  DBCReason.ByApplication -> Common.ByApplication

timeDiffInMinutes :: UTCTime -> UTCTime -> Minutes
timeDiffInMinutes t1 = secondsToMinutes . nominalDiffTimeToSeconds . diffUTCTime t1

-- ride considered as ONGOING_6HRS if ride.status = INPROGRESS, but somehow ride.tripStartTime = Nothing
mkBookingStatus :: DRide.Ride -> UTCTime -> Common.BookingStatus
mkBookingStatus ride now = do
  let sixHours = secondsToNominalDiffTime $ Seconds 21600
  let ongoing6HrsCond = maybe True (\tripStartTime -> diffUTCTime now tripStartTime >= sixHours) ride.tripStartTime
  let upcoming6HrsCond = diffUTCTime now ride.createdAt >= sixHours
  case ride.status of
    DRide.NEW | not upcoming6HrsCond -> Common.UPCOMING
    DRide.NEW -> Common.UPCOMING_6HRS
    DRide.INPROGRESS | not ongoing6HrsCond -> Common.ONGOING
    DRide.INPROGRESS -> Common.ONGOING_6HRS
    DRide.COMPLETED -> Common.COMPLETED
    DRide.CANCELLED -> Common.CANCELLED

---------------------------------------------------------------------
rideSync :: ShortId DM.Merchant -> Id Common.Ride -> Flow Common.RideSyncRes
rideSync merchantShortId reqRideId = do
  merchant <- findMerchantByShortId merchantShortId
  let rideId = cast @Common.Ride @DRide.Ride reqRideId
  ride <- runInReplica $ QRide.findById rideId >>= fromMaybeM (RideDoesNotExist rideId.getId)
  booking <- runInReplica $ QBooking.findById ride.bookingId >>= fromMaybeM (BookingNotFound rideId.getId)

  -- merchant access checking
  unless (merchant.id == booking.providerId) $ throwError (RideDoesNotExist rideId.getId)

  logTagInfo "dashboard -> syncRide : " $ show rideId <> "; status: " <> show ride.status

  case ride.status of
    DRide.NEW -> syncNewRide ride booking
    DRide.INPROGRESS -> syncInProgressRide ride booking
    DRide.COMPLETED -> syncCompletedRide ride booking
    DRide.CANCELLED -> syncCancelledRide ride booking merchant

syncNewRide :: DRide.Ride -> DBooking.Booking -> Flow Common.RideSyncRes
syncNewRide ride booking = do
  handle (errHandler ride.status booking.status "ride assigned") $
    CallBAP.sendRideAssignedUpdateToBAP booking ride
  pure $ Common.RideSyncRes Common.RIDE_NEW "Success. Sent ride started update to bap"

syncInProgressRide :: DRide.Ride -> DBooking.Booking -> Flow Common.RideSyncRes
syncInProgressRide ride booking = do
  handle (errHandler ride.status booking.status "ride started") $
    CallBAP.sendRideStartedUpdateToBAP booking ride
  pure $ Common.RideSyncRes Common.RIDE_INPROGRESS "Success. Sent ride started update to bap"

syncCancelledRide :: DRide.Ride -> DBooking.Booking -> DM.Merchant -> Flow Common.RideSyncRes
syncCancelledRide ride booking merchant = do
  mbBookingCReason <- runInReplica $ QBCReason.findByRideId ride.id
  -- rides cancelled by bap no need to sync, and have mbBookingCReason = Nothing
  case mbBookingCReason of
    Nothing -> pure $ Common.RideSyncRes Common.RIDE_CANCELLED "No cancellation reason found for ride. Nothing to sync, ignoring"
    Just bookingCReason -> do
      case bookingCReason.source of
        DBCReason.ByUser -> pure $ Common.RideSyncRes Common.RIDE_CANCELLED "Ride canceled by customer. Nothing to sync, ignoring"
        source -> do
          handle (errHandler ride.status booking.status "booking cancellation") $
            CallBAP.sendBookingCancelledUpdateToBAP booking merchant source
          pure $ Common.RideSyncRes Common.RIDE_CANCELLED "Success. Sent booking cancellation update to bap"

syncCompletedRide :: DRide.Ride -> DBooking.Booking -> Flow Common.RideSyncRes
syncCompletedRide ride booking = do
  whenNothing_ ride.fareParametersId $ do
    -- only for old rides
    logWarning "No fare params linked to ride. Using fare params linked to booking, they may be not actual"
  let fareParametersId = fromMaybe booking.fareParams.id ride.fareParametersId
  fareParameters <- runInReplica $ QFareParams.findById fareParametersId >>= fromMaybeM (FareParametersNotFound fareParametersId.getId)
  handle (errHandler ride.status booking.status "ride completed") $
    CallBAP.sendRideCompletedUpdateToBAP booking ride fareParameters
  pure $ Common.RideSyncRes Common.RIDE_COMPLETED "Success. Sent ride completed update to bap"

errHandler :: DRide.RideStatus -> DBooking.BookingStatus -> Text -> SomeException -> Flow ()
errHandler rideStatus bookingStatus desc exc
  | Just (BecknAPICallError _endpoint err) <- fromException @BecknAPICallError exc = do
    case err.code of
      code | code == toErrorCode (BookingInvalidStatus "") -> do
        throwError $ InvalidRequest $ bookingErrMessage <> maybe "" (" Bap booking status: " <>) err.message
      code | code == toErrorCode (RideInvalidStatus "") -> do
        throwError $ InvalidRequest $ rideErrMessage <> maybe "" (" Bap ride status: " <>) err.message
      _ -> throwError $ InternalError bookingErrMessage
  | otherwise = throwError $ InternalError bookingErrMessage
  where
    bookingErrMessage = "Fail to send " <> desc <> " update. Bpp booking status: " <> show bookingStatus <> "."
    rideErrMessage = "Fail to send " <> desc <> " update. Bpp ride status: " <> show rideStatus <> "."
