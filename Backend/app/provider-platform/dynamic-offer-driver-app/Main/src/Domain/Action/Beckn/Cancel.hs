{-
 Copyright 2022-23, Juspay India Pvt Ltd

 This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License

 as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version. This program

 is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY

 or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License for more details. You should have received a copy of

 the GNU Affero General Public License along with this program. If not, see <https://www.gnu.org/licenses/>.
-}

module Domain.Action.Beckn.Cancel
  ( cancel,
    CancelReq (..),
    CancelSearchReq (..),
    cancelSearch,
  )
where

import qualified Domain.Types.Booking as SRB
import qualified Domain.Types.BookingCancellationReason as DBCR
import qualified Domain.Types.Driver.DriverFlowStatus as DDFS
import qualified Domain.Types.Merchant as DM
import qualified Domain.Types.Ride as SRide
import qualified Domain.Types.SearchRequest as SR
import EulerHS.Prelude
import qualified Kernel.Storage.Esqueleto as DB
import qualified Kernel.Storage.Esqueleto as Esq
import Kernel.Storage.Hedis (HedisFlow)
import Kernel.Types.Common
import Kernel.Types.Id
import Kernel.Utils.Common
import Kernel.Utils.Servant.SignatureAuth (SignatureAuthResult (..))
import qualified SharedLogic.CallBAP as BP
import qualified SharedLogic.CancelSearch as CS
import qualified SharedLogic.DriverLocation as DLoc
import qualified SharedLogic.Ride as SRide
import Storage.CachedQueries.CacheConfig
import qualified Storage.CachedQueries.Merchant as QM
import qualified Storage.Queries.Booking as QRB
import qualified Storage.Queries.BookingCancellationReason as QBCR
import qualified Storage.Queries.Driver.DriverFlowStatus as QDFS
import qualified Storage.Queries.DriverInformation as QDI
import qualified Storage.Queries.Person as QPers
import qualified Storage.Queries.Person as QPerson
import qualified Storage.Queries.Ride as QRide
import Storage.Queries.SearchRequest as SR
import qualified Storage.Queries.SearchRequestForDriver as QSRD
import Tools.Error
import Tools.Metrics
import qualified Tools.Notifications as Notify

newtype CancelReq = CancelReq
  { bookingId :: Id SRB.Booking
  }

newtype CancelSearchReq = CancelSearchReq
  { searchId :: Id SR.SearchRequest
  }

cancel ::
  ( HasCacheConfig r,
    HedisFlow m r,
    EsqDBFlow m r,
    Esq.EsqDBReplicaFlow m r,
    HedisFlow m r,
    CacheFlow m r,
    HasHttpClientOptions r c,
    EncFlow m r,
    HasFlowEnv m r '["nwAddress" ::: BaseUrl],
    HasLongDurationRetryCfg r c,
    CoreMetrics m
  ) =>
  Id DM.Merchant ->
  SignatureAuthResult ->
  CancelReq ->
  m ()
cancel transporterId _ req = do
  transporter <-
    QM.findById transporterId
      >>= fromMaybeM (MerchantNotFound transporterId.getId)
  booking <- QRB.findById req.bookingId >>= fromMaybeM (BookingDoesNotExist req.bookingId.getId)
  let transporterId' = booking.providerId
  unless (transporterId' == transporterId) $ throwError AccessDenied
  mbRide <- QRide.findActiveByRBId req.bookingId
  bookingCR <- buildBookingCancellationReason
  Esq.runTransaction $ do
    QBCR.upsert bookingCR
    QRB.updateStatus booking.id SRB.CANCELLED
    whenJust mbRide $ \ride -> do
      QRide.updateStatus ride.id SRide.CANCELLED
      driverInfo <- QDI.findById (cast ride.driverId) >>= fromMaybeM (PersonNotFound ride.driverId.getId)
      if driverInfo.active
        then QDFS.updateStatus ride.driverId DDFS.ACTIVE
        else QDFS.updateStatus ride.driverId DDFS.IDLE
  whenJust mbRide $ \ride -> do
    SRide.clearCache $ cast ride.driverId
    DLoc.updateOnRide (cast ride.driverId) False

  logTagInfo ("bookingId-" <> getId req.bookingId) ("Cancellation reason " <> show bookingCR.source)
  fork "cancelBooking - Notify BAP" $ do
    BP.sendBookingCancelledUpdateToBAP booking transporter bookingCR.source
  whenJust mbRide $ \ride ->
    fork "cancelRide - Notify driver" $ do
      driver <- QPers.findById ride.driverId >>= fromMaybeM (PersonNotFound ride.driverId.getId)
      Notify.notifyOnCancel transporter.id booking driver.id driver.deviceToken bookingCR.source
  where
    buildBookingCancellationReason = do
      return $
        DBCR.BookingCancellationReason
          { bookingId = req.bookingId,
            rideId = Nothing,
            source = DBCR.ByUser,
            reasonCode = Nothing,
            driverId = Nothing,
            additionalInfo = Nothing,
            ..
          }

cancelSearch ::
  ( HasCacheConfig r,
    HedisFlow m r,
    EsqDBFlow m r,
    Esq.EsqDBReplicaFlow m r,
    CoreMetrics m
  ) =>
  Id DM.Merchant ->
  SignatureAuthResult ->
  CancelSearchReq ->
  m ()
cancelSearch transporterId _ req = do
  let transactionId = req.searchId
  searchID <- Esq.runInReplica $ SR.getRequestIdfromTransactionId transactionId >>= fromMaybeM (SearchRequestNotFound transactionId.getId)
  CS.lockSearchRequest searchID
  driverSearchReqs <- Esq.runInReplica $ QSRD.findAllActiveByRequestId searchID
  for_ driverSearchReqs $ \driverReq -> do
    logTagInfo ("searchId-" <> getId req.searchId) "Search Request Cancellation"
    DB.runTransaction $ do
      SR.updateStatus searchID SR.CANCELLED
      QSRD.setInactiveByRequestId driverReq.searchRequestId
    driver_ <- Esq.runInReplica $ QPerson.findById driverReq.driverId >>= fromMaybeM (PersonNotFound driverReq.driverId.getId)
    Notify.notifyOnCancelSearchRequest transporterId driverReq.driverId driver_.deviceToken driverReq.searchRequestId
