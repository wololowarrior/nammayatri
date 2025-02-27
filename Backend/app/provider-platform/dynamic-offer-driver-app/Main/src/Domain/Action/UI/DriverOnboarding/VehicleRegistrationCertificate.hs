{-
 Copyright 2022-23, Juspay India Pvt Ltd

 This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License

 as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version. This program

 is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY

 or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License for more details. You should have received a copy of

 the GNU Affero General Public License along with this program. If not, see <https://www.gnu.org/licenses/>.
-}
{-# LANGUAGE ApplicativeDo #-}
{-# LANGUAGE UndecidableInstances #-}

module Domain.Action.UI.DriverOnboarding.VehicleRegistrationCertificate
  ( DriverRCReq (..),
    DriverRCRes,
    verifyRC,
    onVerifyRC,
    convertUTCTimetoDate,
  )
where

import AWS.S3 as S3
import Control.Applicative ((<|>))
import Data.Text as T hiding (length, null)
import qualified Data.Time as DT
import qualified Domain.Types.DriverOnboarding.DriverRCAssociation as Domain
import Domain.Types.DriverOnboarding.Error
import qualified Domain.Types.DriverOnboarding.IdfyVerification as Domain
import qualified Domain.Types.DriverOnboarding.Image as Image
import qualified Domain.Types.DriverOnboarding.VehicleRegistrationCertificate as Domain
import qualified Domain.Types.Merchant as DM
import qualified Domain.Types.OnboardingDocumentConfig as ODC
import qualified Domain.Types.Person as Person
import Environment
import Kernel.External.Encryption
import qualified Kernel.External.Verification.Interface.Idfy as Idfy
import Kernel.Prelude
import Kernel.Storage.Esqueleto hiding (isNothing)
import Kernel.Types.APISuccess
import Kernel.Types.Error
import Kernel.Types.Id
import Kernel.Types.Predicate
import Kernel.Utils.Common
import Kernel.Utils.Predicates
import Kernel.Utils.Validation
import SharedLogic.DriverOnboarding
import qualified Storage.CachedQueries.DriverInformation as DriverInfo
import Storage.CachedQueries.Merchant.TransporterConfig as QTC
import qualified Storage.CachedQueries.OnboardingDocumentConfig as SCO
import qualified Storage.Queries.DriverOnboarding.DriverRCAssociation as DAQuery
import qualified Storage.Queries.DriverOnboarding.IdfyVerification as IVQuery
import qualified Storage.Queries.DriverOnboarding.Image as ImageQuery
import qualified Storage.Queries.DriverOnboarding.OperatingCity as QCity
import qualified Storage.Queries.DriverOnboarding.VehicleRegistrationCertificate as RCQuery
import qualified Storage.Queries.Person as Person
import Tools.Error
import qualified Tools.Verification as Verification

data DriverRCReq = DriverRCReq
  { vehicleRegistrationCertNumber :: Text,
    imageId :: Id Image.Image,
    operatingCity :: Text,
    dateOfRegistration :: Maybe UTCTime
  }
  deriving (Generic, ToSchema, ToJSON, FromJSON)

type DriverRCRes = APISuccess

validateDriverRCReq :: Validate DriverRCReq
validateDriverRCReq DriverRCReq {..} =
  sequenceA_
    [validateField "vehicleRegistrationCertNumber" vehicleRegistrationCertNumber certNum]
  where
    certNum = LengthInRange 5 12 `And` ("KA" <> star (latinUC \/ digit \/ ","))

verifyRC ::
  Bool ->
  Maybe DM.Merchant ->
  Id Person.Person ->
  DriverRCReq ->
  Flow DriverRCRes
verifyRC isDashboard mbMerchant personId req@DriverRCReq {..} = do
  runRequestValidation validateDriverRCReq req
  person <- Person.findById personId >>= fromMaybeM (PersonNotFound personId.getId)
  driverInfo <- DriverInfo.findById (cast personId) >>= fromMaybeM (PersonNotFound personId.getId)
  when driverInfo.blocked $ throwError DriverAccountBlocked
  whenJust mbMerchant $ \merchant -> do
    -- merchant access checking
    unless (merchant.id == person.merchantId) $ throwError (PersonNotFound personId.getId)
  operatingCity' <- case mbMerchant of
    Just merchant -> QCity.findEnabledCityByMerchantIdAndName merchant.id $ T.toLower req.operatingCity
    Nothing -> QCity.findEnabledCityByName $ T.toLower req.operatingCity
  when (null operatingCity') $
    throwError $ InvalidOperatingCity req.operatingCity
  transporterConfig <- QTC.findByMerchantId person.merchantId >>= fromMaybeM (TransporterConfigNotFound person.merchantId.getId)
  onboardingDocumentConfig <- SCO.findByMerchantIdAndDocumentType person.merchantId ODC.RC >>= fromMaybeM (OnboardingDocumentConfigNotFound person.merchantId.getId (show ODC.RC))
  when
    ( isNothing dateOfRegistration && onboardingDocumentConfig.checkExtraction
        && (not isDashboard || transporterConfig.checkImageExtractionForDashboard)
    )
    $ do
      image <- getImage imageId
      resp <-
        Verification.extractRCImage person.merchantId $
          Verification.ExtractImageReq {image1 = image, image2 = Nothing}
      case resp.extractedRC of
        Just extractedRC -> do
          let extractRCNumber = removeSpaceAndDash <$> extractedRC.rcNumber
          let rcNumber = removeSpaceAndDash <$> Just vehicleRegistrationCertNumber
          -- disable this check for debugging with mock-idfy
          unless (extractRCNumber == rcNumber) $
            throwImageError imageId $ ImageDocumentNumberMismatch (maybe "null" maskText extractRCNumber) (maybe "null" maskText rcNumber)
        Nothing -> throwImageError imageId ImageExtractionFailed

  now <- getCurrentTime
  mDriverAssociation <- DAQuery.getActiveAssociationByDriver personId

  case mDriverAssociation of
    Just driverAssociaion -> do
      driverRC <- RCQuery.findById driverAssociaion.rcId >>= fromMaybeM (InvalidRequest "Missing RC entry")
      rcNumber <- decrypt driverRC.certificateNumber
      unless (rcNumber == vehicleRegistrationCertNumber) $ throwImageError imageId DriverAlreadyLinked
      unless (driverRC.fitnessExpiry < now) $ throwImageError imageId RCAlreadyUpdated -- RC not expired
      verifyRCFlow person onboardingDocumentConfig.checkExtraction vehicleRegistrationCertNumber imageId dateOfRegistration
    Nothing -> do
      mVehicleRC <- RCQuery.findLastVehicleRC vehicleRegistrationCertNumber
      case mVehicleRC of
        Just vehicleRC -> do
          mRCAssociation <- DAQuery.getActiveAssociationByRC vehicleRC.id
          when (isJust mRCAssociation) $ throwImageError imageId RCAlreadyLinked
          verifyRCFlow person onboardingDocumentConfig.checkExtraction vehicleRegistrationCertNumber imageId dateOfRegistration
        Nothing -> do
          verifyRCFlow person onboardingDocumentConfig.checkExtraction vehicleRegistrationCertNumber imageId dateOfRegistration

  return Success
  where
    getImage :: Id Image.Image -> Flow Text
    getImage imageId_ = do
      imageMetadata <- ImageQuery.findById imageId_ >>= fromMaybeM (ImageNotFound imageId_.getId)
      unless (imageMetadata.isValid) $ throwError (ImageNotValid imageId_.getId)
      unless (imageMetadata.personId == personId) $ throwError (ImageNotFound imageId_.getId)
      unless (imageMetadata.imageType == Image.VehicleRegistrationCertificate) $
        throwError (ImageInvalidType (show Image.VehicleRegistrationCertificate) (show imageMetadata.imageType))
      S3.get $ T.unpack imageMetadata.s3Path

verifyRCFlow :: Person.Person -> Bool -> Text -> Id Image.Image -> Maybe UTCTime -> Flow ()
verifyRCFlow person imageExtraction rcNumber imageId dateOfRegistration = do
  now <- getCurrentTime
  encryptedRC <- encrypt rcNumber
  let imageExtractionValidation =
        if isNothing dateOfRegistration && imageExtraction
          then Domain.Success
          else Domain.Skipped
  verifyRes <-
    Verification.verifyRCAsync person.merchantId $
      Verification.VerifyRCAsyncReq {rcNumber}
  idfyVerificationEntity <- mkIdfyVerificationEntity verifyRes.requestId now imageExtractionValidation encryptedRC
  runTransaction $ IVQuery.create idfyVerificationEntity
  where
    mkIdfyVerificationEntity requestId now imageExtractionValidation encryptedRC = do
      id <- generateGUID
      return $
        Domain.IdfyVerification
          { id,
            driverId = person.id,
            documentImageId1 = imageId,
            documentImageId2 = Nothing,
            requestId,
            docType = Image.VehicleRegistrationCertificate,
            documentNumber = encryptedRC,
            imageExtractionValidation = imageExtractionValidation,
            issueDateOnDoc = dateOfRegistration,
            status = "pending",
            idfyResponse = Nothing,
            createdAt = now,
            updatedAt = now
          }

onVerifyRC :: Domain.IdfyVerification -> Idfy.RCVerificationOutput -> Flow AckResponse
onVerifyRC verificationReq output = do
  person <- Person.findById verificationReq.driverId >>= fromMaybeM (PersonNotFound verificationReq.driverId.getId)

  if verificationReq.imageExtractionValidation == Domain.Skipped
    && isJust verificationReq.issueDateOnDoc
    && ( (convertUTCTimetoDate <$> verificationReq.issueDateOnDoc)
           /= (convertUTCTimetoDate <$> (convertTextToUTC output.registration_date))
       )
    then runTransaction $ IVQuery.updateExtractValidationStatus verificationReq.requestId Domain.Failed >> return Ack
    else do
      now <- getCurrentTime
      id <- generateGUID
      rCConfigs <- SCO.findByMerchantIdAndDocumentType person.merchantId ODC.RC >>= fromMaybeM (OnboardingDocumentConfigNotFound person.merchantId.getId (show ODC.RC))
      rCInsuranceConfigs <- SCO.findByMerchantIdAndDocumentType person.merchantId ODC.RCInsurance >>= fromMaybeM (OnboardingDocumentConfigNotFound person.merchantId.getId (show ODC.RCInsurance))
      mEncryptedRC <- encrypt `mapM` output.registration_number
      let mbFitnessEpiry = convertTextToUTC output.fitness_upto
      let mVehicleRC = createRC rCConfigs rCInsuranceConfigs output id verificationReq.documentImageId1 now <$> mEncryptedRC <*> mbFitnessEpiry

      case mVehicleRC of
        Just vehicleRC -> do
          runTransaction $ RCQuery.upsert vehicleRC

          -- linking to driver
          rc <- RCQuery.findByRCAndExpiry vehicleRC.certificateNumber vehicleRC.fitnessExpiry >>= fromMaybeM (InternalError "RC not found")
          mRCAssociation <- DAQuery.getActiveAssociationByRC rc.id
          when (isNothing mRCAssociation) $ do
            currAssoc <- DAQuery.getActiveAssociationByDriver person.id
            when (isJust currAssoc) $ do runTransaction $ DAQuery.endAssociation person.id
            driverRCAssoc <- mkAssociation person.id rc.id
            runTransaction $ DAQuery.create driverRCAssoc
          return Ack
        _ -> return Ack
  where
    mkAssociation driverId rcId = do
      id <- generateGUID
      now <- getCurrentTime
      return $
        Domain.DriverRCAssociation
          { id,
            driverId,
            rcId,
            associatedOn = now,
            associatedTill = convertTextToUTC (Just "2099-12-12"),
            consent = True,
            consentTimestamp = now
          }

createRC ::
  ODC.OnboardingDocumentConfig ->
  ODC.OnboardingDocumentConfig ->
  Idfy.RCVerificationOutput ->
  Id Domain.VehicleRegistrationCertificate ->
  Id Image.Image ->
  UTCTime ->
  EncryptedHashedField 'AsEncrypted Text ->
  UTCTime ->
  Domain.VehicleRegistrationCertificate
createRC rcconfigs rcInsurenceConfigs output id imageId now edl expiry = do
  let insuranceValidity = convertTextToUTC output.insurance_validity
  let vehicleClass = output.vehicle_class
  let vehicleCapacity = maybe (Just 3) (readMaybe . T.unpack) output.seating_capacity
  let verificationStatus = validateRCStatus rcconfigs rcInsurenceConfigs expiry insuranceValidity vehicleClass now vehicleCapacity
  Domain.VehicleRegistrationCertificate
    { id,
      documentImageId = imageId,
      certificateNumber = edl,
      fitnessExpiry = expiry,
      permitExpiry = convertTextToUTC output.permit_validity_upto,
      pucExpiry = convertTextToUTC output.puc_validity_upto,
      vehicleClass,
      vehicleManufacturer = output.manufacturer <|> output.manufacturer_model,
      vehicleCapacity,
      vehicleModel = output.m_y_manufacturing <|> output.manufacturer_model,
      vehicleColor = output.color <|> output.colour,
      vehicleEnergyType = output.fuel_type,
      insuranceValidity,
      verificationStatus,
      failedRules = [],
      createdAt = now,
      updatedAt = now
    }

validateRCStatus :: ODC.OnboardingDocumentConfig -> ODC.OnboardingDocumentConfig -> UTCTime -> Maybe UTCTime -> Maybe Text -> UTCTime -> Maybe Int -> Domain.VerificationStatus
validateRCStatus rcconfigs rcInsurenceConfigs expiry insuranceValidity cov now capacity = do
  let validCOVs = rcconfigs.validVehicleClasses
  let validCOVsCheck = rcconfigs.vehicleClassCheckType
  let isCOVValid = (length rcconfigs.validVehicleClasses == 0) || maybe False (isValidCOVRC capacity validCOVs validCOVsCheck) cov
  let validInsurance = (not rcInsurenceConfigs.checkExpiry) || maybe False (now <) insuranceValidity
  if ((not rcconfigs.checkExpiry) || now < expiry) && isCOVValid && validInsurance then Domain.VALID else Domain.INVALID

convertTextToUTC :: Maybe Text -> Maybe UTCTime
convertTextToUTC a = do
  a_ <- a
  DT.parseTimeM True DT.defaultTimeLocale "%Y-%-m-%-d" $ T.unpack a_

isValidCOVRC :: Maybe Int -> [Text] -> ODC.VehicleClassCheckType -> Text -> Bool
isValidCOVRC capacity validCOVs validCOVsCheck cov =
  checkForClass && classSpecificChecks cov capacity
  where
    checkForClass = foldr' (\x acc -> classCheckFunction validCOVsCheck (T.toUpper x) (T.toUpper cov) || acc) False validCOVs

classSpecificChecks :: Text -> Maybe Int -> Bool
classSpecificChecks "Passenger" capacity = capacity == Just 4
classSpecificChecks _ _ = True

classCheckFunction :: ODC.VehicleClassCheckType -> Text -> Text -> Bool
classCheckFunction validCOVsCheck =
  case validCOVsCheck of
    ODC.Infix -> T.isInfixOf
    ODC.Prefix -> T.isPrefixOf
    ODC.Suffix -> T.isSuffixOf

removeSpaceAndDash :: Text -> Text
removeSpaceAndDash = T.replace "-" "" . T.replace " " ""

convertUTCTimetoDate :: UTCTime -> Text
convertUTCTimetoDate utctime = T.pack (DT.formatTime DT.defaultTimeLocale "%d/%m/%Y" utctime)
