{-
 Copyright 2022-23, Juspay India Pvt Ltd

 This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License

 as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version. This program

 is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY

 or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License for more details. You should have received a copy of

 the GNU Affero General Public License along with this program. If not, see <https://www.gnu.org/licenses/>.
-}
{-# LANGUAGE TypeApplications #-}

module Storage.Queries.Estimate where

import Data.Tuple.Extra
import Domain.Types.Estimate
import Domain.Types.Quote
import Domain.Types.SearchRequest
import Kernel.Prelude
import Kernel.Storage.Esqueleto as Esq
import Kernel.Types.Common
import Kernel.Types.Id (Id (getId))
import Storage.Queries.FullEntityBuilders (buildFullEstimate)
import Storage.Tabular.Estimate
import Storage.Tabular.TripTerms

-- order of creating entites make sense!
create :: Estimate -> SqlDB ()
create estimate =
  Esq.withFullEntity estimate $ \(estimateT, estimateBreakupT, mbTripTermsT) -> do
    traverse_ Esq.create' mbTripTermsT
    Esq.create' estimateT
    traverse_ Esq.create' estimateBreakupT

createMany :: [Estimate] -> SqlDB ()
createMany estimates =
  Esq.withFullEntities estimates $ \list -> do
    let estimateTs = map fst3 list
        estimateBreakupT = map snd3 list
        tripTermsTs = mapMaybe thd3 list
    Esq.createMany' tripTermsTs
    Esq.createMany' estimateTs
    traverse_ Esq.createMany' estimateBreakupT

fullEstimateTable ::
  From
    ( Table EstimateT
        :& Esq.MbTable TripTermsT
    )
fullEstimateTable =
  table @EstimateT
    `leftJoin` table @TripTermsT
      `Esq.on` ( \(estimate :& mbTripTerms) ->
                   estimate ^. EstimateTripTermsId ==. mbTripTerms ?. TripTermsTId
               )

findById :: Transactionable m => Id Estimate -> m (Maybe Estimate)
findById estimateId = Esq.buildDType $ do
  mbFullEstimateT <- Esq.findOne' $ do
    (estimate :& mbTripTerms) <- from fullEstimateTable
    where_ $ estimate ^. EstimateTId ==. val (toKey estimateId)
    pure (estimate, mbTripTerms)
  mapM buildFullEstimate mbFullEstimateT

findAllByRequestId :: Transactionable m => Id SearchRequest -> m [Estimate]
findAllByRequestId searchRequestId = Esq.buildDType $ do
  fullEstimateTs <- Esq.findAll' $ do
    (estimate :& mbTripTerms) <- from fullEstimateTable
    where_ $ estimate ^. EstimateRequestId ==. val (toKey searchRequestId)
    pure (estimate, mbTripTerms)
  mapM buildFullEstimate fullEstimateTs

updateQuote ::
  Id Estimate ->
  Id Quote ->
  SqlDB ()
updateQuote estimateId quoteId = do
  now <- getCurrentTime
  Esq.update $ \tbl -> do
    set
      tbl
      [ EstimateUpdatedAt =. val now,
        EstimateAutoAssignQuoteId =. val (Just quoteId.getId)
      ]
    where_ $ tbl ^. EstimateId ==. val (getId estimateId)

updateStatus ::
  Id Estimate ->
  Maybe EstimateStatus ->
  SqlDB ()
updateStatus estimateId status_ = do
  now <- getCurrentTime
  Esq.update $ \tbl -> do
    set
      tbl
      [ EstimateUpdatedAt =. val now,
        EstimateStatus =. val status_
      ]
    where_ $ tbl ^. EstimateId ==. val (getId estimateId)

updateAutoAssign ::
  Id Estimate ->
  Bool ->
  Bool ->
  SqlDB ()
updateAutoAssign estimateId autoAssignedEnabled autoAssignedEnabledV2 = do
  Esq.update $ \tbl -> do
    set
      tbl
      [ EstimateAutoAssignEnabled =. val autoAssignedEnabled,
        EstimateAutoAssignEnabledV2 =. val autoAssignedEnabledV2
      ]
    where_ $ tbl ^. EstimateId ==. val (getId estimateId)

getStatus ::
  (Transactionable m) =>
  Id Estimate ->
  m (Maybe (Maybe EstimateStatus))
getStatus estimateId = do
  findOne $ do
    estimateT <- from $ table @EstimateT
    where_ $
      estimateT ^. EstimateId ==. val (getId estimateId)
    return $ estimateT ^. EstimateStatus

updateStatusbyRequestId ::
  Id SearchRequest ->
  Maybe EstimateStatus ->
  SqlDB ()
updateStatusbyRequestId searchId status_ = do
  now <- getCurrentTime
  Esq.update $ \tbl -> do
    set
      tbl
      [ EstimateUpdatedAt =. val now,
        EstimateStatus =. val status_
      ]
    where_ $ tbl ^. EstimateRequestId ==. val (toKey searchId)

findOneEstimateByRequestId :: Transactionable m => Id SearchRequest -> m (Maybe Estimate)
findOneEstimateByRequestId searchId = Esq.buildDType $ do
  mbFullEstimateT <- Esq.findOne' $ do
    (estimate :& mbTripTerms) <- from fullEstimateTable
    where_ $ estimate ^. EstimateRequestId ==. val (toKey searchId)
    limit 1
    pure (estimate, mbTripTerms)
  mapM buildFullEstimate mbFullEstimateT
