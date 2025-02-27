{-
 Copyright 2022-23, Juspay India Pvt Ltd

 This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License

 as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version. This program

 is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY

 or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License for more details. You should have received a copy of

 the GNU Affero General Public License along with this program. If not, see <https://www.gnu.org/licenses/>.
-}

module Environment where

import Kernel.External.Encryption (EncTools)
import Kernel.Prelude
import Kernel.Storage.Esqueleto.Config
import Kernel.Storage.Hedis (HedisCfg, HedisEnv, connectHedis, disconnectHedis)
import qualified Kernel.Tools.Metrics.CoreMetrics as Metrics
import Kernel.Types.Common
import Kernel.Types.Flow
import Kernel.Types.SlidingWindowLimiter
import Kernel.Utils.App (getPodName)
import Kernel.Utils.Dhall (FromDhall)
import Kernel.Utils.IOLogging
import Kernel.Utils.Servant.Client
import Kernel.Utils.Shutdown
import Tools.Client
import Tools.Metrics

data AppCfg = AppCfg
  { esqDBCfg :: EsqDBConfig,
    esqDBReplicaCfg :: EsqDBConfig,
    hedisCfg :: HedisCfg,
    port :: Int,
    migrationPath :: Maybe FilePath,
    autoMigrate :: Bool,
    loggerConfig :: LoggerConfig,
    graceTerminationPeriod :: Seconds,
    apiRateLimitOptions :: APIRateLimitOptions,
    httpClientOptions :: HttpClientOptions,
    shortDurationRetryCfg :: RetryCfg,
    longDurationRetryCfg :: RetryCfg,
    authTokenCacheExpiry :: Seconds,
    registrationTokenExpiry :: Days,
    encTools :: EncTools,
    exotelToken :: Text,
    dataServers :: [DataServer]
  }
  deriving (Generic, FromDhall)

data AppEnv = AppEnv
  { esqDBEnv :: EsqDBEnv,
    esqDBReplicaEnv :: EsqDBEnv,
    hedisEnv :: HedisEnv,
    port :: Int,
    loggerConfig :: LoggerConfig,
    loggerEnv :: LoggerEnv,
    graceTerminationPeriod :: Seconds,
    apiRateLimitOptions :: APIRateLimitOptions,
    httpClientOptions :: HttpClientOptions,
    shortDurationRetryCfg :: RetryCfg,
    longDurationRetryCfg :: RetryCfg,
    authTokenCacheExpiry :: Seconds,
    registrationTokenExpiry :: Days,
    encTools :: EncTools,
    coreMetrics :: Metrics.CoreMetricsContainer,
    isShuttingDown :: Shutdown,
    authTokenCacheKeyPrefix :: Text,
    exotelToken :: Text,
    dataServers :: [DataServer]
  }
  deriving (Generic)

buildAppEnv :: Text -> AppCfg -> IO AppEnv
buildAppEnv authTokenCacheKeyPrefix AppCfg {..} = do
  podName <- getPodName
  loggerEnv <- prepareLoggerEnv loggerConfig podName
  esqDBEnv <- prepareEsqDBEnv esqDBCfg loggerEnv
  esqDBReplicaEnv <- prepareEsqDBEnv esqDBReplicaCfg loggerEnv
  coreMetrics <- registerCoreMetricsContainer
  let modifierFunc = ("dashboard:" <>)
  hedisEnv <- connectHedis hedisCfg modifierFunc
  isShuttingDown <- mkShutdown
  return $ AppEnv {..}

releaseAppEnv :: AppEnv -> IO ()
releaseAppEnv AppEnv {..} = do
  releaseLoggerEnv loggerEnv
  disconnectHedis hedisEnv

type FlowHandler = FlowHandlerR AppEnv

type FlowServer api = FlowServerR AppEnv api

type Flow = FlowR AppEnv
