#include <Trade/Trade.mqh>

#property strict
#property version "1.03"
#property description "KOUCHA GOLD KIWAMI SURVIVAL TICK"

#define COPYBUFFER_MEMO_MAX 512
#define COPYBUFFER_MEMO_VALUES 80
#define COPYBUFFER_BREAKDOWN_MAX 256

input string TargetSymbol = "GOLD";
input ulong MagicNumber = 2026052401;
input double BaseLot = 0.01;
input bool UseFixedLotOnly = true;
input bool AllowMartingale = false;

input int MaxTotalPositions = 3;
input int MaxBuyPositions = 2;
input int MaxSellPositions = 2;
input int MaxNetPositions = 1;

input bool UseBalanceBasedPositionLimit = true;
input double BalanceTier1 = 20000.0;
input double BalanceTier2 = 30000.0;
input double BalanceTier3 = 50000.0;
input int Tier1MaxTotalPositions = 3;
input int Tier1MaxNetPositions = 1;
input int Tier2MaxTotalPositions = 3;
input int Tier2MaxNetPositions = 2;
input int Tier3MaxTotalPositions = 4;
input int Tier3MaxNetPositions = 2;

input int TickWindowSeconds = 10;
input double EntryScoreThreshold = 82.0;
input double AddPositionScoreThreshold = 86.0;
input double DefenseHedgeScoreThreshold = 82.0;
input double MinimumScoreDifference = 15.0;
input int MinimumTicksInWindow = 5;
input double MinimumTickWindowMove = 0.10;
input double MaximumTickWindowMove = 2.50;
input bool UseM1ShortTrendConfirmation = true;

input double MaxSpreadPrice = 0.80;

input int EntryCooldownSeconds = 180;
input bool UseOneTradeActionPerTick = true;
input int AfterCloseCooldownSeconds = 180;
input int OppositeDirectionCooldownSeconds = 300;
input bool BlockOppositeEntryWhilePositionExists = true;
input bool RequireFlatBeforeOppositeEntry = true;
input int SameDirectionReentryCooldownSeconds = 180;
input int MarketClosedRetryCooldownSeconds = 300;

input bool UseSinglePositionContraryEarlyExit = false;
input double SingleEarlyExitSoftLossYen = 1200.0;
input double SingleEarlyExitHardLossYen = 1800.0;
input double SingleEarlyExitOppositeTickScore = 82.0;
input double SingleEarlyExitOppositeScoreDiff = 15.0;
input bool SingleEarlyExitRequireMaSlopeReverse = true;
input bool SingleEarlyExitRequireTrendMainReverse = true;
input bool SingleEarlyExitOnlyWhenNoHedge = true;
input bool SingleEarlyExitOnlySinglePosition = true;
input int SingleEarlyExitMinHoldSeconds = 300;
input bool SingleEarlyExitBlockIfNewsActive = false;
input bool SingleEarlyExitAllowDuringHardStopRisk = true;
input bool UseSingleEarlyExitPostCooldown = true;
input int SingleEarlyExitPostCooldownMinutes = 120;
input bool BlockSameDirectionReentryAfterSingleEarlyExit = true;
input bool BlockAllNewEntryAfterSingleEarlyExit = false;
input int MaxSingleEarlyExitPerDay = 1;
input int MaxSingleEarlyExitPerSegment = 2;
input bool SingleEarlyExitRequireM5CloseConfirmation = true;
input int SingleEarlyExitConfirmBars = 2;
input bool SingleEarlyExitRequireHardTrendReverseToo = true;
input bool SingleEarlyExitStricterWhenVixCaution = true;
input double SingleEarlyExitVixCautionScoreAdd = 3.0;
input double SingleEarlyExitVixCautionLossAddYen = 300.0;

input bool UseLargeCandleEntryCautionForSinglePosition = false;
input double LargeCandleEntryScoreAddForSingle = 5.0;
input bool BlockEntryOnLargeCandleAgainstMaTrend = false;

input bool UseHardStopOriginEntryBlock = true;
input bool BlockPureTickEntryAfterLargeCandleChase = true;
input int LargeCandleChaseBlockSeconds = 900;
input bool LargeCandleChaseOnlyInitialEntry = true;
input bool LargeCandleChaseRequireSinglePositionFlat = true;
input bool LargeCandleChaseRequireNoPullback = true;
input bool LargeCandleChaseRequireNoStructureConfirmation = true;
input bool LargeCandleChaseBlockOnlyWhenTrendWeakOrMixed = true;
input double LargeCandleChaseMinEntryScoreBuffer = 5.0;

input bool UseSinglePositionReactiveDefenseHedge = true;
input double ReactiveHedgeTriggerLossYen = 2800.0;
input double ReactiveHedgeOppositeTickScore = 90.0;
input double ReactiveHedgeOppositeScoreDiff = 28.0;
input bool ReactiveHedgeRequireMaSlopeReverse = true;
input bool ReactiveHedgeRequireTrendMainReverse = true;
input bool ReactiveHedgeRequireM5CloseConfirmation = true;
input int ReactiveHedgeConfirmBars = 2;
input bool ReactiveHedgeOnlySinglePosition = true;
input bool ReactiveHedgeOnlyWhenNoHedge = true;
input int MaxReactiveDefenseHedgePerDay = 1;
input int MaxReactiveDefenseHedgePerSegment = 1;
input bool BlockNewEntryDuringReactiveDefenseHedge = true;
input double ReactiveHedgeBasketCloseTargetYen = -1200.0;
input double ReactiveHedgeBasketMaxLossYen = -3500.0;
input int ReactiveHedgeMaxHoldMinutes = 90;
input bool ReactiveHedgeCloseAllAtMaxHold = true;

input bool UseHardStopOriginEntryTrace = true;
input bool TraceAllFinalEntryDecisions = true;
input bool TraceOnlyNearHardStopOrigin = false;
input int TraceEntryDecisionWindowMinutesBeforeHardStop = 180;
input bool TraceReactiveHedgeEligibility = true;
input bool TraceEntryBlockEligibility = true;
input int MaxEntryDecisionTraceRowsPerDay = 200;
input int MaxReactiveHedgeTraceRowsPerDay = 200;
input bool UseBacktestFastCompareMode = true;
input bool UseBacktestDiagnosticMode = false;
input bool EnableEntryDecisionTrace = false;
input bool EnableReactiveHedgeEligibilityTrace = false;
input bool EnableRejectedEntryDetailLog = false;
input bool EnableShadowEntryCandidateLog = false;
input bool EnableTickLevelTraceLog = false;
input bool EnableHeavyPrintLog = false;
input bool EnableTradeEventLog = true;
input bool EnableRunStatusLog = true;
input bool EnablePreflightValidationLog = true;
input bool EnableEntryOpportunityAuditSummary = true;
input bool EnableSegmentSummaryLog = true;
input bool EnableAggregateSummaryLog = true;
input bool TraceOnlyAroundTargetEvent = true;
input int TraceWindowMinutesBeforeTargetEvent = 120;
input int TraceWindowMinutesAfterTargetEvent = 30;
input string EntryDecisionTraceFileName = "KOUCHA_GOLD_ENTRY_DECISION_TRACE.csv";
input string ReactiveHedgeEligibilityTraceFileName = "KOUCHA_GOLD_REACTIVE_HEDGE_ELIGIBILITY_TRACE.csv";

input bool UsePerformanceCache = false;
input int DxyVixCacheSeconds = 10;
input int GoldLocationCacheSeconds = 30;
input int TechnicalDangerCacheSeconds = 30;
input bool UpdateHigherTfOnlyOnNewBar = true;
input bool UpdateMaStructureOnlyOnNewBar = true;
input bool UpdateGoldLocationOnlyOnNewM5Bar = true;
input bool UpdateTechnicalDangerOnlyOnNewM5Bar = true;
input bool MinimizeCommentInBacktest = true;
input bool CountPerformanceStats = true;
input string BacktestPatternName = "";
input string PerformanceStatsFileName = "KOUCHA_GOLD_PERFORMANCE_STATS.csv";
input bool UseSafePerformanceOptimization = true;
input bool UseSameTickCopyBufferMemo = true;
input bool UseSameTickPositionScanCache = true;
input bool UseDailyPlIncrementalCache = true;
input bool UseDxyVixOnlyCache = true;
input int DxyVixOnlyCacheSeconds = 5;
input bool UseNewsCsvReadCache = true;
input bool DisableMaGoldTechnicalCacheForSafety = true;
input bool KeepEntryCriticalFiltersTickExact = true;
input string CopyBufferBreakdownFileName = "KOUCHA_GOLD_COPYBUFFER_BREAKDOWN.csv";

input bool UseAddPosition = true;
input double AddPositionDistanceDollars = 4.0;
input int MaxAddPositionsPerDirection = 1;
input bool AddPositionMustUseFixedLot = true;
input bool UseOneTimeSameLotPlannedAdd = false;
input double PlannedAddTriggerLossYen = 1800.0;
input double PlannedAddMaxLossYen = 3200.0;
input double PlannedAddSameDirectionTickScore = 82.0;
input double PlannedAddMinScoreDiff = 15.0;
input bool PlannedAddRequireTrendStillValid = true;
input bool PlannedAddRequireMaStructureStillValid = true;
input bool PlannedAddRequireDxyVixSafe = true;
input bool PlannedAddBlockNearNews = true;
input bool PlannedAddOnlyBeforeDefenseHedge = true;
input bool PlannedAddOnlySingleOriginalPosition = true;
input int MaxPlannedAddPerBasket = 1;
input int MaxPlannedAddPerDay = 1;
input bool PlannedAddUseSameLotOnly = true;
input bool BlockFurtherAddAfterPlannedAdd = true;

input bool UseMarketClosePreControl = false;
input int MarketClosePreBlockMinutes = 120;
input bool MarketClosePreBlockNewEntry = true;
input bool MarketClosePrePrioritizeExistingCloseIntent = true;
input double MarketClosePreBasketCloseNearYen = 300.0;
input double MarketClosePreRecoveryCloseNearYen = 300.0;
input double MarketClosePreHteNearYen = 300.0;
input bool MarketClosePreAllowLossCutOnlyIfAlreadyEligible = true;
input bool MarketClosePreOnlyWhenPositionsExist = true;
input bool MarketClosePreLogOnlyMode = false;
input bool MarketClosePreBlockNewBasketOnly = true;
input bool MarketClosePreAllowExistingBasketManagement = true;
input bool MarketClosePreDoNotCreateNewLossCut = true;

input bool UseDefenseHedge = true;
input bool DefenseHedgeOnlyInDefenseMode = true;
input int MaxDefenseHedgePositions = 1;

input bool UseBasketClose = true;
input int BasketMinPositions = 1;
input double BasketProfitYen = 400.0;
input double BasketProfitBalancePercent = 1.0;
input bool UseBalanceBasedBasketProfit = true;
input bool UseBasketCloseByEitherCondition = true;
input double Tier1BasketProfitYen = 300.0;
input double Tier2BasketProfitYen = 400.0;
input double Tier3BasketProfitYen = 500.0;
input bool UseBasketCloseHistoricalTimeAdaptive = false;
input double BasketCloseHighRiskMultiplier = 0.85;
input double BasketCloseCautionMultiplier = 0.90;
input double BasketCloseClearMultiplier = 1.20;
input double BasketCloseQuietMultiplier = 1.00;
input bool UseBasketRecoveryClose = true;
input double BasketRecoveryProfitYen = 100.0;
input bool CloseBasketWhenNetProfitPositiveAfterHedge = true;
input bool UseBasketRecoveryLossCut = true;
input double BasketRecoveryAcceptLossYen = 1500.0;
input bool CloseHedgedBasketWhenLossImproves = true;
input bool UseBasketRecoveryLossCutMinHold = true;
input int BasketRecoveryLossCutMinHoldMinutes = 15;
input bool UseBasketRecoveryImprovementCheck = true;
input double BasketRecoveryRequiredImprovementYen = 400.0;
input bool UseWorstBasketAfterHedgeAsReference = true;
input bool CountRecoveryLossCutAsConsecutiveLoss = true;
input double RecoveryLossCutConsecutiveLossMinYen = 1200.0;
input bool UseHedgedBasketTimeExit = true;
input int HedgedBasketMaxHoldMinutes = 180;
input double HedgedBasketTimeExitAcceptLossYen = 1800.0;

input bool UsePostDefenseHedgeExitControl = false;
input int PostHedgeMinHoldMinutes = 15;
input int PostHedgeSoftMaxHoldMinutes = 90;
input int PostHedgeHardMaxHoldMinutes = 180;
input double PostHedgeGoodEnoughCloseYen = -1200.0;
input double PostHedgeMaxLossCloseYen = -3500.0;
input double PostHedgeNoImproveCloseYen = -2800.0;
input double PostHedgeRequiredImprovementYen = 800.0;
input bool UseWorstBasketAfterHedgeReferenceForPostExit = true;
input bool UsePostHedgeAgainstStrongTrendFastExit = true;
input int PostHedgeAgainstStrongTrendMaxHoldMinutes = 60;
input double PostHedgeAgainstStrongTrendCloseYen = -1800.0;
input bool UsePostHedgeMarketClosedRetry = true;
input int PostHedgeMarketClosedRetrySeconds = 60;
input int PostHedgeMarketClosedMaxRetryMinutes = 240;
input bool BlockNewEntryWhilePostHedgeExitPending = true;

input bool UseGlobalMarketClosedRetry = false;
input int GlobalMarketClosedRetrySeconds = 60;
input int GlobalMarketClosedMaxRetryMinutes = 720;
input bool BlockNewEntryWhileCloseRetryPending = true;
input bool RetryHardStopClose = true;
input bool RetryBasketClose = true;
input bool RetryBasketRecoveryClose = true;
input bool RetryBasketRecoveryLossCutClose = true;
input bool RetryHedgedBasketTimeExitClose = true;
input bool RetryDefenseHedgeExitClose = true;
input bool RetryManualForceClose = true;

input bool UsePostHedgeSelectiveExitOnly = true;
input bool PostHedgeExitOnlyAgainstStrongTrend = true;
input bool PostHedgeDetectBuyHedgeInStrongBearish = true;
input bool PostHedgeDetectSellHedgeInStrongBullish = true;
input int PostHedgeSelectiveMinHoldMinutes = 60;
input int PostHedgeSelectiveSoftMaxHoldMinutes = 180;
input int PostHedgeSelectiveHardMaxHoldMinutes = 360;
input double PostHedgeSelectiveGoodEnoughCloseYen = -900.0;
input double PostHedgeSelectiveMaxLossCloseYen = -4200.0;
input double PostHedgeSelectiveNoImproveCloseYen = -3500.0;
input double PostHedgeSelectiveRequiredImprovementYen = 1000.0;
input bool PostHedgeSelectiveUseWorstAfterHedgeReference = true;
input int MaxPostHedgeLossClosePerDay = 1;
input int MaxPostHedgeLossClosePerSegment = 2;
input bool PostHedgeDoNotCloseIfNearBasketRecovery = true;
input double PostHedgeNearRecoveryDistanceYen = 500.0;
input bool PostHedgeDoNotCloseIfBasketImproving = true;
input int PostHedgeImprovingLookbackMinutes = 30;
input double PostHedgeImprovingMinYen = 400.0;

input bool UsePostHedgeNewEntryFreeze = false;
input bool EnablePostHedgeTimeExitPriorityDiagnostic = false;
input bool EnablePostHedgeDryRunDiagnostic = false;
input bool EnableHardStopPrecursorDiagnostic = false;
input bool EnablePrioritySnapshotDiagnostic = false;
input bool EnableCorrectedLeadTimeDryRunDiagnostic = false;
input bool EnablePreHardStopCloseableWindowDiagnostic = false;
input bool EnableRuntimeEvaluationStageAudit = false;
input int HardStopPrecursorSnapshotIntervalMinutes = 5;
input bool UseB2M5TickVolLargeAdverseExit = false;
input bool UseB2G5HteLossBandGuard = true;
input double B2G5HteLossBandYen = -1800.0;
input bool B2ExitDryRunOnly = false;
input bool UseCW8OutsideHteBandExit = false;
input double CW8HteLossBandYen = -1800.0;
input bool CW8ExitDryRunOnly = false;
input bool UsePreHardStopS2StrictGuardExit = false;
input double S2HteLossBandYen = -1800.0;
input double S2MinWeakImproveYen = 500.0;
input bool S2RequireRecentWorstUpdate = true;
input bool S2ExitDryRunOnly = false;
input bool UseL1M5R12LargeAdverseExit = false;
input double L1M5TickVolumeRatioThreshold = 1.2;
input bool L1ExitDryRunOnly = false;
input bool EnableTA9ShadowLogging = false;
input bool EnableMultilayerShadowLogging = false;
input int MultilayerShadowLogLevel = 1;
input bool EnableEventRiskMinimalShadow = true;
input int MultilayerShadowFlushMode = 0; // 0=ON_DEINIT_OR_BASKET_END, 1=EVERY_WRITE
input int MultilayerShadowMaxRowsPerRun = 200000;
input string MultilayerShadowFilePrefix = "KOUCHA_ML_SHADOW";
input bool UsePostHedgeRecoveryFailureExit = false;
input int PostHedgeRecoveryFailureMinutes = 60;
input double PostHedgeRecoveryFailureImproveYen = 1000.0;
input bool UsePostHedgeRfHteGuard = true;
input int PostHedgeRfHteGuardLookaheadMinutes = 120;
input bool EnablePostHedgeRfReachabilityDiagnostic = false;

enum ENUM_HARDSTOP_BASIS
{
   HARDSTOP_BALANCE_PERCENT = 0,
   HARDSTOP_FIXED_YEN = 1,
   HARDSTOP_INITIAL_BALANCE_R = 2
};

input double StopNewEntryFloatingLossPercent = 8.0;
input double DefenseModeFloatingLossPercent = 4.0;
input double HardStopFloatingLossPercent = 12.0;
input ENUM_HARDSTOP_BASIS HardStopBasis = HARDSTOP_BALANCE_PERCENT;
input double HardStopFixedYen = 0.0;
input double HardStopInitialRiskPercent = 0.0;
input double HardStopRMultiplier = 1.0;
input bool UseEmergencyCloseAtHardStop = true;
input int HardStopAfterMode = 1;
input int HardStopCooldownMinutes = 240;

input double StopNewEntryMarginLevel = 1000.0;
input double DefenseModeMarginLevel = 700.0;
input double HardStopMarginLevel = 500.0;

input bool UseDailyLossStop = true;
input double DailyLossStopPercent = 12.0;
input double DailyLossStopYen = 3000.0;

input bool UseConsecutiveLossStop = true;
input int MaxConsecutiveLosses = 3;
input int ConsecutiveLossStopMinutes = 180;

input int ManualCloseStopMinutes = 30;

input bool UseTradingTimeFilter = true;
input int TradingStartHourJST = 15;
input int TradingEndHourJST = 2;
input bool AvoidEarlyMorningJST = true;

input bool AvoidLondonOpenFirstMinutes = true;
input int LondonOpenHourJST = 16;
input int LondonOpenAvoidMinutes = 15;
input bool AvoidNYOpenFirstMinutes = true;
input int NYOpenHourJST = 21;
input int NYOpenAvoidMinutes = 15;
input bool UseGoldDailyCloseFilter = true;
input int GoldDailyCloseStartHourJST = 6;
input int GoldDailyCloseStartMinuteJST = 45;
input int GoldDailyCloseEndHourJST = 8;
input int GoldDailyCloseEndMinuteJST = 10;
input bool UseFridayLateStopJST = true;
input int FridayLateStopHourJST = 23;
input int FridayLateStopMinuteJST = 30;

input bool UseManualBias = true;
input int ManualBiasMode = 0;
input bool AllowBuy = true;
input bool AllowSell = true;
input bool AutoTradeMode = true;
input bool SignalOnlyMode = false;

input bool UseDxyFilter = true;
input int DxyMode = 2;
input string DxySymbolName = "DXY";
input bool UseDxyIndicator = true;
input string DxyIndicatorName = "Free Indicators\\Dollar index";
input int DxyIndicatorBufferIndex = 0;
input ENUM_TIMEFRAMES DxyIndicatorTimeframe = PERIOD_M5;
input int DxyTrendLookbackBars = 12;
input double DxyMinTrendChange = 0.05;
input int DxyManualBias = 0;
input string DxyCsvFileName = "dxy_filter.csv";
input int DxyImpactLevel = 1;
input bool UseDxyHardBlock = true;
input int DxyDataFailMode = 1;
input bool UseDxyVolatilityBlock = true;
input int DxyVolatilityState = 0;

input bool UseVixFilter = true;
input int VixMode = 2;
input string VixSymbolName = "VIX";
input bool UseVixIndicator = true;
input string VixIndicatorName = "Free Indicators\\Synthetic VIX";
input int VixIndicatorBufferIndex = 0;
input ENUM_TIMEFRAMES VixTimeframe = PERIOD_M5;
input double VixCautionLevel = 0.50;
input double VixStopLevel = 0.80;
input double VixExtremeStopLevel = 1.20;
input bool UseVixSpikeBlock = false;
input int VixSpikeLookbackBars = 12;
input double VixSpikeChangePercent = 10.0;
input int VixDataFailMode = 1;
input string VixCsvFileName = "vix_filter.csv";

input bool UseNewsFilter = true;
input int NewsMode = 2;
input bool UseMt5EconomicCalendar = false;
input bool UseNewsCsvFallback = true;
input string NewsCsvFileName = "news_blackout.csv";
input bool BlockNewEntryDuringNews = true;
input bool BlockAddPositionDuringNews = true;
input bool BlockDefenseHedgeDuringNews = true;
input bool BlockHedgedBasketTimeExitDuringNewsShock = true;
input int NewsBlockBeforeMinutesHigh = 90;
input int NewsBlockAfterMinutesHigh = 180;
input int NewsBlockBeforeMinutesFomc = 120;
input int NewsBlockAfterMinutesFomc = 240;
input int MinutesBeforeNewsStop = 60;
input int MinutesAfterNewsStop = 60;
input bool CloseBeforeHighImpactNews = false;
input bool StopMediumImpactNews = false;
input bool StopHighImpactNews = true;
input bool UseUltraHighImpactNewsStop = true;
input int MinutesBeforeUltraHighNewsStop = 120;
input int MinutesAfterUltraHighNewsStop = 120;
input int NewsDataFailMode = 1;

input bool UseHigherTimeframeFilter = true;
input bool UseM15Filter = true;
input bool UseM30Filter = true;
input bool UseH1Filter = true;
input bool UseH4Filter = true;
input int HigherTF_EMA_Fast = 20;
input int HigherTF_EMA_Slow = 50;
input bool BlockStrongOppositeHigherTF = true;

input bool UseGoldLocationFilter = true;
input bool UseTechnicalDangerBlock = true;
input bool UseDailyPivotFilter = true;
input bool UsePreviousDayHighLowFilter = true;
input bool UseTodayHighLowFilter = true;
input bool UseH1H4SupportResistanceFilter = true;
input bool UseBreakoutDangerFilter = true;
input bool UseAtrExpansionFilter = true;
input bool UseHedgedBasketTimeExitDangerControl = true;
input double HedgedBasketDangerMaxAcceptLossYen = 1200.0;
input double HedgedBasketDangerEmergencyLossYen = 1800.0;
input int HedgedBasketDangerExtraHoldMinutes = 60;
input bool AvoidRangeMiddle = false;
input bool AvoidBuyingNearRecentHigh = true;
input bool AvoidSellingNearRecentLow = true;
input bool AvoidPreviousDayHighLowChase = true;
input bool AvoidTodayHighLowChase = false;
input bool AvoidEntryAfterSpike = true;
input bool AvoidRoundNumberEntry = true;
input int RecentHighLowLookbackBarsM5 = 48;
input double NearHighLowDistanceDollars = 1.50;
input double SpikeMoveDollars = 3.00;
input int SpikeLookbackSeconds = 60;
input double RoundNumberStepDollars = 10.0;
input double RoundNumberAvoidDistanceDollars = 1.0;
input double RangeMiddleZonePercent = 35.0;

input bool UseTrendPullbackEntry = true;
input bool RequirePullbackForEntry = true;
input ENUM_TIMEFRAMES PullbackTimeframe = PERIOD_M5;
input int PullbackLookbackBars = 48;
input double MinPullbackFromRecentHighDollars = 3.0;
input double MinPullbackFromRecentLowDollars = 3.0;
input bool UsePullbackEmaZone = true;
input int PullbackEmaFast = 20;
input int PullbackEmaSlow = 50;
input double PullbackEmaZoneDistanceDollars = 3.0;
input bool UsePullbackRsiFilter = true;
input int PullbackRsiPeriod = 14;
input double BuyRsiOverheatedLevel = 68.0;
input double SellRsiOversoldLevel = 32.0;
input double BuyRsiPullbackMax = 62.0;
input double SellRsiPullbackMin = 38.0;
input bool BlockBuyImmediatelyAfterSpikeUp = true;
input bool BlockSellImmediatelyAfterSpikeDown = true;
input int TrendSpikeLookbackSeconds = 300;
input double TrendSpikeMoveDollars = 2.0;
input bool BlockCounterTrendEntry = true;
input bool AllowCounterTrendOnlyAsDefense = true;
input bool RequireM5CandleConfirmation = true;

input bool UseMaStructureFilter = true;
input ENUM_TIMEFRAMES MaStructureTimeframe = PERIOD_M5;
input int MaFastPeriod = 20;
input int MaMiddlePeriod = 50;
input int MaLongPeriod = 200;
input double MaTouchDistanceDollars = 2.0;
input double MaTooFarDistanceDollars = 6.0;
input double MaFlatDistanceDollars = 1.0;
input bool RequireMaTrendAlignment = true;
input bool RequirePriceNearMaForPullback = true;
input bool BlockEntryWhenMaTooFar = true;
input bool BlockEntryWhenMaFlat = true;
input bool BlockBuyBelowMiddleMa = true;
input bool BlockSellAboveMiddleMa = true;
input bool UseMaCrossStateFilter = true;
input int MaCrossRecentBars = 12;
input bool BlockImmediatelyAfterMaCross = true;
input int MaCrossWaitBars = 3;
input bool UseMaSlopeFilter = true;
input int MaSlopeLookbackBars = 5;
input double MaSlopeMinDollars = 0.30;
input bool BlockBuyAgainstDownSlopeMa = true;
input bool BlockSellAgainstUpSlopeMa = true;
input bool RequireFastMaSlopeForEntry = true;
input bool RequireMiddleMaSlopeForEntry = false;
input double MaStrongSlopeDollars = 0.80;

input bool UseStructureBeforeTickEntry = true;
input bool AllowPureTickEntry = false;
input bool RequireTickScoreAfterStructure = true;
input bool UseGoldStructureFilter = true;
input bool UseAutoFibonacciContext = true;
input bool UseCandlePatternConfirmation = true;
input bool UseCandlePatternDangerFilter = true;
input bool UseStructureBasedEarlyExit = true;
input bool UsePlannedAddPositionOnly = false;
input bool UseHedgedBasketLossCompression = false;
input double EarlyExitSoftLossYen = 400.0;
input double EarlyExitMaxLossYen = 600.0;
input int MacroStructureTimeframe = PERIOD_H4;
input int StructureConfirmTimeframe1 = PERIOD_H1;
input int StructureConfirmTimeframe2 = PERIOD_M30;
input int EntryConfirmTimeframe1 = PERIOD_M15;
input int EntryConfirmTimeframe2 = PERIOD_M5;
input int MacroFibTimeframe1 = PERIOD_H4;
input int MacroFibTimeframe2 = PERIOD_D1;
input int DayFibTimeframe1 = PERIOD_H1;
input int DayFibTimeframe2 = PERIOD_M30;
input int EntryFibTimeframe1 = PERIOD_M15;
input int EntryFibTimeframe2 = PERIOD_M5;
input int FibSwingLeftBars = 3;
input int FibSwingRightBars = 3;
input int FibLookbackBarsMacro = 300;
input int FibLookbackBarsDay = 200;
input int FibLookbackBarsEntry = 120;
input double FibMinSwingAtrMultiplier = 2.0;
input double FibZoneToleranceDollars = 3.0;
input bool RequireMacroDayFibAlignment = true;
input bool RequireDayFibForEntry = true;
input bool RequireEntryFibConfirmation = false;
input bool UsePreviousDayHighLowStructure = true;
input bool UseTodayHighLowStructure = true;
input bool UsePivotStructureFilter = true;
input bool UseH1H4BreakoutStructureFilter = true;
input bool UseSupportResistanceStructureFilter = true;
input bool UseLargeCandleDangerFilter = true;
input bool UseConsecutiveCandleDangerFilter = true;
input double StructureNearPriceDollars = 3.0;
input double BreakoutRetestToleranceDollars = 4.0;
input double LargeCandleAtrMultiplier = 1.8;
input int ConsecutiveCandleCount = 3;
input bool UseBullishPinBarConfirmation = true;
input bool UseBearishPinBarConfirmation = true;
input bool UseEngulfingConfirmation = true;
input bool UseOutsideBarConfirmation = true;
input bool UseInsideBarBreakoutConfirmation = true;
input bool UseSpikeReversalConfirmation = true;
input bool UseDojiDangerFilter = true;
input bool UseExhaustionCandleFilter = true;
input double PinBarWickBodyRatio = 1.8;
input double SpikeWickBodyRatio = 2.2;
input double MaxOppositeWickBodyRatio = 1.0;
input double EngulfingMinBodyRatio = 1.0;
input double DojiMaxBodyToRangeRatio = 0.2;
input double CandlePatternNearStructureDollars = 3.0;
input int MaxPlannedAddPositions = 1;
input bool AddPositionRequiresStructureSupport = true;
input bool AddPositionRequiresFibOrSr = true;
input bool AddPositionRequiresCandleConfirmation = true;
input double HedgedBasketCompressedMaxLossYen = 700.0;
input int HedgedBasketReviewMinutes = 30;
input int HedgedBasketExtraHoldWhenImprovingMinutes = 30;
input double HedgedBasketRequiredImprovementYen = 300.0;

input bool UseHistoricalTimeRiskFilter = true;
input int HistoricalTimeOffsetHours = 0;
input string HighRiskHoursSourceTime = "15,16,17,18";
input string CautionRiskHoursSourceTime = "10,19";
input string QuietBlockHoursSourceTime = "0,1,2,6,7,23";
input bool BlockNewEntryInQuietHours = true;
input bool BlockAddPositionInRiskHours = true;
input bool BlockDefenseHedgeInQuietHours = true;
input bool BlockBreakoutChaseInHighRiskHours = true;
input double HighRiskEntryScoreAdd = 8.0;
input double CautionRiskEntryScoreAdd = 5.0;
input bool UseWeekdayHourRiskBlock = true;
input string WeekdayHourRiskBlocksSourceTime = "3-15,3-16,3-17,4-15,4-16,4-17";

input bool UseEntryOpportunityAudit = true;
input bool LogRejectedEntryReasons = true;
input bool LogShadowEntryCandidates = true;
input int MaxRejectedEntryLogsPerDay = 200;
input string EntryOpportunityAuditFileName = "KOUCHA_GOLD_ENTRY_OPPORTUNITY_AUDIT.csv";

input bool UseBacktestLightLogMode = true;
input bool AuditSummaryOnlyMode = true;
input int AuditSummaryIntervalMinutes = 240;

input bool UseCsvLog = true;
input string LogFileName = "KOUCHA_GOLD_KIWAMI_SURVIVAL_TICK_LOG.csv";
input int NormalLogIntervalSeconds = 10;
input bool UseTradeEventLog = true;
input string TradeEventLogFileName = "KOUCHA_GOLD_KIWAMI_TRADE_EVENTS.csv";
input bool LogOnlyTradeEvents = false;
input bool ResetLogOnInit = false;
input bool ShowChartStatus = true;

#define EA_NAME "KOUCHA_GOLD_KIWAMI_SURVIVAL_TICK"

CTrade trade;

struct TickItem
{
   datetime time;
   double bid;
   double ask;
   double mid;
   ulong volume;
};

struct ScoreState
{
   double longScore;
   double shortScore;
   int ticks;
   double move;
   string reason;
};

struct PositionState
{
   int total;
   int buys;
   int sells;
   int net;
   double floatingProfit;
   double floatingLossPercent;
   double avgBuy;
   double avgSell;
};

struct ClosePriorityState
{
   bool hardStopNow;
   bool closePriorityOk;
   bool closePriorityBlocked;
   string closePriorityReason;
   string closeIntentState;
   string activeCloseReason;
};

#define TA9_SHADOW_SCHEMA_VERSION "1"
#define TA9_SHADOW_BUILD_ID "TA9_SHADOW_20260618"
#define TA9_SHADOW_SOURCE_BASELINE_SHA "30490B2D7AAC6C0197CC65B326A7728E82A8E62759E7E9202741EF851430CA9B"
#define TA9_SHADOW_STAGE_INDEX 3
#define MULTILAYER_SHADOW_SCHEMA_VERSION "1"
#define MULTILAYER_SHADOW_BUILD_ID "ML_PHASE1_SHADOW_20260620"
#define MULTILAYER_SHADOW_SOURCE_BEFORE_SHA "1353718F46D727DB775827AAF30F86EC790056CB59CE46EB00D5BAD563EF1DE3"

struct TA9ShadowSnapshot
{
   string prioritySnapshotId;
   string basketUid;
   string eventStageName;
   datetime serverTime;
   long serverTimeMsc;
   int tickSequenceId;
   int evalCycleSequence;
   int evalStageIndex;
   string basketLifecycleState;
   string hedgeState;
   double bid;
   double ask;
   double spreadPoints;
   double marginLevel;
   double basketFloatingPl;
   double positionProfitEquivalent;
   string swapState;
   string commissionState;
   string currentBasketPlSemantics;
   string hardStopBasis;
   double hardStopThresholdYen;
   double floatingLossYen;
   double distanceToHardStopRaw;
   double distanceToHardStopNormalized;
   bool runtimeHardStopNow;
   bool snapshotHardStopNow;
   bool hardStopByFloatingLoss;
   bool hardStopByMargin;
   bool hteEligibilityKnown;
   bool hteEligible;
   bool recoveryEligibilityKnown;
   bool recoveryEligible;
   bool basketCloseEligibilityKnown;
   bool basketCloseEligible;
   string eligibilityKnownMask;
   bool closePriorityOk;
   bool closePriorityBlocked;
   string closePriorityReason;
   string pendingCloseState;
   string marketSessionState;
   bool rawInputsKnown;
   bool ta9RawCondition;
   bool ta9SafetyCondition;
   string suppressionPrimaryReason;
   string suppressionBitmask;
   string actualSelectedCloseReason;
   string linkedOrderResult;
   string loggerHealth;
   bool parityError;
   string parityReason;
   double hteConditionDistance;
   double improvementFromHedgeBest;
   double hedgeStartFloatingPl;
   double bestFloatingAfterHedge;
   double worstFloatingAfterHedge;
   string detail;
};

struct MultilayerRootSnapshot
{
   string rootSnapshotId;
   string basketUid;
   datetime serverTime;
   long serverTimeMsc;
   int tickSequenceId;
   int evalCycleSequence;
   string evalStage;
   string lifecycleState;
   string hedgeState;
   string entryState;
   double bid;
   double ask;
   double spreadPoints;
   double marginLevel;
   double basketFloatingProfit;
   string basketSwapState;
   string basketCommissionStatus;
   double currentBasketNetPl;
   double floatingLossYen;
   double hardStopThresholdYen;
   double distanceToHardstopYen;
   bool hardstopNowRuntime;
   bool hardstopNowSnapshot;
   bool closePriorityOk;
   bool closePriorityBlocked;
   string pendingCloseState;
   string marketState;
   string loggerState;
   string currentExposure;
   int entryCount;
   int hedgeCount;
   string hteEligibility;
   string recoveryEligibility;
   string basketCloseEligibility;
};

struct FilterState
{
   bool ok;
   bool caution;
   bool stop;
   bool extreme;
   double value;
   string state;
   string reason;
};

struct PullbackState
{
   string mode;
   string direction;
   bool okBuy;
   bool okSell;
   string reasonBuy;
   string reasonSell;
   double rsi;
   double emaFast;
   double emaSlow;
   double recentHigh;
   double recentLow;
   double distanceFromRecentHigh;
   double distanceFromRecentLow;
   bool spikeUpBlocked;
   bool spikeDownBlocked;
   bool counterTrendBlockedBuy;
   bool counterTrendBlockedSell;
};

struct MaStructureState
{
   string mode;
   string trendDirection;
   double fastValue;
   double middleValue;
   double longValue;
   bool fastAboveMiddle;
   bool middleAboveLong;
   double distanceToFast;
   double distanceToMiddle;
   bool priceTooFarFromMaBuy;
   bool priceTooFarFromMaSell;
   bool priceNearMaPullback;
   bool maFlatBlocked;
   string crossState;
   bool maCrossWaitBlockedBuy;
   bool maCrossWaitBlockedSell;
   double fastSlope;
   double middleSlope;
   double longSlope;
   string fastSlopeState;
   string middleSlopeState;
   string longSlopeState;
   string slopeReasonBuy;
   string slopeReasonSell;
   bool buyingIntoFallingMa;
   bool sellingIntoRisingMa;
   bool okBuy;
   bool okSell;
   string reasonBuy;
   string reasonSell;
};

struct NewsCsvEvent
{
   datetime eventTimeServer;
   string eventTimeJstText;
   string eventTimeServerText;
   string country;
   string impact;
   string eventName;
   int blockBeforeMinutes;
   int blockAfterMinutes;
};

struct FibContextState
{
   string direction;
   double startPrice;
   double endPrice;
   string currentZone;
   bool inZone;
   bool trendAligned;
   bool structureBroken;
};

struct CandlePatternState
{
   bool detected;
   bool confirmedBuy;
   bool confirmedSell;
   bool dangerBuy;
   bool dangerSell;
   string patternType;
   string direction;
   string timeframeText;
   bool nearStructure;
   bool confirmed;
   bool dangerDetected;
   string dangerReason;
};

struct StructureGateState
{
   bool structurePermissionBuy;
   bool structurePermissionSell;
   bool candlePermissionBuy;
   bool candlePermissionSell;
   bool tickTriggerPermissionBuy;
   bool tickTriggerPermissionSell;
   bool blockedPureTickEntryBuy;
   bool blockedPureTickEntrySell;
   string blockedPureTickReasonBuy;
   string blockedPureTickReasonSell;
   string structureTrendState;
   string h1h4BreakoutState;
   string structureReasonBuy;
   string structureReasonSell;
   string candleReasonBuy;
   string candleReasonSell;
   FibContextState macroFib;
   FibContextState dayFib;
   FibContextState entryFib;
   bool macroDayFibAligned;
   double previousDayHighDistance;
   double previousDayLowDistance;
   double pivotDistance;
   double nearestSupportResistance;
   bool largeCandleDetected;
   bool consecutiveCandleDetected;
   CandlePatternState candle;
   string earlyExitReason;
   string plannedAddReason;
   string hedgedBasketLossCompressionReason;
};

TickItem ticks[];
NewsCsvEvent newsEvents[];

int dxyHandle = INVALID_HANDLE;
int vixHandle = INVALID_HANDLE;
int emaM15Fast = INVALID_HANDLE;
int emaM15Slow = INVALID_HANDLE;
int emaM30Fast = INVALID_HANDLE;
int emaM30Slow = INVALID_HANDLE;
int emaH1Fast = INVALID_HANDLE;
int emaH1Slow = INVALID_HANDLE;
int emaH4Fast = INVALID_HANDLE;
int emaH4Slow = INVALID_HANDLE;
int emaM1Fast = INVALID_HANDLE;
int emaM1Slow = INVALID_HANDLE;
int pullbackEmaFastHandle = INVALID_HANDLE;
int pullbackEmaSlowHandle = INVALID_HANDLE;
int pullbackRsiHandle = INVALID_HANDLE;
int maFastHandle = INVALID_HANDLE;
int maMiddleHandle = INVALID_HANDLE;
int maLongHandle = INVALID_HANDLE;
int structureH4Ema20Handle = INVALID_HANDLE;
int structureH4Ema50Handle = INVALID_HANDLE;
int structureH4Ema200Handle = INVALID_HANDLE;
int structureH1Ema20Handle = INVALID_HANDLE;
int structureH1Ema50Handle = INVALID_HANDLE;
int structureH1Ema200Handle = INVALID_HANDLE;
int structureM30Ema20Handle = INVALID_HANDLE;
int structureM30Ema50Handle = INVALID_HANDLE;
int structureM30Ema200Handle = INVALID_HANDLE;

bool dxyHandleFailed = false;
bool vixHandleFailed = false;
bool emaCriticalFailed = false;
bool eaClosingPositions = false;

datetime lastEntryTime = 0;
datetime lastTradeActionTime = 0;
datetime lastAnyEaCloseTime = 0;
datetime consecutiveLossStopUntil = 0;
datetime manualCloseStopUntil = 0;
datetime marketClosedRetryUntil = 0;
datetime lastMarketClosedErrorTime = 0;
datetime lastMarketClosedEventLogTime = 0;
datetime hardStopCooldownUntil = 0;
datetime lastEaCloseTime = 0;
datetime lastLogTime = 0;
datetime lastHardStopTime = 0;
double initialBalanceAtOnInit = 0.0;
datetime lastDailyLossStopLogDay = 0;
datetime lastConsecutiveLossStopLogUntil = 0;
datetime basketRecoveryReferenceHedgeTime = 0;
datetime lastRecoveryLossCutCloseTime = 0;
int lastKnownEaPositions = 0;
int lastEntryDirection = 0;
string lastEaCloseReason = "";
string lastStopReason = "";
bool lastDefenseHedgeAllowed = false;
string lastDefenseHedgeBlockReason = "HEDGE not evaluated";
bool basketRecoveryReferenceActive = false;
double basketRecoveryInitialProfit = 0.0;
double basketRecoveryWorstProfit = 0.0;
double lastRecoveryLossCutBasketProfit = 0.0;
bool newsCsvLoaded = false;
int newsCsvEventCount = 0;
string newsCsvLoadError = "";
bool currentNewsBlockActive = false;
string currentNewsBlockReason = "";
string currentNewsBlockEventName = "";
datetime currentNewsBlockStartServer = 0;
datetime currentNewsBlockEndServer = 0;
string currentNewsBlockEventTimeJst = "";
datetime currentNewsBlockEventTimeServer = 0;
int blockedByNewsCount = 0;
int blockedNewEntryByNewsCount = 0;
int blockedAddPositionByNewsCount = 0;
int blockedDefenseHedgeByNewsCount = 0;
int blockedHedgedBasketTimeExitByNewsCount = 0;
int blockedByTechnicalDangerCount = 0;
int blockedHedgedBasketTimeExitByTechnicalDangerCount = 0;
bool currentTechnicalDangerActive = false;
string currentTechnicalDangerReason = "";
bool currentVixDangerActive = false;
datetime lastNewsBlockCountTime = 0;
datetime lastTechnicalDangerCountTime = 0;
StructureGateState currentStructureGate;
int blockedPureTickEntryCount = 0;
int blockedByGoldStructureCount = 0;
int blockedByFibContextCount = 0;
int blockedByMacroDayMismatchCount = 0;
int blockedByPreviousDayHighLowCount = 0;
int blockedByPivotCount = 0;
int blockedByH1H4BreakoutCount = 0;
int blockedByLargeCandleCount = 0;
int blockedByConsecutiveCandleCount = 0;
int blockedByCandlePatternCount = 0;
int candlePatternConfirmationCount = 0;
int bullishPinBarCount = 0;
int bearishPinBarCount = 0;
int engulfingConfirmationCount = 0;
int spikeReversalConfirmationCount = 0;
int dojiDangerBlockCount = 0;
int structureBasedEarlyExitCount = 0;
double structureBasedEarlyExitProfitTotal = 0.0;
int plannedAddPositionCount = 0;
double plannedAddPositionProfitTotal = 0.0;
int oneTimeSameLotPlannedAddCount = 0;
datetime oneTimePlannedAddCountDay = 0;
int oneTimePlannedAddCountToday = 0;
int marketClosePreControlActiveCount = 0;
int marketClosePreBlockNewEntryCount = 0;
int marketClosePreBasketCloseNearCount = 0;
int marketClosePreRecoveryCloseNearCount = 0;
int marketClosePreHteNearCount = 0;
int marketClosePreExistingLossCutEligibleCount = 0;
int marketClosePreCloseIntentSentCount = 0;
int marketClosePreCloseIntentSucceededCount = 0;
int marketClosePreCloseIntentFailedCount = 0;
datetime lastMarketClosePreControlActiveLogTime = 0;
datetime lastMarketClosePreEntryBlockLogTime = 0;
datetime lastMarketClosePreNearLogTime = 0;
bool postHedgeNewEntryFreezeActive = false;
datetime postHedgeNewEntryFreezeStartTime = 0;
int postHedgeNewEntryFreezeBlockedCount = 0;
int postHedgeNewEntryFreezeBlockedBuyCount = 0;
int postHedgeNewEntryFreezeBlockedSellCount = 0;
datetime lastPostHedgeNewEntryFreezeBlockLogTime = 0;
bool postHedgeRfActive = false;
string postHedgeRfBasketId = "";
int postHedgeRfBasketSeq = 0;
datetime postHedgeRfBasketStartTime = 0;
datetime postHedgeRfHedgeTime = 0;
double postHedgeRfFloatingAtHedge = 0.0;
double postHedgeRfBestFloatingAfterHedge = 0.0;
double postHedgeRfWorstFloatingAfterHedge = 0.0;
double postHedgeRfLastBestLogged = 0.0;
bool postHedgeRfEligible = false;
bool postHedgeRfExecuted = false;
bool postHedgeRf60MinLogged = false;
bool postHedgeRf120ReachedLogged = false;
bool postHedgeRf120EvaluateLogged = false;
bool postHedgeRfEligibleResultLogged = false;
int postHedgeRfExitCount = 0;
double postHedgeRfExitProfitTotal = 0.0;
double postHedgeRfExitWorstLoss = 0.0;
int postHedgeDiagBasketSeq = 0;
bool postHedgeDiagActive = false;
string postHedgeDiagBasketId = "";
string postHedgeDiagBasketUid = "";
datetime postHedgeDiagBasketStartTime = 0;
datetime postHedgeDiagHedgeTime = 0;
datetime postHedgeDiagEndTime = 0;
double postHedgeDiagFloatingAtHedge = 0.0;
double postHedgeDiagBestFloatingAfterHedge = 0.0;
double postHedgeDiagWorstFloatingAfterHedge = 0.0;
double postHedgeDiagNearestBasketCloseDistance = 999999999.0;
double postHedgeDiagNearestRecoveryCloseDistance = 999999999.0;
double postHedgeDiagNearestRecoveryLossCutDistance = 999999999.0;
datetime postHedgeDiagNearestBasketCloseTime = 0;
datetime postHedgeDiagNearestRecoveryCloseTime = 0;
datetime postHedgeDiagNearestRecoveryLossCutTime = 0;
double postHedgeDiagNearestBasketCloseProfit = 0.0;
double postHedgeDiagNearestRecoveryCloseProfit = 0.0;
double postHedgeDiagNearestRecoveryLossCutProfit = 0.0;
bool postHedgeDiagCheckpoint30 = false;
bool postHedgeDiagCheckpoint60 = false;
bool postHedgeDiagCheckpoint120 = false;
bool postHedgeDiagCheckpoint240 = false;
bool postHedgeDiagCheckpoint480 = false;
bool postHedgeDiagCheckpoint720 = false;
bool postHedgeDiagTimeExitLogged = false;
bool postHedgeDiagHardStopLogged = false;
bool postHedgeDiagMarketClosedLogged = false;
bool postHedgeDiagEndLogged = false;
string postHedgeDiagFirstEligibleExit = "";
datetime postHedgeDiagFirstEligibleExitTime = 0;
double postHedgeDiagFirstEligibleExitProfit = 0.0;
int postHedgeDiagFirstEligibleExitMinutes = 0;
string postHedgeDiagActualFinalExit = "";
double postHedgeDiagFinalBasketProfit = 0.0;
string postHedgeDryRunLoggedCandidates = "";
datetime postHedgeDryRunTickTimes[];
string hardStopPrecursorLoggedPlans = "";
int hardStopPrecursorLastSnapshotMinute = -1;
datetime hardStopPrecursorSampleTimes[];
double hardStopPrecursorSamplePnls[];
double hardStopPrecursorSamplePrices[];
int prioritySnapshotSeq = 0;
int preHardStopCwLastSnapshotBucket = -1;
bool preHardStopCwWindowActive = false;
bool preHardStopCwStartLogged = false;
bool preHardStopCwHardStopEnterLogged = false;
datetime preHardStopCwWindowStartTime = 0;
datetime preHardStopCwLastCloseableTime = 0;
double preHardStopCwLastCloseableProfit = 0.0;
bool b2G5Active = false;
string b2G5BasketId = "";
int b2G5BasketSeq = 0;
datetime b2G5HedgeTime = 0;
datetime b2G5TriggerTime = 0;
bool b2G5RawTriggered = false;
bool b2G5GuardBlocked = false;
bool b2G5ExitExecuted = false;
int b2G5RawTriggerCount = 0;
int b2G5GuardBlockCount = 0;
int b2G5ExitCount = 0;
int b2G5ExitFailedCount = 0;
double b2G5ExitProfitTotal = 0.0;
bool cw8Active = false;
string cw8BasketId = "";
int cw8BasketSeq = 0;
datetime cw8HedgeTime = 0;
datetime cw8TriggerTime = 0;
bool cw8RawTriggered = false;
bool cw8PriorityBlocked = false;
bool cw8PriorityOk = false;
bool cw8HteGuardBlocked = false;
bool cw8ExitIntentLogged = false;
bool cw8ExitExecuted = false;
int cw8RawTriggerCount = 0;
int cw8PriorityOkCount = 0;
int cw8PriorityBlockCount = 0;
int cw8HteGuardBlockCount = 0;
int cw8ExitCount = 0;
int cw8ExitFailedCount = 0;
double cw8ExitProfitTotal = 0.0;
bool s2PreHsActive = false;
string s2PreHsBasketId = "";
int s2PreHsBasketSeq = 0;
datetime s2PreHsHedgeTime = 0;
datetime s2PreHsTriggerTime = 0;
bool s2PreHsStageCheckLogged = false;
bool s2PreHsConditionTrueLogged = false;
bool s2PreHsGuardBlockLogged = false;
bool s2PreHsExitIntentLogged = false;
bool s2PreHsExitExecuted = false;
int s2PreHsStageCheckCount = 0;
int s2PreHsConditionTrueCount = 0;
int s2PreHsGuardBlockCount = 0;
int s2PreHsExitIntentCount = 0;
int s2PreHsExitDoneCount = 0;
int s2PreHsExitFailedCount = 0;
int s2PreHsHardStopNowTrueBlockCount = 0;
int s2PreHsHardStopSafetyViolationCount = 0;
double s2PreHsExitProfitTotal = 0.0;
int runtimeEvalTickSequenceId = 0;
int runtimeEvalStageIndex = 0;
datetime runtimeEvalTickTime = 0;
string runtimeEvalStageLoggedKeys = "";
string ta9ShadowRunId = "";
string ta9ShadowLogFileName = "";
long ta9ShadowEventSequence = 0;
int ta9ShadowEvalCycleSequence = 0;
bool ta9ShadowHeaderWritten = false;
bool ta9ShadowLoggerHealthy = true;
bool ta9ShadowLoggerErrorPrinted = false;
int ta9ShadowDroppedRows = 0;
int ta9ShadowSnapshotCount = 0;
int ta9ShadowRawCandidateCount = 0;
int ta9ShadowSafeCandidateCount = 0;
int ta9ShadowSuppressedCount = 0;
int ta9ShadowParityErrorCount = 0;
int ta9ShadowBasketSummaryCount = 0;
string ta9ShadowLastStateKey = "";
bool ta9ShadowLastRaw = false;
bool ta9ShadowLastSafe = false;
string ta9ShadowLastSuppression = "";
bool ta9ShadowPostHedgeActive = false;
string ta9ShadowBasketUid = "";
datetime ta9ShadowHedgeTime = 0;
double ta9ShadowFloatingAtHedge = 0.0;
double ta9ShadowBestFloatingAfterHedge = 0.0;
double ta9ShadowWorstFloatingAfterHedge = 0.0;
int ta9ShadowBasketRowCount = 0;
int ta9ShadowBasketRawCount = 0;
int ta9ShadowBasketSafeCount = 0;
int ta9ShadowBasketSuppressedCount = 0;
int ta9ShadowBasketParityErrorCount = 0;
string mlShadowRunId = "";
string mlShadowLogFileName = "";
datetime mlShadowRunStartTime = 0;
long mlShadowEventSequence = 0;
int mlShadowEvalCycleSequence = 0;
bool mlShadowHeaderWritten = false;
bool mlShadowLoggerHealthy = true;
bool mlShadowLoggerErrorPrinted = false;
int mlShadowLoggerOpenErrorCount = 0;
int mlShadowLoggerWriteErrorCount = 0;
int mlShadowDroppedRows = 0;
int mlShadowDuplicateSnapshotCount = 0;
int mlShadowParityErrorCount = 0;
int mlShadowRootSnapshotCount = 0;
int mlShadowPrehedgeEventCount = 0;
int mlShadowHedgeEventCount = 0;
int mlShadowMaEventCount = 0;
int mlShadowEventRiskEventCount = 0;
int mlShadowBasketSummaryCount = 0;
bool mlShadowMaxRowsReached = false;
string mlShadowLastRootKey = "";
string mlShadowLastPrehedgeStateKey = "";
string mlShadowLastMaStateKey = "";
string mlShadowLastEventRiskStateKey = "";
string mlShadowCurrentBasketUid = "";
datetime mlShadowCurrentBasketStartTime = 0;
datetime mlShadowFirstHedgeTime = 0;
bool mlShadowBasketActive = false;
bool mlShadowBasketHedged = false;
bool mlShadowEventWindowLifetimeOverlap = false;
bool mlShadowEventWindowEntryOverlap = false;
bool mlShadowEventWindowHedgeOverlap = false;
bool mlShadowEventWindowCloseOverlap = false;
bool mlShadowMaBreakObserved = false;
bool mlShadowMaRetestObserved = false;
bool mlShadowMaRetestExitOpportunitySeen = false;
double mlShadowMinDistanceToHardstop = 0.0;
double mlShadowMaxFloatingLoss = 0.0;
double mlShadowPostHedgeBestPl = 0.0;
double mlShadowPostHedgeWorstPl = 0.0;
int mlShadowUnknownFieldCount = 0;
bool l1Active = false;
string l1BasketId = "";
int l1BasketSeq = 0;
datetime l1HedgeTime = 0;
datetime l1TriggerTime = 0;
bool l1RawTriggered = false;
bool l1PriorityBlocked = false;
bool l1PriorityOk = false;
bool l1ExitExecuted = false;
int l1RawTriggerCount = 0;
int l1PriorityOkCount = 0;
int l1PriorityBlockCount = 0;
int l1ExitCount = 0;
int l1ExitFailedCount = 0;
double l1ExitProfitTotal = 0.0;
int hedgedBasketLossCompressionCount = 0;
int singlePositionContraryEarlyExitCount = 0;
double singlePositionContraryEarlyExitProfitTotal = 0.0;
datetime lastSingleEarlyExitTime = 0;
datetime singleEarlyExitPostCooldownUntil = 0;
int lastSingleEarlyExitDirection = 0;
datetime singleEarlyExitCountDay = 0;
int singleEarlyExitCountToday = 0;
int singleEarlyExitCountSegment = 0;
int singleEarlyExitPostCooldownBlockCount = 0;
int sameDirectionReentryBlockedAfterSingleEarlyExitCount = 0;
int maxSingleEarlyExitPerDayHitCount = 0;
int m5ConfirmationPassedCount = 0;
int m5ConfirmationFailedCount = 0;
datetime lastSingleEarlyExitPostCooldownBlockLogTime = 0;
int largeCandleEntryCautionCount = 0;
int largeCandleEntryBlockedCount = 0;
int hardStopOriginEntryBlockCount = 0;
datetime lastHardStopOriginBlockLogTime = 0;
string lastHardStopOriginBlockReason = "";
string lastHardStopOriginLargeCandleDirection = "";
string lastHardStopOriginEntryDirection = "";
int lastHardStopOriginSecondsAfterLargeCandle = 0;
bool lastHardStopOriginHasPullbackConfirmation = false;
bool lastHardStopOriginHasStructureConfirmation = false;
double lastHardStopOriginEntryScore = 0.0;
double lastHardStopOriginEntryScoreThreshold = 0.0;
double lastHardStopOriginEntryScoreBuffer = 0.0;
int singleReactiveDefenseHedgeCount = 0;
int reactiveHedgeBasketCloseCount = 0;
int reactiveHedgeMaxLossCloseCount = 0;
int reactiveHedgeTimeCloseCount = 0;
double reactiveHedgeProfitTotal = 0.0;
int postHedgeGoodEnoughCloseCount = 0;
int postHedgeMaxLossCloseCount = 0;
int postHedgeNoImprovementCloseCount = 0;
int postHedgeHardTimeCloseCount = 0;
int postHedgeAgainstStrongTrendCloseCount = 0;
int postHedgeCloseRetryPendingCount = 0;
int postHedgeCloseRetrySuccessCount = 0;
int postHedgeCloseRetryFailedCount = 0;
int postHedgeSelectiveGoodEnoughCloseCount = 0;
int postHedgeSelectiveMaxLossCloseCount = 0;
int postHedgeSelectiveNoImprovementCloseCount = 0;
int postHedgeSelectiveHardTimeCloseCount = 0;
int postHedgeSelectiveHardTimeGraceCount = 0;
datetime postHedgeSelectiveLossCloseDay = 0;
int postHedgeSelectiveLossCloseCountToday = 0;
int postHedgeSelectiveLossCloseCountSegment = 0;
datetime postHedgeSelectiveLastHardTimeGraceHedgeTime = 0;
bool postHedgeReferenceActive = false;
datetime postHedgeReferenceHedgeTime = 0;
double postHedgeInitialProfit = 0.0;
double postHedgeWorstProfit = 0.0;
datetime postHedgeImprovingAnchorHedgeTime = 0;
datetime postHedgeImprovingAnchorTime = 0;
double postHedgeImprovingAnchorProfit = 0.0;
bool postHedgeCloseIntentPending = false;
string postHedgeCloseIntentReason = "";
datetime postHedgeCloseIntentFirstTime = 0;
datetime postHedgeCloseIntentLastRetryTime = 0;
bool postHedgeCloseRetryInProgress = false;
int globalCloseRetryPendingCount = 0;
int globalCloseRetryAttemptCount = 0;
int globalCloseRetrySuccessCount = 0;
int globalCloseRetryTimeoutCount = 0;
int globalCloseRetryBlockNewEntryCount = 0;
bool globalCloseIntentPending = false;
bool globalCloseIntentTimedOut = false;
string globalCloseIntentReason = "";
string globalCloseIntentTargetTickets = "";
string globalCloseIntentExpectedAction = "";
datetime globalCloseIntentFirstTime = 0;
datetime globalCloseIntentLastRetryTime = 0;
uint globalCloseIntentOriginalRetcode = 0;
string globalCloseIntentOriginalRetcodeDescription = "";
int globalCloseIntentRetryCount = 0;
bool globalCloseRetryInProgress = false;
datetime lastGlobalCloseRetryBlockLogTime = 0;
datetime reactiveHedgeCountDay = 0;
int reactiveHedgeCountToday = 0;
int reactiveHedgeCountSegment = 0;
string lastReactiveHedgeReason = "";
double lastReactiveHedgeCurrentFloatingProfitYen = 0.0;
double lastReactiveHedgeFloatingLossYen = 0.0;
double lastReactiveHedgeOppositeTickScore = 0.0;
double lastReactiveHedgeOppositeScoreDiff = 0.0;
bool lastReactiveHedgeM5ConfirmationPassed = false;
int lastReactiveHedgeM5ConfirmationBars = 0;
datetime lastReactiveHedgeOpenTime = 0;
datetime lastReactiveHedgeCloseTime = 0;
string lastReactiveHedgeCloseReason = "";
string lastSingleEarlyExitReason = "";
double lastSingleEarlyExitCurrentFloatingProfitYen = 0.0;
double lastSingleEarlyExitFloatingLossYen = 0.0;
double lastSingleEarlyExitOppositeTickScore = 0.0;
double lastSingleEarlyExitOppositeScoreDiff = 0.0;
string lastSingleEarlyExitPositionDirection = "";
int lastSingleEarlyExitHoldSeconds = 0;
bool lastSingleEarlyExitMaReverse = false;
bool lastSingleEarlyExitTrendReverse = false;
bool lastSingleEarlyExitTickReverse = false;
bool lastSingleEarlyExitPostCooldownActive = false;
datetime lastSingleEarlyExitPostCooldownUntil = 0;
bool lastSingleEarlyExitM5ConfirmationPassed = false;
int lastSingleEarlyExitM5ConfirmationBars = 0;
bool lastSingleEarlyExitVixCautionAdjustmentApplied = false;
double lastSingleEarlyExitEffectiveOppositeTickScoreThreshold = 0.0;
double lastSingleEarlyExitEffectiveSoftLossYen = 0.0;
double lastSingleEarlyExitEffectiveHardLossYen = 0.0;
bool currentLargeCandleEntryCaution = false;
bool currentLargeCandleEntryBlock = false;
string currentLargeCandleDirection = "";
string currentLargeCandleEntryDirection = "";
datetime hedgedBasketCompressionReviewTime = 0;
double hedgedBasketCompressionReferenceProfit = 0.0;
bool currentHistoricalTimeRiskActive = false;
bool currentHistoricalTimeHighRisk = false;
bool currentHistoricalTimeCaution = false;
bool currentHistoricalTimeQuiet = false;
bool currentHistoricalWeekdayHourBlock = false;
int currentHistoricalTimeSourceHour = -1;
int currentHistoricalTimeSourceWeekday = -1;
double currentHistoricalTimeScoreAdd = 0.0;
string currentHistoricalTimeRiskState = "disabled";
string currentHistoricalTimeRiskReason = "";
int blockedByHistoricalTimeRiskCount = 0;
int blockedNewEntryByHistoricalTimeRiskCount = 0;
int blockedAddByHistoricalTimeRiskCount = 0;
int blockedDefenseHedgeByHistoricalTimeRiskCount = 0;
int blockedBreakoutChaseByHistoricalTimeRiskCount = 0;
datetime auditCurrentDay = 0;
int auditRejectedLogsToday = 0;
datetime lastAuditSummaryTime = 0;
long auditRawTickSignalCount = 0;
long auditRawBuyTickSignalCount = 0;
long auditRawSellTickSignalCount = 0;
long auditSpreadOkCandidateCount = 0;
long auditBlockedBySpreadCount = 0;
long auditBlockedByNewsCount = 0;
long auditBlockedByDxyCount = 0;
long auditBlockedByVixCount = 0;
long auditBlockedByHistoricalTimeRiskCount = 0;
long auditBlockedByQuietHourCount = 0;
long auditBlockedByHighRiskHourCount = 0;
long auditBlockedByWeekdayHourRiskCount = 0;
long auditBlockedByEntryCooldownCount = 0;
long auditBlockedBySameDirectionCooldownCount = 0;
long auditBlockedByOppositeDirectionCooldownCount = 0;
long auditBlockedByMaxPositionsCount = 0;
long auditBlockedByTrendPullbackCount = 0;
long auditBlockedByMaStructureCount = 0;
long auditBlockedByMaSlopeCount = 0;
long auditBlockedByEntryScoreCount = 0;
long auditBlockedByMinimumScoreDifferenceCount = 0;
long auditBlockedByFloatingLossStopCount = 0;
long auditBlockedByDailyLossStopCount = 0;
long auditBlockedByConsecutiveLossStopCount = 0;
long auditBlockedByBasketStateCount = 0;
long auditFinalEntryApprovedCount = 0;
long auditActualOrderSendCount = 0;
long auditOrderSendFailedCount = 0;
long auditDailyRawTickSignalCount = 0;
long auditDailyRawBuyTickSignalCount = 0;
long auditDailyRawSellTickSignalCount = 0;
long auditDailyFinalEntryApprovedCount = 0;
long auditDailyActualOrderSendCount = 0;
long auditDailyOrderSendFailedCount = 0;
datetime entryDecisionTraceDay = 0;
int entryDecisionTraceRowsToday = 0;
datetime reactiveHedgeTraceDay = 0;
int reactiveHedgeTraceRowsToday = 0;
long entryDecisionTraceCandidateSeq = 0;

long perfCopyBufferCallCount = 0;
long perfCopyBufferRequestedCount = 0;
long perfCopyBufferDuplicateSameTickCount = 0;
long perfCopyBufferMemoHitCount = 0;
long perfCopyBufferMemoMissCount = 0;
long perfICustomCallCount = 0;
long perfDxyUpdateCount = 0;
long perfVixUpdateCount = 0;
long perfGoldLocationUpdateCount = 0;
long perfTechnicalDangerUpdateCount = 0;
long perfHigherTfUpdateCount = 0;
long perfMaStructureUpdateCount = 0;
long perfNewsCsvReadCount = 0;
long perfPositionScanCount = 0;
long perfPositionScanCacheHitCount = 0;
long perfHistoryScanCount = 0;
long perfDailyPlCacheUpdateCount = 0;
long perfCsvWriteCount = 0;
long perfPrintCount = 0;
long perfFileFlushCount = 0;
long perfCommentUpdateCount = 0;
datetime perfInitWallTime = 0;

bool perfTickActive = false;
long perfCurrentTickMsc = -1;
int copyBufferMemoItems = 0;
int copyBufferMemoHandle[COPYBUFFER_MEMO_MAX];
int copyBufferMemoBuffer[COPYBUFFER_MEMO_MAX];
int copyBufferMemoStart[COPYBUFFER_MEMO_MAX];
int copyBufferMemoCount[COPYBUFFER_MEMO_MAX];
int copyBufferMemoCopied[COPYBUFFER_MEMO_MAX];
double copyBufferMemoValues[COPYBUFFER_MEMO_MAX][COPYBUFFER_MEMO_VALUES];

bool positionTotalCacheValid = false;
int positionTotalCacheValue = 0;

int copyBufferBreakdownItems = 0;
string copyBufferBreakdownCategory[COPYBUFFER_BREAKDOWN_MAX];
string copyBufferBreakdownSymbol[COPYBUFFER_BREAKDOWN_MAX];
string copyBufferBreakdownTimeframe[COPYBUFFER_BREAKDOWN_MAX];
string copyBufferBreakdownName[COPYBUFFER_BREAKDOWN_MAX];
int copyBufferBreakdownBuffer[COPYBUFFER_BREAKDOWN_MAX];
int copyBufferBreakdownShift[COPYBUFFER_BREAKDOWN_MAX];
int copyBufferBreakdownCountParam[COPYBUFFER_BREAKDOWN_MAX];
long copyBufferBreakdownCallCount[COPYBUFFER_BREAKDOWN_MAX];
long copyBufferBreakdownUniqueTickCount[COPYBUFFER_BREAKDOWN_MAX];
long copyBufferBreakdownDuplicateSameTickCount[COPYBUFFER_BREAKDOWN_MAX];

bool cachedDailyPlValid = false;
datetime cachedDailyPlDay = 0;
datetime cachedDailyPlActionTime = 0;
double cachedDailyPlValue = 0.0;
bool cachedConsecutiveLossesValid = false;
datetime cachedConsecutiveLossesActionTime = 0;
int cachedConsecutiveLossesValue = 0;

bool cachedDxyValid = false;
FilterState cachedDxyState;
datetime cachedDxyUpdateTime = 0;
bool cachedVixValid = false;
FilterState cachedVixState;
datetime cachedVixUpdateTime = 0;

bool cachedHtfValid = false;
string cachedHtfState = "disabled";
bool cachedHtfBuyBlock = false;
bool cachedHtfSellBlock = false;
datetime cachedHtfM15Bar = 0;
datetime cachedHtfM30Bar = 0;
datetime cachedHtfH1Bar = 0;
datetime cachedHtfH4Bar = 0;

bool cachedMaStructureValid = false;
MaStructureState cachedMaStructureState;
datetime cachedMaStructureBar = 0;

bool cachedGoldLocationValid = false;
bool cachedGoldBuyOk = true;
bool cachedGoldSellOk = true;
string cachedGoldBuyReason = "";
string cachedGoldSellReason = "";
datetime cachedGoldLocationUpdateTime = 0;
datetime cachedGoldLocationM5Bar = 0;

bool cachedTechnicalDangerValid = false;
bool cachedTechnicalBuyDanger = false;
bool cachedTechnicalSellDanger = false;
string cachedTechnicalBuyReason = "";
string cachedTechnicalSellReason = "";
datetime cachedTechnicalDangerUpdateTime = 0;
datetime cachedTechnicalDangerM5Bar = 0;

bool tradeEventContextReady = false;
MqlTick tradeEventTick;
ScoreState tradeEventScore;
FilterState tradeEventDxy;
FilterState tradeEventVix;
PullbackState tradeEventPullback;
MaStructureState tradeEventMa;
PositionState tradeEventPosition;
double tradeEventMarginLevel = 0.0;
double tradeEventDailyPL = 0.0;
int tradeEventConsecutiveLosses = 0;
string tradeEventSignal = "NONE";
string tradeEventNewsState = "";
string tradeEventHtfState = "";
double tradeEventThreshold = 0.0;

bool IsFastCompareMode()
{
   return (UseBacktestFastCompareMode && !UseBacktestDiagnosticMode);
}

bool IsDiagnosticMode()
{
   return UseBacktestDiagnosticMode;
}

bool EffectiveTradeEventLogEnabled()
{
   return (UseTradeEventLog && EnableTradeEventLog);
}

bool EffectiveEntryDecisionTraceEnabled()
{
   if(!IsDiagnosticMode())
      return false;
   return (UseHardStopOriginEntryTrace && EnableEntryDecisionTrace);
}

bool EffectiveReactiveHedgeTraceEnabled()
{
   if(!IsDiagnosticMode())
      return false;
   return (TraceReactiveHedgeEligibility && EnableReactiveHedgeEligibilityTrace);
}

bool EffectiveRejectedEntryDetailLogEnabled()
{
   if(IsFastCompareMode())
      return false;
   if(IsDiagnosticMode())
      return EnableRejectedEntryDetailLog;
   return LogRejectedEntryReasons;
}

bool EffectiveShadowEntryCandidateLogEnabled()
{
   if(IsFastCompareMode())
      return false;
   if(IsDiagnosticMode())
      return EnableShadowEntryCandidateLog;
   return LogShadowEntryCandidates;
}

bool EffectiveAuditSummaryEnabled()
{
   return (UseEntryOpportunityAudit && EnableEntryOpportunityAuditSummary);
}

bool ShouldSuppressTradeEventInFastCompare(string eventType)
{
   if(!IsFastCompareMode())
      return false;
   if(eventType == "HARDSTOP_ORIGIN_ENTRY_BLOCK")
      return true;
   if(eventType == "LARGE_CANDLE_ENTRY_CAUTION")
      return true;
   if(eventType == "LARGE_CANDLE_ENTRY_BLOCK")
      return true;
   if(eventType == "REACTIVE_HEDGE_CANENTER_BLOCK")
      return true;
   if(eventType == "SINGLE_EARLY_EXIT_POST_COOLDOWN_BLOCK")
      return true;
   return false;
}

int PerfCopyBuffer(int indicatorHandle, int bufferNum, int startPos, int count, double &buffer[])
{
   if(CountPerformanceStats)
      perfCopyBufferRequestedCount++;

   int breakdownIndex = RegisterCopyBufferBreakdown(indicatorHandle, bufferNum, startPos, count);
   bool useMemo = (UseSafePerformanceOptimization && UseSameTickCopyBufferMemo && perfTickActive &&
                   count > 0 && count <= COPYBUFFER_MEMO_VALUES);

   if(useMemo)
   {
      for(int i = 0; i < copyBufferMemoItems; i++)
      {
         if(copyBufferMemoHandle[i] == indicatorHandle &&
            copyBufferMemoBuffer[i] == bufferNum &&
            copyBufferMemoStart[i] == startPos &&
            copyBufferMemoCount[i] == count)
         {
            ArrayResize(buffer, copyBufferMemoCopied[i]);
            for(int j = 0; j < copyBufferMemoCopied[i]; j++)
               buffer[j] = copyBufferMemoValues[i][j];
            if(CountPerformanceStats)
            {
               perfCopyBufferMemoHitCount++;
               perfCopyBufferDuplicateSameTickCount++;
               if(breakdownIndex >= 0)
                  copyBufferBreakdownDuplicateSameTickCount[breakdownIndex]++;
            }
            return copyBufferMemoCopied[i];
         }
      }
   }

   if(CountPerformanceStats)
   {
      perfCopyBufferCallCount++;
      if(useMemo)
         perfCopyBufferMemoMissCount++;
      if(breakdownIndex >= 0)
      {
         copyBufferBreakdownCallCount[breakdownIndex]++;
         copyBufferBreakdownUniqueTickCount[breakdownIndex]++;
      }
   }

   int copied = CopyBuffer(indicatorHandle, bufferNum, startPos, count, buffer);
   if(useMemo && copied > 0 && copyBufferMemoItems < COPYBUFFER_MEMO_MAX)
   {
      int slot = copyBufferMemoItems;
      copyBufferMemoItems++;
      copyBufferMemoHandle[slot] = indicatorHandle;
      copyBufferMemoBuffer[slot] = bufferNum;
      copyBufferMemoStart[slot] = startPos;
      copyBufferMemoCount[slot] = count;
      copyBufferMemoCopied[slot] = MathMin(copied, COPYBUFFER_MEMO_VALUES);
      for(int j = 0; j < copyBufferMemoCopied[slot]; j++)
         copyBufferMemoValues[slot][j] = buffer[j];
   }
   return copied;
}

int PerfPositionsTotal()
{
   if(UseSafePerformanceOptimization && UseSameTickPositionScanCache && perfTickActive && positionTotalCacheValid)
   {
      if(CountPerformanceStats)
         perfPositionScanCacheHitCount++;
      return positionTotalCacheValue;
   }

   if(CountPerformanceStats)
      perfPositionScanCount++;
   int total = PositionsTotal();
   if(UseSafePerformanceOptimization && UseSameTickPositionScanCache && perfTickActive)
   {
      positionTotalCacheValue = total;
      positionTotalCacheValid = true;
   }
   return total;
}

bool PerfHistorySelect(datetime fromDate, datetime toDate)
{
   if(CountPerformanceStats)
      perfHistoryScanCount++;
   return HistorySelect(fromDate, toDate);
}

uint PerfFileWriteString(int fileHandle, string text)
{
   if(CountPerformanceStats)
      perfCsvWriteCount++;
   return FileWriteString(fileHandle, text);
}

void BeginPerformanceTick(const MqlTick &tick)
{
   long tickMsc = (long)tick.time_msc;
   if(tickMsc <= 0)
      tickMsc = ((long)tick.time) * 1000;

   if(!perfTickActive || perfCurrentTickMsc != tickMsc)
   {
      perfTickActive = true;
      perfCurrentTickMsc = tickMsc;
      copyBufferMemoItems = 0;
      positionTotalCacheValid = false;
   }
}

void InvalidateSameTickPositionCache()
{
   positionTotalCacheValid = false;
}

string CopyBufferCategoryForHandle(int indicatorHandle, string &seriesName, string &tfText)
{
   tfText = "";
   seriesName = "OTHER";
   if(indicatorHandle == dxyHandle)
   {
      tfText = TfText(DxyIndicatorTimeframe);
      seriesName = "DXY";
      return "DXY";
   }
   if(indicatorHandle == vixHandle)
   {
      tfText = TfText(VixTimeframe);
      seriesName = "VIX";
      return "VIX";
   }
   if(indicatorHandle == emaM1Fast || indicatorHandle == emaM1Slow)
   {
      tfText = "PERIOD_M1";
      seriesName = indicatorHandle == emaM1Fast ? "M1_EMA_FAST" : "M1_EMA_SLOW";
      return "TICK_SCORE";
   }
   if(indicatorHandle == emaM15Fast || indicatorHandle == emaM15Slow)
   {
      tfText = "PERIOD_M15";
      seriesName = indicatorHandle == emaM15Fast ? "HTF_M15_FAST" : "HTF_M15_SLOW";
      return "HIGHER_TF";
   }
   if(indicatorHandle == emaM30Fast || indicatorHandle == emaM30Slow)
   {
      tfText = "PERIOD_M30";
      seriesName = indicatorHandle == emaM30Fast ? "HTF_M30_FAST" : "HTF_M30_SLOW";
      return "HIGHER_TF";
   }
   if(indicatorHandle == emaH1Fast || indicatorHandle == emaH1Slow)
   {
      tfText = "PERIOD_H1";
      seriesName = indicatorHandle == emaH1Fast ? "HTF_H1_FAST" : "HTF_H1_SLOW";
      return "HIGHER_TF";
   }
   if(indicatorHandle == emaH4Fast || indicatorHandle == emaH4Slow)
   {
      tfText = "PERIOD_H4";
      seriesName = indicatorHandle == emaH4Fast ? "HTF_H4_FAST" : "HTF_H4_SLOW";
      return "HIGHER_TF";
   }
   if(indicatorHandle == maFastHandle || indicatorHandle == maMiddleHandle || indicatorHandle == maLongHandle)
   {
      tfText = TfText(MaStructureTimeframe);
      if(indicatorHandle == maFastHandle)
         seriesName = "MA_FAST";
      else if(indicatorHandle == maMiddleHandle)
         seriesName = "MA_MIDDLE";
      else
         seriesName = "MA_LONG";
      return seriesName;
   }
   if(indicatorHandle == pullbackEmaFastHandle || indicatorHandle == pullbackEmaSlowHandle || indicatorHandle == pullbackRsiHandle)
   {
      tfText = TfText(PullbackTimeframe);
      if(indicatorHandle == pullbackEmaFastHandle)
         seriesName = "PULLBACK_EMA_FAST";
      else if(indicatorHandle == pullbackEmaSlowHandle)
         seriesName = "PULLBACK_EMA_SLOW";
      else
         seriesName = "PULLBACK_RSI";
      return "PULLBACK";
   }
   tfText = "";
   return "OTHER";
}

int RegisterCopyBufferBreakdown(int indicatorHandle, int bufferNum, int startPos, int count)
{
   if(!CountPerformanceStats)
      return -1;

   string seriesName = "";
   string tfText = "";
   string category = CopyBufferCategoryForHandle(indicatorHandle, seriesName, tfText);
   for(int i = 0; i < copyBufferBreakdownItems; i++)
   {
      if(copyBufferBreakdownName[i] == seriesName &&
         copyBufferBreakdownBuffer[i] == bufferNum &&
         copyBufferBreakdownShift[i] == startPos &&
         copyBufferBreakdownCountParam[i] == count)
         return i;
   }

   if(copyBufferBreakdownItems >= COPYBUFFER_BREAKDOWN_MAX)
      return -1;

   int slot = copyBufferBreakdownItems;
   copyBufferBreakdownItems++;
   copyBufferBreakdownCategory[slot] = category;
   copyBufferBreakdownSymbol[slot] = _Symbol;
   copyBufferBreakdownTimeframe[slot] = tfText;
   copyBufferBreakdownName[slot] = seriesName;
   copyBufferBreakdownBuffer[slot] = bufferNum;
   copyBufferBreakdownShift[slot] = startPos;
   copyBufferBreakdownCountParam[slot] = count;
   copyBufferBreakdownCallCount[slot] = 0;
   copyBufferBreakdownUniqueTickCount[slot] = 0;
   copyBufferBreakdownDuplicateSameTickCount[slot] = 0;
   return slot;
}

void ResetPerformanceCaches()
{
   cachedDxyValid = false;
   cachedDxyUpdateTime = 0;
   cachedVixValid = false;
   cachedVixUpdateTime = 0;
   cachedHtfValid = false;
   cachedHtfM15Bar = 0;
   cachedHtfM30Bar = 0;
   cachedHtfH1Bar = 0;
   cachedHtfH4Bar = 0;
   cachedMaStructureValid = false;
   cachedMaStructureBar = 0;
   cachedGoldLocationValid = false;
   cachedGoldLocationUpdateTime = 0;
   cachedGoldLocationM5Bar = 0;
   cachedTechnicalDangerValid = false;
   cachedTechnicalDangerUpdateTime = 0;
   cachedTechnicalDangerM5Bar = 0;
   copyBufferMemoItems = 0;
   positionTotalCacheValid = false;
   cachedDailyPlValid = false;
   cachedConsecutiveLossesValid = false;
}

datetime CurrentBarTime(ENUM_TIMEFRAMES tf)
{
   datetime t = iTime(_Symbol, tf, 0);
   return t;
}

bool HasEnabledTfNewBar(bool useM15, bool useM30, bool useH1, bool useH4,
                        datetime &m15Bar, datetime &m30Bar, datetime &h1Bar, datetime &h4Bar)
{
   bool changed = false;
   if(useM15)
   {
      datetime t = CurrentBarTime(PERIOD_M15);
      if(t > 0 && t != m15Bar)
      {
         m15Bar = t;
         changed = true;
      }
   }
   if(useM30)
   {
      datetime t = CurrentBarTime(PERIOD_M30);
      if(t > 0 && t != m30Bar)
      {
         m30Bar = t;
         changed = true;
      }
   }
   if(useH1)
   {
      datetime t = CurrentBarTime(PERIOD_H1);
      if(t > 0 && t != h1Bar)
      {
         h1Bar = t;
         changed = true;
      }
   }
   if(useH4)
   {
      datetime t = CurrentBarTime(PERIOD_H4);
      if(t > 0 && t != h4Bar)
      {
         h4Bar = t;
         changed = true;
      }
   }
   return changed;
}

void ReadDxyStateCached(FilterState &state)
{
   bool useDxyCache = (UsePerformanceCache || (UseSafePerformanceOptimization && UseDxyVixOnlyCache));
   if(!useDxyCache)
   {
      ReadDxyState(state);
      if(CountPerformanceStats)
         perfDxyUpdateCount++;
      return;
   }

   datetime now = TimeCurrent();
   int cacheSeconds = MathMax(1, UseDxyVixOnlyCache ? DxyVixOnlyCacheSeconds : DxyVixCacheSeconds);
   if(!cachedDxyValid || now - cachedDxyUpdateTime >= cacheSeconds)
   {
      ReadDxyState(cachedDxyState);
      cachedDxyUpdateTime = now;
      cachedDxyValid = true;
      if(CountPerformanceStats)
         perfDxyUpdateCount++;
   }
   state = cachedDxyState;
}

void ReadVixStateCached(FilterState &state)
{
   bool useVixCache = (UsePerformanceCache || (UseSafePerformanceOptimization && UseDxyVixOnlyCache));
   if(!useVixCache)
   {
      ReadVixState(state);
      if(CountPerformanceStats)
         perfVixUpdateCount++;
      return;
   }

   datetime now = TimeCurrent();
   int cacheSeconds = MathMax(1, UseDxyVixOnlyCache ? DxyVixOnlyCacheSeconds : DxyVixCacheSeconds);
   if(!cachedVixValid || now - cachedVixUpdateTime >= cacheSeconds)
   {
      ReadVixState(cachedVixState);
      cachedVixUpdateTime = now;
      cachedVixValid = true;
      if(CountPerformanceStats)
         perfVixUpdateCount++;
   }
   state = cachedVixState;
}

void CheckHigherTimeframesCached(string &state, bool &buyBlock, bool &sellBlock)
{
   if(!UsePerformanceCache || !UpdateHigherTfOnlyOnNewBar || DisableMaGoldTechnicalCacheForSafety || KeepEntryCriticalFiltersTickExact)
   {
      CheckHigherTimeframes(state, buyBlock, sellBlock);
      if(CountPerformanceStats)
         perfHigherTfUpdateCount++;
      return;
   }

   bool changed = HasEnabledTfNewBar(UseM15Filter, UseM30Filter, UseH1Filter, UseH4Filter,
                                    cachedHtfM15Bar, cachedHtfM30Bar, cachedHtfH1Bar, cachedHtfH4Bar);
   if(!cachedHtfValid || changed)
   {
      CheckHigherTimeframes(cachedHtfState, cachedHtfBuyBlock, cachedHtfSellBlock);
      cachedHtfValid = true;
      if(CountPerformanceStats)
         perfHigherTfUpdateCount++;
   }
   state = cachedHtfState;
   buyBlock = cachedHtfBuyBlock;
   sellBlock = cachedHtfSellBlock;
}

void CheckMaStructureStateCached(MaStructureState &state)
{
   if(!UsePerformanceCache || !UpdateMaStructureOnlyOnNewBar || DisableMaGoldTechnicalCacheForSafety || KeepEntryCriticalFiltersTickExact)
   {
      CheckMaStructureState(state);
      if(CountPerformanceStats)
         perfMaStructureUpdateCount++;
      return;
   }

   datetime barTime = CurrentBarTime(MaStructureTimeframe);
   if(!cachedMaStructureValid || barTime <= 0 || barTime != cachedMaStructureBar)
   {
      CheckMaStructureState(cachedMaStructureState);
      cachedMaStructureBar = barTime;
      cachedMaStructureValid = true;
      if(CountPerformanceStats)
         perfMaStructureUpdateCount++;
   }
   state = cachedMaStructureState;
}

void GetGoldLocationCached(bool &buyOk, string &buyReason, bool &sellOk, string &sellReason)
{
   if(!UsePerformanceCache || DisableMaGoldTechnicalCacheForSafety || KeepEntryCriticalFiltersTickExact)
   {
      buyOk = IsGoldLocationAllowed(true, buyReason);
      sellOk = IsGoldLocationAllowed(false, sellReason);
      if(CountPerformanceStats)
         perfGoldLocationUpdateCount++;
      return;
   }

   datetime now = TimeCurrent();
   datetime m5Bar = CurrentBarTime(PERIOD_M5);
   bool staleBySeconds = (now - cachedGoldLocationUpdateTime >= MathMax(1, GoldLocationCacheSeconds));
   bool staleByBar = (UpdateGoldLocationOnlyOnNewM5Bar && m5Bar > 0 && m5Bar != cachedGoldLocationM5Bar);
   if(!cachedGoldLocationValid || staleBySeconds || staleByBar)
   {
      cachedGoldBuyOk = IsGoldLocationAllowed(true, cachedGoldBuyReason);
      cachedGoldSellOk = IsGoldLocationAllowed(false, cachedGoldSellReason);
      cachedGoldLocationUpdateTime = now;
      cachedGoldLocationM5Bar = m5Bar;
      cachedGoldLocationValid = true;
      if(CountPerformanceStats)
         perfGoldLocationUpdateCount++;
   }
   buyOk = cachedGoldBuyOk;
   sellOk = cachedGoldSellOk;
   buyReason = cachedGoldBuyReason;
   sellReason = cachedGoldSellReason;
}

void GetTechnicalDangerCached(bool &buyDanger, string &buyReason, bool &sellDanger, string &sellReason)
{
   if(!UsePerformanceCache || DisableMaGoldTechnicalCacheForSafety || KeepEntryCriticalFiltersTickExact)
   {
      buyDanger = IsTechnicalDangerBlocked(true, buyReason, false);
      sellDanger = IsTechnicalDangerBlocked(false, sellReason, false);
      if(CountPerformanceStats)
         perfTechnicalDangerUpdateCount++;
      return;
   }

   datetime now = TimeCurrent();
   datetime m5Bar = CurrentBarTime(PERIOD_M5);
   bool staleBySeconds = (now - cachedTechnicalDangerUpdateTime >= MathMax(1, TechnicalDangerCacheSeconds));
   bool staleByBar = (UpdateTechnicalDangerOnlyOnNewM5Bar && m5Bar > 0 && m5Bar != cachedTechnicalDangerM5Bar);
   if(!cachedTechnicalDangerValid || staleBySeconds || staleByBar)
   {
      cachedTechnicalBuyDanger = IsTechnicalDangerBlocked(true, cachedTechnicalBuyReason, false);
      cachedTechnicalSellDanger = IsTechnicalDangerBlocked(false, cachedTechnicalSellReason, false);
      cachedTechnicalDangerUpdateTime = now;
      cachedTechnicalDangerM5Bar = m5Bar;
      cachedTechnicalDangerValid = true;
      if(CountPerformanceStats)
         perfTechnicalDangerUpdateCount++;
   }
   buyDanger = cachedTechnicalBuyDanger;
   sellDanger = cachedTechnicalSellDanger;
   buyReason = cachedTechnicalBuyReason;
   sellReason = cachedTechnicalSellReason;
}

bool IsTechnicalDangerBlockedCached(bool isBuy, string &reason, bool countBlock)
{
   if(!UsePerformanceCache || DisableMaGoldTechnicalCacheForSafety || KeepEntryCriticalFiltersTickExact)
      return IsTechnicalDangerBlocked(isBuy, reason, countBlock);

   bool buyDanger = false;
   bool sellDanger = false;
   string buyReason = "";
   string sellReason = "";
   GetTechnicalDangerCached(buyDanger, buyReason, sellDanger, sellReason);
   bool blocked = isBuy ? buyDanger : sellDanger;
   reason = isBuy ? buyReason : sellReason;
   if(blocked)
   {
      currentTechnicalDangerActive = true;
      currentTechnicalDangerReason = reason;
      if(countBlock)
         blockedByTechnicalDangerCount++;
   }
   return blocked;
}

int OnInit()
{
   trade.SetExpertMagicNumber(MagicNumber);
   trade.SetDeviationInPoints(30);
   initialBalanceAtOnInit = AccountInfoDouble(ACCOUNT_BALANCE);
   if(initialBalanceAtOnInit <= 0.0)
      initialBalanceAtOnInit = AccountInfoDouble(ACCOUNT_EQUITY);
   perfInitWallTime = TimeLocal();
   ResetPerformanceCaches();
   LoadNewsCsvEvents();

   if(DxyMode == 2 && UseDxyIndicator)
   {
      if(CountPerformanceStats)
         perfICustomCallCount++;
      dxyHandle = iCustom(_Symbol, DxyIndicatorTimeframe, DxyIndicatorName);
      if(dxyHandle == INVALID_HANDLE)
      {
         dxyHandleFailed = true;
         if(CountPerformanceStats)
            perfPrintCount++;
         Print(EA_NAME, ": DXY handle failed. error=", GetLastError());
      }
   }

   if(VixMode == 2 && UseVixIndicator)
   {
      if(CountPerformanceStats)
         perfICustomCallCount++;
      vixHandle = iCustom(_Symbol, VixTimeframe, VixIndicatorName);
      if(vixHandle == INVALID_HANDLE)
      {
         vixHandleFailed = true;
         if(CountPerformanceStats)
            perfPrintCount++;
         Print(EA_NAME, ": VIX handle failed. error=", GetLastError());
      }
   }

   if(UseHigherTimeframeFilter)
   {
      if(UseM15Filter) CreateEmaPair(PERIOD_M15, emaM15Fast, emaM15Slow, HigherTF_EMA_Fast, HigherTF_EMA_Slow);
      if(UseM30Filter) CreateEmaPair(PERIOD_M30, emaM30Fast, emaM30Slow, HigherTF_EMA_Fast, HigherTF_EMA_Slow);
      if(UseH1Filter) CreateEmaPair(PERIOD_H1, emaH1Fast, emaH1Slow, HigherTF_EMA_Fast, HigherTF_EMA_Slow);
      if(UseH4Filter) CreateEmaPair(PERIOD_H4, emaH4Fast, emaH4Slow, HigherTF_EMA_Fast, HigherTF_EMA_Slow);
   }

   if(UseM1ShortTrendConfirmation)
      CreateEmaPair(PERIOD_M1, emaM1Fast, emaM1Slow, HigherTF_EMA_Fast, HigherTF_EMA_Slow);

   if(UseTrendPullbackEntry || UsePullbackEmaZone || UsePullbackRsiFilter || RequireM5CandleConfirmation)
   {
      pullbackEmaFastHandle = iMA(_Symbol, PullbackTimeframe, PullbackEmaFast, 0, MODE_EMA, PRICE_CLOSE);
      pullbackEmaSlowHandle = iMA(_Symbol, PullbackTimeframe, PullbackEmaSlow, 0, MODE_EMA, PRICE_CLOSE);
      pullbackRsiHandle = iRSI(_Symbol, PullbackTimeframe, PullbackRsiPeriod, PRICE_CLOSE);
      if(pullbackEmaFastHandle == INVALID_HANDLE || pullbackEmaSlowHandle == INVALID_HANDLE || pullbackRsiHandle == INVALID_HANDLE)
      {
         if(CountPerformanceStats)
            perfPrintCount++;
         Print(EA_NAME, ": pullback indicator handle failed. error=", GetLastError());
      }
   }

   if(UseMaStructureFilter || UseMaSlopeFilter)
   {
      maFastHandle = iMA(_Symbol, MaStructureTimeframe, MaFastPeriod, 0, MODE_EMA, PRICE_CLOSE);
      maMiddleHandle = iMA(_Symbol, MaStructureTimeframe, MaMiddlePeriod, 0, MODE_EMA, PRICE_CLOSE);
      maLongHandle = iMA(_Symbol, MaStructureTimeframe, MaLongPeriod, 0, MODE_EMA, PRICE_CLOSE);
      if(maFastHandle == INVALID_HANDLE || maMiddleHandle == INVALID_HANDLE || maLongHandle == INVALID_HANDLE)
      {
         if(CountPerformanceStats)
            perfPrintCount++;
         Print(EA_NAME, ": MA structure handle failed. error=", GetLastError());
      }
   }

   if(UseGoldStructureFilter || UseStructureBeforeTickEntry)
   {
      structureH4Ema20Handle = iMA(_Symbol, PERIOD_H4, 20, 0, MODE_EMA, PRICE_CLOSE);
      structureH4Ema50Handle = iMA(_Symbol, PERIOD_H4, 50, 0, MODE_EMA, PRICE_CLOSE);
      structureH4Ema200Handle = iMA(_Symbol, PERIOD_H4, 200, 0, MODE_EMA, PRICE_CLOSE);
      structureH1Ema20Handle = iMA(_Symbol, PERIOD_H1, 20, 0, MODE_EMA, PRICE_CLOSE);
      structureH1Ema50Handle = iMA(_Symbol, PERIOD_H1, 50, 0, MODE_EMA, PRICE_CLOSE);
      structureH1Ema200Handle = iMA(_Symbol, PERIOD_H1, 200, 0, MODE_EMA, PRICE_CLOSE);
      structureM30Ema20Handle = iMA(_Symbol, PERIOD_M30, 20, 0, MODE_EMA, PRICE_CLOSE);
      structureM30Ema50Handle = iMA(_Symbol, PERIOD_M30, 50, 0, MODE_EMA, PRICE_CLOSE);
      structureM30Ema200Handle = iMA(_Symbol, PERIOD_M30, 200, 0, MODE_EMA, PRICE_CLOSE);
      if(structureH4Ema20Handle == INVALID_HANDLE || structureH4Ema50Handle == INVALID_HANDLE || structureH4Ema200Handle == INVALID_HANDLE ||
         structureH1Ema20Handle == INVALID_HANDLE || structureH1Ema50Handle == INVALID_HANDLE || structureH1Ema200Handle == INVALID_HANDLE ||
         structureM30Ema20Handle == INVALID_HANDLE || structureM30Ema50Handle == INVALID_HANDLE || structureM30Ema200Handle == INVALID_HANDLE)
      {
         if(CountPerformanceStats)
            perfPrintCount++;
         Print(EA_NAME, ": structure EMA handle failed. error=", GetLastError());
      }
   }

   if(ResetLogOnInit && EffectiveTradeEventLogEnabled())
      FileDelete(TradeEventLogFileName);
   if(ResetLogOnInit && UseEntryOpportunityAudit)
      FileDelete(EntryOpportunityAuditFileName);
   if(ResetLogOnInit && EffectiveEntryDecisionTraceEnabled())
      FileDelete(EntryDecisionTraceFileName);
   if(ResetLogOnInit && EffectiveReactiveHedgeTraceEnabled())
      FileDelete(ReactiveHedgeEligibilityTraceFileName);

   if(UseCsvLog && !LogOnlyTradeEvents && !IsFastCompareMode() && !UseBacktestLightLogMode)
      WriteCsvHeader();
   if(EffectiveTradeEventLogEnabled())
      WriteTradeEventHeader();
   if(UseEntryOpportunityAudit)
      WriteEntryOpportunityAuditHeader();
   if(EffectiveEntryDecisionTraceEnabled())
      WriteEntryDecisionTraceHeader();
   if(EffectiveReactiveHedgeTraceEnabled())
      WriteReactiveHedgeEligibilityTraceHeader();
   MultilayerShadowResetRun();

   return INIT_SUCCEEDED;
}

void OnDeinit(const int reason)
{
   TA9ShadowWriteRunSummary("ON_DEINIT");
   MultilayerShadowWriteRunSummary("ON_DEINIT");
   if(EffectiveAuditSummaryEnabled())
      WriteEntryOpportunityAuditSummary("FINAL_SUMMARY");
   if(CountPerformanceStats)
   {
      WritePerformanceStats();
      WriteCopyBufferBreakdown();
   }

   ReleaseHandle(dxyHandle);
   ReleaseHandle(vixHandle);
   ReleaseHandle(emaM15Fast);
   ReleaseHandle(emaM15Slow);
   ReleaseHandle(emaM30Fast);
   ReleaseHandle(emaM30Slow);
   ReleaseHandle(emaH1Fast);
   ReleaseHandle(emaH1Slow);
   ReleaseHandle(emaH4Fast);
   ReleaseHandle(emaH4Slow);
   ReleaseHandle(emaM1Fast);
   ReleaseHandle(emaM1Slow);
   ReleaseHandle(pullbackEmaFastHandle);
   ReleaseHandle(pullbackEmaSlowHandle);
   ReleaseHandle(pullbackRsiHandle);
   ReleaseHandle(maFastHandle);
   ReleaseHandle(maMiddleHandle);
   ReleaseHandle(maLongHandle);
   ReleaseHandle(structureH4Ema20Handle);
   ReleaseHandle(structureH4Ema50Handle);
   ReleaseHandle(structureH4Ema200Handle);
   ReleaseHandle(structureH1Ema20Handle);
   ReleaseHandle(structureH1Ema50Handle);
   ReleaseHandle(structureH1Ema200Handle);
   ReleaseHandle(structureM30Ema20Handle);
   ReleaseHandle(structureM30Ema50Handle);
   ReleaseHandle(structureM30Ema200Handle);
   Comment("");
}

double GetFloatingLossYen(const PositionState &ps)
{
   if(ps.floatingProfit < 0.0)
      return -ps.floatingProfit;
   return 0.0;
}

double GetBalancePercentHardStopThresholdYen()
{
   double balance = AccountInfoDouble(ACCOUNT_BALANCE);
   if(balance <= 0.0 || HardStopFloatingLossPercent <= 0.0)
      return 0.0;
   return balance * HardStopFloatingLossPercent / 100.0;
}

double GetHardStopThresholdYen()
{
   if(HardStopBasis == HARDSTOP_FIXED_YEN && HardStopFixedYen > 0.0)
      return HardStopFixedYen;

   if(HardStopBasis == HARDSTOP_INITIAL_BALANCE_R &&
      initialBalanceAtOnInit > 0.0 &&
      HardStopInitialRiskPercent > 0.0 &&
      HardStopRMultiplier > 0.0)
   {
      return initialBalanceAtOnInit * HardStopInitialRiskPercent / 100.0 * HardStopRMultiplier;
   }

   return GetBalancePercentHardStopThresholdYen();
}

bool IsHardStopTriggeredByBasis(const PositionState &ps, double marginLevel)
{
   double thresholdYen = GetHardStopThresholdYen();
   bool floatingLossHit = (thresholdYen > 0.0 && GetFloatingLossYen(ps) >= thresholdYen);
   bool marginLevelHit = (marginLevel <= HardStopMarginLevel);
   return (floatingLossHit || marginLevelHit);
}

void OnTick()
{
   MqlTick tick;
   if(!SymbolInfoTick(_Symbol, tick))
      return;

   BeginPerformanceTick(tick);
   AddTick(tick);
   PruneTicks();
   RuntimeEvalStageStartTick(tick);

   ScoreState score;
   CalculateScore(score, tick);

   PositionState ps;
   GetPositionState(ps);

   string action = "none";
   string noEntryReason = score.reason;
   bool tradeActionDone = false;
   lastDefenseHedgeAllowed = false;
   lastDefenseHedgeBlockReason = "HEDGE not evaluated this tick";
   currentLargeCandleEntryCaution = false;
   currentLargeCandleEntryBlock = false;
   currentLargeCandleDirection = "";
   currentLargeCandleEntryDirection = "";

   if(_Symbol != TargetSymbol)
      noEntryReason = "chart symbol does not match TargetSymbol";

   double marginLevel = GetSafeMarginLevel();
   double dailyPL = CalculateTodayRealizedPL();
   int consecutiveLosses = CalculateConsecutiveLosses();
   bool dailyStop = IsDailyLossStop(dailyPL);
   bool consecutiveStop = IsConsecutiveLossStop(consecutiveLosses);

   FilterState dxy;
   ReadDxyStateCached(dxy);

   FilterState vix;
   ReadVixStateCached(vix);

   string newsState = "disabled";
   string newsReason = "";
   bool newsBlock = IsNewsBlackout(newsState, newsReason);

   string htfState = "disabled";
   bool htfBuyBlock = false;
   bool htfSellBlock = false;
   CheckHigherTimeframesCached(htfState, htfBuyBlock, htfSellBlock);

   bool defenseMode = (ps.floatingLossPercent >= DefenseModeFloatingLossPercent || marginLevel <= DefenseModeMarginLevel);
   bool hardStop = IsHardStopTriggeredByBasis(ps, marginLevel);
   TraceRuntimeEvaluationStage("TICK_START",
                               ps,
                               false,
                               false,
                               false,
                               false,
                               false,
                               true,
                               "after_position_state_before_hardstop_evaluation");
   TraceRuntimeEvaluationStage("AFTER_FLOATING_PNL_UPDATE",
                               ps,
                               false,
                               false,
                               false,
                               false,
                               false,
                               true,
                               "floating_pnl_available_before_hardstop_evaluation");
   TraceRuntimeEvaluationStage("BEFORE_HARDSTOP_EVALUATION",
                               ps,
                               false,
                               false,
                               false,
                               false,
                               false,
                               true,
                               "diagnostic_pre_hardstop_slot_no_existing_exit_gate");
   if(EnableTA9ShadowLogging)
      ObserveTA9PreHardStopShadow(ps, hardStop, marginLevel);
   if(!tradeActionDone &&
      CheckPreHardStopS2StrictGuardExit(ps, hardStop, marginLevel, newsState, action, noEntryReason))
   {
      tradeActionDone = true;
      GetPositionState(ps);
      hardStop = false;
      defenseMode = false;
   }
   TraceRuntimeEvaluationStage("AFTER_HARDSTOP_EVALUATION",
                               ps,
                               hardStop,
                               false,
                               false,
                               false,
                               false,
                               false,
                               "hardstop_state_available_after_on_tick_hardstop_evaluation");

   string goldBuyReason = "";
   string goldSellReason = "";
   bool goldBuyOk = true;
   bool goldSellOk = true;
   GetGoldLocationCached(goldBuyOk, goldBuyReason, goldSellOk, goldSellReason);

   PullbackState pullback;
   CheckPullbackState(pullback, htfState, false);

   MaStructureState ma;
   CheckMaStructureStateCached(ma);

   currentNewsBlockActive = newsBlock;
   if(!newsBlock)
      currentNewsBlockReason = newsReason;
   currentVixDangerActive = (vix.caution || vix.stop || vix.extreme);
   currentTechnicalDangerActive = false;
   currentTechnicalDangerReason = "";
   string technicalBuyReason = "";
   string technicalSellReason = "";
   bool technicalBuyDanger = false;
   bool technicalSellDanger = false;
   GetTechnicalDangerCached(technicalBuyDanger, technicalBuyReason, technicalSellDanger, technicalSellReason);
   currentTechnicalDangerActive = technicalBuyDanger || technicalSellDanger;
   currentTechnicalDangerReason = technicalBuyDanger ? technicalBuyReason : technicalSellReason;

   EvaluateHistoricalTimeRisk();
   TraceRuntimeEvaluationStage("AFTER_MARKET_STATE_UPDATE",
                               ps,
                               false,
                               false,
                               false,
                               false,
                               false,
                               true,
                               "market_and_risk_state_available_before_hardstop_evaluation");

   double threshold = EntryScoreThreshold;
   if(vix.caution)
      threshold += 5.0;
   threshold += currentHistoricalTimeScoreAdd;

   EvaluateStructureGate(tick, score, dxy, vix, ma, threshold);

   double buyThreshold = threshold;
   double sellThreshold = threshold;
   bool rawBuySignal = (score.longScore >= threshold &&
                        score.longScore > score.shortScore &&
                        score.longScore - score.shortScore >= MinimumScoreDifference);
   bool rawSellSignal = (score.shortScore >= threshold &&
                         score.shortScore > score.longScore &&
                         score.shortScore - score.longScore >= MinimumScoreDifference);
   bool largeCandleBuyBlock = false;
   bool largeCandleSellBlock = false;

   if(UseLargeCandleEntryCautionForSinglePosition && ps.total == 0 && currentStructureGate.largeCandleDetected &&
      (rawBuySignal || rawSellSignal))
   {
      currentLargeCandleEntryCaution = true;
      currentLargeCandleDirection = ma.trendDirection;
      currentLargeCandleEntryDirection = rawBuySignal ? "BUY" : "SELL";
      if(rawBuySignal)
         buyThreshold += LargeCandleEntryScoreAddForSingle;
      if(rawSellSignal)
         sellThreshold += LargeCandleEntryScoreAddForSingle;

      if(BlockEntryOnLargeCandleAgainstMaTrend)
      {
         if(rawBuySignal && StringFind(ma.trendDirection, "bearish") >= 0)
            largeCandleBuyBlock = true;
         if(rawSellSignal && StringFind(ma.trendDirection, "bullish") >= 0)
            largeCandleSellBlock = true;
         currentLargeCandleEntryBlock = (largeCandleBuyBlock || largeCandleSellBlock);
      }

      if(currentLargeCandleEntryBlock)
         largeCandleEntryBlockedCount++;
      else
         largeCandleEntryCautionCount++;
   }

   bool buySignal = (!largeCandleBuyBlock &&
                     score.longScore >= buyThreshold &&
                     score.longScore > score.shortScore &&
                     score.longScore - score.shortScore >= MinimumScoreDifference);

   bool sellSignal = (!largeCandleSellBlock &&
                      score.shortScore >= sellThreshold &&
                      score.shortScore > score.longScore &&
                      score.shortScore - score.longScore >= MinimumScoreDifference);

   string signal = "NONE";
   if(buySignal)
      signal = "BUY";
   else if(sellSignal)
      signal = "SELL";

   AuditEntryOpportunity(tick, score, ps, dxy, vix, newsBlock, newsReason,
                         htfBuyBlock, htfSellBlock, goldBuyOk, goldSellOk,
                         goldBuyReason, goldSellReason, pullback, ma,
                         marginLevel, dailyStop, consecutiveStop, hardStop, threshold);

   UpdateTradeEventContext(tick, score, signal, dxy, vix, newsState, htfState,
                           pullback, ma, ps, marginLevel, dailyPL, consecutiveLosses, threshold);
   UpdatePostHedgeNewEntryFreezeState(ps);
   UpdatePostHedgeTimeExitPriorityDiagnostic(ps, hardStop);
   TraceRuntimeEvaluationStage("AFTER_BASKET_STATE_UPDATE",
                               ps,
                               hardStop,
                               false,
                               false,
                               false,
                               false,
                               false,
                               "basket_diagnostic_state_updated");
   if(EnableMultilayerShadowLogging && MultilayerShadowLogLevel > 0)
      ObserveMultilayerPreCloseShadow(ps,
                                      hardStop,
                                      marginLevel,
                                      tick,
                                      dxy,
                                      vix,
                                      newsBlock,
                                      newsReason,
                                      ma);
   int marketCloseMinutesToClose = 0;
   bool marketClosePreActive = IsMarketClosePreControlActive(ps, marketCloseMinutesToClose);
   if(marketClosePreActive)
      LogMarketClosePreControlActive(ps, marketCloseMinutesToClose);

   if(currentLargeCandleEntryBlock)
      WriteTradeEventLog("LARGE_CANDLE_ENTRY_BLOCK", 0, 0, "", "large candle entry block",
                         rawBuySignal ? "BUY" : "SELL", 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, ps.floatingProfit);
   else if(currentLargeCandleEntryCaution)
      WriteTradeEventLog("LARGE_CANDLE_ENTRY_CAUTION", 0, 0, "", "large candle entry caution",
                         rawBuySignal ? "BUY" : "SELL", 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, ps.floatingProfit);
   LogStopEventsIfNeeded(dailyStop, consecutiveStop, dailyPL, consecutiveLosses);

   if(DetectManualClose(ps.total))
   {
      action = "manual close detected";
      noEntryReason = "manual close protection active";
      tradeActionDone = true;
   }

   if(!tradeActionDone && ExecuteGlobalCloseIntent(ps, action, noEntryReason))
      tradeActionDone = true;

   if(!tradeActionDone && CheckReactiveHedgeExit(ps, action, noEntryReason))
      tradeActionDone = true;

   if(!tradeActionDone && CheckPostDefenseHedgeExitControl(ps, ma, action, noEntryReason))
      tradeActionDone = true;

   if(!tradeActionDone && CheckMarketClosePreCloseIntent(ps, action, noEntryReason))
      tradeActionDone = true;

   bool basketRecoveryClosed = false;
   if(!tradeActionDone)
   {
      TraceRuntimeEvaluationStage("BEFORE_CLOSE_PRIORITY_RESOLUTION",
                                  ps,
                                  hardStop,
                                  false,
                                  false,
                                  false,
                                  false,
                                  false,
                                  "before_CheckBasketRecoveryClose_call");
      basketRecoveryClosed = CheckBasketRecoveryClose(ps);
      TraceRuntimeEvaluationStage("AFTER_CLOSE_PRIORITY_RESOLUTION",
                                  ps,
                                  hardStop,
                                  false,
                                  false,
                                  false,
                                  false,
                                  false,
                                  "after_CheckBasketRecoveryClose_call");
   }
   if(!tradeActionDone && basketRecoveryClosed)
   {
      action = "basket recovery close";
      noEntryReason = "Basket recovery close";
      tradeActionDone = true;
   }

   if(!tradeActionDone && UseBasketClose && CheckBasketClose(ps))
   {
      action = "basket close";
      noEntryReason = "after EA close cooldown";
      tradeActionDone = true;
   }

   if(!tradeActionDone && CheckStructureBasedEarlyExit(ps))
   {
      action = "structure based early exit";
      noEntryReason = currentStructureGate.earlyExitReason;
      tradeActionDone = true;
   }

   bool allowMore = (!UseOneTradeActionPerTick || !tradeActionDone);
   bool reactiveHedgeEligibleThisTick = TraceReactiveHedgeEligibilityState(score, ps, vix, newsBlock, newsReason, ma, hardStop);
   if(action == "none" && allowMore)
   {
      if(TrySinglePositionReactiveDefenseHedge(tick, score, ps, dxy, vix, newsBlock, newsReason,
                                               ma, marginLevel, hardStop, action, noEntryReason))
         tradeActionDone = true;
   }

   allowMore = (!UseOneTradeActionPerTick || !tradeActionDone);
   if(action == "none" && allowMore)
   {
      if(TryOneTimeSameLotPlannedAdd(tick, score, ps, dxy, vix, newsBlock, newsReason,
                                     htfBuyBlock, htfSellBlock, goldBuyOk, goldSellOk,
                                     goldBuyReason, goldSellReason, pullback, ma,
                                     marginLevel, dailyStop, consecutiveStop, hardStop,
                                     action, noEntryReason))
         tradeActionDone = true;
   }

   allowMore = (!UseOneTradeActionPerTick || !tradeActionDone);
   if(action == "none" && allowMore)
   {
      if(TryDefenseHedge(tick, score, ps, dxy, vix, newsBlock, newsReason, htfBuyBlock, htfSellBlock,
                         marginLevel, defenseMode, hardStop, action, noEntryReason))
         tradeActionDone = true;
   }

   if(!tradeActionDone && !hardStop && !dailyStop &&
      TrySinglePositionContraryEarlyExit(score, ps, ma, vix, newsBlock, action, noEntryReason))
      tradeActionDone = true;

   if(!tradeActionDone && hardStop && UseEmergencyCloseAtHardStop && ps.total > 0)
   {
      TraceRuntimeEvaluationStage("RUNTIME_HARDSTOP_GATE",
                                  ps,
                                  hardStop,
                                  false,
                                  false,
                                  false,
                                  true,
                                  false,
                                  "existing_hardstop_emergency_close_gate");
      eaClosingPositions = true;
      if(CloseAllEaPositions("hard stop emergency close"))
      {
         ApplyHardStopAfterMode();
         action = "hard stop emergency close";
         noEntryReason = "hard stop mode";
         tradeActionDone = true;
      }
      eaClosingPositions = false;
   }

   allowMore = (!UseOneTradeActionPerTick || !tradeActionDone);

   if(allowMore && buySignal)
   {
      if(IsMarketClosePreNewEntryBlocked(ps, true, score, action, noEntryReason))
      {
         action = "BUY blocked";
      }
      else
      {
      long candidateId = NextEntryDecisionTraceCandidateId();
      string hardBlockReason = "";
      string hardLargeDirection = "";
      int hardSeconds = 0;
      bool hardHasPullback = false;
      bool hardHasStructure = false;
      double hardEntryScore = 0.0;
      double hardEntryScoreBuffer = 0.0;
      bool hardEligible = EvaluateHardStopOriginEntryBlockEligibility(true, score, ps, pullback, ma, buyThreshold,
                                                                     hardBlockReason, hardLargeDirection, hardSeconds,
                                                                     hardHasPullback, hardHasStructure,
                                                                     hardEntryScore, hardEntryScoreBuffer);
      bool hardFired = IsHardStopOriginEntryBlocked(true, score, ps, pullback, ma, buyThreshold, noEntryReason);
      if(hardFired)
      {
         action = "BUY blocked";
         WriteEntryDecisionTrace(true, candidateId, 0, false, false, noEntryReason, 0, "hard stop origin entry block",
                                 tick, score, ps, dxy, vix, newsBlock, pullback, ma, buyThreshold,
                                 hardEligible, true, hardBlockReason, reactiveHedgeEligibleThisTick);
      }
      else
      {
         bool finalAllowed = CanEnter(true, tick, score, ps, dxy, vix, newsBlock, newsReason, htfBuyBlock, goldBuyOk, goldBuyReason,
                                      pullback.okBuy, pullback.reasonBuy, ma.okBuy, ma.reasonBuy, false,
                                      marginLevel, dailyStop, consecutiveStop, hardStop, noEntryReason);
         if(finalAllowed)
         {
            bool opened = TryOpen(true, BaseLot, "tick pullback buy");
            uint retcode = trade.ResultRetcode();
            ulong orderTicket = trade.ResultOrder();
            WriteEntryDecisionTrace(true, candidateId, orderTicket, opened, true, opened ? "order sent" : "order failed",
                                    retcode, "tick pullback buy", tick, score, ps, dxy, vix, newsBlock, pullback, ma,
                                    buyThreshold, hardEligible, false, hardBlockReason, reactiveHedgeEligibleThisTick);
            if(opened)
            {
               action = "BUY opened";
               tradeActionDone = true;
            }
            else
               action = "BUY failed";
         }
         else
         {
            WriteEntryDecisionTrace(true, candidateId, 0, false, false, noEntryReason, 0, "CanEnter false",
                                    tick, score, ps, dxy, vix, newsBlock, pullback, ma, buyThreshold,
                                    hardEligible, false, hardBlockReason, reactiveHedgeEligibleThisTick);
         }
      }
      }
   }
   else if(allowMore && sellSignal)
   {
      if(IsMarketClosePreNewEntryBlocked(ps, false, score, action, noEntryReason))
      {
         action = "SELL blocked";
      }
      else
      {
      long candidateId = NextEntryDecisionTraceCandidateId();
      string hardBlockReason = "";
      string hardLargeDirection = "";
      int hardSeconds = 0;
      bool hardHasPullback = false;
      bool hardHasStructure = false;
      double hardEntryScore = 0.0;
      double hardEntryScoreBuffer = 0.0;
      bool hardEligible = EvaluateHardStopOriginEntryBlockEligibility(false, score, ps, pullback, ma, sellThreshold,
                                                                     hardBlockReason, hardLargeDirection, hardSeconds,
                                                                     hardHasPullback, hardHasStructure,
                                                                     hardEntryScore, hardEntryScoreBuffer);
      bool hardFired = IsHardStopOriginEntryBlocked(false, score, ps, pullback, ma, sellThreshold, noEntryReason);
      if(hardFired)
      {
         action = "SELL blocked";
         WriteEntryDecisionTrace(false, candidateId, 0, false, false, noEntryReason, 0, "hard stop origin entry block",
                                 tick, score, ps, dxy, vix, newsBlock, pullback, ma, sellThreshold,
                                 hardEligible, true, hardBlockReason, reactiveHedgeEligibleThisTick);
      }
      else
      {
         bool finalAllowed = CanEnter(false, tick, score, ps, dxy, vix, newsBlock, newsReason, htfSellBlock, goldSellOk, goldSellReason,
                                      pullback.okSell, pullback.reasonSell, ma.okSell, ma.reasonSell, false,
                                      marginLevel, dailyStop, consecutiveStop, hardStop, noEntryReason);
         if(finalAllowed)
         {
            bool opened = TryOpen(false, BaseLot, "tick pullback sell");
            uint retcode = trade.ResultRetcode();
            ulong orderTicket = trade.ResultOrder();
            WriteEntryDecisionTrace(false, candidateId, orderTicket, opened, true, opened ? "order sent" : "order failed",
                                    retcode, "tick pullback sell", tick, score, ps, dxy, vix, newsBlock, pullback, ma,
                                    sellThreshold, hardEligible, false, hardBlockReason, reactiveHedgeEligibleThisTick);
            if(opened)
            {
               action = "SELL opened";
               tradeActionDone = true;
            }
            else
               action = "SELL failed";
         }
         else
         {
            WriteEntryDecisionTrace(false, candidateId, 0, false, false, noEntryReason, 0, "CanEnter false",
                                    tick, score, ps, dxy, vix, newsBlock, pullback, ma, sellThreshold,
                                    hardEligible, false, hardBlockReason, reactiveHedgeEligibleThisTick);
         }
      }
      }
   }

   allowMore = (!UseOneTradeActionPerTick || !tradeActionDone);
   if(action == "none" && allowMore)
   {
      if(TryAddPosition(tick, score, ps, dxy, vix, newsBlock, newsReason, htfBuyBlock, htfSellBlock,
                        htfState, goldBuyOk, goldSellOk, goldBuyReason, goldSellReason, pullback, ma, marginLevel,
                        dailyStop, consecutiveStop, hardStop, action, noEntryReason))
         tradeActionDone = true;
   }

   lastStopReason = noEntryReason;

   if(ShowChartStatus && !UseBacktestLightLogMode && !IsFastCompareMode())
      DisplayStatus(score, signal, action, noEntryReason, dxy, vix, newsState, newsReason, htfState,
                    goldBuyReason, goldSellReason, pullback, ma, ps, marginLevel, dailyPL, consecutiveLosses);

   int normalLogInterval = NormalLogIntervalSeconds;
   if(normalLogInterval < 1)
      normalLogInterval = 1;

   if(UseCsvLog && !UseBacktestLightLogMode && !IsFastCompareMode() && !LogOnlyTradeEvents && (lastLogTime == 0 || TimeCurrent() - lastLogTime >= normalLogInterval))
   {
      WriteCsvLog(tick, score, signal, action, noEntryReason, goldBuyOk, goldSellOk, goldBuyReason, goldSellReason,
                  dxy, vix, newsState, newsReason, htfState, pullback, ma, ps, marginLevel, dailyPL, consecutiveLosses);
      lastLogTime = TimeCurrent();
   }

   TraceRuntimeEvaluationStage("TICK_END",
                               ps,
                               hardStop,
                               false,
                               false,
                               false,
                               false,
                               false,
                               "end_of_on_tick_after_trade_actions");

   lastKnownEaPositions = ps.total;
}

void CreateEmaPair(ENUM_TIMEFRAMES tf, int &fastHandle, int &slowHandle, int fastPeriod, int slowPeriod)
{
   fastHandle = iMA(_Symbol, tf, fastPeriod, 0, MODE_EMA, PRICE_CLOSE);
   slowHandle = iMA(_Symbol, tf, slowPeriod, 0, MODE_EMA, PRICE_CLOSE);
   if(fastHandle == INVALID_HANDLE || slowHandle == INVALID_HANDLE)
      emaCriticalFailed = true;
}

void ReleaseHandle(int &handle)
{
   if(handle != INVALID_HANDLE)
   {
      IndicatorRelease(handle);
      handle = INVALID_HANDLE;
   }
}

void AddTick(const MqlTick &tick)
{
   TickItem item;
   item.time = (datetime)tick.time;
   item.bid = tick.bid;
   item.ask = tick.ask;
   item.mid = (tick.bid + tick.ask) / 2.0;
   item.volume = tick.volume;

   int size = ArraySize(ticks);
   ArrayResize(ticks, size + 1);
   ticks[size] = item;
}

void PruneTicks()
{
   datetime cutoff = TimeCurrent() - TickWindowSeconds;
   int size = ArraySize(ticks);
   int start = 0;

   while(start < size && ticks[start].time < cutoff)
      start++;

   if(start <= 0)
      return;

   int newSize = size - start;
   for(int i = 0; i < newSize; i++)
      ticks[i] = ticks[i + start];

   ArrayResize(ticks, newSize);
}

bool IsValidValue(double value)
{
   return (MathIsValidNumber(value) && value != EMPTY_VALUE && value != 0.0 && MathAbs(value) < 1000000.0);
}

void CalculateScore(ScoreState &score, const MqlTick &tick)
{
   score.longScore = 0.0;
   score.shortScore = 0.0;
   score.ticks = ArraySize(ticks);
   score.move = 0.0;
   score.reason = "";

   if(score.ticks < MinimumTicksInWindow)
   {
      score.reason = "not enough ticks";
      return;
   }

   double spread = tick.ask - tick.bid;
   if(spread > MaxSpreadPrice)
   {
      score.reason = "spread too high";
      return;
   }

   int up = 0;
   int down = 0;
   double volumeSum = 0.0;
   double vwapSum = 0.0;

   for(int i = 1; i < score.ticks; i++)
   {
      if(ticks[i].mid > ticks[i - 1].mid)
         up++;
      else if(ticks[i].mid < ticks[i - 1].mid)
         down++;

      double vol = ticks[i].volume > 0 ? (double)ticks[i].volume : 1.0;
      volumeSum += vol;
      vwapSum += ticks[i].mid * vol;
   }

   score.move = ticks[score.ticks - 1].mid - ticks[0].mid;
   double absMove = MathAbs(score.move);

   if(absMove < MinimumTickWindowMove)
   {
      score.reason = "tick window move too small";
      return;
   }

   if(absMove > MaximumTickWindowMove)
   {
      score.reason = "tick window move too large spike";
      return;
   }

   int directionalTicks = up + down;
   double upRatio = directionalTicks > 0 ? (double)up / directionalTicks : 0.5;
   double downRatio = directionalTicks > 0 ? (double)down / directionalTicks : 0.5;
   double vwap = volumeSum > 0.0 ? vwapSum / volumeSum : ticks[score.ticks - 1].mid;
   double current = ticks[score.ticks - 1].mid;

   double longScore = 20.0 + upRatio * 35.0;
   double shortScore = 20.0 + downRatio * 35.0;

   if(score.move > 0.0)
      longScore += MathMin(25.0, absMove / MaximumTickWindowMove * 25.0);
   else
      shortScore += MathMin(25.0, absMove / MaximumTickWindowMove * 25.0);

   if(current > vwap)
      longScore += 10.0;
   else if(current < vwap)
      shortScore += 10.0;

   double density = MathMin(10.0, (double)score.ticks / MathMax(1.0, (double)MinimumTicksInWindow) * 5.0);
   longScore += density;
   shortScore += density;

   if(spread <= MaxSpreadPrice * 0.70)
   {
      longScore += 5.0;
      shortScore += 5.0;
   }

   if(UseM1ShortTrendConfirmation)
   {
      int bias = GetEmaBias(emaM1Fast, emaM1Slow);
      if(bias > 0)
         longScore += 5.0;
      else if(bias < 0)
         shortScore += 5.0;
   }

   score.longScore = MathMin(100.0, longScore);
   score.shortScore = MathMin(100.0, shortScore);
   score.reason = MathAbs(score.longScore - score.shortScore) < MinimumScoreDifference ? "score difference too small" : "score calculated";
}

bool ReadBufferValue(int handle, int bufferIndex, int shift, double &value)
{
   value = 0.0;
   if(handle == INVALID_HANDLE)
      return false;

   double buf[];
   ArraySetAsSeries(buf, true);
   if(PerfCopyBuffer(handle, bufferIndex, shift, 1, buf) < 1)
      return false;

   value = buf[0];
   return IsValidValue(value);
}

bool ReadIndicatorCurrentPrevious(int handle, int bufferIndex, int lookback, double &current, double &previous)
{
   current = 0.0;
   previous = 0.0;
   if(handle == INVALID_HANDLE || lookback < 1)
      return false;

   double buf[];
   ArraySetAsSeries(buf, true);
   int need = lookback + 1;
   if(PerfCopyBuffer(handle, bufferIndex, 0, need, buf) < need)
      return false;

   current = buf[0];
   previous = buf[lookback];
   return IsValidValue(current) && IsValidValue(previous);
}

bool ReadSymbolCurrentPrevious(string symbol, ENUM_TIMEFRAMES tf, int lookback, double &current, double &previous)
{
   current = 0.0;
   previous = 0.0;
   SymbolSelect(symbol, true);

   MqlTick tick;
   if(!SymbolInfoTick(symbol, tick))
      return false;

   current = (tick.bid + tick.ask) / 2.0;

   double close[];
   ArraySetAsSeries(close, true);
   if(CopyClose(symbol, tf, 0, lookback + 1, close) < lookback + 1)
      return false;

   previous = close[lookback];
   return IsValidValue(current) && IsValidValue(previous);
}

bool ReadSimpleCsv(string fileName, double &current, double &previous)
{
   current = 0.0;
   previous = 0.0;
   int handle = FileOpen(fileName, FILE_READ | FILE_CSV | FILE_ANSI);
   if(handle == INVALID_HANDLE)
      return false;

   while(!FileIsEnding(handle))
   {
      string first = FileReadString(handle);
      string second = FileReadString(handle);
      if(first != "")
      {
         previous = current;
         current = StringToDouble(first);
         if(second != "")
            previous = StringToDouble(second);
      }
   }

   FileClose(handle);
   return IsValidValue(current);
}

bool ReadSyntheticDxy(double &current, double &previous)
{
   string symbols[6] = {"EURUSD", "USDJPY", "GBPUSD", "USDCAD", "USDSEK", "USDCHF"};
   double latest[6];
   double old[6];

   for(int i = 0; i < 6; i++)
   {
      if(!ReadSymbolCurrentPrevious(symbols[i], DxyIndicatorTimeframe, DxyTrendLookbackBars, latest[i], old[i]))
         return false;
   }

   current = 50.14348112 * MathPow(latest[0], -0.576) * MathPow(latest[1], 0.136) *
             MathPow(latest[2], -0.119) * MathPow(latest[3], 0.091) *
             MathPow(latest[4], 0.042) * MathPow(latest[5], 0.036);

   previous = 50.14348112 * MathPow(old[0], -0.576) * MathPow(old[1], 0.136) *
              MathPow(old[2], -0.119) * MathPow(old[3], 0.091) *
              MathPow(old[4], 0.042) * MathPow(old[5], 0.036);

   return IsValidValue(current) && IsValidValue(previous);
}

void SetDataFailure(FilterState &state, int failMode, string reason)
{
   state.ok = (failMode == 0);
   state.stop = (failMode == 1);
   state.state = "unknown";
   state.reason = reason;
}

void ReadDxyState(FilterState &state)
{
   state.ok = true;
   state.caution = false;
   state.stop = false;
   state.extreme = false;
   state.value = 0.0;
   state.state = "disabled";
   state.reason = "";

   if(!UseDxyFilter || DxyMode == 0)
      return;

   if(UseDxyVolatilityBlock && DxyVolatilityState == 2)
   {
      state.ok = false;
      state.stop = true;
      state.state = "volatile";
      state.reason = "DXY volatility block";
      return;
   }

   if(DxyMode == 5)
   {
      if(DxyManualBias == 1)
      {
         state.state = "bullish";
         state.reason = "DXY manual bullish";
         return;
      }
      if(DxyManualBias == 2)
      {
         state.state = "bearish";
         state.reason = "DXY manual bearish";
         return;
      }
      if(DxyManualBias == 3)
      {
         state.state = "neutral";
         state.reason = "DXY manual neutral";
         return;
      }
      SetDataFailure(state, DxyDataFailMode, "DXY manual bias unknown");
      return;
   }

   double current = 0.0;
   double previous = 0.0;
   bool ok = false;

   if(DxyMode == 1)
      ok = ReadSymbolCurrentPrevious(DxySymbolName, DxyIndicatorTimeframe, DxyTrendLookbackBars, current, previous);
   else if(DxyMode == 2 && !dxyHandleFailed)
      ok = ReadIndicatorCurrentPrevious(dxyHandle, DxyIndicatorBufferIndex, DxyTrendLookbackBars, current, previous);
   else if(DxyMode == 3)
      ok = ReadSyntheticDxy(current, previous);
   else if(DxyMode == 4)
      ok = ReadSimpleCsv(DxyCsvFileName, current, previous);

   if(!ok)
   {
      state.value = current;
      SetDataFailure(state, DxyDataFailMode, "DXY data failed");
      return;
   }

   state.value = current;
   double change = current - previous;
   if(change >= DxyMinTrendChange)
      state.state = "bullish";
   else if(change <= -DxyMinTrendChange)
      state.state = "bearish";
   else
      state.state = "neutral";

   state.reason = "DXY " + state.state;
}

void ReadVixState(FilterState &state)
{
   state.ok = true;
   state.caution = false;
   state.stop = false;
   state.extreme = false;
   state.value = 0.0;
   state.state = "disabled";
   state.reason = "";

   if(!UseVixFilter || VixMode == 0)
      return;

   double current = 0.0;
   double previous = 0.0;
   bool ok = false;

   if(VixMode == 1)
      ok = ReadSymbolCurrentPrevious(VixSymbolName, VixTimeframe, VixSpikeLookbackBars, current, previous);
   else if(VixMode == 2 && !vixHandleFailed)
      ok = ReadIndicatorCurrentPrevious(vixHandle, VixIndicatorBufferIndex, VixSpikeLookbackBars, current, previous);
   else if(VixMode == 3)
      ok = ReadSimpleCsv(VixCsvFileName, current, previous);

   if(!ok || !IsValidValue(current))
   {
      state.value = current;
      SetDataFailure(state, VixDataFailMode, "VIX data failed");
      return;
   }

   state.value = current;

   if(current >= VixExtremeStopLevel)
   {
      state.ok = false;
      state.stop = true;
      state.extreme = true;
      state.state = "extreme";
      state.reason = "VIX extreme stop";
      return;
   }

   if(current >= VixStopLevel)
   {
      state.ok = false;
      state.stop = true;
      state.state = "stop";
      state.reason = "VIX stop state";
      return;
   }

   if(UseVixSpikeBlock && previous > 0.0 && (current - previous) / previous * 100.0 >= VixSpikeChangePercent)
   {
      state.ok = false;
      state.stop = true;
      state.state = "spike";
      state.reason = "VIX spike block";
      return;
   }

   if(current >= VixCautionLevel)
   {
      state.caution = true;
      state.state = "caution";
      state.reason = "VIX caution";
      return;
   }

   state.state = "normal";
   state.reason = "VIX normal";
}

string TrimText(string value)
{
   StringTrimLeft(value);
   StringTrimRight(value);
   return value;
}

void LoadNewsCsvEvents()
{
   if(CountPerformanceStats)
      perfNewsCsvReadCount++;
   ArrayResize(newsEvents, 0);
   newsCsvLoaded = false;
   newsCsvEventCount = 0;
   newsCsvLoadError = "";

   if(!UseNewsCsvFallback)
   {
      newsCsvLoadError = "news csv fallback disabled";
      return;
   }

   int handle = FileOpen(NewsCsvFileName, FILE_READ | FILE_TXT | FILE_ANSI);
   if(handle == INVALID_HANDLE)
   {
      int firstError = GetLastError();
      handle = FileOpen(NewsCsvFileName, FILE_READ | FILE_TXT | FILE_ANSI | FILE_COMMON);
      if(handle == INVALID_HANDLE)
      {
         newsCsvLoadError = "FileOpen failed error=" + IntegerToString(firstError) + " common_error=" + IntegerToString(GetLastError());
         if(CountPerformanceStats)
            perfPrintCount++;
         Print(EA_NAME, ": news csv load failed. file=", NewsCsvFileName, " ", newsCsvLoadError);
         return;
      }
   }

   int fileSize = (int)FileSize(handle);
   int tokenCount = 0;
   while(!FileIsEnding(handle))
   {
      string line = TrimText(FileReadString(handle));
      tokenCount++;
      string parts[];
      ushort comma = StringGetCharacter(",", 0);
      int partCount = StringSplit(line, comma, parts);
      if(partCount < 7)
         continue;

      string eventTimeJst = TrimText(parts[0]);
      string eventTimeServerText = TrimText(parts[1]);
      string country = TrimText(parts[2]);
      string impact = TrimText(parts[3]);
      string eventName = TrimText(parts[4]);
      string beforeText = TrimText(parts[5]);
      string afterText = TrimText(parts[6]);

      StringReplace(eventTimeJst, "_", " ");
      StringReplace(eventTimeServerText, "_", " ");
      StringReplace(eventName, "_", " ");

      if(eventTimeJst == "" && eventTimeServerText == "")
         continue;
      if(eventTimeJst == "EventTimeJST")
         continue;

      StringToUpper(country);
      StringToUpper(impact);
      if(country != "USD")
         continue;

      datetime serverTime = StringToTime(eventTimeServerText);
      if(serverTime <= 0)
         continue;

      int beforeMin = (int)StringToInteger(beforeText);
      int afterMin = (int)StringToInteger(afterText);
      bool fomc = (impact == "FOMC" || IsUltraNewsTitle(eventName));
      if(beforeMin <= 0)
         beforeMin = fomc ? NewsBlockBeforeMinutesFomc : NewsBlockBeforeMinutesHigh;
      if(afterMin <= 0)
         afterMin = fomc ? NewsBlockAfterMinutesFomc : NewsBlockAfterMinutesHigh;

      int size = ArraySize(newsEvents);
      ArrayResize(newsEvents, size + 1);
      newsEvents[size].eventTimeServer = serverTime;
      newsEvents[size].eventTimeJstText = eventTimeJst;
      newsEvents[size].eventTimeServerText = eventTimeServerText;
      newsEvents[size].country = country;
      newsEvents[size].impact = impact;
      newsEvents[size].eventName = eventName;
      newsEvents[size].blockBeforeMinutes = beforeMin;
      newsEvents[size].blockAfterMinutes = afterMin;
   }
   FileClose(handle);
   newsCsvEventCount = ArraySize(newsEvents);
   newsCsvLoaded = (newsCsvEventCount > 0);
   if(!newsCsvLoaded)
      newsCsvLoadError = "CSV loaded but no valid USD events fileSize=" + IntegerToString(fileSize) + " tokenCount=" + IntegerToString(tokenCount);
}

bool IsNewsBlackout(string &state, string &reason)
{
   state = "disabled";
   reason = "";
   if(!UseNewsFilter || NewsMode == 0)
      return false;

   bool ok = false;
   bool blocked = false;

   if(NewsMode == 1 && UseMt5EconomicCalendar)
      ok = CheckMt5Calendar(blocked, state, reason);

   if((!ok || NewsMode == 2) && UseNewsCsvFallback)
   {
      bool csvBlocked = false;
      bool csvOk = CheckNewsCsv(csvBlocked, state, reason);
      ok = csvOk;
      blocked = csvBlocked;
   }

   if(!ok)
   {
      state = "unknown";
      reason = NewsDataFailMode == 1 ? "news data failed, stop entries" : "news data failed, filter disabled";
      return (NewsDataFailMode == 1);
   }

   if(blocked)
      return true;

   if(state == "" || state == "calendar")
      state = "clear";
   if(reason == "")
      reason = "no news blackout";
   return false;
}

bool CheckMt5Calendar(bool &blocked, string &state, string &reason)
{
   blocked = false;
   state = "calendar";
   reason = "";

   datetime now = TimeCurrent();
   datetime from = now - MinutesAfterUltraHighNewsStop * 60;
   datetime to = now + MinutesBeforeUltraHighNewsStop * 60;

   MqlCalendarValue values[];
   ResetLastError();
   int total = CalendarValueHistory(values, from, to, "", "USD");
   if(total < 0)
   {
      Print(EA_NAME, ": economic calendar error=", GetLastError());
      return false;
   }

   if(total == 0)
   {
      state = "clear";
      reason = "calendar clear: no USD events";
      return true;
   }

   for(int i = 0; i < total; i++)
   {
      MqlCalendarEvent event;
      if(!CalendarEventById(values[i].event_id, event))
         continue;

      bool ultra = IsUltraNewsTitle(event.name);
      bool high = (event.importance == CALENDAR_IMPORTANCE_HIGH);
      bool medium = (event.importance == CALENDAR_IMPORTANCE_MODERATE);

      if(!ultra && high && !StopHighImpactNews)
         continue;
      if(!ultra && medium && !StopMediumImpactNews)
         continue;
      if(!ultra && !high && !medium)
         continue;

      int beforeMin = (ultra && UseUltraHighImpactNewsStop) ? MinutesBeforeUltraHighNewsStop : MinutesBeforeNewsStop;
      int afterMin = (ultra && UseUltraHighImpactNewsStop) ? MinutesAfterUltraHighNewsStop : MinutesAfterNewsStop;
      datetime eventTime = values[i].time;

      if(now >= eventTime - beforeMin * 60 && now <= eventTime + afterMin * 60)
      {
         blocked = true;
         state = ultra ? "ultra blackout" : "news blackout";
         reason = "Blocked: news blackout " + event.name;
         return true;
      }
   }

   state = "clear";
   reason = "calendar clear";
   return true;
}

bool CheckNewsCsv(bool &blocked, string &state, string &reason)
{
   blocked = false;
   state = "enabled_csv";
   reason = "";
   currentNewsBlockActive = false;
   currentNewsBlockReason = "";
   currentNewsBlockEventName = "";
   currentNewsBlockStartServer = 0;
   currentNewsBlockEndServer = 0;
   currentNewsBlockEventTimeJst = "";
   currentNewsBlockEventTimeServer = 0;

   if(!newsCsvLoaded || newsCsvEventCount <= 0)
   {
      state = (newsCsvLoadError == "" ? "csv_missing" : "csv_load_failed");
      reason = "NewsCsvLoaded=false file=" + NewsCsvFileName + " error=" + newsCsvLoadError;
      return false;
   }

   datetime now = TimeCurrent();
   for(int i = 0; i < newsCsvEventCount; i++)
   {
      datetime startTime = newsEvents[i].eventTimeServer - newsEvents[i].blockBeforeMinutes * 60;
      datetime endTime = newsEvents[i].eventTimeServer + newsEvents[i].blockAfterMinutes * 60;
      if(now >= startTime && now <= endTime)
      {
         blocked = true;
         state = "enabled_csv_blackout";
         reason = "Blocked: news blackout " + newsEvents[i].eventName;
         currentNewsBlockActive = true;
         currentNewsBlockReason = reason;
         currentNewsBlockEventName = newsEvents[i].eventName;
         currentNewsBlockStartServer = startTime;
         currentNewsBlockEndServer = endTime;
         currentNewsBlockEventTimeJst = newsEvents[i].eventTimeJstText;
         currentNewsBlockEventTimeServer = newsEvents[i].eventTimeServer;
         return true;
      }
   }

   state = "enabled_csv_clear";
   reason = "news csv clear";
   return true;
}

bool IsUltraNewsTitle(string title)
{
   string text = title;
   StringToUpper(text);
   return (StringFind(text, "NON-FARM") >= 0 ||
           StringFind(text, "NFP") >= 0 ||
           StringFind(text, "CPI") >= 0 ||
           StringFind(text, "FOMC") >= 0 ||
           StringFind(text, "FEDERAL FUNDS") >= 0 ||
           StringFind(text, "POWELL") >= 0 ||
           StringFind(text, "RATE DECISION") >= 0 ||
           StringFind(text, "PPI") >= 0 ||
           StringFind(text, "ADP") >= 0 ||
           StringFind(text, "RETAIL SALES") >= 0 ||
           StringFind(text, "ISM") >= 0 ||
           StringFind(text, "GDP") >= 0);
}

int GetEmaBias(int fastHandle, int slowHandle)
{
   if(fastHandle == INVALID_HANDLE || slowHandle == INVALID_HANDLE)
      return 0;

   double fast[];
   double slow[];
   ArraySetAsSeries(fast, true);
   ArraySetAsSeries(slow, true);

   if(PerfCopyBuffer(fastHandle, 0, 0, 2, fast) < 2)
      return 0;
   if(PerfCopyBuffer(slowHandle, 0, 0, 2, slow) < 2)
      return 0;

   if(!IsValidValue(fast[0]) || !IsValidValue(slow[0]))
      return 0;

   double diff = fast[0] - slow[0];
   double minDiff = SymbolInfoDouble(_Symbol, SYMBOL_POINT) * 50.0;

   if(diff > minDiff)
      return 1;
   if(diff < -minDiff)
      return -1;
   return 0;
}

void AddTfBias(bool enabled, int fastHandle, int slowHandle, int &bullish, int &bearish, int &checked)
{
   if(!enabled)
      return;

   int bias = GetEmaBias(fastHandle, slowHandle);
   if(bias > 0)
      bullish++;
   else if(bias < 0)
      bearish++;

   checked++;
}

void CheckHigherTimeframes(string &state, bool &buyBlock, bool &sellBlock)
{
   state = "disabled";
   buyBlock = false;
   sellBlock = false;

   if(!UseHigherTimeframeFilter)
      return;

   if(emaCriticalFailed)
   {
      state = "EMA failed";
      buyBlock = true;
      sellBlock = true;
      return;
   }

   int bullish = 0;
   int bearish = 0;
   int checked = 0;

   AddTfBias(UseM15Filter, emaM15Fast, emaM15Slow, bullish, bearish, checked);
   AddTfBias(UseM30Filter, emaM30Fast, emaM30Slow, bullish, bearish, checked);
   AddTfBias(UseH1Filter, emaH1Fast, emaH1Slow, bullish, bearish, checked);
   AddTfBias(UseH4Filter, emaH4Fast, emaH4Slow, bullish, bearish, checked);

   if(checked <= 0)
   {
      state = "unknown";
      buyBlock = true;
      sellBlock = true;
      return;
   }

   if(BlockStrongOppositeHigherTF)
   {
      if(bearish >= MathMax(2, checked - 1))
         buyBlock = true;
      if(bullish >= MathMax(2, checked - 1))
         sellBlock = true;
   }

   if(bullish > bearish)
      state = "bullish";
   else if(bearish > bullish)
      state = "bearish";
   else
      state = "neutral";
}

void CheckPullbackState(PullbackState &state, string htfState, bool isDefense)
{
   state.mode = UseTrendPullbackEntry ? "trend pullback" : "disabled";
   state.direction = htfState;
   state.okBuy = true;
   state.okSell = true;
   state.reasonBuy = "pullback BUY allowed";
   state.reasonSell = "pullback SELL allowed";
   state.rsi = 0.0;
   state.emaFast = 0.0;
   state.emaSlow = 0.0;
   state.recentHigh = 0.0;
   state.recentLow = 0.0;
   state.distanceFromRecentHigh = 0.0;
   state.distanceFromRecentLow = 0.0;
   state.spikeUpBlocked = false;
   state.spikeDownBlocked = false;
   state.counterTrendBlockedBuy = false;
   state.counterTrendBlockedSell = false;

   if(!UseTrendPullbackEntry)
      return;

   MqlTick tick;
   if(!SymbolInfoTick(_Symbol, tick))
   {
      state.okBuy = false;
      state.okSell = false;
      state.reasonBuy = "BUY blocked: no pullback tick";
      state.reasonSell = "SELL blocked: no pullback tick";
      return;
   }

   double buyPrice = tick.ask;
   double sellPrice = tick.bid;

   int highIndex = iHighest(_Symbol, PullbackTimeframe, MODE_HIGH, PullbackLookbackBars, 0);
   int lowIndex = iLowest(_Symbol, PullbackTimeframe, MODE_LOW, PullbackLookbackBars, 0);
   state.recentHigh = highIndex >= 0 ? iHigh(_Symbol, PullbackTimeframe, highIndex) : 0.0;
   state.recentLow = lowIndex >= 0 ? iLow(_Symbol, PullbackTimeframe, lowIndex) : 0.0;
   state.distanceFromRecentHigh = state.recentHigh > 0.0 ? state.recentHigh - buyPrice : 0.0;
   state.distanceFromRecentLow = state.recentLow > 0.0 ? sellPrice - state.recentLow : 0.0;

   ReadBufferValue(pullbackEmaFastHandle, 0, 0, state.emaFast);
   ReadBufferValue(pullbackEmaSlowHandle, 0, 0, state.emaSlow);
   ReadBufferValue(pullbackRsiHandle, 0, 0, state.rsi);

   if(BlockCounterTrendEntry && !(isDefense && AllowCounterTrendOnlyAsDefense))
   {
      if(htfState == "bearish")
      {
         state.okBuy = false;
         state.counterTrendBlockedBuy = true;
         state.reasonBuy = "BUY blocked: HTF bearish counter trend";
      }
      if(htfState == "bullish")
      {
         state.okSell = false;
         state.counterTrendBlockedSell = true;
         state.reasonSell = "SELL blocked: HTF bullish counter trend";
      }
   }

   if(RequirePullbackForEntry)
   {
      if(state.okBuy && (state.recentHigh <= 0.0 || state.distanceFromRecentHigh < MinPullbackFromRecentHighDollars))
      {
         state.okBuy = false;
         state.reasonBuy = "BUY blocked: no pullback from recent high";
      }
      if(state.okSell && (state.recentLow <= 0.0 || state.distanceFromRecentLow < MinPullbackFromRecentLowDollars))
      {
         state.okSell = false;
         state.reasonSell = "SELL blocked: no pullback from recent low";
      }
   }

   if(UsePullbackEmaZone)
   {
      bool emaOk = IsValidValue(state.emaFast) || IsValidValue(state.emaSlow);
      double buyDistFast = IsValidValue(state.emaFast) ? MathAbs(buyPrice - state.emaFast) : 999999.0;
      double buyDistSlow = IsValidValue(state.emaSlow) ? MathAbs(buyPrice - state.emaSlow) : 999999.0;
      double sellDistFast = IsValidValue(state.emaFast) ? MathAbs(sellPrice - state.emaFast) : 999999.0;
      double sellDistSlow = IsValidValue(state.emaSlow) ? MathAbs(sellPrice - state.emaSlow) : 999999.0;

      if(state.okBuy && (!emaOk || MathMin(buyDistFast, buyDistSlow) > PullbackEmaZoneDistanceDollars))
      {
         state.okBuy = false;
         state.reasonBuy = "BUY blocked: not returned to EMA zone";
      }
      if(state.okSell && (!emaOk || MathMin(sellDistFast, sellDistSlow) > PullbackEmaZoneDistanceDollars))
      {
         state.okSell = false;
         state.reasonSell = "SELL blocked: not returned to EMA zone";
      }
   }

   if(UsePullbackRsiFilter)
   {
      if(!IsValidValue(state.rsi))
      {
         if(state.okBuy)
         {
            state.okBuy = false;
            state.reasonBuy = "BUY blocked: RSI unavailable";
         }
         if(state.okSell)
         {
            state.okSell = false;
            state.reasonSell = "SELL blocked: RSI unavailable";
         }
      }
      else
      {
         if(state.okBuy && state.rsi >= BuyRsiOverheatedLevel)
         {
            state.okBuy = false;
            state.reasonBuy = "BUY blocked: RSI overheated";
         }
         if(state.okBuy && state.rsi > BuyRsiPullbackMax)
         {
            state.okBuy = false;
            state.reasonBuy = "BUY blocked: RSI not pullback";
         }
         if(state.okSell && state.rsi <= SellRsiOversoldLevel)
         {
            state.okSell = false;
            state.reasonSell = "SELL blocked: RSI oversold";
         }
         if(state.okSell && state.rsi < SellRsiPullbackMin)
         {
            state.okSell = false;
            state.reasonSell = "SELL blocked: RSI not pullback";
         }
      }
   }

   double spikeMove = GetRecentSpikeMove(TrendSpikeLookbackSeconds, (buyPrice + sellPrice) / 2.0);
   if(BlockBuyImmediatelyAfterSpikeUp && spikeMove >= TrendSpikeMoveDollars)
   {
      state.spikeUpBlocked = true;
      if(state.okBuy)
      {
         state.okBuy = false;
         state.reasonBuy = "BUY blocked: spike up chase";
      }
   }
   if(BlockSellImmediatelyAfterSpikeDown && spikeMove <= -TrendSpikeMoveDollars)
   {
      state.spikeDownBlocked = true;
      if(state.okSell)
      {
         state.okSell = false;
         state.reasonSell = "SELL blocked: spike down chase";
      }
   }

   if(RequireM5CandleConfirmation)
   {
      double open1 = iOpen(_Symbol, PullbackTimeframe, 1);
      double close1 = iClose(_Symbol, PullbackTimeframe, 1);
      bool buyCandle = (close1 > open1) || (IsValidValue(state.emaFast) && close1 > state.emaFast);
      bool sellCandle = (close1 < open1) || (IsValidValue(state.emaFast) && close1 < state.emaFast);

      if(state.okBuy && !buyCandle)
      {
         state.okBuy = false;
         state.reasonBuy = "BUY blocked: no M5 bullish confirmation";
      }
      if(state.okSell && !sellCandle)
      {
         state.okSell = false;
         state.reasonSell = "SELL blocked: no M5 bearish confirmation";
      }
   }
}

double GetRecentSpikeMove(int lookbackSeconds, double currentMid)
{
   if(ArraySize(ticks) < 2)
      return 0.0;

   datetime cutoff = TimeCurrent() - lookbackSeconds;
   double old = 0.0;

   for(int i = 0; i < ArraySize(ticks); i++)
   {
      if(ticks[i].time >= cutoff)
      {
         old = ticks[i].mid;
         break;
      }
   }

   if(old <= 0.0)
      return 0.0;

   return currentMid - old;
}

string MaSlopeStateText(double slope)
{
   if(slope >= MaStrongSlopeDollars)
      return "strong up";
   if(slope >= MaSlopeMinDollars)
      return "up";
   if(slope <= -MaStrongSlopeDollars)
      return "strong down";
   if(slope <= -MaSlopeMinDollars)
      return "down";
   return "flat";
}

void CheckMaStructureState(MaStructureState &state)
{
   state.mode = UseMaStructureFilter ? "enabled" : (UseMaSlopeFilter ? "slope-only" : "disabled");
   state.trendDirection = "neutral";
   state.fastValue = 0.0;
   state.middleValue = 0.0;
   state.longValue = 0.0;
   state.fastAboveMiddle = false;
   state.middleAboveLong = false;
   state.distanceToFast = 0.0;
   state.distanceToMiddle = 0.0;
   state.priceTooFarFromMaBuy = false;
   state.priceTooFarFromMaSell = false;
   state.priceNearMaPullback = true;
   state.maFlatBlocked = false;
   state.crossState = "none";
   state.maCrossWaitBlockedBuy = false;
   state.maCrossWaitBlockedSell = false;
   state.fastSlope = 0.0;
   state.middleSlope = 0.0;
   state.longSlope = 0.0;
   state.fastSlopeState = "flat";
   state.middleSlopeState = "flat";
   state.longSlopeState = "flat";
   state.slopeReasonBuy = "MA slope BUY allowed";
   state.slopeReasonSell = "MA slope SELL allowed";
   state.buyingIntoFallingMa = false;
   state.sellingIntoRisingMa = false;
   state.okBuy = true;
   state.okSell = true;
   state.reasonBuy = "MA structure BUY allowed";
   state.reasonSell = "MA structure SELL allowed";

   if(!UseMaStructureFilter && !UseMaSlopeFilter)
      return;

   MqlTick tick;
   if(!SymbolInfoTick(_Symbol, tick))
   {
      state.okBuy = false;
      state.okSell = false;
      state.reasonBuy = "BUY blocked: MA tick unavailable";
      state.reasonSell = "SELL blocked: MA tick unavailable";
      return;
   }

   if(!ReadBufferValue(maFastHandle, 0, 0, state.fastValue) ||
      !ReadBufferValue(maMiddleHandle, 0, 0, state.middleValue) ||
      !ReadBufferValue(maLongHandle, 0, 0, state.longValue))
   {
      state.okBuy = false;
      state.okSell = false;
      state.reasonBuy = "BUY blocked: MA data unavailable";
      state.reasonSell = "SELL blocked: MA data unavailable";
      return;
   }

   double midPrice = (tick.bid + tick.ask) / 2.0;
   state.fastAboveMiddle = (state.fastValue > state.middleValue);
   state.middleAboveLong = (state.middleValue > state.longValue);
   state.distanceToFast = MathAbs(midPrice - state.fastValue);
   state.distanceToMiddle = MathAbs(midPrice - state.middleValue);
   state.priceNearMaPullback = (MathMin(state.distanceToFast, state.distanceToMiddle) <= MaTouchDistanceDollars);

   bool buyTrend = (state.fastValue > state.middleValue);
   bool sellTrend = (state.fastValue < state.middleValue);
   if(buyTrend && state.middleValue > state.longValue)
      state.trendDirection = "strong bullish";
   else if(sellTrend && state.middleValue < state.longValue)
      state.trendDirection = "strong bearish";
   else if(buyTrend)
      state.trendDirection = "bullish";
   else if(sellTrend)
      state.trendDirection = "bearish";

   double close1 = iClose(_Symbol, MaStructureTimeframe, 1);
   if(close1 <= 0.0)
      close1 = midPrice;

   if(UseMaSlopeFilter)
   {
      int slopeLookback = MaSlopeLookbackBars;
      if(slopeLookback < 1)
         slopeLookback = 1;
      double fastPast = 0.0;
      double middlePast = 0.0;
      double longPast = 0.0;

      if(!ReadBufferValue(maFastHandle, 0, slopeLookback, fastPast) ||
         !ReadBufferValue(maMiddleHandle, 0, slopeLookback, middlePast) ||
         !ReadBufferValue(maLongHandle, 0, slopeLookback, longPast))
      {
         state.okBuy = false;
         state.okSell = false;
         state.slopeReasonBuy = "BUY blocked: MA slope data unavailable";
         state.slopeReasonSell = "SELL blocked: MA slope data unavailable";
         state.reasonBuy = state.slopeReasonBuy;
         state.reasonSell = state.slopeReasonSell;
         return;
      }

      state.fastSlope = state.fastValue - fastPast;
      state.middleSlope = state.middleValue - middlePast;
      state.longSlope = state.longValue - longPast;
      state.fastSlopeState = MaSlopeStateText(state.fastSlope);
      state.middleSlopeState = MaSlopeStateText(state.middleSlope);
      state.longSlopeState = MaSlopeStateText(state.longSlope);

      bool fastDown = (state.fastSlope <= -MaSlopeMinDollars);
      bool fastUp = (state.fastSlope >= MaSlopeMinDollars);
      bool middleDown = (state.middleSlope <= -MaSlopeMinDollars);
      bool middleUp = (state.middleSlope >= MaSlopeMinDollars);
      bool priceBelowFast = (close1 < state.fastValue);
      bool priceBelowMiddle = (close1 < state.middleValue);
      bool priceAboveFast = (close1 > state.fastValue);
      bool priceAboveMiddle = (close1 > state.middleValue);

      if(BlockBuyAgainstDownSlopeMa)
      {
         if(RequireFastMaSlopeForEntry && fastDown)
         {
            state.buyingIntoFallingMa = true;
            state.okBuy = false;
            state.slopeReasonBuy = "BUY blocked: EMA20 slope down";
            state.reasonBuy = state.slopeReasonBuy;
         }
         else if(RequireMiddleMaSlopeForEntry && middleDown)
         {
            state.buyingIntoFallingMa = true;
            state.okBuy = false;
            state.slopeReasonBuy = "BUY blocked: buying into falling MA";
            state.reasonBuy = state.slopeReasonBuy;
         }
         else if(state.fastValue < state.middleValue && fastDown)
         {
            state.buyingIntoFallingMa = true;
            state.okBuy = false;
            state.slopeReasonBuy = "BUY blocked: buying into falling MA";
            state.reasonBuy = state.slopeReasonBuy;
         }
         else if((priceBelowFast || priceBelowMiddle) && fastDown)
         {
            state.buyingIntoFallingMa = true;
            state.okBuy = false;
            state.slopeReasonBuy = "BUY blocked: below falling EMA20";
            state.reasonBuy = state.slopeReasonBuy;
         }
      }

      if(BlockSellAgainstUpSlopeMa)
      {
         if(RequireFastMaSlopeForEntry && fastUp)
         {
            state.sellingIntoRisingMa = true;
            state.okSell = false;
            state.slopeReasonSell = "SELL blocked: EMA20 slope up";
            state.reasonSell = state.slopeReasonSell;
         }
         else if(RequireMiddleMaSlopeForEntry && middleUp)
         {
            state.sellingIntoRisingMa = true;
            state.okSell = false;
            state.slopeReasonSell = "SELL blocked: selling into rising MA";
            state.reasonSell = state.slopeReasonSell;
         }
         else if(state.fastValue > state.middleValue && fastUp)
         {
            state.sellingIntoRisingMa = true;
            state.okSell = false;
            state.slopeReasonSell = "SELL blocked: selling into rising MA";
            state.reasonSell = state.slopeReasonSell;
         }
         else if((priceAboveFast || priceAboveMiddle) && fastUp)
         {
            state.sellingIntoRisingMa = true;
            state.okSell = false;
            state.slopeReasonSell = "SELL blocked: above rising EMA20";
            state.reasonSell = state.slopeReasonSell;
         }
      }
   }

   int crossCount = 0;
   int crossUpBarsAgo = -1;
   int crossDownBarsAgo = -1;
   GetMaCrossInfo(crossCount, crossUpBarsAgo, crossDownBarsAgo);

   if(crossUpBarsAgo >= 0)
      state.crossState = "recent cross up";
   if(crossDownBarsAgo >= 0 && (crossUpBarsAgo < 0 || crossDownBarsAgo < crossUpBarsAgo))
      state.crossState = "recent cross down";

   if(UseMaStructureFilter &&
      BlockEntryWhenMaFlat &&
      (MathAbs(state.fastValue - state.middleValue) < MaFlatDistanceDollars || crossCount >= 2))
   {
      state.maFlatBlocked = true;
      state.okBuy = false;
      state.okSell = false;
      state.reasonBuy = "Entry blocked: MA flat/range";
      state.reasonSell = "Entry blocked: MA flat/range";
      return;
   }

   if(UseMaStructureFilter && RequireMaTrendAlignment)
   {
      if(state.okBuy && !buyTrend)
      {
         state.okBuy = false;
         state.reasonBuy = "BUY blocked: MA trend not bullish";
      }
      if(state.okSell && !sellTrend)
      {
         state.okSell = false;
         state.reasonSell = "SELL blocked: MA trend not bearish";
      }
   }

   if(UseMaStructureFilter && RequirePriceNearMaForPullback && !state.priceNearMaPullback)
   {
      if(state.okBuy)
      {
         state.okBuy = false;
         state.reasonBuy = "BUY blocked: not near MA pullback zone";
      }
      if(state.okSell)
      {
         state.okSell = false;
         state.reasonSell = "SELL blocked: not near MA pullback zone";
      }
   }

   if(UseMaStructureFilter && BlockEntryWhenMaTooFar)
   {
      if(tick.ask - state.fastValue > MaTooFarDistanceDollars)
      {
         state.priceTooFarFromMaBuy = true;
         if(state.okBuy)
         {
            state.okBuy = false;
            state.reasonBuy = "BUY blocked: price too far above EMA20";
         }
      }
      if(state.fastValue - tick.bid > MaTooFarDistanceDollars)
      {
         state.priceTooFarFromMaSell = true;
         if(state.okSell)
         {
            state.okSell = false;
            state.reasonSell = "SELL blocked: price too far below EMA20";
         }
      }
   }

   if(UseMaStructureFilter && BlockBuyBelowMiddleMa && close1 < state.middleValue)
   {
      if(state.okBuy)
      {
         state.okBuy = false;
         state.reasonBuy = "BUY blocked: below EMA50";
      }
   }
   if(UseMaStructureFilter && BlockSellAboveMiddleMa && close1 > state.middleValue)
   {
      if(state.okSell)
      {
         state.okSell = false;
         state.reasonSell = "SELL blocked: above EMA50";
      }
   }

   if(UseMaStructureFilter && UseMaCrossStateFilter && BlockImmediatelyAfterMaCross)
   {
      if(crossUpBarsAgo >= 0 && crossUpBarsAgo < MaCrossWaitBars)
      {
         state.maCrossWaitBlockedBuy = true;
         if(state.okBuy)
         {
            state.okBuy = false;
            state.reasonBuy = "BUY blocked: immediately after MA cross";
         }
      }
      if(crossDownBarsAgo >= 0 && crossDownBarsAgo < MaCrossWaitBars)
      {
         state.maCrossWaitBlockedSell = true;
         if(state.okSell)
         {
            state.okSell = false;
            state.reasonSell = "SELL blocked: immediately after MA cross";
         }
      }
   }
}

void GetMaCrossInfo(int &crossCount, int &crossUpBarsAgo, int &crossDownBarsAgo)
{
   crossCount = 0;
   crossUpBarsAgo = -1;
   crossDownBarsAgo = -1;

   int need = MathMax(MaCrossRecentBars + 2, MaCrossWaitBars + 2);
   if(need < 3)
      need = 3;

   double fast[];
   double middle[];
   ArraySetAsSeries(fast, true);
   ArraySetAsSeries(middle, true);

   if(PerfCopyBuffer(maFastHandle, 0, 0, need, fast) < need)
      return;
   if(PerfCopyBuffer(maMiddleHandle, 0, 0, need, middle) < need)
      return;

   for(int barsAgo = 1; barsAgo <= MaCrossRecentBars && barsAgo < need; barsAgo++)
   {
      bool crossedUp = (fast[barsAgo] <= middle[barsAgo] && fast[barsAgo - 1] > middle[barsAgo - 1]);
      bool crossedDown = (fast[barsAgo] >= middle[barsAgo] && fast[barsAgo - 1] < middle[barsAgo - 1]);

      if(crossedUp)
      {
         crossCount++;
         if(crossUpBarsAgo < 0)
            crossUpBarsAgo = barsAgo - 1;
      }
      if(crossedDown)
      {
         crossCount++;
         if(crossDownBarsAgo < 0)
            crossDownBarsAgo = barsAgo - 1;
      }
   }
}

bool IsGoldLocationAllowed(bool isBuy, string &reason)
{
   reason = "GOLD location allowed";
   if(!UseGoldLocationFilter)
      return true;

   MqlTick tick;
   if(!SymbolInfoTick(_Symbol, tick))
   {
      reason = "Blocked: no tick for GOLD location";
      return false;
   }

   double price = isBuy ? tick.ask : tick.bid;
   double previousHigh = iHigh(_Symbol, PERIOD_D1, 1);
   double previousLow = iLow(_Symbol, PERIOD_D1, 1);
   double todayHigh = iHigh(_Symbol, PERIOD_D1, 0);
   double todayLow = iLow(_Symbol, PERIOD_D1, 0);

   int highIndex = iHighest(_Symbol, PERIOD_M5, MODE_HIGH, RecentHighLowLookbackBarsM5, 0);
   int lowIndex = iLowest(_Symbol, PERIOD_M5, MODE_LOW, RecentHighLowLookbackBarsM5, 0);
   double recentHigh = highIndex >= 0 ? iHigh(_Symbol, PERIOD_M5, highIndex) : 0.0;
   double recentLow = lowIndex >= 0 ? iLow(_Symbol, PERIOD_M5, lowIndex) : 0.0;

   if(isBuy)
   {
      if(AvoidBuyingNearRecentHigh && recentHigh > 0.0 && recentHigh - price <= NearHighLowDistanceDollars && price <= recentHigh)
      {
         reason = "BUY blocked: near recent high";
         return false;
      }
      if(AvoidTodayHighLowChase && todayHigh > 0.0 && todayHigh - price <= NearHighLowDistanceDollars && price <= todayHigh)
      {
         reason = "BUY blocked: near current day high";
         return false;
      }
      if(AvoidPreviousDayHighLowChase && previousHigh > 0.0 && previousHigh - price <= NearHighLowDistanceDollars && price <= previousHigh)
      {
         reason = "BUY blocked: near previous day high";
         return false;
      }
   }
   else
   {
      if(AvoidSellingNearRecentLow && recentLow > 0.0 && price - recentLow <= NearHighLowDistanceDollars && price >= recentLow)
      {
         reason = "SELL blocked: near recent low";
         return false;
      }
      if(AvoidTodayHighLowChase && todayLow > 0.0 && price - todayLow <= NearHighLowDistanceDollars && price >= todayLow)
      {
         reason = "SELL blocked: near current day low";
         return false;
      }
      if(AvoidPreviousDayHighLowChase && previousLow > 0.0 && price - previousLow <= NearHighLowDistanceDollars && price >= previousLow)
      {
         reason = "SELL blocked: near previous day low";
         return false;
      }
   }

   if(AvoidRangeMiddle && recentHigh > recentLow && recentHigh > 0.0 && recentLow > 0.0)
   {
      double range = recentHigh - recentLow;
      double mid = (recentHigh + recentLow) / 2.0;
      double zone = range * RangeMiddleZonePercent / 100.0 / 2.0;
      if(MathAbs(price - mid) <= zone)
      {
         reason = "Blocked: range middle";
         return false;
      }
   }

   if(AvoidRoundNumberEntry && RoundNumberStepDollars > 0.0)
   {
      double nearest = MathRound(price / RoundNumberStepDollars) * RoundNumberStepDollars;
      if(MathAbs(price - nearest) <= RoundNumberAvoidDistanceDollars)
      {
         reason = "Blocked: near round number";
         return false;
      }
   }

   if(AvoidEntryAfterSpike)
   {
      double spikeMove = GetRecentSpikeMove(SpikeLookbackSeconds, price);
      if(isBuy && spikeMove >= SpikeMoveDollars)
      {
         reason = "BUY blocked: after upward spike";
         return false;
      }
      if(!isBuy && spikeMove <= -SpikeMoveDollars)
      {
         reason = "SELL blocked: after downward spike";
         return false;
      }
   }

   return true;
}

bool IsNearLevel(double price, double level, double distance)
{
   return (level > 0.0 && MathAbs(price - level) <= distance);
}

double AverageBarRange(ENUM_TIMEFRAMES tf, int startShift, int bars)
{
   if(bars <= 0)
      return 0.0;
   double total = 0.0;
   int counted = 0;
   for(int i = startShift; i < startShift + bars; i++)
   {
      double high = iHigh(_Symbol, tf, i);
      double low = iLow(_Symbol, tf, i);
      if(high > 0.0 && low > 0.0 && high > low)
      {
         total += high - low;
         counted++;
      }
   }
   return counted > 0 ? total / counted : 0.0;
}

bool IsAtrExpansion()
{
   if(!UseAtrExpansionFilter)
      return false;
   double recent = AverageBarRange(PERIOD_M5, 1, 3);
   double base = AverageBarRange(PERIOD_M5, 4, 20);
   return (recent > 0.0 && base > 0.0 && recent >= base * 1.8);
}

bool IsBreakoutDanger(bool isBuy, ENUM_TIMEFRAMES tf, double price)
{
   if(!UseBreakoutDangerFilter)
      return false;
   int lookback = 24;
   int highIndex = iHighest(_Symbol, tf, MODE_HIGH, lookback, 1);
   int lowIndex = iLowest(_Symbol, tf, MODE_LOW, lookback, 1);
   double high = highIndex >= 0 ? iHigh(_Symbol, tf, highIndex) : 0.0;
   double low = lowIndex >= 0 ? iLow(_Symbol, tf, lowIndex) : 0.0;
   double close1 = iClose(_Symbol, tf, 1);
   if(isBuy && high > 0.0 && price > high && close1 > high)
      return true;
   if(!isBuy && low > 0.0 && price < low && close1 < low)
      return true;
   return false;
}

bool IsTechnicalDangerBlocked(bool isBuy, string &reason, bool countBlock)
{
   reason = "";
   if(!UseTechnicalDangerBlock)
      return false;

   MqlTick tick;
   if(!SymbolInfoTick(_Symbol, tick))
      return false;

   double price = isBuy ? tick.ask : tick.bid;
   double previousHigh = iHigh(_Symbol, PERIOD_D1, 1);
   double previousLow = iLow(_Symbol, PERIOD_D1, 1);
   double previousClose = iClose(_Symbol, PERIOD_D1, 1);
   double todayHigh = iHigh(_Symbol, PERIOD_D1, 0);
   double todayLow = iLow(_Symbol, PERIOD_D1, 0);
   double dangerDistance = MathMax(NearHighLowDistanceDollars, RoundNumberAvoidDistanceDollars);

   if(UsePreviousDayHighLowFilter)
   {
      if(isBuy && IsNearLevel(price, previousHigh, dangerDistance))
         reason = "TechnicalDanger: BUY near previous day high";
      if(!isBuy && IsNearLevel(price, previousLow, dangerDistance))
         reason = "TechnicalDanger: SELL near previous day low";
   }

   if(reason == "" && UseTodayHighLowFilter)
   {
      if(isBuy && IsNearLevel(price, todayHigh, dangerDistance))
         reason = "TechnicalDanger: BUY near current day high";
      if(!isBuy && IsNearLevel(price, todayLow, dangerDistance))
         reason = "TechnicalDanger: SELL near current day low";
   }

   if(reason == "" && UseDailyPivotFilter && previousHigh > previousLow && previousClose > 0.0)
   {
      double pivot = (previousHigh + previousLow + previousClose) / 3.0;
      double r1 = 2.0 * pivot - previousLow;
      double s1 = 2.0 * pivot - previousHigh;
      double r2 = pivot + (previousHigh - previousLow);
      double s2 = pivot - (previousHigh - previousLow);
      if(IsNearLevel(price, pivot, dangerDistance) || IsNearLevel(price, r1, dangerDistance) ||
         IsNearLevel(price, r2, dangerDistance) || IsNearLevel(price, s1, dangerDistance) ||
         IsNearLevel(price, s2, dangerDistance))
         reason = "TechnicalDanger: near daily pivot level";
   }

   if(reason == "" && UseH1H4SupportResistanceFilter)
   {
      if(IsBreakoutDanger(isBuy, PERIOD_H1, price) || IsBreakoutDanger(isBuy, PERIOD_H4, price))
         reason = isBuy ? "TechnicalDanger: H1/H4 upside breakout chase" : "TechnicalDanger: H1/H4 downside breakout chase";
   }

   if(reason == "" && IsAtrExpansion())
      reason = "TechnicalDanger: ATR expansion";

   if(reason != "")
   {
      currentTechnicalDangerActive = true;
      currentTechnicalDangerReason = reason;
      if(countBlock)
         blockedByTechnicalDangerCount++;
      return true;
   }

   return false;
}

void ResetFibContext(FibContextState &fib)
{
   fib.direction = "unknown";
   fib.startPrice = 0.0;
   fib.endPrice = 0.0;
   fib.currentZone = "none";
   fib.inZone = false;
   fib.trendAligned = false;
   fib.structureBroken = false;
}

void ResetCandlePattern(CandlePatternState &state)
{
   state.detected = false;
   state.confirmedBuy = false;
   state.confirmedSell = false;
   state.dangerBuy = false;
   state.dangerSell = false;
   state.patternType = "none";
   state.direction = "none";
   state.timeframeText = "";
   state.nearStructure = false;
   state.confirmed = false;
   state.dangerDetected = false;
   state.dangerReason = "";
}

void ResetStructureGateState(StructureGateState &state)
{
   state.structurePermissionBuy = true;
   state.structurePermissionSell = true;
   state.candlePermissionBuy = true;
   state.candlePermissionSell = true;
   state.tickTriggerPermissionBuy = false;
   state.tickTriggerPermissionSell = false;
   state.blockedPureTickEntryBuy = false;
   state.blockedPureTickEntrySell = false;
   state.blockedPureTickReasonBuy = "";
   state.blockedPureTickReasonSell = "";
   state.structureTrendState = "disabled";
   state.h1h4BreakoutState = "none";
   state.structureReasonBuy = "structure disabled";
   state.structureReasonSell = "structure disabled";
   state.candleReasonBuy = "candle disabled";
   state.candleReasonSell = "candle disabled";
   ResetFibContext(state.macroFib);
   ResetFibContext(state.dayFib);
   ResetFibContext(state.entryFib);
   state.macroDayFibAligned = true;
   state.previousDayHighDistance = 0.0;
   state.previousDayLowDistance = 0.0;
   state.pivotDistance = 0.0;
   state.nearestSupportResistance = 0.0;
   state.largeCandleDetected = false;
   state.consecutiveCandleDetected = false;
   ResetCandlePattern(state.candle);
   state.earlyExitReason = "";
   state.plannedAddReason = "";
   state.hedgedBasketLossCompressionReason = "";
}

string TfText(ENUM_TIMEFRAMES tf)
{
   return EnumToString(tf);
}

bool GetEmaValue(ENUM_TIMEFRAMES tf, int period, int shift, double &value)
{
   value = 0.0;
   int cachedHandle = INVALID_HANDLE;
   if(tf == PERIOD_H4 && period == 20) cachedHandle = structureH4Ema20Handle;
   else if(tf == PERIOD_H4 && period == 50) cachedHandle = structureH4Ema50Handle;
   else if(tf == PERIOD_H4 && period == 200) cachedHandle = structureH4Ema200Handle;
   else if(tf == PERIOD_H1 && period == 20) cachedHandle = structureH1Ema20Handle;
   else if(tf == PERIOD_H1 && period == 50) cachedHandle = structureH1Ema50Handle;
   else if(tf == PERIOD_H1 && period == 200) cachedHandle = structureH1Ema200Handle;
   else if(tf == PERIOD_M30 && period == 20) cachedHandle = structureM30Ema20Handle;
   else if(tf == PERIOD_M30 && period == 50) cachedHandle = structureM30Ema50Handle;
   else if(tf == PERIOD_M30 && period == 200) cachedHandle = structureM30Ema200Handle;

   if(cachedHandle != INVALID_HANDLE)
   {
      double cachedBuf[];
      ArraySetAsSeries(cachedBuf, true);
      if(PerfCopyBuffer(cachedHandle, 0, shift, 1, cachedBuf) >= 1 && IsValidValue(cachedBuf[0]))
      {
         value = cachedBuf[0];
         return true;
      }
   }

   int handle = iMA(_Symbol, tf, period, 0, MODE_EMA, PRICE_CLOSE);
   if(handle == INVALID_HANDLE)
      return false;
   double buf[];
   ArraySetAsSeries(buf, true);
   bool ok = (PerfCopyBuffer(handle, 0, shift, 1, buf) >= 1 && IsValidValue(buf[0]));
   if(ok)
      value = buf[0];
   IndicatorRelease(handle);
   return ok;
}

string StructureDirectionForTimeframe(ENUM_TIMEFRAMES tf)
{
   double ema20 = 0.0, ema50 = 0.0, ema200 = 0.0, ema20Prev = 0.0, ema50Prev = 0.0;
   double close1 = iClose(_Symbol, tf, 1);
   if(close1 <= 0.0)
      return "unknown";
   if(!GetEmaValue(tf, 20, 1, ema20) || !GetEmaValue(tf, 50, 1, ema50) || !GetEmaValue(tf, 200, 1, ema200))
      return "unknown";
   if(!GetEmaValue(tf, 20, 6, ema20Prev) || !GetEmaValue(tf, 50, 6, ema50Prev))
      return "unknown";

   int highIndex = iHighest(_Symbol, tf, MODE_HIGH, 24, 2);
   int lowIndex = iLowest(_Symbol, tf, MODE_LOW, 24, 2);
   double recentHigh = highIndex >= 0 ? iHigh(_Symbol, tf, highIndex) : 0.0;
   double recentLow = lowIndex >= 0 ? iLow(_Symbol, tf, lowIndex) : 0.0;
   bool bosUp = (recentHigh > 0.0 && close1 > recentHigh);
   bool bosDown = (recentLow > 0.0 && close1 < recentLow);
   bool bullish = (ema20 > ema50 && ema50 > ema200 && ema20 >= ema20Prev && ema50 >= ema50Prev && close1 > ema20);
   bool bearish = (ema20 < ema50 && ema50 < ema200 && ema20 <= ema20Prev && ema50 <= ema50Prev && close1 < ema20);

   if(bullish || bosUp)
      return "bullish";
   if(bearish || bosDown)
      return "bearish";
   return "neutral";
}

string CombineStructureDirection()
{
   string macro = StructureDirectionForTimeframe((ENUM_TIMEFRAMES)MacroStructureTimeframe);
   string h1 = StructureDirectionForTimeframe((ENUM_TIMEFRAMES)StructureConfirmTimeframe1);
   string m30 = StructureDirectionForTimeframe((ENUM_TIMEFRAMES)StructureConfirmTimeframe2);
   int bull = 0, bear = 0;
   if(macro == "bullish") bull++; else if(macro == "bearish") bear++;
   if(h1 == "bullish") bull++; else if(h1 == "bearish") bear++;
   if(m30 == "bullish") bull++; else if(m30 == "bearish") bear++;
   if(bull >= 2 && bear == 0)
      return "strong bullish";
   if(bear >= 2 && bull == 0)
      return "strong bearish";
   if(bull > bear)
      return "bullish";
   if(bear > bull)
      return "bearish";
   return "neutral";
}

void EvaluateFibContext(ENUM_TIMEFRAMES tf, int lookback, string direction, double price, FibContextState &fib)
{
   ResetFibContext(fib);
   fib.direction = direction;
   if(direction != "bullish" && direction != "bearish" && direction != "strong bullish" && direction != "strong bearish")
      return;
   if(lookback < 20)
      lookback = 20;

   int highIndex = iHighest(_Symbol, tf, MODE_HIGH, lookback, 1);
   int lowIndex = iLowest(_Symbol, tf, MODE_LOW, lookback, 1);
   if(highIndex < 0 || lowIndex < 0)
      return;

   double high = iHigh(_Symbol, tf, highIndex);
   double low = iLow(_Symbol, tf, lowIndex);
   if(high <= low || high <= 0.0 || low <= 0.0)
      return;

   double atr = AverageBarRange(tf, 1, 20);
   if(atr > 0.0 && (high - low) < atr * FibMinSwingAtrMultiplier)
      return;

   bool bullish = (StringFind(direction, "bullish") >= 0);
   fib.startPrice = bullish ? low : high;
   fib.endPrice = bullish ? high : low;
   fib.trendAligned = true;

   double range = high - low;
   double p382 = bullish ? high - range * 0.382 : low + range * 0.382;
   double p500 = bullish ? high - range * 0.500 : low + range * 0.500;
   double p618 = bullish ? high - range * 0.618 : low + range * 0.618;
   double p786 = bullish ? high - range * 0.786 : low + range * 0.786;
   double upper = MathMax(p382, p786) + FibZoneToleranceDollars;
   double lower = MathMin(p382, p786) - FibZoneToleranceDollars;
   fib.inZone = (price >= lower && price <= upper);

   if(fib.inZone)
   {
      if(price >= MathMin(p382, p500) - FibZoneToleranceDollars && price <= MathMax(p382, p500) + FibZoneToleranceDollars)
         fib.currentZone = "38.2-50.0";
      else if(price >= MathMin(p500, p618) - FibZoneToleranceDollars && price <= MathMax(p500, p618) + FibZoneToleranceDollars)
         fib.currentZone = "50.0-61.8";
      else if(price >= MathMin(p618, p786) - FibZoneToleranceDollars && price <= MathMax(p618, p786) + FibZoneToleranceDollars)
         fib.currentZone = "61.8-78.6";
      else
         fib.currentZone = "fib edge";
   }
   else
      fib.currentZone = "outside";

   fib.structureBroken = bullish ? (price < p786 - FibZoneToleranceDollars) : (price > p786 + FibZoneToleranceDollars);
}

double DailyPivotDistance(double price)
{
   double previousHigh = iHigh(_Symbol, PERIOD_D1, 1);
   double previousLow = iLow(_Symbol, PERIOD_D1, 1);
   double previousClose = iClose(_Symbol, PERIOD_D1, 1);
   if(previousHigh <= previousLow || previousClose <= 0.0)
      return 0.0;
   double pivot = (previousHigh + previousLow + previousClose) / 3.0;
   double r1 = 2.0 * pivot - previousLow;
   double s1 = 2.0 * pivot - previousHigh;
   double r2 = pivot + (previousHigh - previousLow);
   double s2 = pivot - (previousHigh - previousLow);
   double nearest = MathAbs(price - pivot);
   nearest = MathMin(nearest, MathAbs(price - r1));
   nearest = MathMin(nearest, MathAbs(price - s1));
   nearest = MathMin(nearest, MathAbs(price - r2));
   nearest = MathMin(nearest, MathAbs(price - s2));
   return nearest;
}

double NearestSupportResistanceDistance(double price)
{
   double nearest = 0.0;
   ENUM_TIMEFRAMES tfs[2] = {PERIOD_H1, PERIOD_H4};
   for(int t = 0; t < 2; t++)
   {
      int highIndex = iHighest(_Symbol, tfs[t], MODE_HIGH, 48, 1);
      int lowIndex = iLowest(_Symbol, tfs[t], MODE_LOW, 48, 1);
      double high = highIndex >= 0 ? iHigh(_Symbol, tfs[t], highIndex) : 0.0;
      double low = lowIndex >= 0 ? iLow(_Symbol, tfs[t], lowIndex) : 0.0;
      if(high > 0.0)
      {
         double d = MathAbs(price - high);
         nearest = nearest <= 0.0 ? d : MathMin(nearest, d);
      }
      if(low > 0.0)
      {
         double d = MathAbs(price - low);
         nearest = nearest <= 0.0 ? d : MathMin(nearest, d);
      }
   }
   return nearest;
}

bool IsLargeCandle(ENUM_TIMEFRAMES tf, bool isBuy)
{
   if(!UseLargeCandleDangerFilter)
      return false;
   double high = iHigh(_Symbol, tf, 1);
   double low = iLow(_Symbol, tf, 1);
   double open = iOpen(_Symbol, tf, 1);
   double close = iClose(_Symbol, tf, 1);
   double atr = AverageBarRange(tf, 2, 20);
   if(high <= low || atr <= 0.0)
      return false;
   bool large = ((high - low) >= atr * LargeCandleAtrMultiplier || MathAbs(close - open) >= atr * LargeCandleAtrMultiplier);
   if(!large)
      return false;
   if(isBuy && close > open)
      return true;
   if(!isBuy && close < open)
      return true;
   return false;
}

bool IsConsecutiveCandleDanger(ENUM_TIMEFRAMES tf, bool isBuy)
{
   if(!UseConsecutiveCandleDangerFilter || ConsecutiveCandleCount <= 1)
      return false;
   for(int i = 1; i <= ConsecutiveCandleCount; i++)
   {
      double open = iOpen(_Symbol, tf, i);
      double close = iClose(_Symbol, tf, i);
      if(open <= 0.0 || close <= 0.0)
         return false;
      if(isBuy && close <= open)
         return false;
      if(!isBuy && close >= open)
         return false;
   }
   return true;
}

void DetectCandlePatternOnTf(ENUM_TIMEFRAMES tf, bool nearStructure, CandlePatternState &state)
{
   double o1 = iOpen(_Symbol, tf, 1), c1 = iClose(_Symbol, tf, 1), h1 = iHigh(_Symbol, tf, 1), l1 = iLow(_Symbol, tf, 1);
   double o2 = iOpen(_Symbol, tf, 2), c2 = iClose(_Symbol, tf, 2), h2 = iHigh(_Symbol, tf, 2), l2 = iLow(_Symbol, tf, 2);
   if(o1 <= 0.0 || c1 <= 0.0 || h1 <= l1 || o2 <= 0.0 || c2 <= 0.0)
      return;

   double body1 = MathMax(MathAbs(c1 - o1), _Point);
   double range1 = h1 - l1;
   double upperWick = h1 - MathMax(o1, c1);
   double lowerWick = MathMin(o1, c1) - l1;
   double body2 = MathMax(MathAbs(c2 - o2), _Point);

   if(UseDojiDangerFilter && range1 > 0.0 && body1 / range1 <= DojiMaxBodyToRangeRatio && nearStructure)
   {
      state.dangerDetected = true;
      state.dangerBuy = true;
      state.dangerSell = true;
      state.dangerReason = "Doji near structure";
      dojiDangerBlockCount++;
   }

   if(!nearStructure)
      return;

   bool bullishPin = UseBullishPinBarConfirmation && lowerWick >= body1 * PinBarWickBodyRatio && upperWick <= body1 * MaxOppositeWickBodyRatio && c1 > o1;
   bool bearishPin = UseBearishPinBarConfirmation && upperWick >= body1 * PinBarWickBodyRatio && lowerWick <= body1 * MaxOppositeWickBodyRatio && c1 < o1;
   bool bullishEngulf = UseEngulfingConfirmation && c1 > o1 && c2 < o2 && o1 <= c2 && c1 >= o2 && body1 >= body2 * EngulfingMinBodyRatio;
   bool bearishEngulf = UseEngulfingConfirmation && c1 < o1 && c2 > o2 && o1 >= c2 && c1 <= o2 && body1 >= body2 * EngulfingMinBodyRatio;
   bool bullishOutside = UseOutsideBarConfirmation && h1 > h2 && l1 < l2 && c1 > o1;
   bool bearishOutside = UseOutsideBarConfirmation && h1 > h2 && l1 < l2 && c1 < o1;
   bool bullishSpike = UseSpikeReversalConfirmation && lowerWick >= body1 * SpikeWickBodyRatio && c1 > (h1 + l1) / 2.0;
   bool bearishSpike = UseSpikeReversalConfirmation && upperWick >= body1 * SpikeWickBodyRatio && c1 < (h1 + l1) / 2.0;

   if(bullishPin || bullishEngulf || bullishOutside || bullishSpike)
   {
      state.detected = true;
      state.confirmed = true;
      state.confirmedBuy = true;
      state.direction = "BUY";
      state.timeframeText = TfText(tf);
      state.nearStructure = true;
      if(bullishPin) { state.patternType = "Bullish Pin Bar"; bullishPinBarCount++; }
      else if(bullishEngulf) { state.patternType = "Bullish Engulfing"; engulfingConfirmationCount++; }
      else if(bullishOutside) state.patternType = "Bullish Outside Bar";
      else { state.patternType = "Spike Reversal Buy"; spikeReversalConfirmationCount++; }
      candlePatternConfirmationCount++;
   }

   if(!state.confirmed && (bearishPin || bearishEngulf || bearishOutside || bearishSpike))
   {
      state.detected = true;
      state.confirmed = true;
      state.confirmedSell = true;
      state.direction = "SELL";
      state.timeframeText = TfText(tf);
      state.nearStructure = true;
      if(bearishPin) { state.patternType = "Bearish Pin Bar"; bearishPinBarCount++; }
      else if(bearishEngulf) { state.patternType = "Bearish Engulfing"; engulfingConfirmationCount++; }
      else if(bearishOutside) state.patternType = "Bearish Outside Bar";
      else { state.patternType = "Spike Reversal Sell"; spikeReversalConfirmationCount++; }
      candlePatternConfirmationCount++;
   }
}

void EvaluateStructureGate(const MqlTick &tick, const ScoreState &score, const FilterState &dxy, const FilterState &vix, const MaStructureState &ma, double threshold)
{
   ResetStructureGateState(currentStructureGate);
   double price = (tick.bid + tick.ask) / 2.0;
   currentStructureGate.tickTriggerPermissionBuy = (score.longScore >= threshold && score.longScore > score.shortScore && score.longScore - score.shortScore >= MinimumScoreDifference);
   currentStructureGate.tickTriggerPermissionSell = (score.shortScore >= threshold && score.shortScore > score.longScore && score.shortScore - score.longScore >= MinimumScoreDifference);

   double previousHighForStructure = iHigh(_Symbol, PERIOD_D1, 1);
   double previousLowForStructure = iLow(_Symbol, PERIOD_D1, 1);
   currentStructureGate.previousDayHighDistance = previousHighForStructure > 0.0 ? MathAbs(price - previousHighForStructure) : 0.0;
   currentStructureGate.previousDayLowDistance = previousLowForStructure > 0.0 ? MathAbs(price - previousLowForStructure) : 0.0;
   currentStructureGate.pivotDistance = DailyPivotDistance(price);
   currentStructureGate.nearestSupportResistance = NearestSupportResistanceDistance(price);
   bool nonFibLocationEvidence = ((UsePreviousDayHighLowStructure && (currentStructureGate.previousDayHighDistance <= StructureNearPriceDollars || currentStructureGate.previousDayLowDistance <= StructureNearPriceDollars)) ||
                                  (UsePivotStructureFilter && currentStructureGate.pivotDistance > 0.0 && currentStructureGate.pivotDistance <= StructureNearPriceDollars) ||
                                  (UseSupportResistanceStructureFilter && currentStructureGate.nearestSupportResistance > 0.0 && currentStructureGate.nearestSupportResistance <= StructureNearPriceDollars));

   string trend = UseGoldStructureFilter ? CombineStructureDirection() : "disabled";
   currentStructureGate.structureTrendState = trend;
   currentStructureGate.structurePermissionBuy = (!UseGoldStructureFilter || StringFind(trend, "bullish") >= 0);
   currentStructureGate.structurePermissionSell = (!UseGoldStructureFilter || StringFind(trend, "bearish") >= 0);
   currentStructureGate.structureReasonBuy = currentStructureGate.structurePermissionBuy ? "structure BUY allowed" : "BUY blocked: H4/H1/M30 structure not bullish";
   currentStructureGate.structureReasonSell = currentStructureGate.structurePermissionSell ? "structure SELL allowed" : "SELL blocked: H4/H1/M30 structure not bearish";

   if(UseAutoFibonacciContext)
   {
      EvaluateFibContext((ENUM_TIMEFRAMES)MacroFibTimeframe1, FibLookbackBarsMacro, trend, price, currentStructureGate.macroFib);
      EvaluateFibContext((ENUM_TIMEFRAMES)DayFibTimeframe1, FibLookbackBarsDay, trend, price, currentStructureGate.dayFib);
      EvaluateFibContext((ENUM_TIMEFRAMES)EntryFibTimeframe2, FibLookbackBarsEntry, trend, price, currentStructureGate.entryFib);
      currentStructureGate.macroDayFibAligned = (currentStructureGate.macroFib.direction == currentStructureGate.dayFib.direction ||
                                                currentStructureGate.macroFib.direction == "unknown" ||
                                                currentStructureGate.dayFib.direction == "unknown");
      if(RequireMacroDayFibAlignment && !currentStructureGate.macroDayFibAligned)
      {
         currentStructureGate.structurePermissionBuy = false;
         currentStructureGate.structurePermissionSell = false;
         currentStructureGate.structureReasonBuy = "BUY blocked: MacroFib and DayFib mismatch";
         currentStructureGate.structureReasonSell = "SELL blocked: MacroFib and DayFib mismatch";
      }
      if(RequireDayFibForEntry && !currentStructureGate.dayFib.inZone && !nonFibLocationEvidence)
      {
         if(StringFind(trend, "bullish") >= 0)
         {
            currentStructureGate.structurePermissionBuy = false;
            currentStructureGate.structureReasonBuy = "BUY blocked: price outside DayFib zone";
         }
         if(StringFind(trend, "bearish") >= 0)
         {
            currentStructureGate.structurePermissionSell = false;
            currentStructureGate.structureReasonSell = "SELL blocked: price outside DayFib zone";
         }
      }
      if(RequireEntryFibConfirmation && !currentStructureGate.entryFib.inZone)
      {
         currentStructureGate.structurePermissionBuy = false;
         currentStructureGate.structurePermissionSell = false;
      }
   }

   double previousHigh = iHigh(_Symbol, PERIOD_D1, 1);
   double previousLow = iLow(_Symbol, PERIOD_D1, 1);
   currentStructureGate.previousDayHighDistance = previousHigh > 0.0 ? MathAbs(price - previousHigh) : 0.0;
   currentStructureGate.previousDayLowDistance = previousLow > 0.0 ? MathAbs(price - previousLow) : 0.0;
   currentStructureGate.pivotDistance = DailyPivotDistance(price);
   currentStructureGate.nearestSupportResistance = NearestSupportResistanceDistance(price);
   bool nearStructure = (currentStructureGate.dayFib.inZone || currentStructureGate.entryFib.inZone ||
                         (UsePreviousDayHighLowStructure && (currentStructureGate.previousDayHighDistance <= StructureNearPriceDollars || currentStructureGate.previousDayLowDistance <= StructureNearPriceDollars)) ||
                         (UsePivotStructureFilter && currentStructureGate.pivotDistance > 0.0 && currentStructureGate.pivotDistance <= StructureNearPriceDollars) ||
                         (UseSupportResistanceStructureFilter && currentStructureGate.nearestSupportResistance > 0.0 && currentStructureGate.nearestSupportResistance <= StructureNearPriceDollars));

   currentStructureGate.largeCandleDetected = IsLargeCandle((ENUM_TIMEFRAMES)EntryConfirmTimeframe2, true) || IsLargeCandle((ENUM_TIMEFRAMES)EntryConfirmTimeframe2, false);
   currentStructureGate.consecutiveCandleDetected = IsConsecutiveCandleDanger((ENUM_TIMEFRAMES)EntryConfirmTimeframe2, true) || IsConsecutiveCandleDanger((ENUM_TIMEFRAMES)EntryConfirmTimeframe2, false);
   if(IsBreakoutDanger(true, PERIOD_H1, price) || IsBreakoutDanger(true, PERIOD_H4, price))
      currentStructureGate.h1h4BreakoutState = "upside breakout danger";
   else if(IsBreakoutDanger(false, PERIOD_H1, price) || IsBreakoutDanger(false, PERIOD_H4, price))
      currentStructureGate.h1h4BreakoutState = "downside breakout danger";

   if(UseCandlePatternConfirmation || UseCandlePatternDangerFilter)
   {
      ResetCandlePattern(currentStructureGate.candle);
      DetectCandlePatternOnTf((ENUM_TIMEFRAMES)EntryConfirmTimeframe1, nearStructure, currentStructureGate.candle);
      if(!currentStructureGate.candle.confirmed)
         DetectCandlePatternOnTf((ENUM_TIMEFRAMES)EntryConfirmTimeframe2, nearStructure, currentStructureGate.candle);
      currentStructureGate.candlePermissionBuy = (!UseCandlePatternConfirmation || currentStructureGate.candle.confirmedBuy);
      currentStructureGate.candlePermissionSell = (!UseCandlePatternConfirmation || currentStructureGate.candle.confirmedSell);
      if(UseCandlePatternDangerFilter && (currentStructureGate.candle.dangerBuy || currentStructureGate.largeCandleDetected || currentStructureGate.consecutiveCandleDetected))
         currentStructureGate.candlePermissionBuy = false;
      if(UseCandlePatternDangerFilter && (currentStructureGate.candle.dangerSell || currentStructureGate.largeCandleDetected || currentStructureGate.consecutiveCandleDetected))
         currentStructureGate.candlePermissionSell = false;
      currentStructureGate.candleReasonBuy = currentStructureGate.candlePermissionBuy ? "candle BUY confirmed" : "BUY blocked: candle confirmation/danger";
      currentStructureGate.candleReasonSell = currentStructureGate.candlePermissionSell ? "candle SELL confirmed" : "SELL blocked: candle confirmation/danger";
   }

   if(!AllowPureTickEntry && UseStructureBeforeTickEntry)
   {
      if(!currentStructureGate.structurePermissionBuy || !currentStructureGate.candlePermissionBuy)
      {
         currentStructureGate.blockedPureTickEntryBuy = true;
         currentStructureGate.blockedPureTickReasonBuy = !currentStructureGate.structurePermissionBuy ? currentStructureGate.structureReasonBuy : currentStructureGate.candleReasonBuy;
      }
      if(!currentStructureGate.structurePermissionSell || !currentStructureGate.candlePermissionSell)
      {
         currentStructureGate.blockedPureTickEntrySell = true;
         currentStructureGate.blockedPureTickReasonSell = !currentStructureGate.structurePermissionSell ? currentStructureGate.structureReasonSell : currentStructureGate.candleReasonSell;
      }
   }
}

bool CheckStructureEntryGate(bool isBuy, const ScoreState &score, string &reason)
{
   if(!UseStructureBeforeTickEntry && AllowPureTickEntry)
      return true;
   if(!AllowPureTickEntry && UseStructureBeforeTickEntry)
   {
      bool structureOk = isBuy ? currentStructureGate.structurePermissionBuy : currentStructureGate.structurePermissionSell;
      bool candleOk = isBuy ? currentStructureGate.candlePermissionBuy : currentStructureGate.candlePermissionSell;
      bool tickOk = isBuy ? currentStructureGate.tickTriggerPermissionBuy : currentStructureGate.tickTriggerPermissionSell;
      if(!structureOk)
      {
         reason = isBuy ? currentStructureGate.structureReasonBuy : currentStructureGate.structureReasonSell;
         blockedPureTickEntryCount++;
         blockedByGoldStructureCount++;
         if(StringFind(reason, "Fib") >= 0 || StringFind(reason, "fib") >= 0)
            blockedByFibContextCount++;
         if(StringFind(reason, "MacroFib") >= 0)
            blockedByMacroDayMismatchCount++;
         if(currentStructureGate.previousDayHighDistance > 0.0 && currentStructureGate.previousDayHighDistance <= StructureNearPriceDollars)
            blockedByPreviousDayHighLowCount++;
         if(currentStructureGate.previousDayLowDistance > 0.0 && currentStructureGate.previousDayLowDistance <= StructureNearPriceDollars)
            blockedByPreviousDayHighLowCount++;
         if(currentStructureGate.pivotDistance > 0.0 && currentStructureGate.pivotDistance <= StructureNearPriceDollars)
            blockedByPivotCount++;
         if(currentStructureGate.h1h4BreakoutState != "none")
            blockedByH1H4BreakoutCount++;
         return false;
      }
      if(!candleOk)
      {
         reason = isBuy ? currentStructureGate.candleReasonBuy : currentStructureGate.candleReasonSell;
         blockedPureTickEntryCount++;
         blockedByCandlePatternCount++;
         if(currentStructureGate.largeCandleDetected)
            blockedByLargeCandleCount++;
         if(currentStructureGate.consecutiveCandleDetected)
            blockedByConsecutiveCandleCount++;
         return false;
      }
      if(RequireTickScoreAfterStructure && !tickOk)
      {
         reason = "tick trigger not confirmed after structure";
         return false;
      }
   }
   return true;
}

bool CheckStructureBasedEarlyExit(const PositionState &ps)
{
   if(!UseStructureBasedEarlyExit || ps.total <= 0 || ps.floatingProfit >= -EarlyExitSoftLossYen)
      return false;
   bool buyExposure = ps.net > 0;
   bool sellExposure = ps.net < 0;
   if(!buyExposure && !sellExposure)
      return false;
   bool structureBroken = buyExposure ? (!currentStructureGate.structurePermissionBuy || currentStructureGate.dayFib.structureBroken || currentStructureGate.entryFib.structureBroken)
                                      : (!currentStructureGate.structurePermissionSell || currentStructureGate.dayFib.structureBroken || currentStructureGate.entryFib.structureBroken);
   bool hardLoss = (EarlyExitMaxLossYen > 0.0 && ps.floatingProfit <= -EarlyExitMaxLossYen);
   if(structureBroken && (hardLoss || currentStructureGate.largeCandleDetected || IsAtrExpansion()))
   {
      currentStructureGate.earlyExitReason = buyExposure ? "BUY structure broken early exit" : "SELL structure broken early exit";
      lastStopReason = currentStructureGate.earlyExitReason;
      structureBasedEarlyExitCount++;
      structureBasedEarlyExitProfitTotal += ps.floatingProfit;
      return CloseAllEaPositions("structure based early exit");
   }
   return false;
}

bool CheckPlannedAddPositionGate(bool isBuy, string &reason)
{
   reason = "planned add allowed";
   if(!UsePlannedAddPositionOnly)
      return true;
   if(CountAddPositions(isBuy) >= MaxPlannedAddPositions)
   {
      reason = "planned add blocked: max planned add positions";
      return false;
   }
   if(AddPositionRequiresStructureSupport)
   {
      bool structureOk = isBuy ? currentStructureGate.structurePermissionBuy : currentStructureGate.structurePermissionSell;
      if(!structureOk)
      {
         reason = "planned add blocked: no structure support";
         return false;
      }
   }
   if(AddPositionRequiresFibOrSr)
   {
      bool fibOrSr = currentStructureGate.dayFib.inZone || currentStructureGate.entryFib.inZone ||
                     (currentStructureGate.nearestSupportResistance > 0.0 && currentStructureGate.nearestSupportResistance <= StructureNearPriceDollars) ||
                     (currentStructureGate.pivotDistance > 0.0 && currentStructureGate.pivotDistance <= StructureNearPriceDollars);
      if(!fibOrSr)
      {
         reason = "planned add blocked: no Fib/SR support";
         return false;
      }
   }
   if(AddPositionRequiresCandleConfirmation)
   {
      bool candleOk = isBuy ? currentStructureGate.candlePermissionBuy : currentStructureGate.candlePermissionSell;
      if(!candleOk)
      {
         reason = "planned add blocked: no candle confirmation";
         return false;
      }
   }
   if(IsAtrExpansion())
   {
      reason = "planned add blocked: ATR expansion";
      return false;
   }
   currentStructureGate.plannedAddReason = reason;
   return true;
}

bool CheckHedgedBasketLossCompression(const PositionState &ps, datetime firstHedgeTime)
{
   if(!UseHedgedBasketLossCompression || firstHedgeTime <= 0 || ps.total < 2)
      return false;
   if(hedgedBasketCompressionReviewTime != firstHedgeTime)
   {
      hedgedBasketCompressionReviewTime = firstHedgeTime;
      hedgedBasketCompressionReferenceProfit = ps.floatingProfit;
   }
   if(HedgedBasketReviewMinutes <= 0 || TimeCurrent() - firstHedgeTime < HedgedBasketReviewMinutes * 60)
      return false;
   double improvement = ps.floatingProfit - hedgedBasketCompressionReferenceProfit;
   bool improving = improvement >= HedgedBasketRequiredImprovementYen;
   bool extraHoldExpired = (HedgedBasketExtraHoldWhenImprovingMinutes > 0 &&
                            TimeCurrent() - firstHedgeTime >= (HedgedBasketReviewMinutes + HedgedBasketExtraHoldWhenImprovingMinutes) * 60);
   bool compressedLossExceeded = (HedgedBasketCompressedMaxLossYen > 0.0 && ps.floatingProfit <= -HedgedBasketCompressedMaxLossYen);
   if(compressedLossExceeded && (!improving || extraHoldExpired))
   {
      currentStructureGate.hedgedBasketLossCompressionReason = improving ? "loss compression extra hold expired" : "loss compression no recovery";
      lastStopReason = currentStructureGate.hedgedBasketLossCompressionReason;
      hedgedBasketLossCompressionCount++;
      return CloseAllEaPositions("Hedged basket loss compression");
   }
   return false;
}

bool ListContainsHour(string listText, int hour)
{
   string parts[];
   int count = StringSplit(listText, ',', parts);
   for(int i = 0; i < count; i++)
   {
      string item = TrimText(parts[i]);
      if(item == "")
         continue;
      if((int)StringToInteger(item) == hour)
         return true;
   }
   return false;
}

bool ListContainsWeekdayHour(string listText, int weekday, int hour)
{
   string parts[];
   int count = StringSplit(listText, ',', parts);
   for(int i = 0; i < count; i++)
   {
      string item = TrimText(parts[i]);
      if(item == "")
         continue;
      string wh[];
      if(StringSplit(item, '-', wh) != 2)
         continue;
      int w = (int)StringToInteger(TrimText(wh[0]));
      int h = (int)StringToInteger(TrimText(wh[1]));
      if(w == weekday && h == hour)
         return true;
   }
   return false;
}

int MqlWeekdayToMondayZero(int dayOfWeek)
{
   if(dayOfWeek == 0)
      return 6;
   return dayOfWeek - 1;
}

void EvaluateHistoricalTimeRisk()
{
   currentHistoricalTimeRiskActive = false;
   currentHistoricalTimeHighRisk = false;
   currentHistoricalTimeCaution = false;
   currentHistoricalTimeQuiet = false;
   currentHistoricalWeekdayHourBlock = false;
   currentHistoricalTimeSourceHour = -1;
   currentHistoricalTimeSourceWeekday = -1;
   currentHistoricalTimeScoreAdd = 0.0;
   currentHistoricalTimeRiskState = "disabled";
   currentHistoricalTimeRiskReason = "";

   if(!UseHistoricalTimeRiskFilter)
      return;

   datetime sourceTime = TimeCurrent() - HistoricalTimeOffsetHours * 3600;
   MqlDateTime dt;
   TimeToStruct(sourceTime, dt);
   currentHistoricalTimeSourceHour = dt.hour;
   currentHistoricalTimeSourceWeekday = MqlWeekdayToMondayZero(dt.day_of_week);

   currentHistoricalTimeHighRisk = ListContainsHour(HighRiskHoursSourceTime, dt.hour);
   currentHistoricalTimeCaution = ListContainsHour(CautionRiskHoursSourceTime, dt.hour);
   currentHistoricalTimeQuiet = ListContainsHour(QuietBlockHoursSourceTime, dt.hour);
   currentHistoricalWeekdayHourBlock = UseWeekdayHourRiskBlock && ListContainsWeekdayHour(WeekdayHourRiskBlocksSourceTime, currentHistoricalTimeSourceWeekday, dt.hour);

   if(currentHistoricalTimeQuiet)
   {
      currentHistoricalTimeRiskState = "quiet_block";
      currentHistoricalTimeRiskReason = "HistoricalTimeRisk: quiet low-edge hour";
      currentHistoricalTimeRiskActive = true;
   }
   else if(currentHistoricalWeekdayHourBlock)
   {
      currentHistoricalTimeRiskState = "weekday_hour_high_risk";
      currentHistoricalTimeRiskReason = "HistoricalTimeRisk: weekday-hour high risk";
      currentHistoricalTimeRiskActive = true;
      currentHistoricalTimeScoreAdd = HighRiskEntryScoreAdd;
   }
   else if(currentHistoricalTimeHighRisk)
   {
      currentHistoricalTimeRiskState = "high_risk";
      currentHistoricalTimeRiskReason = "HistoricalTimeRisk: high volatility whipsaw hour";
      currentHistoricalTimeRiskActive = true;
      currentHistoricalTimeScoreAdd = HighRiskEntryScoreAdd;
   }
   else if(currentHistoricalTimeCaution)
   {
      currentHistoricalTimeRiskState = "caution";
      currentHistoricalTimeRiskReason = "HistoricalTimeRisk: caution hour";
      currentHistoricalTimeRiskActive = true;
      currentHistoricalTimeScoreAdd = CautionRiskEntryScoreAdd;
   }
   else
   {
      currentHistoricalTimeRiskState = "clear";
      currentHistoricalTimeRiskReason = "HistoricalTimeRisk clear";
   }
}

bool IsHistoricalTimeRiskEntryBlocked(bool isBuy, bool isDefenseEntry, string &reason)
{
   if(!UseHistoricalTimeRiskFilter)
      return false;

   if(currentHistoricalTimeQuiet && BlockNewEntryInQuietHours && !isDefenseEntry)
   {
      reason = currentHistoricalTimeRiskReason;
      blockedByHistoricalTimeRiskCount++;
      blockedNewEntryByHistoricalTimeRiskCount++;
      return true;
   }

   if(currentHistoricalTimeQuiet && BlockDefenseHedgeInQuietHours && isDefenseEntry)
   {
      reason = "HEDGE blocked: " + currentHistoricalTimeRiskReason;
      blockedByHistoricalTimeRiskCount++;
      blockedDefenseHedgeByHistoricalTimeRiskCount++;
      return true;
   }

   if(BlockBreakoutChaseInHighRiskHours && !isDefenseEntry && (currentHistoricalTimeHighRisk || currentHistoricalWeekdayHourBlock))
   {
      MqlTick tick;
      if(SymbolInfoTick(_Symbol, tick))
      {
         double price = isBuy ? tick.ask : tick.bid;
         if(IsBreakoutDanger(isBuy, PERIOD_H1, price) || IsBreakoutDanger(isBuy, PERIOD_H4, price) || currentTechnicalDangerActive)
         {
            reason = "HistoricalTimeRisk: breakout chase blocked";
            blockedByHistoricalTimeRiskCount++;
            blockedBreakoutChaseByHistoricalTimeRiskCount++;
            return true;
         }
      }
   }

   return false;
}

datetime GetEarliestEaPositionTime()
{
   datetime earliest = 0;
   for(int i = PerfPositionsTotal() - 1; i >= 0; i--)
   {
      ulong ticket = PositionGetTicket(i);
      if(ticket == 0 || !PositionSelectByTicket(ticket) || !IsEaPosition())
         continue;
      datetime openTime = (datetime)PositionGetInteger(POSITION_TIME);
      if(openTime <= 0)
         continue;
      if(earliest == 0 || openTime < earliest)
         earliest = openTime;
   }
   return earliest;
}

double GetGrossLotsByType(int positionType)
{
   double lots = 0.0;
   for(int i = PerfPositionsTotal() - 1; i >= 0; i--)
   {
      ulong ticket = PositionGetTicket(i);
      if(ticket == 0 || !PositionSelectByTicket(ticket) || !IsEaPosition())
         continue;
      if((int)PositionGetInteger(POSITION_TYPE) == positionType)
         lots += PositionGetDouble(POSITION_VOLUME);
   }
   return lots;
}

string GetPostHedgeDiagSessionJst()
{
   MqlDateTime jst;
   TimeToStruct(TimeGMT() + 9 * 3600, jst);
   int minuteOfDay = jst.hour * 60 + jst.min;
   if(minuteOfDay >= 7 * 60 && minuteOfDay < 15 * 60)
      return "ASIA";
   if(minuteOfDay >= 15 * 60 && minuteOfDay < 21 * 60)
      return "LONDON";
   if(minuteOfDay >= 21 * 60 || minuteOfDay < 3 * 60)
      return "NY";
   return "QUIET";
}

int MinutesToEstimatedDailyMarketClose()
{
   datetime now = TimeCurrent();
   datetime closeTime = EstimatedNextDailyMarketClose(now);
   int secondsToClose = (int)(closeTime - now);
   if(secondsToClose < 0)
      return -1;
   return (int)MathFloor(secondsToClose / 60.0);
}

void PostHedgeDiagAppend(string &detail, string key, string value)
{
   StringReplace(value, "|", "/");
   StringReplace(value, "\r", " ");
   StringReplace(value, "\n", " ");
   if(detail != "")
      detail += "|";
   detail += key + "=" + value;
}

void PostHedgeDiagAppendD(string &detail, string key, double value, int digits = 2)
{
   PostHedgeDiagAppend(detail, key, DoubleToString(value, digits));
}

void PostHedgeDiagAppendI(string &detail, string key, int value)
{
   PostHedgeDiagAppend(detail, key, IntegerToString(value));
}

void PostHedgeDiagAppendT(string &detail, string key, datetime value)
{
   PostHedgeDiagAppend(detail, key, value > 0 ? TimeToString(value, TIME_DATE | TIME_SECONDS) : "");
}

int PostHedgeDiagMinutesAfterHedge()
{
   if(postHedgeDiagHedgeTime <= 0)
      return 0;
   return (int)MathFloor((TimeCurrent() - postHedgeDiagHedgeTime) / 60.0);
}

bool IsPostHedgeDiagnosticEnabled()
{
   return (EnablePostHedgeTimeExitPriorityDiagnostic || EnablePostHedgeDryRunDiagnostic ||
           EnableHardStopPrecursorDiagnostic || EnablePrioritySnapshotDiagnostic ||
           EnableCorrectedLeadTimeDryRunDiagnostic || EnablePreHardStopCloseableWindowDiagnostic ||
           EnableRuntimeEvaluationStageAudit ||
           UseB2M5TickVolLargeAdverseExit ||
           UseCW8OutsideHteBandExit ||
           UsePreHardStopS2StrictGuardExit ||
           UseL1M5R12LargeAdverseExit);
}

string PostHedgeBasketDirectionText(const PositionState &ps)
{
   if(ps.net > 0)
      return "BUY_NET";
   if(ps.net < 0)
      return "SELL_NET";
   if(ps.total > 0)
      return "HEDGED";
   return "FLAT";
}

ulong GetEarliestEaPositionTicket(datetime &openTime)
{
   openTime = 0;
   ulong firstTicket = 0;
   for(int i = PerfPositionsTotal() - 1; i >= 0; i--)
   {
      ulong ticket = PositionGetTicket(i);
      if(ticket == 0 || !PositionSelectByTicket(ticket) || !IsEaPosition())
         continue;
      datetime candidateTime = (datetime)PositionGetInteger(POSITION_TIME);
      if(candidateTime <= 0)
         continue;
      if(openTime == 0 || candidateTime < openTime || (candidateTime == openTime && ticket < firstTicket))
      {
         openTime = candidateTime;
         firstTicket = ticket;
      }
   }
   return firstTicket;
}

string BuildPostHedgeBasketUid(const PositionState &ps)
{
   datetime firstOpenTime = 0;
   ulong firstTicket = GetEarliestEaPositionTicket(firstOpenTime);
   datetime basketStart = firstOpenTime;
   if(basketStart <= 0)
      basketStart = postHedgeDiagBasketStartTime;
   if(basketStart <= 0)
      basketStart = GetFirstDefenseHedgeTime();
   if(basketStart <= 0)
      basketStart = TimeCurrent();

   string ticketText = (firstTicket > 0 ? IntegerToString((long)firstTicket) : "0");
   string timeText = TimeToString(basketStart, TIME_DATE | TIME_SECONDS);
   StringReplace(timeText, " ", "T");
   return _Symbol + "#" +
          timeText + "#" +
          ticketText + "#" +
          PostHedgeBasketDirectionText(ps) + "#" +
          IntegerToString(ps.total);
}

string CurrentPostHedgeBasketUid(const PositionState &ps)
{
   if(postHedgeDiagBasketUid != "")
      return postHedgeDiagBasketUid;
   return BuildPostHedgeBasketUid(ps);
}

string CurrentCloseIntentState()
{
   string state = "";
   if(postHedgeCloseIntentPending)
      state = "POST_HEDGE_PENDING:" + postHedgeCloseIntentReason;
   if(globalCloseIntentPending)
   {
      if(state != "")
         state += ";";
      state += "GLOBAL_PENDING:" + globalCloseIntentReason;
   }
   if(state == "")
      state = "NONE";
   return state;
}

string CurrentMarketClosedState()
{
   if(IsMarketClosedRetryActive())
      return "MARKET_CLOSED_RETRY_ACTIVE";
   if(lastMarketClosedErrorTime > 0)
      return "MARKET_CLOSED_RETRY_INACTIVE";
   return "OPEN_OR_UNKNOWN";
}

ClosePriorityState BuildRuntimeClosePriorityState(const PositionState &ps,
                                                  bool hardStop,
                                                  bool recoveryCloseEligible,
                                                  bool recoveryLossCutEligible,
                                                  bool hteEligibleNow)
{
   ClosePriorityState state;
   state.hardStopNow = hardStop;
   state.closePriorityOk = false;
   state.closePriorityBlocked = true;
   state.closePriorityReason = "OK";
   state.closeIntentState = CurrentCloseIntentState();
   state.activeCloseReason = "";

   bool basketCloseEligibleNow = PostHedgeDiagBasketCloseEligible(ps);
   if(hardStop)
   {
      state.closePriorityReason = "HARDSTOP_PRIORITY";
      state.activeCloseReason = "hard stop emergency close";
   }
   else if(basketCloseEligibleNow)
   {
      state.closePriorityReason = "BASKETCLOSE_PRIORITY";
      state.activeCloseReason = "basket close";
   }
   else if(recoveryCloseEligible)
   {
      state.closePriorityReason = "RECOVERYCLOSE_PRIORITY";
      state.activeCloseReason = "basket recovery close";
   }
   else if(recoveryLossCutEligible)
   {
      state.closePriorityReason = "RECOVERYLOSSCUT_PRIORITY";
      state.activeCloseReason = "Basket recovery losscut close";
   }
   else if(hteEligibleNow)
   {
      state.closePriorityReason = "HTE_PRIORITY";
      state.activeCloseReason = "Hedged basket time exit";
   }
   else
   {
      state.closePriorityReason = "OK";
      state.activeCloseReason = "NONE";
      state.closePriorityOk = true;
      state.closePriorityBlocked = false;
   }
   return state;
}

string TA9ShadowSafeFileToken(string text)
{
   StringReplace(text, " ", "_");
   StringReplace(text, ":", "");
   StringReplace(text, ".", "");
   StringReplace(text, "#", "_");
   StringReplace(text, "\\", "_");
   StringReplace(text, "/", "_");
   return text;
}

string TA9ShadowTimeText(datetime value)
{
   if(value <= 0)
      return "NA";
   return TimeToString(value, TIME_DATE | TIME_SECONDS);
}

string TA9ShadowDoubleText(double value, int digits = 2)
{
   if(!MathIsValidNumber(value))
      return "NA";
   return DoubleToString(value, digits);
}

string TA9ShadowTriText(bool known, bool value)
{
   if(!known)
      return "UNKNOWN";
   return BoolText(value);
}

string TA9ShadowHardStopBasisText()
{
   if(HardStopBasis == HARDSTOP_FIXED_YEN)
      return "HARDSTOP_FIXED_YEN";
   if(HardStopBasis == HARDSTOP_INITIAL_BALANCE_R)
      return "HARDSTOP_INITIAL_BALANCE_R";
   return "HARDSTOP_BALANCE_PERCENT";
}

string TA9ShadowBasketUidNoRuntimeMutation()
{
   if(ta9ShadowBasketUid != "")
      return ta9ShadowBasketUid;
   if(postHedgeDiagBasketUid != "")
      return postHedgeDiagBasketUid;
   if(postHedgeDiagBasketId != "")
      return postHedgeDiagBasketId;
   return _Symbol + "#UNKNOWN_BASKET_UID";
}

void TA9ShadowAppendReason(string &mask, string reason)
{
   if(reason == "")
      return;
   if(mask != "")
      mask += "|";
   mask += reason;
}

void TA9ShadowEnsureRunId()
{
   if(ta9ShadowRunId != "")
      return;
   string timeToken = TA9ShadowSafeFileToken(TimeToString(TimeLocal(), TIME_DATE | TIME_SECONDS));
   ta9ShadowRunId = "TA9SHADOW_" + _Symbol + "_" + timeToken + "_" + IntegerToString((int)GetTickCount());
   ta9ShadowLogFileName = ta9ShadowRunId + ".csv";
}

string TA9ShadowHeaderLine()
{
   string line = "";
   CsvAppend(line, "schema_version");
   CsvAppend(line, "shadow_build_id");
   CsvAppend(line, "run_id");
   CsvAppend(line, "source_baseline_sha");
   CsvAppend(line, "event_name");
   CsvAppend(line, "event_sequence");
   CsvAppend(line, "priority_snapshot_id");
   CsvAppend(line, "basket_uid");
   CsvAppend(line, "symbol");
   CsvAppend(line, "timeframe");
   CsvAppend(line, "server_time");
   CsvAppend(line, "server_time_msc");
   CsvAppend(line, "tick_sequence_id");
   CsvAppend(line, "eval_cycle_sequence");
   CsvAppend(line, "eval_stage_index");
   CsvAppend(line, "eval_stage_name");
   CsvAppend(line, "basket_lifecycle_state");
   CsvAppend(line, "hedge_state");
   CsvAppend(line, "bid");
   CsvAppend(line, "ask");
   CsvAppend(line, "spread_points");
   CsvAppend(line, "margin_level");
   CsvAppend(line, "basket_floating_pl_yen");
   CsvAppend(line, "position_profit_equivalent_yen");
   CsvAppend(line, "swap_state");
   CsvAppend(line, "commission_state");
   CsvAppend(line, "current_basket_pl_semantics");
   CsvAppend(line, "hardstop_basis");
   CsvAppend(line, "hardstop_threshold_yen");
   CsvAppend(line, "floating_loss_yen");
   CsvAppend(line, "distance_to_hardstop_yen_raw");
   CsvAppend(line, "distance_to_hardstop_yen_normalized");
   CsvAppend(line, "runtime_hardstop_now");
   CsvAppend(line, "snapshot_hardstop_now");
   CsvAppend(line, "hardstop_by_floating_loss");
   CsvAppend(line, "hardstop_by_margin");
   CsvAppend(line, "hte_eligibility");
   CsvAppend(line, "recovery_eligibility");
   CsvAppend(line, "basketclose_eligibility");
   CsvAppend(line, "eligibility_known_mask");
   CsvAppend(line, "close_priority_ok");
   CsvAppend(line, "close_priority_blocked");
   CsvAppend(line, "close_priority_reason");
   CsvAppend(line, "pending_close_state");
   CsvAppend(line, "market_session_state");
   CsvAppend(line, "ta9_raw_condition");
   CsvAppend(line, "ta9_raw_inputs_known");
   CsvAppend(line, "ta9_safety_condition");
   CsvAppend(line, "suppression_primary_reason");
   CsvAppend(line, "suppression_bitmask");
   CsvAppend(line, "actual_selected_close_reason");
   CsvAppend(line, "linked_order_result");
   CsvAppend(line, "logger_health");
   CsvAppend(line, "parity_error");
   CsvAppend(line, "parity_reason");
   CsvAppend(line, "hte_condition_distance");
   CsvAppend(line, "improvement_from_hedge_best_yen");
   CsvAppend(line, "hedge_start_floating_pl_yen");
   CsvAppend(line, "best_floating_after_hedge_yen");
   CsvAppend(line, "worst_floating_after_hedge_yen");
   CsvAppend(line, "detail");
   return line;
}

string TA9ShadowSnapshotLine(string eventName, const TA9ShadowSnapshot &s, string detail)
{
   string line = "";
   CsvAppend(line, TA9_SHADOW_SCHEMA_VERSION);
   CsvAppend(line, TA9_SHADOW_BUILD_ID);
   CsvAppend(line, ta9ShadowRunId);
   CsvAppend(line, TA9_SHADOW_SOURCE_BASELINE_SHA);
   CsvAppend(line, eventName);
   CsvAppend(line, IntegerToString((long)ta9ShadowEventSequence));
   CsvAppend(line, s.prioritySnapshotId);
   CsvAppend(line, s.basketUid);
   CsvAppend(line, _Symbol);
   CsvAppend(line, TfText((ENUM_TIMEFRAMES)_Period));
   CsvAppend(line, TA9ShadowTimeText(s.serverTime));
   CsvAppend(line, IntegerToString((long)s.serverTimeMsc));
   CsvAppend(line, IntegerToString(s.tickSequenceId));
   CsvAppend(line, IntegerToString(s.evalCycleSequence));
   CsvAppend(line, IntegerToString(s.evalStageIndex));
   CsvAppend(line, s.eventStageName);
   CsvAppend(line, s.basketLifecycleState);
   CsvAppend(line, s.hedgeState);
   CsvAppend(line, TA9ShadowDoubleText(s.bid, _Digits));
   CsvAppend(line, TA9ShadowDoubleText(s.ask, _Digits));
   CsvAppend(line, TA9ShadowDoubleText(s.spreadPoints, 1));
   CsvAppend(line, TA9ShadowDoubleText(s.marginLevel, 2));
   CsvAppend(line, TA9ShadowDoubleText(s.basketFloatingPl, 2));
   CsvAppend(line, TA9ShadowDoubleText(s.positionProfitEquivalent, 2));
   CsvAppend(line, s.swapState);
   CsvAppend(line, s.commissionState);
   CsvAppend(line, s.currentBasketPlSemantics);
   CsvAppend(line, s.hardStopBasis);
   CsvAppend(line, TA9ShadowDoubleText(s.hardStopThresholdYen, 2));
   CsvAppend(line, TA9ShadowDoubleText(s.floatingLossYen, 2));
   CsvAppend(line, TA9ShadowDoubleText(s.distanceToHardStopRaw, 8));
   CsvAppend(line, TA9ShadowDoubleText(s.distanceToHardStopNormalized, 2));
   CsvAppend(line, BoolText(s.runtimeHardStopNow));
   CsvAppend(line, BoolText(s.snapshotHardStopNow));
   CsvAppend(line, BoolText(s.hardStopByFloatingLoss));
   CsvAppend(line, BoolText(s.hardStopByMargin));
   CsvAppend(line, TA9ShadowTriText(s.hteEligibilityKnown, s.hteEligible));
   CsvAppend(line, TA9ShadowTriText(s.recoveryEligibilityKnown, s.recoveryEligible));
   CsvAppend(line, TA9ShadowTriText(s.basketCloseEligibilityKnown, s.basketCloseEligible));
   CsvAppend(line, s.eligibilityKnownMask);
   CsvAppend(line, BoolText(s.closePriorityOk));
   CsvAppend(line, BoolText(s.closePriorityBlocked));
   CsvAppend(line, s.closePriorityReason);
   CsvAppend(line, s.pendingCloseState);
   CsvAppend(line, s.marketSessionState);
   CsvAppend(line, BoolText(s.ta9RawCondition));
   CsvAppend(line, BoolText(s.rawInputsKnown));
   CsvAppend(line, BoolText(s.ta9SafetyCondition));
   CsvAppend(line, s.suppressionPrimaryReason);
   CsvAppend(line, s.suppressionBitmask);
   CsvAppend(line, s.actualSelectedCloseReason);
   CsvAppend(line, s.linkedOrderResult);
   CsvAppend(line, s.loggerHealth);
   CsvAppend(line, BoolText(s.parityError));
   CsvAppend(line, s.parityReason);
   CsvAppend(line, TA9ShadowDoubleText(s.hteConditionDistance, 2));
   CsvAppend(line, TA9ShadowDoubleText(s.improvementFromHedgeBest, 2));
   CsvAppend(line, TA9ShadowDoubleText(s.hedgeStartFloatingPl, 2));
   CsvAppend(line, TA9ShadowDoubleText(s.bestFloatingAfterHedge, 2));
   CsvAppend(line, TA9ShadowDoubleText(s.worstFloatingAfterHedge, 2));
   CsvAppend(line, detail);
   return line;
}

bool TA9ShadowWriteLine(string line)
{
   if(!EnableTA9ShadowLogging)
      return false;
   TA9ShadowEnsureRunId();
   int handle = FileOpen(ta9ShadowLogFileName, FILE_READ | FILE_WRITE | FILE_CSV | FILE_ANSI | FILE_SHARE_READ | FILE_SHARE_WRITE);
   if(handle == INVALID_HANDLE)
   {
      ta9ShadowLoggerHealthy = false;
      ta9ShadowDroppedRows++;
      if(!ta9ShadowLoggerErrorPrinted)
      {
         Print(EA_NAME, ": TA9 shadow log open failed. error=", GetLastError());
         ta9ShadowLoggerErrorPrinted = true;
      }
      return false;
   }
   FileSeek(handle, 0, SEEK_END);
   if(!ta9ShadowHeaderWritten)
   {
      PerfFileWriteString(handle, TA9ShadowHeaderLine() + "\r\n");
      ta9ShadowHeaderWritten = true;
   }
   uint written = PerfFileWriteString(handle, line + "\r\n");
   if(written == 0)
   {
      ta9ShadowLoggerHealthy = false;
      ta9ShadowDroppedRows++;
      if(!ta9ShadowLoggerErrorPrinted)
      {
         Print(EA_NAME, ": TA9 shadow log write failed. error=", GetLastError());
         ta9ShadowLoggerErrorPrinted = true;
      }
      FileClose(handle);
      return false;
   }
   FileClose(handle);
   return true;
}

bool TA9ShadowWriteEvent(string eventName, const TA9ShadowSnapshot &s, string detail)
{
   TA9ShadowEnsureRunId();
   ta9ShadowEventSequence++;
   if(eventName == "CLOSE_PRIORITY_SNAPSHOT")
      ta9ShadowSnapshotCount++;
   else if(eventName == "TA9_RAW_CANDIDATE")
      ta9ShadowRawCandidateCount++;
   else if(eventName == "TA9_SAFE_CANDIDATE")
      ta9ShadowSafeCandidateCount++;
   else if(eventName == "TA9_SUPPRESSED")
      ta9ShadowSuppressedCount++;
   else if(eventName == "SNAPSHOT_PARITY_ERROR")
      ta9ShadowParityErrorCount++;
   else if(eventName == "TA9_SHADOW_BASKET_SUMMARY")
      ta9ShadowBasketSummaryCount++;

   return TA9ShadowWriteLine(TA9ShadowSnapshotLine(eventName, s, detail));
}

bool TA9ShadowHteEligible(const PositionState &ps, bool &known)
{
   known = true;
   if(!UseHedgedBasketTimeExit || ta9ShadowHedgeTime <= 0 ||
      HedgedBasketMaxHoldMinutes <= 0 || HedgedBasketTimeExitAcceptLossYen <= 0.0)
      return false;
   return (TimeCurrent() - ta9ShadowHedgeTime >= HedgedBasketMaxHoldMinutes * 60 &&
           ps.floatingProfit >= -HedgedBasketTimeExitAcceptLossYen);
}

bool TA9ShadowRecoveryCloseEligible(const PositionState &ps, int defenseHedges, bool &known)
{
   known = true;
   if(!UseBasketRecoveryClose || ps.total < 2 || defenseHedges <= 0)
      return false;
   return (ps.floatingProfit >= BasketRecoveryProfitYen ||
           (CloseBasketWhenNetProfitPositiveAfterHedge && ps.floatingProfit >= 0.0));
}

bool TA9ShadowRecoveryLossCutEligible(const PositionState &ps, bool &known)
{
   known = true;
   if(!UseBasketRecoveryLossCut || !CloseHedgedBasketWhenLossImproves ||
      BasketRecoveryAcceptLossYen <= 0.0 || ta9ShadowHedgeTime <= 0 ||
      TimeCurrent() <= ta9ShadowHedgeTime)
      return false;
   bool lossCutMinHoldPassed = (!UseBasketRecoveryLossCutMinHold ||
                                BasketRecoveryLossCutMinHoldMinutes <= 0 ||
                                TimeCurrent() - ta9ShadowHedgeTime >= BasketRecoveryLossCutMinHoldMinutes * 60);
   if(!lossCutMinHoldPassed)
      return false;
   bool improvementReached = true;
   if(UseBasketRecoveryImprovementCheck && BasketRecoveryRequiredImprovementYen > 0.0)
   {
      double referenceProfit = UseWorstBasketAfterHedgeAsReference ?
                               ta9ShadowWorstFloatingAfterHedge :
                               ta9ShadowFloatingAtHedge;
      improvementReached = (ps.floatingProfit >= referenceProfit + BasketRecoveryRequiredImprovementYen);
   }
   return (ps.floatingProfit >= -BasketRecoveryAcceptLossYen && improvementReached);
}

bool TA9ShadowBasketCloseEligible(const PositionState &ps, bool &known)
{
   known = true;
   return PostHedgeDiagBasketCloseEligible(ps);
}

void TA9ShadowResetTracking()
{
   ta9ShadowPostHedgeActive = false;
   ta9ShadowBasketUid = "";
   ta9ShadowHedgeTime = 0;
   ta9ShadowFloatingAtHedge = 0.0;
   ta9ShadowBestFloatingAfterHedge = 0.0;
   ta9ShadowWorstFloatingAfterHedge = 0.0;
   ta9ShadowBasketRowCount = 0;
   ta9ShadowBasketRawCount = 0;
   ta9ShadowBasketSafeCount = 0;
   ta9ShadowBasketSuppressedCount = 0;
   ta9ShadowBasketParityErrorCount = 0;
   ta9ShadowLastStateKey = "";
   ta9ShadowLastRaw = false;
   ta9ShadowLastSafe = false;
   ta9ShadowLastSuppression = "";
}

void TA9ShadowWriteBasketSummary(string reason)
{
   if(!EnableTA9ShadowLogging || !ta9ShadowPostHedgeActive || ta9ShadowBasketUid == "")
      return;
   TA9ShadowSnapshot s;
   s.prioritySnapshotId = ta9ShadowRunId + "#" + ta9ShadowBasketUid + "#SUMMARY";
   s.basketUid = ta9ShadowBasketUid;
   s.eventStageName = "TA9_SHADOW_BASKET_END";
   s.serverTime = TimeCurrent();
   s.serverTimeMsc = ((long)s.serverTime) * 1000;
   s.tickSequenceId = runtimeEvalTickSequenceId;
   s.evalCycleSequence = ta9ShadowEvalCycleSequence;
   s.evalStageIndex = TA9_SHADOW_STAGE_INDEX;
   s.basketLifecycleState = "BASKET_SUMMARY";
   s.hedgeState = "UNKNOWN";
   s.bid = 0.0;
   s.ask = 0.0;
   s.spreadPoints = 0.0;
   s.marginLevel = 0.0;
   s.basketFloatingPl = 0.0;
   s.positionProfitEquivalent = 0.0;
   s.swapState = "NOT_SEPARATELY_COLLECTED";
   s.commissionState = "NOT_COLLECTED";
   s.currentBasketPlSemantics = "POSITION_PROFIT_PLUS_SWAP";
   s.hardStopBasis = TA9ShadowHardStopBasisText();
   s.hardStopThresholdYen = 0.0;
   s.floatingLossYen = 0.0;
   s.distanceToHardStopRaw = 0.0;
   s.distanceToHardStopNormalized = 0.0;
   s.runtimeHardStopNow = false;
   s.snapshotHardStopNow = false;
   s.hardStopByFloatingLoss = false;
   s.hardStopByMargin = false;
   s.hteEligibilityKnown = false;
   s.hteEligible = false;
   s.recoveryEligibilityKnown = false;
   s.recoveryEligible = false;
   s.basketCloseEligibilityKnown = false;
   s.basketCloseEligible = false;
   s.eligibilityKnownMask = "HTE:0;RECOVERY:0;BASKETCLOSE:0";
   s.closePriorityOk = false;
   s.closePriorityBlocked = false;
   s.closePriorityReason = "NA";
   s.pendingCloseState = "NA";
   s.marketSessionState = "NA";
   s.rawInputsKnown = false;
   s.ta9RawCondition = false;
   s.ta9SafetyCondition = false;
   s.suppressionPrimaryReason = reason;
   s.suppressionBitmask = reason;
   s.actualSelectedCloseReason = "NA";
   s.linkedOrderResult = "NA";
   s.loggerHealth = ta9ShadowLoggerHealthy ? "OK" : "DEGRADED";
   s.parityError = false;
   s.parityReason = "";
   s.hteConditionDistance = 0.0;
   s.improvementFromHedgeBest = ta9ShadowBestFloatingAfterHedge - ta9ShadowFloatingAtHedge;
   s.hedgeStartFloatingPl = ta9ShadowFloatingAtHedge;
   s.bestFloatingAfterHedge = ta9ShadowBestFloatingAfterHedge;
   s.worstFloatingAfterHedge = ta9ShadowWorstFloatingAfterHedge;
   string detail = "reason=" + reason +
                   "|basket_rows=" + IntegerToString(ta9ShadowBasketRowCount) +
                   "|raw_count=" + IntegerToString(ta9ShadowBasketRawCount) +
                   "|safe_count=" + IntegerToString(ta9ShadowBasketSafeCount) +
                   "|suppressed_count=" + IntegerToString(ta9ShadowBasketSuppressedCount) +
                   "|parity_error_count=" + IntegerToString(ta9ShadowBasketParityErrorCount);
   TA9ShadowWriteEvent("TA9_SHADOW_BASKET_SUMMARY", s, detail);
}

void TA9ShadowUpdateTracking(const PositionState &ps, int defenseHedges)
{
   if(ps.total <= 0 || defenseHedges <= 0)
   {
      if(ta9ShadowPostHedgeActive)
      {
         TA9ShadowWriteBasketSummary("BASKET_FLAT_OR_NO_DEFENSE_HEDGE");
         TA9ShadowResetTracking();
      }
      return;
   }

   if(!ta9ShadowPostHedgeActive)
   {
      ta9ShadowPostHedgeActive = true;
      ta9ShadowHedgeTime = GetFirstDefenseHedgeTime();
      if(ta9ShadowHedgeTime <= 0)
         ta9ShadowHedgeTime = TimeCurrent();
      ta9ShadowFloatingAtHedge = ps.floatingProfit;
      ta9ShadowBestFloatingAfterHedge = ps.floatingProfit;
      ta9ShadowWorstFloatingAfterHedge = ps.floatingProfit;
      ta9ShadowBasketUid = BuildPostHedgeBasketUid(ps);
      ta9ShadowBasketRowCount = 0;
      ta9ShadowBasketRawCount = 0;
      ta9ShadowBasketSafeCount = 0;
      ta9ShadowBasketSuppressedCount = 0;
      ta9ShadowBasketParityErrorCount = 0;
      ta9ShadowLastStateKey = "";
      ta9ShadowLastRaw = false;
      ta9ShadowLastSafe = false;
      ta9ShadowLastSuppression = "";
   }
   else
   {
      if(ps.floatingProfit > ta9ShadowBestFloatingAfterHedge)
         ta9ShadowBestFloatingAfterHedge = ps.floatingProfit;
      if(ps.floatingProfit < ta9ShadowWorstFloatingAfterHedge)
         ta9ShadowWorstFloatingAfterHedge = ps.floatingProfit;
   }
}

void TA9ShadowBuildSnapshot(const PositionState &ps,
                            bool runtimeHardStop,
                            double marginLevel,
                            int defenseHedges,
                            TA9ShadowSnapshot &s)
{
   MqlTick tick;
   bool tickOk = SymbolInfoTick(_Symbol, tick);
   datetime now = TimeCurrent();
   long timeMsc = ((long)now) * 1000;
   if(tickOk && tick.time_msc > 0)
      timeMsc = (long)tick.time_msc;

   ta9ShadowEvalCycleSequence++;

   double threshold = GetHardStopThresholdYen();
   double floatingLoss = GetFloatingLossYen(ps);
   double distance = 999999999.0;
   if(threshold > 0.0)
      distance = threshold - floatingLoss;

   bool floatingLossHit = (threshold > 0.0 && floatingLoss >= threshold);
   bool marginLevelHit = (marginLevel <= HardStopMarginLevel);
   bool snapshotHardStop = (floatingLossHit || marginLevelHit);

   bool hteKnown = false;
   bool hteEligible = TA9ShadowHteEligible(ps, hteKnown);
   bool recoveryKnown = false;
   bool recoveryEligible = TA9ShadowRecoveryCloseEligible(ps, defenseHedges, recoveryKnown);
   bool recoveryLossCutKnown = false;
   bool recoveryLossCutEligible = TA9ShadowRecoveryLossCutEligible(ps, recoveryLossCutKnown);
   bool basketKnown = false;
   bool basketEligible = TA9ShadowBasketCloseEligible(ps, basketKnown);

   ClosePriorityState priority = BuildRuntimeClosePriorityState(ps,
                                                                snapshotHardStop,
                                                                recoveryEligible,
                                                                recoveryLossCutEligible,
                                                                hteEligible);

   bool postHedge = (ta9ShadowPostHedgeActive && ps.total > 0 && defenseHedges > 0);
   double hteBand = -HedgedBasketTimeExitAcceptLossYen;
   bool outsideHteBand = (HedgedBasketTimeExitAcceptLossYen > 0.0 &&
                          ps.floatingProfit < hteBand);
   double improvementFromHedgeBest = ta9ShadowBestFloatingAfterHedge - ta9ShadowFloatingAtHedge;
   bool weakImprovement = (improvementFromHedgeBest < 500.0);
   bool rawInputsKnown = (postHedge &&
                          HedgedBasketTimeExitAcceptLossYen > 0.0 &&
                          MathIsValidNumber(ps.floatingProfit) &&
                          MathIsValidNumber(ta9ShadowBestFloatingAfterHedge) &&
                          MathIsValidNumber(ta9ShadowFloatingAtHedge));
   bool rawCondition = (rawInputsKnown && outsideHteBand && weakImprovement);

   string marketState = CurrentMarketClosedState();
   bool marketClosed = (marketState == "MARKET_CLOSED_RETRY_ACTIVE");
   bool pendingClose = (priority.closeIntentState != "NONE");

   string bitmask = "";
   string primary = "";
   bool parityError = false;
   string parityReason = "";

   if(!MathIsValidNumber(distance) || !MathIsValidNumber(threshold) || !MathIsValidNumber(floatingLoss))
   {
      parityError = true;
      parityReason = "INVALID_NUMERIC_HARDSTOP_METRIC";
      TA9ShadowAppendReason(bitmask, "SNAPSHOT_INVALID");
   }
   if(runtimeHardStop != snapshotHardStop)
   {
      parityError = true;
      if(parityReason != "")
         parityReason += "|";
      parityReason += "RUNTIME_SNAPSHOT_HARDSTOP_MISMATCH";
      TA9ShadowAppendReason(bitmask, "PARITY_ERROR");
   }
   if(distance <= 0.0 && !snapshotHardStop)
   {
      parityError = true;
      if(parityReason != "")
         parityReason += "|";
      parityReason += "DISTANCE_NONPOSITIVE_WITH_HARDSTOP_FALSE";
      TA9ShadowAppendReason(bitmask, "PARITY_ERROR");
   }

   if(!postHedge)
      TA9ShadowAppendReason(bitmask, "NOT_POST_HEDGE");
   if(!rawInputsKnown && postHedge)
      TA9ShadowAppendReason(bitmask, "RAW_INPUT_UNKNOWN");
   if(rawInputsKnown && !rawCondition)
      TA9ShadowAppendReason(bitmask, "RAW_NOT_MATCHED");
   if(snapshotHardStop)
      TA9ShadowAppendReason(bitmask, "HARDSTOP_NOW_TRUE");
   if(!priority.closePriorityOk)
      TA9ShadowAppendReason(bitmask, priority.closePriorityBlocked ? "CLOSE_PRIORITY_BLOCKED" : "CLOSE_PRIORITY_NOT_OK");
   if(pendingClose)
      TA9ShadowAppendReason(bitmask, "PENDING_CLOSE");
   if(marketClosed)
      TA9ShadowAppendReason(bitmask, "MARKET_CLOSED");
   if(!hteKnown)
      TA9ShadowAppendReason(bitmask, "HTE_ELIGIBILITY_UNKNOWN");
   else if(hteEligible)
      TA9ShadowAppendReason(bitmask, "HTE_ELIGIBLE_NOW");
   if(!recoveryKnown)
      TA9ShadowAppendReason(bitmask, "RECOVERY_ELIGIBILITY_UNKNOWN");
   else if(recoveryEligible)
      TA9ShadowAppendReason(bitmask, "RECOVERY_ELIGIBLE_NOW");
   if(!basketKnown)
      TA9ShadowAppendReason(bitmask, "BASKET_CLOSE_ELIGIBILITY_UNKNOWN");
   else if(basketEligible)
      TA9ShadowAppendReason(bitmask, "BASKET_CLOSE_ELIGIBLE_NOW");
   if(distance <= 0.0)
      TA9ShadowAppendReason(bitmask, "DISTANCE_NOT_POSITIVE");
   if(parityError)
      TA9ShadowAppendReason(bitmask, "PARITY_ERROR");

   if(!postHedge)
      primary = "NOT_POST_HEDGE";
   else if(parityError)
      primary = "PARITY_ERROR";
   else if(!rawInputsKnown)
      primary = "RAW_INPUT_UNKNOWN";
   else if(!rawCondition)
      primary = "RAW_NOT_MATCHED";
   else if(snapshotHardStop)
      primary = "HARDSTOP_NOW_TRUE";
   else if(pendingClose)
      primary = "PENDING_CLOSE";
   else if(marketClosed)
      primary = "MARKET_CLOSED";
   else if(!hteKnown)
      primary = "HTE_ELIGIBILITY_UNKNOWN";
   else if(hteEligible)
      primary = "HTE_ELIGIBLE_NOW";
   else if(!recoveryKnown)
      primary = "RECOVERY_ELIGIBILITY_UNKNOWN";
   else if(recoveryEligible)
      primary = "RECOVERY_ELIGIBLE_NOW";
   else if(!basketKnown)
      primary = "BASKET_CLOSE_ELIGIBILITY_UNKNOWN";
   else if(basketEligible)
      primary = "BASKET_CLOSE_ELIGIBLE_NOW";
   else if(!priority.closePriorityOk)
      primary = priority.closePriorityBlocked ? "CLOSE_PRIORITY_BLOCKED" : "CLOSE_PRIORITY_NOT_OK";
   else if(distance <= 0.0)
      primary = "DISTANCE_NOT_POSITIVE";
   else
      primary = "NONE";

   bool safeCondition = (primary == "NONE" && rawCondition &&
                         !snapshotHardStop &&
                         distance > 0.0 &&
                         priority.closePriorityOk &&
                         !priority.closePriorityBlocked &&
                         !pendingClose &&
                         !marketClosed &&
                         hteKnown && !hteEligible &&
                         recoveryKnown && !recoveryEligible &&
                         basketKnown && !basketEligible);

   s.prioritySnapshotId = ta9ShadowRunId + "#" +
                          TA9ShadowBasketUidNoRuntimeMutation() + "#" +
                          IntegerToString(runtimeEvalTickSequenceId) + "#" +
                          IntegerToString(ta9ShadowEvalCycleSequence) + "#" +
                          IntegerToString(TA9_SHADOW_STAGE_INDEX);
   s.basketUid = TA9ShadowBasketUidNoRuntimeMutation();
   s.eventStageName = "BEFORE_HARDSTOP_EVALUATION";
   s.serverTime = now;
   s.serverTimeMsc = timeMsc;
   s.tickSequenceId = runtimeEvalTickSequenceId;
   s.evalCycleSequence = ta9ShadowEvalCycleSequence;
   s.evalStageIndex = TA9_SHADOW_STAGE_INDEX;
   s.basketLifecycleState = ps.total > 0 ? "OPEN" : "FLAT";
   s.hedgeState = defenseHedges > 0 ? "HEDGED" : "NO_HEDGE";
   s.bid = tickOk ? tick.bid : 0.0;
   s.ask = tickOk ? tick.ask : 0.0;
   s.spreadPoints = (tickOk && _Point > 0.0) ? (tick.ask - tick.bid) / _Point : 0.0;
   s.marginLevel = marginLevel;
   s.basketFloatingPl = ps.floatingProfit;
   s.positionProfitEquivalent = ps.floatingProfit;
   s.swapState = "INCLUDED_IN_POSITION_PROFIT_PLUS_SWAP_NOT_SEPARATELY_COLLECTED";
   s.commissionState = "NOT_COLLECTED";
   s.currentBasketPlSemantics = "PositionState.floatingProfit=POSITION_PROFIT+POSITION_SWAP;commission_not_added";
   s.hardStopBasis = TA9ShadowHardStopBasisText();
   s.hardStopThresholdYen = threshold;
   s.floatingLossYen = floatingLoss;
   s.distanceToHardStopRaw = distance;
   s.distanceToHardStopNormalized = distance;
   s.runtimeHardStopNow = runtimeHardStop;
   s.snapshotHardStopNow = snapshotHardStop;
   s.hardStopByFloatingLoss = floatingLossHit;
   s.hardStopByMargin = marginLevelHit;
   s.hteEligibilityKnown = hteKnown;
   s.hteEligible = hteEligible;
   s.recoveryEligibilityKnown = recoveryKnown;
   s.recoveryEligible = recoveryEligible;
   s.basketCloseEligibilityKnown = basketKnown;
   s.basketCloseEligible = basketEligible;
   s.eligibilityKnownMask = "HTE:" + (hteKnown ? "1" : "0") +
                            ";RECOVERY:" + (recoveryKnown ? "1" : "0") +
                            ";BASKETCLOSE:" + (basketKnown ? "1" : "0");
   s.closePriorityOk = priority.closePriorityOk;
   s.closePriorityBlocked = priority.closePriorityBlocked;
   s.closePriorityReason = priority.closePriorityReason;
   s.pendingCloseState = priority.closeIntentState;
   s.marketSessionState = marketState;
   s.rawInputsKnown = rawInputsKnown;
   s.ta9RawCondition = rawCondition;
   s.ta9SafetyCondition = safeCondition;
   s.suppressionPrimaryReason = primary;
   s.suppressionBitmask = bitmask;
   s.actualSelectedCloseReason = priority.activeCloseReason;
   s.linkedOrderResult = "NOT_HOOKED_NON_INTERVENTION_SHADOW";
   s.loggerHealth = ta9ShadowLoggerHealthy ? "OK" : "DEGRADED";
   s.parityError = parityError;
   s.parityReason = parityReason;
   s.hteConditionDistance = ps.floatingProfit - hteBand;
   s.improvementFromHedgeBest = improvementFromHedgeBest;
   s.hedgeStartFloatingPl = ta9ShadowFloatingAtHedge;
   s.bestFloatingAfterHedge = ta9ShadowBestFloatingAfterHedge;
   s.worstFloatingAfterHedge = ta9ShadowWorstFloatingAfterHedge;
   s.detail = "outside_hte_band=" + BoolText(outsideHteBand) +
              "|weak_improvement_lt_500=" + BoolText(weakImprovement) +
              "|runtime_mapping=posthedge_outside_hte_band_weak_improvement_current_eligibility_suppression";
}

void ObserveTA9PreHardStopShadow(const PositionState &ps,
                                 bool runtimeHardStop,
                                 double marginLevel)
{
   if(!EnableTA9ShadowLogging)
      return;

   TA9ShadowEnsureRunId();
   int defenseHedges = CountDefenseHedges();
   TA9ShadowUpdateTracking(ps, defenseHedges);

   TA9ShadowSnapshot s;
   TA9ShadowBuildSnapshot(ps, runtimeHardStop, marginLevel, defenseHedges, s);

   string stateKey = s.basketUid + "|" +
                     s.closePriorityReason + "|" +
                     BoolText(s.ta9RawCondition) + "|" +
                     BoolText(s.ta9SafetyCondition) + "|" +
                     s.suppressionPrimaryReason + "|" +
                     s.suppressionBitmask + "|" +
                     BoolText(s.parityError);

   bool stateChanged = (stateKey != ta9ShadowLastStateKey);
   bool rawRising = (s.ta9RawCondition && !ta9ShadowLastRaw);
   bool safeRising = (s.ta9SafetyCondition && !ta9ShadowLastSafe);
   bool suppressionChanged = (!s.ta9SafetyCondition && s.suppressionPrimaryReason != ta9ShadowLastSuppression);

   if(stateChanged)
   {
      TA9ShadowWriteEvent("CLOSE_PRIORITY_SNAPSHOT", s, s.detail);
      ta9ShadowBasketRowCount++;
   }
   if(rawRising)
   {
      TA9ShadowWriteEvent("TA9_RAW_CANDIDATE", s, s.detail);
      ta9ShadowBasketRawCount++;
   }
   if(safeRising)
   {
      TA9ShadowWriteEvent("TA9_SAFE_CANDIDATE", s, s.detail);
      ta9ShadowBasketSafeCount++;
   }
   if(suppressionChanged && s.suppressionPrimaryReason != "NONE")
   {
      TA9ShadowWriteEvent("TA9_SUPPRESSED", s, s.detail);
      ta9ShadowBasketSuppressedCount++;
   }
   if(s.parityError)
   {
      TA9ShadowWriteEvent("SNAPSHOT_PARITY_ERROR", s, s.detail);
      ta9ShadowBasketParityErrorCount++;
   }
   if(stateChanged && s.closePriorityReason != "OK")
   {
      if(s.snapshotHardStopNow)
         TA9ShadowWriteEvent("HARDSTOP_SELECTED", s, s.detail);
      else
         TA9ShadowWriteEvent("EXISTING_CLOSE_SELECTED", s, s.detail);
   }

   ta9ShadowLastStateKey = stateKey;
   ta9ShadowLastRaw = s.ta9RawCondition;
   ta9ShadowLastSafe = s.ta9SafetyCondition;
   ta9ShadowLastSuppression = s.suppressionPrimaryReason;
}

void TA9ShadowWriteRunSummary(string reason)
{
   if(!EnableTA9ShadowLogging)
      return;
   if(ta9ShadowPostHedgeActive)
      TA9ShadowWriteBasketSummary("DEINIT_ACTIVE_BASKET");
   TA9ShadowSnapshot s;
   s.prioritySnapshotId = ta9ShadowRunId + "#RUN_SUMMARY";
   s.basketUid = "RUN";
   s.eventStageName = "TA9_SHADOW_RUN_END";
   s.serverTime = TimeCurrent();
   s.serverTimeMsc = ((long)s.serverTime) * 1000;
   s.tickSequenceId = runtimeEvalTickSequenceId;
   s.evalCycleSequence = ta9ShadowEvalCycleSequence;
   s.evalStageIndex = TA9_SHADOW_STAGE_INDEX;
   s.basketLifecycleState = "RUN_SUMMARY";
   s.hedgeState = "NA";
   s.bid = 0.0;
   s.ask = 0.0;
   s.spreadPoints = 0.0;
   s.marginLevel = 0.0;
   s.basketFloatingPl = 0.0;
   s.positionProfitEquivalent = 0.0;
   s.swapState = "NOT_SEPARATELY_COLLECTED";
   s.commissionState = "NOT_COLLECTED";
   s.currentBasketPlSemantics = "NA";
   s.hardStopBasis = TA9ShadowHardStopBasisText();
   s.hardStopThresholdYen = 0.0;
   s.floatingLossYen = 0.0;
   s.distanceToHardStopRaw = 0.0;
   s.distanceToHardStopNormalized = 0.0;
   s.runtimeHardStopNow = false;
   s.snapshotHardStopNow = false;
   s.hardStopByFloatingLoss = false;
   s.hardStopByMargin = false;
   s.hteEligibilityKnown = false;
   s.hteEligible = false;
   s.recoveryEligibilityKnown = false;
   s.recoveryEligible = false;
   s.basketCloseEligibilityKnown = false;
   s.basketCloseEligible = false;
   s.eligibilityKnownMask = "HTE:0;RECOVERY:0;BASKETCLOSE:0";
   s.closePriorityOk = false;
   s.closePriorityBlocked = false;
   s.closePriorityReason = "NA";
   s.pendingCloseState = "NA";
   s.marketSessionState = "NA";
   s.rawInputsKnown = false;
   s.ta9RawCondition = false;
   s.ta9SafetyCondition = false;
   s.suppressionPrimaryReason = reason;
   s.suppressionBitmask = reason;
   s.actualSelectedCloseReason = "NA";
   s.linkedOrderResult = "NA";
   s.loggerHealth = ta9ShadowLoggerHealthy ? "OK" : "DEGRADED";
   s.parityError = false;
   s.parityReason = "";
   s.hteConditionDistance = 0.0;
   s.improvementFromHedgeBest = 0.0;
   s.hedgeStartFloatingPl = 0.0;
   s.bestFloatingAfterHedge = 0.0;
   s.worstFloatingAfterHedge = 0.0;
   string detail = "reason=" + reason +
                   "|snapshots=" + IntegerToString(ta9ShadowSnapshotCount) +
                   "|raw_candidates=" + IntegerToString(ta9ShadowRawCandidateCount) +
                   "|safe_candidates=" + IntegerToString(ta9ShadowSafeCandidateCount) +
                   "|suppressed=" + IntegerToString(ta9ShadowSuppressedCount) +
                   "|parity_errors=" + IntegerToString(ta9ShadowParityErrorCount) +
                   "|basket_summaries=" + IntegerToString(ta9ShadowBasketSummaryCount) +
                   "|dropped_rows=" + IntegerToString(ta9ShadowDroppedRows);
   TA9ShadowWriteEvent("TA9_SHADOW_RUN_SUMMARY", s, detail);
}

bool MultilayerShadowEnabled()
{
   return (EnableMultilayerShadowLogging && MultilayerShadowLogLevel > 0);
}

string MLShadowSafeFileToken(string text)
{
   StringReplace(text, " ", "_");
   StringReplace(text, ":", "");
   StringReplace(text, ".", "");
   StringReplace(text, "#", "_");
   StringReplace(text, "\\", "_");
   StringReplace(text, "/", "_");
   return text;
}

string MLShadowTimeText(datetime value)
{
   if(value <= 0)
      return "NA";
   return TimeToString(value, TIME_DATE | TIME_SECONDS);
}

string MLShadowDoubleText(double value, int digits = 2)
{
   if(!MathIsValidNumber(value))
      return "NA";
   return DoubleToString(value, digits);
}

string MLShadowTri(bool known, bool value)
{
   if(!known)
      return "UNKNOWN";
   return BoolText(value);
}

void MultilayerShadowResetRun()
{
   mlShadowRunId = "";
   mlShadowLogFileName = "";
   mlShadowRunStartTime = TimeCurrent();
   mlShadowEventSequence = 0;
   mlShadowEvalCycleSequence = 0;
   mlShadowHeaderWritten = false;
   mlShadowLoggerHealthy = true;
   mlShadowLoggerErrorPrinted = false;
   mlShadowLoggerOpenErrorCount = 0;
   mlShadowLoggerWriteErrorCount = 0;
   mlShadowDroppedRows = 0;
   mlShadowDuplicateSnapshotCount = 0;
   mlShadowParityErrorCount = 0;
   mlShadowRootSnapshotCount = 0;
   mlShadowPrehedgeEventCount = 0;
   mlShadowHedgeEventCount = 0;
   mlShadowMaEventCount = 0;
   mlShadowEventRiskEventCount = 0;
   mlShadowBasketSummaryCount = 0;
   mlShadowMaxRowsReached = false;
   mlShadowLastRootKey = "";
   mlShadowLastPrehedgeStateKey = "";
   mlShadowLastMaStateKey = "";
   mlShadowLastEventRiskStateKey = "";
   mlShadowCurrentBasketUid = "";
   mlShadowCurrentBasketStartTime = 0;
   mlShadowFirstHedgeTime = 0;
   mlShadowBasketActive = false;
   mlShadowBasketHedged = false;
   mlShadowEventWindowLifetimeOverlap = false;
   mlShadowEventWindowEntryOverlap = false;
   mlShadowEventWindowHedgeOverlap = false;
   mlShadowEventWindowCloseOverlap = false;
   mlShadowMaBreakObserved = false;
   mlShadowMaRetestObserved = false;
   mlShadowMaRetestExitOpportunitySeen = false;
   mlShadowMinDistanceToHardstop = 0.0;
   mlShadowMaxFloatingLoss = 0.0;
   mlShadowPostHedgeBestPl = 0.0;
   mlShadowPostHedgeWorstPl = 0.0;
   mlShadowUnknownFieldCount = 0;
}

void MLShadowEnsureRunId()
{
   if(mlShadowRunId != "")
      return;
   string timeToken = MLShadowSafeFileToken(TimeToString(TimeLocal(), TIME_DATE | TIME_SECONDS));
   mlShadowRunId = "MLSHADOW_" + _Symbol + "_" + timeToken + "_" + IntegerToString((int)GetTickCount());
   string prefix = MultilayerShadowFilePrefix;
   if(prefix == "")
      prefix = "KOUCHA_ML_SHADOW";
   mlShadowLogFileName = MLShadowSafeFileToken(prefix) + "_" + mlShadowRunId + ".csv";
   if(mlShadowRunStartTime <= 0)
      mlShadowRunStartTime = TimeCurrent();
}

string MLShadowHeaderLine()
{
   string line = "";
   CsvAppend(line, "schema_version");
   CsvAppend(line, "build_id");
   CsvAppend(line, "source_before_sha256");
   CsvAppend(line, "run_id");
   CsvAppend(line, "event_sequence");
   CsvAppend(line, "event_type");
   CsvAppend(line, "module_name");
   CsvAppend(line, "root_snapshot_id");
   CsvAppend(line, "basket_uid");
   CsvAppend(line, "symbol");
   CsvAppend(line, "period");
   CsvAppend(line, "server_time");
   CsvAppend(line, "server_time_msc");
   CsvAppend(line, "tick_sequence_id");
   CsvAppend(line, "eval_cycle_sequence");
   CsvAppend(line, "eval_stage");
   CsvAppend(line, "lifecycle_state");
   CsvAppend(line, "hedge_state");
   CsvAppend(line, "entry_state");
   CsvAppend(line, "bid");
   CsvAppend(line, "ask");
   CsvAppend(line, "spread_points");
   CsvAppend(line, "margin_level");
   CsvAppend(line, "basket_floating_profit");
   CsvAppend(line, "basket_swap_state");
   CsvAppend(line, "basket_commission_status");
   CsvAppend(line, "current_basket_net_pl");
   CsvAppend(line, "floating_loss_yen");
   CsvAppend(line, "hardstop_threshold_yen");
   CsvAppend(line, "distance_to_hardstop_yen");
   CsvAppend(line, "hardstop_now_runtime");
   CsvAppend(line, "hardstop_now_snapshot");
   CsvAppend(line, "close_priority_ok");
   CsvAppend(line, "close_priority_blocked");
   CsvAppend(line, "pending_close_state");
   CsvAppend(line, "market_state");
   CsvAppend(line, "logger_state");
   CsvAppend(line, "is_pre_hedge");
   CsvAppend(line, "is_never_hedged");
   CsvAppend(line, "basket_age_seconds");
   CsvAppend(line, "distance_band");
   CsvAppend(line, "loss_slope_short");
   CsvAppend(line, "loss_slope_mid");
   CsvAppend(line, "adverse_movement_speed");
   CsvAppend(line, "current_exposure");
   CsvAppend(line, "entry_count");
   CsvAppend(line, "hedge_count");
   CsvAppend(line, "large_candle_state");
   CsvAppend(line, "DXY_state");
   CsvAppend(line, "VIX_state");
   CsvAppend(line, "market_session");
   CsvAppend(line, "weekday");
   CsvAppend(line, "friday_close_proximity");
   CsvAppend(line, "month_start_end_flag");
   CsvAppend(line, "current_HTE_eligibility");
   CsvAppend(line, "current_Recovery_eligibility");
   CsvAppend(line, "current_BasketClose_eligibility");
   CsvAppend(line, "price_vs_m5_ema20");
   CsvAppend(line, "price_vs_m5_ema50");
   CsvAppend(line, "price_vs_m15_ema20");
   CsvAppend(line, "price_vs_m15_ema50");
   CsvAppend(line, "price_vs_h1_ema20");
   CsvAppend(line, "price_vs_h1_ema50");
   CsvAppend(line, "m5_ema20_slope");
   CsvAppend(line, "m5_ema50_slope");
   CsvAppend(line, "ma_distance_m5_ema20");
   CsvAppend(line, "ma_distance_m5_ema50");
   CsvAppend(line, "ma_cross_state");
   CsvAppend(line, "ma_break_confirmed");
   CsvAppend(line, "ma_retest_state");
   CsvAppend(line, "ma_retest_exit_opportunity_shadow");
   CsvAppend(line, "event_calendar_available");
   CsvAppend(line, "event_calendar_source");
   CsvAppend(line, "event_timezone_verified");
   CsvAppend(line, "high_impact_usd_event_window_state");
   CsvAppend(line, "nearest_event_name");
   CsvAppend(line, "existing_newsblock_state");
   CsvAppend(line, "calendar_event_window_but_ea_not_blocked");
   CsvAppend(line, "ea_blocked_without_calendar_event");
   CsvAppend(line, "reason_primary");
   CsvAppend(line, "reason_bitmask");
   CsvAppend(line, "summary_reason");
   CsvAppend(line, "detail");
   return line;
}

bool MLShadowWriteLine(string line)
{
   if(!MultilayerShadowEnabled())
      return false;
   MLShadowEnsureRunId();
   if(MultilayerShadowMaxRowsPerRun > 0 && mlShadowEventSequence >= MultilayerShadowMaxRowsPerRun)
   {
      mlShadowMaxRowsReached = true;
      mlShadowDroppedRows++;
      return false;
   }

   int handle = FileOpen(mlShadowLogFileName, FILE_READ | FILE_WRITE | FILE_CSV | FILE_ANSI | FILE_SHARE_READ | FILE_SHARE_WRITE);
   if(handle == INVALID_HANDLE)
   {
      mlShadowLoggerHealthy = false;
      mlShadowLoggerOpenErrorCount++;
      mlShadowDroppedRows++;
      if(!mlShadowLoggerErrorPrinted)
      {
         Print(EA_NAME, ": multilayer shadow log open failed. error=", GetLastError());
         mlShadowLoggerErrorPrinted = true;
      }
      return false;
   }

   if(!mlShadowHeaderWritten || FileSize(handle) == 0)
   {
      FileSeek(handle, 0, SEEK_END);
      if(!PerfFileWriteString(handle, MLShadowHeaderLine() + "\r\n"))
      {
         mlShadowLoggerHealthy = false;
         mlShadowLoggerWriteErrorCount++;
      }
      mlShadowHeaderWritten = true;
   }

   FileSeek(handle, 0, SEEK_END);
   bool ok = PerfFileWriteString(handle, line + "\r\n");
   if(!ok)
   {
      mlShadowLoggerHealthy = false;
      mlShadowLoggerWriteErrorCount++;
      mlShadowDroppedRows++;
   }
   if(MultilayerShadowFlushMode == 1)
      FileFlush(handle);
   FileClose(handle);
   return ok;
}

string MLShadowBasketUidNoRuntimeMutation(const PositionState &ps)
{
   if(postHedgeDiagBasketUid != "")
      return postHedgeDiagBasketUid;
   if(postHedgeDiagBasketId != "")
      return postHedgeDiagBasketId;
   datetime firstOpenTime = 0;
   ulong firstTicket = GetEarliestEaPositionTicket(firstOpenTime);
   datetime basketStart = firstOpenTime;
   if(basketStart <= 0)
      basketStart = TimeCurrent();
   string timeText = TimeToString(basketStart, TIME_DATE | TIME_SECONDS);
   StringReplace(timeText, " ", "T");
   return _Symbol + "#" + timeText + "#" + IntegerToString((long)firstTicket) + "#" + PostHedgeBasketDirectionText(ps) + "#" + IntegerToString(ps.total);
}

string MLShadowLifecycleState(const PositionState &ps, int hedgeCount)
{
   if(ps.total <= 0)
      return "FLAT";
   if(hedgeCount > 0 || postHedgeDiagActive)
      return "POST_HEDGE";
   return "PRE_HEDGE";
}

string MLShadowDistanceBand(double distance, double threshold, bool hardStopNow)
{
   if(hardStopNow)
      return "HARDSTOP_NOW";
   if(threshold <= 0.0 || !MathIsValidNumber(distance))
      return "UNKNOWN";
   if(distance <= 0.0)
      return "CRITICAL";
   double ratio = distance / threshold;
   if(ratio <= 0.10)
      return "CRITICAL";
   if(ratio <= 0.25)
      return "DANGER";
   if(ratio <= 0.50)
      return "CAUTION";
   if(ratio <= 1.00)
      return "WATCH";
   return "SAFE";
}

string MLShadowTimeFlag(datetime t)
{
   MqlDateTime dt;
   TimeToStruct(t, dt);
   string flag = "NORMAL";
   if(dt.day <= 3)
      flag = "MONTH_START";
   if(dt.day >= 28)
      flag = (flag == "NORMAL" ? "MONTH_END" : flag + "|MONTH_END");
   return flag;
}

string MLShadowFridayFlag(datetime t)
{
   MqlDateTime dt;
   TimeToStruct(t, dt);
   if(dt.day_of_week == 5 && dt.hour >= 18)
      return "FRIDAY_CLOSE_PROXIMITY";
   return "NONE";
}

string MLShadowWeekdayText(datetime t)
{
   MqlDateTime dt;
   TimeToStruct(t, dt);
   return IntegerToString(dt.day_of_week);
}

string MLShadowSessionText(datetime t)
{
   MqlDateTime dt;
   TimeToStruct(t, dt);
   if(dt.hour >= 0 && dt.hour < 7)
      return "ASIA";
   if(dt.hour >= 7 && dt.hour < 13)
      return "EUROPE_PRE_US";
   if(dt.hour >= 13 && dt.hour < 21)
      return "US_OVERLAP";
   return "LATE_US";
}

string MLShadowPriceVs(double price, double maValue)
{
   if(!MathIsValidNumber(price) || !MathIsValidNumber(maValue) || maValue <= 0.0)
      return "UNKNOWN";
   if(price > maValue)
      return "ABOVE";
   if(price < maValue)
      return "BELOW";
   return "EQUAL";
}

bool MLShadowEmaNowPrev(ENUM_TIMEFRAMES tf, int period, double &nowValue, double &prevValue)
{
   nowValue = 0.0;
   prevValue = 0.0;
   bool nowOk = GetEmaValue(tf, period, 0, nowValue);
   bool prevOk = GetEmaValue(tf, period, 1, prevValue);
   return (nowOk && prevOk && MathIsValidNumber(nowValue) && MathIsValidNumber(prevValue));
}

string MLShadowEligibilityText(bool known, bool eligible)
{
   return MLShadowTri(known, eligible);
}

void MLShadowUpdateBasketCache(const MultilayerRootSnapshot &s, const PositionState &ps, bool eventWindowNow)
{
   if(ps.total <= 0)
      return;
   if(!mlShadowBasketActive || mlShadowCurrentBasketUid != s.basketUid)
   {
      mlShadowBasketActive = true;
      mlShadowCurrentBasketUid = s.basketUid;
      mlShadowCurrentBasketStartTime = s.serverTime;
      mlShadowFirstHedgeTime = 0;
      mlShadowBasketHedged = false;
      mlShadowEventWindowLifetimeOverlap = false;
      mlShadowEventWindowEntryOverlap = eventWindowNow;
      mlShadowEventWindowHedgeOverlap = false;
      mlShadowEventWindowCloseOverlap = false;
      mlShadowMaBreakObserved = false;
      mlShadowMaRetestObserved = false;
      mlShadowMaRetestExitOpportunitySeen = false;
      mlShadowMinDistanceToHardstop = s.distanceToHardstopYen;
      mlShadowMaxFloatingLoss = s.floatingLossYen;
      mlShadowPostHedgeBestPl = ps.floatingProfit;
      mlShadowPostHedgeWorstPl = ps.floatingProfit;
      mlShadowUnknownFieldCount = 0;
   }
   if(eventWindowNow)
      mlShadowEventWindowLifetimeOverlap = true;
   if(s.distanceToHardstopYen < mlShadowMinDistanceToHardstop || mlShadowMinDistanceToHardstop == 0.0)
      mlShadowMinDistanceToHardstop = s.distanceToHardstopYen;
   if(s.floatingLossYen > mlShadowMaxFloatingLoss)
      mlShadowMaxFloatingLoss = s.floatingLossYen;
   if(mlShadowBasketHedged || CountDefenseHedges() > 0)
   {
      if(ps.floatingProfit > mlShadowPostHedgeBestPl)
         mlShadowPostHedgeBestPl = ps.floatingProfit;
      if(ps.floatingProfit < mlShadowPostHedgeWorstPl)
         mlShadowPostHedgeWorstPl = ps.floatingProfit;
   }
}

MultilayerRootSnapshot MLShadowBuildRootSnapshot(const PositionState &ps,
                                                 bool runtimeHardStop,
                                                 double marginLevel,
                                                 const MqlTick &tick,
                                                 string evalStage)
{
   MLShadowEnsureRunId();
   MultilayerRootSnapshot s;
   int hedgeCount = CountDefenseHedges();
   bool hteKnown = false;
   bool hteEligible = TA9ShadowHteEligible(ps, hteKnown);
   bool recoveryKnown = false;
   bool recoveryEligible = TA9ShadowRecoveryCloseEligible(ps, hedgeCount, recoveryKnown);
   bool basketKnown = false;
   bool basketEligible = TA9ShadowBasketCloseEligible(ps, basketKnown);
   bool recoveryLossCutKnown = false;
   bool recoveryLossCutEligible = TA9ShadowRecoveryLossCutEligible(ps, recoveryLossCutKnown);
   ClosePriorityState priority = BuildRuntimeClosePriorityState(ps,
                                                                runtimeHardStop,
                                                                recoveryEligible,
                                                                recoveryLossCutEligible,
                                                                hteEligible);

   mlShadowEvalCycleSequence++;
   s.serverTime = (tick.time > 0 ? tick.time : TimeCurrent());
   s.serverTimeMsc = (tick.time_msc > 0 ? (long)tick.time_msc : ((long)s.serverTime) * 1000);
   s.tickSequenceId = runtimeEvalTickSequenceId;
   s.evalCycleSequence = mlShadowEvalCycleSequence;
   s.evalStage = evalStage;
   s.basketUid = (ps.total > 0 ? MLShadowBasketUidNoRuntimeMutation(ps) : "NO_ACTIVE_BASKET");
   s.rootSnapshotId = mlShadowRunId + "#" + s.basketUid + "#" + IntegerToString(s.tickSequenceId) + "#" + IntegerToString(s.evalCycleSequence) + "#" + evalStage;
   s.lifecycleState = MLShadowLifecycleState(ps, hedgeCount);
   s.hedgeState = (hedgeCount > 0 ? "HEDGED" : "NO_HEDGE");
   s.entryState = (ps.total > 0 ? "HAS_POSITION" : "FLAT");
   s.bid = tick.bid;
   s.ask = tick.ask;
   s.spreadPoints = (tick.ask > 0.0 && tick.bid > 0.0 && _Point > 0.0 ? (tick.ask - tick.bid) / _Point : 0.0);
   s.marginLevel = marginLevel;
   s.basketFloatingProfit = ps.floatingProfit;
   s.basketSwapState = "NOT_SEPARATELY_COLLECTED";
   s.basketCommissionStatus = "NOT_COLLECTED";
   s.currentBasketNetPl = ps.floatingProfit;
   s.floatingLossYen = GetFloatingLossYen(ps);
   s.hardStopThresholdYen = GetHardStopThresholdYen();
   s.distanceToHardstopYen = s.hardStopThresholdYen - s.floatingLossYen;
   s.hardstopNowRuntime = runtimeHardStop;
   bool floatingLossHit = (s.hardStopThresholdYen > 0.0 && s.floatingLossYen >= s.hardStopThresholdYen);
   bool marginHit = (marginLevel <= HardStopMarginLevel);
   s.hardstopNowSnapshot = (floatingLossHit || marginHit);
   if(s.hardstopNowRuntime != s.hardstopNowSnapshot)
      mlShadowParityErrorCount++;
   s.closePriorityOk = priority.closePriorityOk;
   s.closePriorityBlocked = priority.closePriorityBlocked;
   s.pendingCloseState = priority.closeIntentState;
   s.marketState = CurrentMarketClosedState();
   s.loggerState = mlShadowLoggerHealthy ? "OK" : "DEGRADED";
   s.currentExposure = IntegerToString(ps.net);
   s.entryCount = ps.total;
   s.hedgeCount = hedgeCount;
   s.hteEligibility = MLShadowEligibilityText(hteKnown, hteEligible);
   s.recoveryEligibility = MLShadowEligibilityText(recoveryKnown, recoveryEligible);
   s.basketCloseEligibility = MLShadowEligibilityText(basketKnown, basketEligible);
   return s;
}

void MLShadowAppendBase(string &line,
                        string eventName,
                        string moduleName,
                        const MultilayerRootSnapshot &s)
{
   CsvAppend(line, MULTILAYER_SHADOW_SCHEMA_VERSION);
   CsvAppend(line, MULTILAYER_SHADOW_BUILD_ID);
   CsvAppend(line, MULTILAYER_SHADOW_SOURCE_BEFORE_SHA);
   CsvAppend(line, mlShadowRunId);
   CsvAppend(line, IntegerToString((long)mlShadowEventSequence));
   CsvAppend(line, eventName);
   CsvAppend(line, moduleName);
   CsvAppend(line, s.rootSnapshotId);
   CsvAppend(line, s.basketUid);
   CsvAppend(line, _Symbol);
   CsvAppend(line, TfText((ENUM_TIMEFRAMES)_Period));
   CsvAppend(line, MLShadowTimeText(s.serverTime));
   CsvAppend(line, IntegerToString((long)s.serverTimeMsc));
   CsvAppend(line, IntegerToString(s.tickSequenceId));
   CsvAppend(line, IntegerToString(s.evalCycleSequence));
   CsvAppend(line, s.evalStage);
   CsvAppend(line, s.lifecycleState);
   CsvAppend(line, s.hedgeState);
   CsvAppend(line, s.entryState);
   CsvAppend(line, MLShadowDoubleText(s.bid, _Digits));
   CsvAppend(line, MLShadowDoubleText(s.ask, _Digits));
   CsvAppend(line, MLShadowDoubleText(s.spreadPoints, 1));
   CsvAppend(line, MLShadowDoubleText(s.marginLevel, 2));
   CsvAppend(line, MLShadowDoubleText(s.basketFloatingProfit, 2));
   CsvAppend(line, s.basketSwapState);
   CsvAppend(line, s.basketCommissionStatus);
   CsvAppend(line, MLShadowDoubleText(s.currentBasketNetPl, 2));
   CsvAppend(line, MLShadowDoubleText(s.floatingLossYen, 2));
   CsvAppend(line, MLShadowDoubleText(s.hardStopThresholdYen, 2));
   CsvAppend(line, MLShadowDoubleText(s.distanceToHardstopYen, 8));
   CsvAppend(line, BoolText(s.hardstopNowRuntime));
   CsvAppend(line, BoolText(s.hardstopNowSnapshot));
   CsvAppend(line, BoolText(s.closePriorityOk));
   CsvAppend(line, BoolText(s.closePriorityBlocked));
   CsvAppend(line, s.pendingCloseState);
   CsvAppend(line, s.marketState);
   CsvAppend(line, s.loggerState);
}

void MLShadowAppendCommonTail(string &line,
                              const MultilayerRootSnapshot &s,
                              bool isPreHedge,
                              string distanceBand,
                              string largeCandleState,
                              string dxyState,
                              string vixState,
                              string maCrossState,
                              string maBreakConfirmed,
                              string maRetestState,
                              string maRetestExitOpportunity,
                              string eventCalendarAvailable,
                              string eventWindowState,
                              string existingNewsBlockState,
                              string reasonPrimary,
                              string reasonBitmask,
                              string summaryReason,
                              string detail)
{
   datetime startTime = (mlShadowCurrentBasketStartTime > 0 ? mlShadowCurrentBasketStartTime : s.serverTime);
   int ageSeconds = (s.serverTime >= startTime ? (int)(s.serverTime - startTime) : 0);
   CsvAppend(line, BoolText(isPreHedge));
   CsvAppend(line, BoolText(s.hedgeCount <= 0));
   CsvAppend(line, IntegerToString(ageSeconds));
   CsvAppend(line, distanceBand);
   CsvAppend(line, "NA");
   CsvAppend(line, "NA");
   CsvAppend(line, "NA");
   CsvAppend(line, s.currentExposure);
   CsvAppend(line, IntegerToString(s.entryCount));
   CsvAppend(line, IntegerToString(s.hedgeCount));
   CsvAppend(line, largeCandleState);
   CsvAppend(line, dxyState);
   CsvAppend(line, vixState);
   CsvAppend(line, MLShadowSessionText(s.serverTime));
   CsvAppend(line, MLShadowWeekdayText(s.serverTime));
   CsvAppend(line, MLShadowFridayFlag(s.serverTime));
   CsvAppend(line, MLShadowTimeFlag(s.serverTime));
   CsvAppend(line, s.hteEligibility);
   CsvAppend(line, s.recoveryEligibility);
   CsvAppend(line, s.basketCloseEligibility);
   // Shadow logging must not create indicator handles or touch the runtime CopyBuffer memo.
   CsvAppend(line, "UNKNOWN");
   CsvAppend(line, "UNKNOWN");
   CsvAppend(line, "UNKNOWN");
   CsvAppend(line, "UNKNOWN");
   CsvAppend(line, "UNKNOWN");
   CsvAppend(line, "UNKNOWN");
   CsvAppend(line, "NA");
   CsvAppend(line, "NA");
   CsvAppend(line, "NA");
   CsvAppend(line, "NA");
   CsvAppend(line, maCrossState);
   CsvAppend(line, maBreakConfirmed);
   CsvAppend(line, maRetestState);
   CsvAppend(line, maRetestExitOpportunity);
   CsvAppend(line, eventCalendarAvailable);
   CsvAppend(line, NewsCsvFileName);
   CsvAppend(line, newsCsvLoaded ? "PARTIAL" : "UNKNOWN");
   CsvAppend(line, eventWindowState);
   CsvAppend(line, currentNewsBlockEventName);
   CsvAppend(line, existingNewsBlockState);
   CsvAppend(line, "UNKNOWN");
   CsvAppend(line, "UNKNOWN");
   CsvAppend(line, reasonPrimary);
   CsvAppend(line, reasonBitmask);
   CsvAppend(line, summaryReason);
   CsvAppend(line, detail);
}

bool MLShadowWriteEvent(string eventName,
                        string moduleName,
                        const MultilayerRootSnapshot &s,
                        bool isPreHedge,
                        string distanceBand,
                        string largeCandleState,
                        string dxyState,
                        string vixState,
                        string maCrossState,
                        string maBreakConfirmed,
                        string maRetestState,
                        string maRetestExitOpportunity,
                        string eventCalendarAvailable,
                        string eventWindowState,
                        string existingNewsBlockState,
                        string reasonPrimary,
                        string reasonBitmask,
                        string summaryReason,
                        string detail)
{
   if(!MultilayerShadowEnabled())
      return false;
   mlShadowEventSequence++;
   string line = "";
   MLShadowAppendBase(line, eventName, moduleName, s);
   MLShadowAppendCommonTail(line,
                            s,
                            isPreHedge,
                            distanceBand,
                            largeCandleState,
                            dxyState,
                            vixState,
                            maCrossState,
                            maBreakConfirmed,
                            maRetestState,
                            maRetestExitOpportunity,
                            eventCalendarAvailable,
                            eventWindowState,
                            existingNewsBlockState,
                            reasonPrimary,
                            reasonBitmask,
                            summaryReason,
                            detail);
   return MLShadowWriteLine(line);
}

void MLShadowWriteRootSnapshot(const MultilayerRootSnapshot &s,
                               string distanceBand,
                               string dxyState,
                               string vixState,
                               string maCrossState,
                               string eventCalendarAvailable,
                               string eventWindowState,
                               string existingNewsBlockState)
{
   string rootKey = s.rootSnapshotId;
   if(rootKey == mlShadowLastRootKey)
   {
      mlShadowDuplicateSnapshotCount++;
      return;
   }
   mlShadowLastRootKey = rootKey;
   mlShadowRootSnapshotCount++;
   MLShadowWriteEvent("MULTILAYER_ROOT_SNAPSHOT",
                      "ROOT",
                      s,
                      s.lifecycleState == "PRE_HEDGE",
                      distanceBand,
                      currentTechnicalDangerActive ? currentTechnicalDangerReason : "FALSE",
                      dxyState,
                      vixState,
                      maCrossState,
                      "UNKNOWN",
                      "UNKNOWN",
                      "UNKNOWN",
                      eventCalendarAvailable,
                      eventWindowState,
                      existingNewsBlockState,
                      "ROOT_SNAPSHOT",
                      "ROOT_SNAPSHOT",
                      "",
                      "root_snapshot_contract=single_snapshot_per_eval_cycle");
}

void ObserveMultilayerPreCloseShadow(const PositionState &ps,
                                     bool runtimeHardStop,
                                     double marginLevel,
                                     const MqlTick &tick,
                                     const FilterState &dxy,
                                     const FilterState &vix,
                                     bool newsBlock,
                                     string newsReason,
                                     const MaStructureState &ma)
{
   if(!MultilayerShadowEnabled())
      return;
   MultilayerRootSnapshot s = MLShadowBuildRootSnapshot(ps, runtimeHardStop, marginLevel, tick, "PRE_CLOSE_EVALUATION");
   string distanceBand = MLShadowDistanceBand(s.distanceToHardstopYen, s.hardStopThresholdYen, s.hardstopNowSnapshot);
   string eventCalendarAvailable = newsCsvLoaded ? "TRUE" : "UNKNOWN";
   string eventWindowState = "UNKNOWN";
   if(EnableEventRiskMinimalShadow && newsCsvLoaded)
      eventWindowState = newsBlock ? "TRUE" : "FALSE";
   string newsBlockState = MLShadowTri(true, newsBlock);
   bool eventWindowNow = (eventWindowState == "TRUE");
   MLShadowUpdateBasketCache(s, ps, eventWindowNow);

   string maBreak = (ma.buyingIntoFallingMa || ma.sellingIntoRisingMa) ? "TRUE" : "FALSE";
   string maRetest = ma.priceNearMaPullback ? "RETEST_ZONE" : "NO_RETEST";
   string maExitOpportunity = (ps.floatingProfit < 0.0 && ma.priceNearMaPullback && (ma.buyingIntoFallingMa || ma.sellingIntoRisingMa)) ? "TRUE" : "FALSE";
   string stateKey = s.basketUid + "|" + distanceBand + "|" + s.lifecycleState + "|" + s.hedgeState + "|" + eventWindowState;
   string maKey = (ps.total > 0 ? s.basketUid + "|" + ma.crossState + "|" + maBreak + "|" + maRetest + "|" + maExitOpportunity : "NO_ACTIVE_BASKET");
   string eventKey = s.basketUid + "|" + eventWindowState + "|" + newsBlockState + "|" + currentNewsBlockEventName;
   bool debugLogging = (MultilayerShadowLogLevel >= 2);
   bool stateChanged = (stateKey != mlShadowLastPrehedgeStateKey);
   bool maChanged = (maKey != mlShadowLastMaStateKey);
   bool eventChanged = (eventKey != mlShadowLastEventRiskStateKey);
   bool writeRoot = (debugLogging || stateChanged || maChanged || eventChanged);
   if(!writeRoot)
      return;

   MLShadowWriteRootSnapshot(s, distanceBand, dxy.state, vix.state, ma.crossState, eventCalendarAvailable, eventWindowState, newsBlockState);

   if(debugLogging || stateChanged)
   {
      mlShadowPrehedgeEventCount++;
      string preReason = "DATA_UNKNOWN";
      string preMask = "";
      if(distanceBand == "CRITICAL" || distanceBand == "HARDSTOP_NOW")
         preReason = "HARDSTOP_DISTANCE_TOO_SMALL";
      else if(distanceBand == "DANGER")
         preReason = "LOSS_DISTANCE_SHRINKING";
      else if(ma.buyingIntoFallingMa || ma.sellingIntoRisingMa)
         preReason = "MA_REGIME_BROKEN";
      else if(eventWindowState == "TRUE")
         preReason = "EVENT_RISK_ACTIVE";
      else if(eventWindowState == "UNKNOWN")
         preReason = "EVENT_RISK_UNKNOWN";
      TA9ShadowAppendReason(preMask, preReason);
      if(currentTechnicalDangerActive)
         TA9ShadowAppendReason(preMask, "LARGE_CANDLE_OR_TECHNICAL_ABNORMAL");
      if(dxy.stop || dxy.extreme || vix.stop || vix.extreme)
         TA9ShadowAppendReason(preMask, "DXY_VIX_ABNORMAL");
      MLShadowWriteEvent("PRE_HEDGE_RISK_STATE_CHANGE",
                         "PRE_HEDGE_RISK_SHADOW",
                         s,
                         s.lifecycleState == "PRE_HEDGE",
                         distanceBand,
                         currentTechnicalDangerActive ? currentTechnicalDangerReason : "FALSE",
                         dxy.state,
                         vix.state,
                         ma.crossState,
                         "UNKNOWN",
                         "UNKNOWN",
                         "UNKNOWN",
                         eventCalendarAvailable,
                         eventWindowState,
                         newsBlockState,
                         preReason,
                         preMask,
                         "",
                         "floating_loss=" + MLShadowDoubleText(s.floatingLossYen, 2) +
                         "|distance=" + MLShadowDoubleText(s.distanceToHardstopYen, 2) +
                         "|news_reason=" + newsReason);
      mlShadowLastPrehedgeStateKey = stateKey;
   }

   if(debugLogging || maChanged)
   {
      if(maBreak == "TRUE")
         mlShadowMaBreakObserved = true;
      if(maRetest == "RETEST_ZONE")
         mlShadowMaRetestObserved = true;
      if(maExitOpportunity == "TRUE")
         mlShadowMaRetestExitOpportunitySeen = true;
      mlShadowMaEventCount++;
      MLShadowWriteEvent("MA_REGIME_SNAPSHOT",
                         "MA_RETEST_SHADOW",
                         s,
                         s.lifecycleState == "PRE_HEDGE",
                         distanceBand,
                         currentTechnicalDangerActive ? currentTechnicalDangerReason : "FALSE",
                         dxy.state,
                         vix.state,
                         ma.crossState,
                         maBreak,
                         maRetest,
                         maExitOpportunity,
                         eventCalendarAvailable,
                         eventWindowState,
                         newsBlockState,
                         maExitOpportunity == "TRUE" ? "MA_RETEST_EXIT_ZONE" : "MA_DATA_OBSERVED",
                         maKey,
                         "",
                         "ma_mode=" + ma.mode +
                         "|ma_trend=" + ma.trendDirection +
                         "|distance_fast=" + MLShadowDoubleText(ma.distanceToFast, _Digits) +
                         "|distance_middle=" + MLShadowDoubleText(ma.distanceToMiddle, _Digits));
      mlShadowLastMaStateKey = maKey;
   }

   if(EnableEventRiskMinimalShadow && (debugLogging || eventChanged))
   {
      mlShadowEventRiskEventCount++;
      string eventReason = "EVENT_RISK_UNKNOWN";
      if(eventWindowState == "TRUE")
         eventReason = "EVENT_WINDOW_ACTIVE";
      else if(eventWindowState == "FALSE")
         eventReason = "EVENT_WINDOW_CLEAR";
      if(eventWindowState == "TRUE" && !newsBlock)
         eventReason = "EVENT_NEWSBLOCK_MISMATCH_SHADOW";
      MLShadowWriteEvent(eventWindowState == "TRUE" ? "EVENT_WINDOW_ENTERED" : "EVENT_RISK_STATE_SNAPSHOT",
                         "EVENT_RISK_MINIMAL_SHADOW",
                         s,
                         s.lifecycleState == "PRE_HEDGE",
                         distanceBand,
                         currentTechnicalDangerActive ? currentTechnicalDangerReason : "FALSE",
                         dxy.state,
                         vix.state,
                         ma.crossState,
                         maBreak,
                         maRetest,
                         maExitOpportunity,
                         eventCalendarAvailable,
                         eventWindowState,
                         newsBlockState,
                         eventReason,
                         eventKey,
                         "",
                         "calendar_source=" + NewsCsvFileName +
                         "|news_event=" + currentNewsBlockEventName +
                         "|news_reason=" + newsReason);
      mlShadowLastEventRiskStateKey = eventKey;
   }
}

void ObserveMultilayerHedgeTransitionShadow(const PositionState &preHedgePs,
                                            const PositionState &postHedgePs,
                                            bool hedgeIsBuy,
                                            double hedgeVolume)
{
   if(!MultilayerShadowEnabled())
      return;
   MqlTick tick;
   if(!SymbolInfoTick(_Symbol, tick))
      return;
   double marginLevel = AccountInfoDouble(ACCOUNT_MARGIN_LEVEL);
   bool runtimeHardStop = IsHardStopTriggeredByBasis(postHedgePs, marginLevel);
   MultilayerRootSnapshot s = MLShadowBuildRootSnapshot(postHedgePs, runtimeHardStop, marginLevel, tick, "HEDGE_TRIGGER");
   string distanceBand = MLShadowDistanceBand(s.distanceToHardstopYen, s.hardStopThresholdYen, s.hardstopNowSnapshot);
   string eventCalendarAvailable = newsCsvLoaded ? "TRUE" : "UNKNOWN";
   string eventWindowState = (EnableEventRiskMinimalShadow && newsCsvLoaded ? (currentNewsBlockActive ? "TRUE" : "FALSE") : "UNKNOWN");
   mlShadowBasketHedged = true;
   mlShadowFirstHedgeTime = s.serverTime;
   if(eventWindowState == "TRUE")
      mlShadowEventWindowHedgeOverlap = true;
   mlShadowPostHedgeBestPl = postHedgePs.floatingProfit;
   mlShadowPostHedgeWorstPl = postHedgePs.floatingProfit;
   mlShadowHedgeEventCount++;

   MLShadowWriteRootSnapshot(s, distanceBand, "NA", "NA", "NA", eventCalendarAvailable, eventWindowState, MLShadowTri(true, currentNewsBlockActive));
   string reason = "HEDGE_WITH_RECOVERY_ROOM";
   if(distanceBand == "CRITICAL" || distanceBand == "HARDSTOP_NOW")
      reason = "HEDGE_ENTERED_NEAR_HARDSTOP";
   else if(s.distanceToHardstopYen < (s.hardStopThresholdYen * 0.25))
      reason = "HEDGE_TOO_LATE";
   MLShadowWriteEvent("HEDGE_TRIGGER_OBSERVED",
                      "HEDGE_TRANSITION_SHADOW",
                      s,
                      false,
                      distanceBand,
                      currentTechnicalDangerActive ? currentTechnicalDangerReason : "FALSE",
                      "NA",
                      "NA",
                      "NA",
                      "UNKNOWN",
                      "UNKNOWN",
                      "UNKNOWN",
                      eventCalendarAvailable,
                      eventWindowState,
                      MLShadowTri(true, currentNewsBlockActive),
                      reason,
                      reason,
                      "",
                      "hedge_side=" + (hedgeIsBuy ? "BUY" : "SELL") +
                      "|hedge_volume=" + MLShadowDoubleText(hedgeVolume, 2) +
                      "|pl_at_hedge=" + MLShadowDoubleText(preHedgePs.floatingProfit, 2) +
                      "|floating_loss_at_hedge=" + MLShadowDoubleText(GetFloatingLossYen(preHedgePs), 2) +
                      "|post_hedge_pl=" + MLShadowDoubleText(postHedgePs.floatingProfit, 2));
}

void ObserveMultilayerBasketSummaryShadow(string closeReason)
{
   if(!MultilayerShadowEnabled() || !mlShadowBasketActive)
      return;
   MultilayerRootSnapshot s;
   MLShadowEnsureRunId();
   s.rootSnapshotId = mlShadowRunId + "#" + mlShadowCurrentBasketUid + "#BASKET_SUMMARY";
   s.basketUid = mlShadowCurrentBasketUid;
   s.serverTime = TimeCurrent();
   s.serverTimeMsc = ((long)s.serverTime) * 1000;
   s.tickSequenceId = runtimeEvalTickSequenceId;
   s.evalCycleSequence = mlShadowEvalCycleSequence;
   s.evalStage = "BASKET_FINAL_CLOSE";
   s.lifecycleState = "BASKET_SUMMARY";
   s.hedgeState = mlShadowBasketHedged ? "HEDGED" : "NO_HEDGE";
   s.entryState = "FINAL_CLOSE";
   s.bid = 0.0;
   s.ask = 0.0;
   s.spreadPoints = 0.0;
   s.marginLevel = 0.0;
   s.basketFloatingProfit = tradeEventContextReady ? tradeEventPosition.floatingProfit : 0.0;
   s.basketSwapState = "NOT_SEPARATELY_COLLECTED";
   s.basketCommissionStatus = "NOT_COLLECTED";
   s.currentBasketNetPl = s.basketFloatingProfit;
   s.floatingLossYen = 0.0;
   s.hardStopThresholdYen = GetHardStopThresholdYen();
   s.distanceToHardstopYen = mlShadowMinDistanceToHardstop;
   s.hardstopNowRuntime = false;
   s.hardstopNowSnapshot = false;
   s.closePriorityOk = false;
   s.closePriorityBlocked = false;
   s.pendingCloseState = CurrentCloseIntentState();
   s.marketState = CurrentMarketClosedState();
   s.loggerState = mlShadowLoggerHealthy ? "OK" : "DEGRADED";
   s.currentExposure = "NA";
   s.entryCount = 0;
   s.hedgeCount = mlShadowBasketHedged ? 1 : 0;
   s.hteEligibility = "UNKNOWN";
   s.recoveryEligibility = "UNKNOWN";
   s.basketCloseEligibility = "UNKNOWN";
   if(currentNewsBlockActive)
      mlShadowEventWindowCloseOverlap = true;
   mlShadowBasketSummaryCount++;
   MLShadowWriteEvent("MULTILAYER_BASKET_SUMMARY",
                      "MULTILAYER_BASKET_SUMMARY",
                      s,
                      false,
                      "NA",
                      currentTechnicalDangerActive ? currentTechnicalDangerReason : "FALSE",
                      "NA",
                      "NA",
                      "NA",
                      mlShadowMaBreakObserved ? "TRUE" : "FALSE",
                      mlShadowMaRetestObserved ? "RETEST_OBSERVED" : "NO_RETEST",
                      mlShadowMaRetestExitOpportunitySeen ? "TRUE" : "FALSE",
                      newsCsvLoaded ? "TRUE" : "UNKNOWN",
                      currentNewsBlockActive ? "TRUE" : (newsCsvLoaded ? "FALSE" : "UNKNOWN"),
                      MLShadowTri(true, currentNewsBlockActive),
                      "BASKET_SUMMARY",
                      "BASKET_SUMMARY",
                      closeReason,
                      "start_time=" + MLShadowTimeText(mlShadowCurrentBasketStartTime) +
                      "|end_time=" + MLShadowTimeText(s.serverTime) +
                      "|final_close_reason=" + closeReason +
                      "|hedged=" + BoolText(mlShadowBasketHedged) +
                      "|first_hedge_time=" + MLShadowTimeText(mlShadowFirstHedgeTime) +
                      "|min_distance_to_hardstop=" + MLShadowDoubleText(mlShadowMinDistanceToHardstop, 2) +
                      "|max_floating_loss=" + MLShadowDoubleText(mlShadowMaxFloatingLoss, 2) +
                      "|event_lifetime_overlap=" + BoolText(mlShadowEventWindowLifetimeOverlap) +
                      "|event_entry_overlap=" + BoolText(mlShadowEventWindowEntryOverlap) +
                      "|event_hedge_overlap=" + BoolText(mlShadowEventWindowHedgeOverlap) +
                      "|event_close_overlap=" + BoolText(mlShadowEventWindowCloseOverlap) +
                      "|post_hedge_best_pl=" + MLShadowDoubleText(mlShadowPostHedgeBestPl, 2) +
                      "|post_hedge_giveback=" + MLShadowDoubleText(mlShadowPostHedgeBestPl - s.basketFloatingProfit, 2) +
                      "|basket_dropped_rows=" + IntegerToString(mlShadowDroppedRows));
   if(MultilayerShadowFlushMode == 0)
   {
      int handle = FileOpen(mlShadowLogFileName, FILE_READ | FILE_WRITE | FILE_CSV | FILE_ANSI | FILE_SHARE_READ | FILE_SHARE_WRITE);
      if(handle != INVALID_HANDLE)
      {
         FileFlush(handle);
         FileClose(handle);
      }
   }
   mlShadowBasketActive = false;
   mlShadowCurrentBasketUid = "";
}

void MultilayerShadowWriteRunSummary(string reason)
{
   if(!MultilayerShadowEnabled())
      return;
   if(mlShadowBasketActive)
      ObserveMultilayerBasketSummaryShadow("DEINIT_ACTIVE_BASKET");
   MultilayerRootSnapshot s;
   MLShadowEnsureRunId();
   s.rootSnapshotId = mlShadowRunId + "#RUN_SUMMARY";
   s.basketUid = "RUN";
   s.serverTime = TimeCurrent();
   s.serverTimeMsc = ((long)s.serverTime) * 1000;
   s.tickSequenceId = runtimeEvalTickSequenceId;
   s.evalCycleSequence = mlShadowEvalCycleSequence;
   s.evalStage = "ON_DEINIT";
   s.lifecycleState = "RUN_SUMMARY";
   s.hedgeState = "NA";
   s.entryState = "NA";
   s.bid = 0.0;
   s.ask = 0.0;
   s.spreadPoints = 0.0;
   s.marginLevel = 0.0;
   s.basketFloatingProfit = 0.0;
   s.basketSwapState = "NOT_SEPARATELY_COLLECTED";
   s.basketCommissionStatus = "NOT_COLLECTED";
   s.currentBasketNetPl = 0.0;
   s.floatingLossYen = 0.0;
   s.hardStopThresholdYen = 0.0;
   s.distanceToHardstopYen = 0.0;
   s.hardstopNowRuntime = false;
   s.hardstopNowSnapshot = false;
   s.closePriorityOk = false;
   s.closePriorityBlocked = false;
   s.pendingCloseState = "NA";
   s.marketState = "NA";
   s.loggerState = mlShadowLoggerHealthy ? "OK" : "DEGRADED";
   s.currentExposure = "NA";
   s.entryCount = 0;
   s.hedgeCount = 0;
   s.hteEligibility = "UNKNOWN";
   s.recoveryEligibility = "UNKNOWN";
   s.basketCloseEligibility = "UNKNOWN";
   MLShadowWriteEvent("MULTILAYER_RUN_SUMMARY",
                      "MULTILAYER_RUN_SUMMARY",
                      s,
                      false,
                      "NA",
                      "NA",
                      "NA",
                      "NA",
                      "NA",
                      "UNKNOWN",
                      "UNKNOWN",
                      "UNKNOWN",
                      newsCsvLoaded ? "TRUE" : "UNKNOWN",
                      "UNKNOWN",
                      "UNKNOWN",
                      "RUN_SUMMARY",
                      reason,
                      reason,
                      "start_time=" + MLShadowTimeText(mlShadowRunStartTime) +
                      "|end_time=" + MLShadowTimeText(s.serverTime) +
                      "|root_snapshots=" + IntegerToString(mlShadowRootSnapshotCount) +
                      "|prehedge_events=" + IntegerToString(mlShadowPrehedgeEventCount) +
                      "|hedge_events=" + IntegerToString(mlShadowHedgeEventCount) +
                      "|ma_events=" + IntegerToString(mlShadowMaEventCount) +
                      "|event_risk_events=" + IntegerToString(mlShadowEventRiskEventCount) +
                      "|basket_summaries=" + IntegerToString(mlShadowBasketSummaryCount) +
                      "|logger_open_errors=" + IntegerToString(mlShadowLoggerOpenErrorCount) +
                      "|logger_write_errors=" + IntegerToString(mlShadowLoggerWriteErrorCount) +
                      "|dropped_rows=" + IntegerToString(mlShadowDroppedRows) +
                      "|duplicate_snapshots=" + IntegerToString(mlShadowDuplicateSnapshotCount) +
                      "|parity_errors=" + IntegerToString(mlShadowParityErrorCount) +
                      "|max_rows_reached=" + BoolText(mlShadowMaxRowsReached));
}

string WritePrioritySnapshot(const PositionState &ps,
                             string oldBasketId,
                             string source,
                             const ClosePriorityState &priority,
                             string triggerName,
                             string extra="")
{
   if(!EnablePrioritySnapshotDiagnostic && !EnableCorrectedLeadTimeDryRunDiagnostic &&
      !EnablePreHardStopCloseableWindowDiagnostic &&
      !UseL1M5R12LargeAdverseExit && !UseB2M5TickVolLargeAdverseExit &&
      !UseCW8OutsideHteBandExit && !UsePreHardStopS2StrictGuardExit)
      return "";

   prioritySnapshotSeq++;
   string snapshotId = "PS" + IntegerToString(prioritySnapshotSeq, 6, '0');
   MqlTick tick;
   double spread = 0.0;
   datetime tickTime = TimeCurrent();
   if(SymbolInfoTick(_Symbol, tick))
   {
      spread = tick.ask - tick.bid;
      tickTime = (datetime)tick.time;
   }
   datetime barTime = iTime(_Symbol, PERIOD_M5, 0);
   if(barTime <= 0)
      barTime = TimeCurrent();

   string detail = "PrioritySnapshotId=" + snapshotId +
                   "|BasketUid=" + CurrentPostHedgeBasketUid(ps) +
                   "|OldBasketId=" + oldBasketId +
                   "|Source=" + source +
                   "|TriggerName=" + triggerName +
                   "|ServerTime=" + TimeToString(TimeCurrent(), TIME_DATE | TIME_SECONDS) +
                   "|JstTime=" + TimeToString(TimeGMT() + 9 * 3600, TIME_DATE | TIME_SECONDS) +
                   "|BarTime=" + TimeToString(barTime, TIME_DATE | TIME_SECONDS) +
                   "|TickTime=" + TimeToString(tickTime, TIME_DATE | TIME_SECONDS) +
                   "|Symbol=" + _Symbol +
                   "|Direction=" + PostHedgeBasketDirectionText(ps) +
                   "|PositionCount=" + IntegerToString(ps.total) +
                   "|HedgeState=" + (CountDefenseHedges() > 0 ? "DEFENSE_HEDGE_ACTIVE" : "NO_DEFENSE_HEDGE") +
                   "|FloatingPnLYen=" + DoubleToString(ps.floatingProfit, 2) +
                   "|HardStopNow=" + BoolText(priority.hardStopNow) +
                   "|ClosePriorityOK=" + BoolText(priority.closePriorityOk) +
                   "|ClosePriorityBlocked=" + BoolText(priority.closePriorityBlocked) +
                   "|ClosePriorityReason=" + priority.closePriorityReason +
                   "|CloseIntentState=" + priority.closeIntentState +
                   "|ActiveCloseReason=" + priority.activeCloseReason +
                   "|MarketClosedState=" + CurrentMarketClosedState() +
                   "|SpreadPrice=" + DoubleToString(spread, 3);
   if(extra != "")
      detail += "|" + extra;

   WriteTradeEventLog("PRIORITY_SNAPSHOT", 0, 0, "", detail, "", 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, ps.floatingProfit);
   return snapshotId;
}

void RuntimeEvalStageStartTick(const MqlTick &tick)
{
   if(!EnableRuntimeEvaluationStageAudit && !UsePreHardStopS2StrictGuardExit)
      return;
   runtimeEvalTickSequenceId++;
   runtimeEvalStageIndex = 0;
   runtimeEvalTickTime = (datetime)tick.time;
}

bool RuntimeEvalStageMarkOnce(string key)
{
   string token = "|" + key + "|";
   if(StringFind(runtimeEvalStageLoggedKeys, token) >= 0)
      return false;
   runtimeEvalStageLoggedKeys += token;
   return true;
}

bool RuntimeEvalStageShouldLog(string stageName,
                               const PositionState &ps,
                               const ClosePriorityState &priority,
                               bool cw8ConditionTrue,
                               string &phase)
{
   phase = "";
   if(!EnableRuntimeEvaluationStageAudit || !postHedgeDiagActive || ps.total <= 0 || CountDefenseHedges() <= 0)
      return false;

   if(cw8ConditionTrue && priority.closePriorityOk && !priority.hardStopNow)
      phase = "CW8_CLOSEABLE";
   else if(cw8ConditionTrue && priority.hardStopNow)
      phase = "CW8_HARDSTOP";
   else if(priority.hardStopNow)
      phase = "HARDSTOP";
   else if(ps.floatingProfit < CW8HteLossBandYen && priority.closePriorityOk)
      phase = "LOSS_CLOSEABLE";
   else if(stageName == "RUNTIME_EXIT_GATE" && ps.floatingProfit < 0.0)
      phase = "RUNTIME_GATE_RAW";
   else
      return false;

   string key = CurrentPostHedgeBasketUid(ps) + "#" + stageName + "#" + phase;
   return RuntimeEvalStageMarkOnce(key);
}

void TraceRuntimeEvaluationStage(string stageName,
                                 const PositionState &ps,
                                 bool hardStop,
                                 bool recoveryCloseEligible,
                                 bool recoveryLossCutEligible,
                                 bool hteEligibleNow,
                                 bool canPlaceExitHere,
                                 bool wouldChangePriorityOrder,
                                 string stageComment)
{
   if(!EnableRuntimeEvaluationStageAudit)
      return;
   ClosePriorityState priority = BuildRuntimeClosePriorityState(ps,
                                                                hardStop,
                                                                recoveryCloseEligible,
                                                                recoveryLossCutEligible,
                                                                hteEligibleNow);
   bool outsideHteBand = (ps.floatingProfit < CW8HteLossBandYen);
   bool hteNearState = (ps.floatingProfit >= CW8HteLossBandYen);
   bool cw8ConditionTrue = (outsideHteBand && !hteNearState);
   string phase = "";
   if(!RuntimeEvalStageShouldLog(stageName, ps, priority, cw8ConditionTrue, phase))
      return;

   runtimeEvalStageIndex++;
   MqlTick tick;
   datetime tickTime = runtimeEvalTickTime > 0 ? runtimeEvalTickTime : TimeCurrent();
   double spread = 0.0;
   if(SymbolInfoTick(_Symbol, tick))
   {
      tickTime = (datetime)tick.time;
      spread = tick.ask - tick.bid;
   }
   datetime barTime = iTime(_Symbol, PERIOD_M5, 0);
   if(barTime <= 0)
      barTime = TimeCurrent();
   string snapshotId = "EST" + IntegerToString(runtimeEvalTickSequenceId, 6, '0') + "_" +
                       IntegerToString(runtimeEvalStageIndex, 3, '0');
   string detail = "BasketId=" + postHedgeDiagBasketId +
                   "|BasketUid=" + CurrentPostHedgeBasketUid(ps) +
                   "|OldBasketId=" + postHedgeDiagBasketId +
                   "|ServerTime=" + TimeToString(TimeCurrent(), TIME_DATE | TIME_SECONDS) +
                   "|JstTime=" + TimeToString(TimeGMT() + 9 * 3600, TIME_DATE | TIME_SECONDS) +
                   "|BarTime=" + TimeToString(barTime, TIME_DATE | TIME_SECONDS) +
                   "|TickTime=" + TimeToString(tickTime, TIME_DATE | TIME_SECONDS) +
                   "|TickSequenceId=" + IntegerToString(runtimeEvalTickSequenceId) +
                   "|EvalStageIndex=" + IntegerToString(runtimeEvalStageIndex) +
                   "|EvalStageName=" + stageName +
                   "|PrioritySnapshotId=" + snapshotId +
                   "|Symbol=" + _Symbol +
                   "|Direction=" + PostHedgeBasketDirectionText(ps) +
                   "|PositionCount=" + IntegerToString(ps.total) +
                   "|HedgeState=" + (CountDefenseHedges() > 0 ? "HEDGED" : "NO_HEDGE") +
                   "|FloatingPnLYen=" + DoubleToString(ps.floatingProfit, 2) +
                   "|BestFloatingPnLYen=" + DoubleToString(postHedgeDiagBestFloatingAfterHedge, 2) +
                   "|WorstFloatingPnLYen=" + DoubleToString(postHedgeDiagWorstFloatingAfterHedge, 2) +
                   "|HardStopNow=" + BoolText(priority.hardStopNow) +
                   "|ClosePriorityOK=" + BoolText(priority.closePriorityOk) +
                   "|ClosePriorityBlocked=" + BoolText(priority.closePriorityBlocked) +
                   "|ClosePriorityReason=" + priority.closePriorityReason +
                   "|CloseIntentState=" + priority.closeIntentState +
                   "|ActiveCloseReason=" + priority.activeCloseReason +
                   "|MarketClosedState=" + CurrentMarketClosedState() +
                   "|SpreadPrice=" + DoubleToString(spread, 3) +
                   "|CW8ConditionTrue=" + BoolText(cw8ConditionTrue) +
                   "|OutsideHteBand=" + BoolText(outsideHteBand) +
                   "|HteNearState=" + BoolText(hteNearState) +
                   "|HteConditionDistance=" + DoubleToString(ps.floatingProfit - CW8HteLossBandYen, 2) +
                   "|CanPlaceExitHere=" + BoolText(canPlaceExitHere) +
                   "|WouldChangePriorityOrder=" + BoolText(wouldChangePriorityOrder) +
                   "|StagePhase=" + phase +
                   "|StageComment=" + stageComment;
   WriteTradeEventLog("EVAL_STAGE_TRACE",
                      0,
                      0,
                      "",
                      detail,
                      "",
                      0.0,
                      0.0,
                      0.0,
                      0.0,
                      0.0,
                      0.0,
                      ps.floatingProfit);
}

void PostHedgeDryRunAppendTickTime()
{
   if(!EnablePostHedgeDryRunDiagnostic || !postHedgeDiagActive)
      return;

   int size = ArraySize(postHedgeDryRunTickTimes);
   ArrayResize(postHedgeDryRunTickTimes, size + 1);
   postHedgeDryRunTickTimes[size] = TimeCurrent();

   datetime cutoff = TimeCurrent() - 180;
   int start = 0;
   while(start < size + 1 && postHedgeDryRunTickTimes[start] < cutoff)
      start++;
   if(start <= 0)
      return;

   int newSize = size + 1 - start;
   for(int i = 0; i < newSize; i++)
      postHedgeDryRunTickTimes[i] = postHedgeDryRunTickTimes[i + start];
   ArrayResize(postHedgeDryRunTickTimes, newSize);
}

int PostHedgeDryRunTickCountWindow(int seconds, int offsetSeconds)
{
   datetime toTime = TimeCurrent() - offsetSeconds;
   datetime fromTime = toTime - seconds;
   int count = 0;
   int size = ArraySize(postHedgeDryRunTickTimes);
   for(int i = 0; i < size; i++)
   {
      datetime t = postHedgeDryRunTickTimes[i];
      if(t > fromTime && t <= toTime)
         count++;
   }
   return count;
}

double PostHedgeDryRunTickCountRatio(int seconds)
{
   if(postHedgeDiagHedgeTime <= 0 || TimeCurrent() - postHedgeDiagHedgeTime < seconds * 2)
      return 0.0;
   int recent = PostHedgeDryRunTickCountWindow(seconds, 0);
   int previous = PostHedgeDryRunTickCountWindow(seconds, seconds);
   if(previous <= 0)
      return recent > 0 ? 999.0 : 0.0;
   return (double)recent / (double)previous;
}

double PostHedgeDryRunTickVolumeRatio(ENUM_TIMEFRAMES tf, long &currentVolume, double &averageVolume)
{
   currentVolume = 0;
   averageVolume = 0.0;
   long volumes[];
   ArraySetAsSeries(volumes, true);
   int copied = CopyTickVolume(_Symbol, tf, 0, 21, volumes);
   if(copied < 21)
      return 0.0;
   currentVolume = volumes[0];
   double sum = 0.0;
   for(int i = 1; i <= 20; i++)
      sum += (double)volumes[i];
   averageVolume = sum / 20.0;
   if(averageVolume <= 0.0)
      return 0.0;
   return (double)currentVolume / averageVolume;
}

double HardStopPrecursorCurrentMidPrice()
{
   MqlTick tick;
   if(!SymbolInfoTick(_Symbol, tick))
      return 0.0;
   return (tick.bid + tick.ask) / 2.0;
}

void ResetHardStopPrecursorDiagnostic()
{
   hardStopPrecursorLoggedPlans = "";
   hardStopPrecursorLastSnapshotMinute = -1;
   ArrayResize(hardStopPrecursorSampleTimes, 0);
   ArrayResize(hardStopPrecursorSamplePnls, 0);
   ArrayResize(hardStopPrecursorSamplePrices, 0);
}

void HardStopPrecursorAppendSample(const PositionState &ps)
{
   if((!EnableHardStopPrecursorDiagnostic && !UseB2M5TickVolLargeAdverseExit &&
       !UseCW8OutsideHteBandExit && !UsePreHardStopS2StrictGuardExit &&
       !UseL1M5R12LargeAdverseExit) || !postHedgeDiagActive)
      return;
   datetime minuteTime = (datetime)((long)(TimeCurrent() / 60) * 60);
   int size = ArraySize(hardStopPrecursorSampleTimes);
   if(size > 0 && hardStopPrecursorSampleTimes[size - 1] == minuteTime)
   {
      hardStopPrecursorSamplePnls[size - 1] = ps.floatingProfit;
      hardStopPrecursorSamplePrices[size - 1] = HardStopPrecursorCurrentMidPrice();
      return;
   }
   ArrayResize(hardStopPrecursorSampleTimes, size + 1);
   ArrayResize(hardStopPrecursorSamplePnls, size + 1);
   ArrayResize(hardStopPrecursorSamplePrices, size + 1);
   hardStopPrecursorSampleTimes[size] = minuteTime;
   hardStopPrecursorSamplePnls[size] = ps.floatingProfit;
   hardStopPrecursorSamplePrices[size] = HardStopPrecursorCurrentMidPrice();
}

bool HardStopPrecursorGetSampleMinutesAgo(int minutesAgo, double &pnl, double &price)
{
   pnl = 0.0;
   price = 0.0;
   int size = ArraySize(hardStopPrecursorSampleTimes);
   if(size <= 0)
      return false;
   datetime target = TimeCurrent() - minutesAgo * 60;
   for(int i = size - 1; i >= 0; i--)
   {
      if(hardStopPrecursorSampleTimes[i] <= target)
      {
         pnl = hardStopPrecursorSamplePnls[i];
         price = hardStopPrecursorSamplePrices[i];
         return true;
      }
   }
   return false;
}

double HardStopPrecursorPnlChangeMinutes(int minutesAgo)
{
   double pastPnl = 0.0;
   double pastPrice = 0.0;
   if(!HardStopPrecursorGetSampleMinutesAgo(minutesAgo, pastPnl, pastPrice))
      return 0.0;
   int size = ArraySize(hardStopPrecursorSamplePnls);
   if(size <= 0)
      return 0.0;
   return hardStopPrecursorSamplePnls[size - 1] - pastPnl;
}

double HardStopPrecursorPriceMoveMinutes(int minutesAgo, bool adverseOnly)
{
   double pastPnl = 0.0;
   double pastPrice = 0.0;
   if(!HardStopPrecursorGetSampleMinutesAgo(minutesAgo, pastPnl, pastPrice))
      return 0.0;
   int size = ArraySize(hardStopPrecursorSamplePrices);
   if(size <= 0)
      return 0.0;
   double currentPnl = hardStopPrecursorSamplePnls[size - 1];
   double currentPrice = hardStopPrecursorSamplePrices[size - 1];
   double move = currentPrice - pastPrice;
   if(!adverseOnly)
      return move;
   return (currentPnl < pastPnl ? MathAbs(move) : 0.0);
}

int HardStopPrecursorSameDirectionCount(ENUM_TIMEFRAMES tf)
{
   double open1 = iOpen(_Symbol, tf, 1);
   double close1 = iClose(_Symbol, tf, 1);
   if(open1 <= 0.0 || close1 <= 0.0 || close1 == open1)
      return 0;
   int dir = close1 > open1 ? 1 : -1;
   int count = 0;
   for(int i = 1; i <= 20; i++)
   {
      double o = iOpen(_Symbol, tf, i);
      double c = iClose(_Symbol, tf, i);
      if(o <= 0.0 || c <= 0.0 || c == o)
         break;
      int d = c > o ? 1 : -1;
      if(d != dir)
         break;
      count++;
   }
   return count;
}

double HardStopPrecursorBodyAtrRatio(ENUM_TIMEFRAMES tf)
{
   double open1 = iOpen(_Symbol, tf, 1);
   double close1 = iClose(_Symbol, tf, 1);
   if(open1 <= 0.0 || close1 <= 0.0)
      return 0.0;
   double sumRange = 0.0;
   int count = 0;
   for(int i = 1; i <= 14; i++)
   {
      double h = iHigh(_Symbol, tf, i);
      double l = iLow(_Symbol, tf, i);
      if(h <= 0.0 || l <= 0.0 || h < l)
         continue;
      sumRange += (h - l);
      count++;
   }
   if(count <= 0 || sumRange <= 0.0)
      return 0.0;
   double avgRange = sumRange / (double)count;
   if(avgRange <= 0.0)
      return 0.0;
   return MathAbs(close1 - open1) / avgRange;
}

bool HardStopPrecursorPlanAlreadyLogged(string planName)
{
   return (StringFind(hardStopPrecursorLoggedPlans, "|" + planName + "|") >= 0);
}

void HardStopPrecursorMarkPlan(string planName)
{
   if(HardStopPrecursorPlanAlreadyLogged(planName))
      return;
   hardStopPrecursorLoggedPlans += "|" + planName + "|";
}

void LogHardStopPrecursorDryRunPlan(const PositionState &ps,
                                    string planName,
                                    string planGroup,
                                    string condition,
                                    const ClosePriorityState &priority,
                                    string extra = "")
{
   if(!EnableHardStopPrecursorDiagnostic || !postHedgeDiagActive)
      return;
   if(HardStopPrecursorPlanAlreadyLogged(planName))
      return;
   HardStopPrecursorMarkPlan(planName);
   string snapshotId = WritePrioritySnapshot(ps,
                                             postHedgeDiagBasketId,
                                             "DRYRUN_DIAG",
                                             priority,
                                             planName);

   string reason = "DryRunExitPlan=" + planName +
                   "|PlanGroup=" + planGroup +
                   "|Condition=" + condition +
                   "|BasketUid=" + CurrentPostHedgeBasketUid(ps) +
                   "|PrioritySnapshotId=" + snapshotId +
                   "|HardStopNow=" + BoolText(priority.hardStopNow) +
                   "|ClosePriorityOK=" + BoolText(priority.closePriorityOk) +
                   "|ClosePriorityBlocked=" + BoolText(priority.closePriorityBlocked) +
                   "|ClosePriorityReason=" + priority.closePriorityReason +
                   "|CloseIntentState=" + priority.closeIntentState +
                   "|ExecutableCandidate=" + BoolText(priority.closePriorityOk) +
                   "|DryRunExitTime=" + TimeToString(TimeCurrent(), TIME_DATE | TIME_SECONDS) +
                   "|DryRunExitMinutesAfterHedge=" + IntegerToString(PostHedgeDiagMinutesAfterHedge()) +
                   "|DryRunExitProfitYen=" + DoubleToString(ps.floatingProfit, 2) +
                   "|BestFloatingPnLAfterHedge=" + DoubleToString(postHedgeDiagBestFloatingAfterHedge, 2) +
                   "|WorstFloatingPnLAfterHedge=" + DoubleToString(postHedgeDiagWorstFloatingAfterHedge, 2) +
                   "|DistanceToBasketCloseYen=" + DoubleToString(PostHedgeDiagDistanceToBasketClose(ps), 2) +
                   "|DistanceToRecoveryCloseYen=" + DoubleToString(PostHedgeDiagDistanceToRecoveryClose(ps), 2) +
                   "|DistanceToHardStopYen=" + DoubleToString(PostHedgeDiagDistanceToHardStop(ps), 2);
   if(extra != "")
      reason += "|" + extra;
   WritePostHedgeDiagEvent("HARDSTOP_PRECURSOR_DRYRUN_CANDIDATE", ps, reason);
}

string HardStopPrecursorMetricDetail(const PositionState &ps)
{
   long m1Volume = 0;
   long m5Volume = 0;
   double m1Average = 0.0;
   double m5Average = 0.0;
   double m1Ratio = PostHedgeDryRunTickVolumeRatio(PERIOD_M1, m1Volume, m1Average);
   double m5Ratio = PostHedgeDryRunTickVolumeRatio(PERIOD_M5, m5Volume, m5Average);
   double pnl5 = HardStopPrecursorPnlChangeMinutes(5);
   double pnl15 = HardStopPrecursorPnlChangeMinutes(15);
   double pnl30 = HardStopPrecursorPnlChangeMinutes(30);
   double pnl60 = HardStopPrecursorPnlChangeMinutes(60);
   double price5 = HardStopPrecursorPriceMoveMinutes(5, true);
   double price15 = HardStopPrecursorPriceMoveMinutes(15, true);
   double price30 = HardStopPrecursorPriceMoveMinutes(30, true);
   double price60 = HardStopPrecursorPriceMoveMinutes(60, true);
   int m1Same = HardStopPrecursorSameDirectionCount(PERIOD_M1);
   int m5Same = HardStopPrecursorSameDirectionCount(PERIOD_M5);
   double m1BodyRatio = HardStopPrecursorBodyAtrRatio(PERIOD_M1);
   double m5BodyRatio = HardStopPrecursorBodyAtrRatio(PERIOD_M5);
   MqlTick tick;
   double spread = 0.0;
   if(SymbolInfoTick(_Symbol, tick))
      spread = tick.ask - tick.bid;

   MqlDateTime jst;
   TimeToStruct(TimeGMT() + 9 * 3600, jst);

   string detail = "";
   PostHedgeDiagAppendD(detail, "PnlChange5m", pnl5, 2);
   PostHedgeDiagAppendD(detail, "PnlChange15m", pnl15, 2);
   PostHedgeDiagAppendD(detail, "PnlChange30m", pnl30, 2);
   PostHedgeDiagAppendD(detail, "PnlChange60m", pnl60, 2);
   PostHedgeDiagAppendD(detail, "AdversePriceMove5m", price5, 3);
   PostHedgeDiagAppendD(detail, "AdversePriceMove15m", price15, 3);
   PostHedgeDiagAppendD(detail, "AdversePriceMove30m", price30, 3);
   PostHedgeDiagAppendD(detail, "AdversePriceMove60m", price60, 3);
   PostHedgeDiagAppendI(detail, "M1TickVolume", (int)m1Volume);
   PostHedgeDiagAppendD(detail, "M1TickVolumeRatio", m1Ratio, 3);
   PostHedgeDiagAppendI(detail, "M5TickVolume", (int)m5Volume);
   PostHedgeDiagAppendD(detail, "M5TickVolumeRatio", m5Ratio, 3);
   PostHedgeDiagAppendI(detail, "M1SameDirectionCount", m1Same);
   PostHedgeDiagAppendI(detail, "M5SameDirectionCount", m5Same);
   PostHedgeDiagAppendD(detail, "M1BodyAtrRatio", m1BodyRatio, 3);
   PostHedgeDiagAppendD(detail, "M5BodyAtrRatio", m5BodyRatio, 3);
   PostHedgeDiagAppendD(detail, "SpreadPrice", spread, 3);
   PostHedgeDiagAppend(detail, "SessionName", GetPostHedgeDiagSessionJst());
   PostHedgeDiagAppendI(detail, "Weekday", jst.day_of_week);
   PostHedgeDiagAppendI(detail, "JstHour", jst.hour);
   PostHedgeDiagAppend(detail, "NewsWindowState", currentNewsBlockActive ? "active" : "clear");
   return detail;
}

string PreHardStopCloseableMetricDetail(const PositionState &ps,
                                        const ClosePriorityState &priority,
                                        string snapshotType,
                                        string snapshotId)
{
   long m5Volume = 0;
   long m15Volume = 0;
   double m5Average = 0.0;
   double m15Average = 0.0;
   double m5Ratio = PostHedgeDryRunTickVolumeRatio(PERIOD_M5, m5Volume, m5Average);
   double m15Ratio = PostHedgeDryRunTickVolumeRatio(PERIOD_M15, m15Volume, m15Average);
   double pnl5 = HardStopPrecursorPnlChangeMinutes(5);
   double pnl15 = HardStopPrecursorPnlChangeMinutes(15);
   double pnl30 = HardStopPrecursorPnlChangeMinutes(30);
   double pnl60 = HardStopPrecursorPnlChangeMinutes(60);
   double pnl120 = HardStopPrecursorPnlChangeMinutes(120);
   double m5BodyRatio = HardStopPrecursorBodyAtrRatio(PERIOD_M5);
   double m15BodyRatio = HardStopPrecursorBodyAtrRatio(PERIOD_M15);
   MqlTick tick;
   double spread = 0.0;
   if(SymbolInfoTick(_Symbol, tick))
      spread = tick.ask - tick.bid;

   double hteConditionDistance = ps.floatingProfit - B2G5HteLossBandYen;
   bool hteNear = (ps.floatingProfit >= B2G5HteLossBandYen);
   string detail = "";
   PostHedgeDiagAppend(detail, "SnapshotType", snapshotType);
   PostHedgeDiagAppend(detail, "PrioritySnapshotId", snapshotId);
   PostHedgeDiagAppend(detail, "HardStopNow", BoolText(priority.hardStopNow));
   PostHedgeDiagAppend(detail, "ClosePriorityOK", BoolText(priority.closePriorityOk));
   PostHedgeDiagAppend(detail, "ClosePriorityBlocked", BoolText(priority.closePriorityBlocked));
   PostHedgeDiagAppend(detail, "ClosePriorityReason", priority.closePriorityReason);
   PostHedgeDiagAppendD(detail, "FloatingPnLYen", ps.floatingProfit, 2);
   PostHedgeDiagAppendD(detail, "BestFloatingPnLYen", postHedgeDiagBestFloatingAfterHedge, 2);
   PostHedgeDiagAppendD(detail, "WorstFloatingPnLYen", postHedgeDiagWorstFloatingAfterHedge, 2);
   PostHedgeDiagAppendD(detail, "PnlChange5m", pnl5, 2);
   PostHedgeDiagAppendD(detail, "PnlChange15m", pnl15, 2);
   PostHedgeDiagAppendD(detail, "PnlChange30m", pnl30, 2);
   PostHedgeDiagAppendD(detail, "PnlChange60m", pnl60, 2);
   PostHedgeDiagAppendD(detail, "PnlChange120m", pnl120, 2);
   PostHedgeDiagAppendI(detail, "M5TickVolume", (int)m5Volume);
   PostHedgeDiagAppendD(detail, "M5TickVolumeRatio", m5Ratio, 3);
   PostHedgeDiagAppendD(detail, "M5BodyAtrRatio", m5BodyRatio, 3);
   PostHedgeDiagAppend(detail, "M5CandleDirection", pnl15 < 0.0 ? "ADVERSE" : (pnl15 > 0.0 ? "FAVORABLE" : "FLAT"));
   PostHedgeDiagAppendI(detail, "M15TickVolume", (int)m15Volume);
   PostHedgeDiagAppendD(detail, "M15TickVolumeRatio", m15Ratio, 3);
   PostHedgeDiagAppendD(detail, "M15BodyAtrRatio", m15BodyRatio, 3);
   PostHedgeDiagAppend(detail, "M15CandleDirection", pnl60 < 0.0 ? "ADVERSE" : (pnl60 > 0.0 ? "FAVORABLE" : "FLAT"));
   PostHedgeDiagAppend(detail, "AdverseDirection", BoolText(ps.floatingProfit < postHedgeDiagFloatingAtHedge));
   PostHedgeDiagAppendD(detail, "SpreadPrice", spread, 3);
   PostHedgeDiagAppend(detail, "HteNearState", BoolText(hteNear));
   PostHedgeDiagAppendD(detail, "HteConditionDistance", hteConditionDistance, 2);
   PostHedgeDiagAppend(detail, "SessionName", GetPostHedgeDiagSessionJst());
   MqlDateTime jst;
   TimeToStruct(TimeGMT() + 9 * 3600, jst);
   PostHedgeDiagAppendI(detail, "JstHour", jst.hour);
   PostHedgeDiagAppend(detail, "NewsWindowState", currentNewsBlockActive ? "active" : "clear");
   PostHedgeDiagAppendD(detail, "VirtualExitProfitYen", ps.floatingProfit, 2);
   PostHedgeDiagAppend(detail, "ExecutableCandidate", BoolText(priority.closePriorityOk));
   return detail;
}

void LogPreHardStopCloseableWindowSnapshot(const PositionState &ps,
                                           bool hardStop,
                                           string snapshotType,
                                           bool force=false)
{
   if(!EnablePreHardStopCloseableWindowDiagnostic || !postHedgeDiagActive)
      return;

   bool recoveryCloseEligible = PostHedgeDiagRecoveryCloseEligible(ps);
   bool recoveryLossCutEligible = PostHedgeDiagRecoveryLossCutEligible(ps);
   bool timeExitEligible = PostHedgeDiagTimeExitEligible(ps);
   ClosePriorityState priority = BuildRuntimeClosePriorityState(ps,
                                                                hardStop,
                                                                recoveryCloseEligible,
                                                                recoveryLossCutEligible,
                                                                timeExitEligible);
   int minutes = PostHedgeDiagMinutesAfterHedge();
   int bucket = (int)MathFloor((double)minutes / 5.0);
   if(!force && snapshotType == "CLOSEABLE_WINDOW_MIDDLE" && bucket == preHardStopCwLastSnapshotBucket)
      return;
   if(snapshotType == "CLOSEABLE_WINDOW_MIDDLE")
      preHardStopCwLastSnapshotBucket = bucket;

   string extra = "SnapshotType=" + snapshotType;
   string snapshotId = WritePrioritySnapshot(ps,
                                             postHedgeDiagBasketId,
                                             "DRYRUN_DIAG",
                                             priority,
                                             "PRE_HARDSTOP_CLOSEABLE_WINDOW",
                                             extra);
   string detail = PreHardStopCloseableMetricDetail(ps, priority, snapshotType, snapshotId);
   WritePostHedgeDiagEvent("PRE_HARDSTOP_CW_SNAPSHOT", ps, detail);
}

void EvaluatePreHardStopCloseableWindowDiagnostic(const PositionState &ps, bool hardStop)
{
   if(!EnablePreHardStopCloseableWindowDiagnostic || !postHedgeDiagActive)
      return;

   bool recoveryCloseEligible = PostHedgeDiagRecoveryCloseEligible(ps);
   bool recoveryLossCutEligible = PostHedgeDiagRecoveryLossCutEligible(ps);
   bool timeExitEligible = PostHedgeDiagTimeExitEligible(ps);
   ClosePriorityState priority = BuildRuntimeClosePriorityState(ps,
                                                                hardStop,
                                                                recoveryCloseEligible,
                                                                recoveryLossCutEligible,
                                                                timeExitEligible);

   if(priority.closePriorityOk && !priority.hardStopNow)
   {
      if(!preHardStopCwWindowActive)
      {
         preHardStopCwWindowActive = true;
         preHardStopCwWindowStartTime = TimeCurrent();
         if(!preHardStopCwStartLogged)
         {
            preHardStopCwStartLogged = true;
            LogPreHardStopCloseableWindowSnapshot(ps, hardStop, "CLOSEABLE_WINDOW_START", true);
         }
      }
      preHardStopCwLastCloseableTime = TimeCurrent();
      preHardStopCwLastCloseableProfit = ps.floatingProfit;
      LogPreHardStopCloseableWindowSnapshot(ps, hardStop, "CLOSEABLE_WINDOW_MIDDLE");
   }

   if(!preHardStopCwHardStopEnterLogged && priority.closePriorityBlocked &&
      priority.closePriorityReason == "HARDSTOP_PRIORITY")
   {
      preHardStopCwHardStopEnterLogged = true;
      LogPreHardStopCloseableWindowSnapshot(ps, hardStop, "HARDSTOP_PRIORITY_ENTER", true);
   }
}

void LogHardStopPrecursorSnapshotIfNeeded(const PositionState &ps, bool hardStop, bool force=false)
{
   if(!EnableHardStopPrecursorDiagnostic || !postHedgeDiagActive)
      return;
   int minutes = PostHedgeDiagMinutesAfterHedge();
   int interval = HardStopPrecursorSnapshotIntervalMinutes;
   if(interval <= 0)
      interval = 5;
   int bucket = (int)MathFloor((double)minutes / (double)interval);
   if(!force && bucket == hardStopPrecursorLastSnapshotMinute)
      return;
   hardStopPrecursorLastSnapshotMinute = bucket;
   string reason = "SnapshotMinutesAfterHedge=" + IntegerToString(minutes) +
                   "|HardStopNow=" + BoolText(hardStop) +
                   "|" + HardStopPrecursorMetricDetail(ps);
   WritePostHedgeDiagEvent("HARDSTOP_PRECURSOR_SNAPSHOT", ps, reason);
}

void EvaluateHardStopPrecursorDryRunPlans(const PositionState &ps, bool hardStop)
{
   if(!EnableHardStopPrecursorDiagnostic || !postHedgeDiagActive)
      return;
   if(PostHedgeDiagDistanceToHardStop(ps) <= 0.0)
      return;

   bool recoveryCloseEligible = PostHedgeDiagRecoveryCloseEligible(ps);
   bool recoveryLossCutEligible = PostHedgeDiagRecoveryLossCutEligible(ps);
   bool timeExitEligible = PostHedgeDiagTimeExitEligible(ps);
   ClosePriorityState priority = BuildRuntimeClosePriorityState(ps,
                                                                hardStop,
                                                                recoveryCloseEligible,
                                                                recoveryLossCutEligible,
                                                                timeExitEligible);

   int minutes = PostHedgeDiagMinutesAfterHedge();
   double pnl5 = HardStopPrecursorPnlChangeMinutes(5);
   double pnl15 = HardStopPrecursorPnlChangeMinutes(15);
   double pnl30 = HardStopPrecursorPnlChangeMinutes(30);
   double pnl60 = HardStopPrecursorPnlChangeMinutes(60);
   long m1Volume = 0;
   long m5Volume = 0;
   double m1Average = 0.0;
   double m5Average = 0.0;
   double m1Ratio = PostHedgeDryRunTickVolumeRatio(PERIOD_M1, m1Volume, m1Average);
   double m5Ratio = PostHedgeDryRunTickVolumeRatio(PERIOD_M5, m5Volume, m5Average);
   int m1Same = HardStopPrecursorSameDirectionCount(PERIOD_M1);
   int m5Same = HardStopPrecursorSameDirectionCount(PERIOD_M5);
   double m1BodyRatio = HardStopPrecursorBodyAtrRatio(PERIOD_M1);
   double m5BodyRatio = HardStopPrecursorBodyAtrRatio(PERIOD_M5);
   bool m1LargeAdverse = (pnl5 < 0.0 && m1BodyRatio >= 1.0);
   bool m5LargeAdverse = (pnl15 < 0.0 && m5BodyRatio >= 1.0);

   string metric = HardStopPrecursorMetricDetail(ps);
   if(minutes >= 15 && pnl15 <= -1000.0)
      LogHardStopPrecursorDryRunPlan(ps, "A1_ADVERSE_ACCEL_15M_1000", "AdverseAcceleration",
                                     "15min pnl deterioration <= -1000 after hedge+15min", priority, metric);
   if(minutes >= 30 && pnl30 <= -1500.0)
      LogHardStopPrecursorDryRunPlan(ps, "A2_ADVERSE_ACCEL_30M_1500", "AdverseAcceleration",
                                     "30min pnl deterioration <= -1500 after hedge+30min", priority, metric);
   if(minutes >= 30 && minutes <= 60 &&
      postHedgeDiagBestFloatingAfterHedge < postHedgeDiagFloatingAtHedge + 500.0 &&
      pnl30 <= -1000.0)
      LogHardStopPrecursorDryRunPlan(ps, "A3_NO_RECOVERY_60M_ACCEL_30M", "AdverseAcceleration",
                                     "within 60min no +500 recovery and 30min pnl deterioration <= -1000", priority, metric);
   if(m1Ratio >= 2.0 && m1LargeAdverse)
      LogHardStopPrecursorDryRunPlan(ps, "B1_M1_TICKVOL_R2_LARGE_ADVERSE", "TickVolumeShock",
                                     "M1 tick volume ratio >= 2.0 and adverse large body", priority, metric);
   if(m5Ratio >= 2.0 && m5LargeAdverse)
      LogHardStopPrecursorDryRunPlan(ps, "B2_M5_TICKVOL_R2_LARGE_ADVERSE", "TickVolumeShock",
                                     "M5 tick volume ratio >= 2.0 and adverse large body", priority, metric);
   if(m1Same >= 5 && pnl5 < 0.0)
      LogHardStopPrecursorDryRunPlan(ps, "C1_M1_ONE_WAY_5_ADVERSE", "OneWayCandle",
                                     "M1 same direction candles >= 5 and pnl deteriorating", priority, metric);
   if(m5Same >= 3 && pnl15 < 0.0)
      LogHardStopPrecursorDryRunPlan(ps, "C2_M5_ONE_WAY_3_ADVERSE", "OneWayCandle",
                                     "M5 same direction candles >= 3 and pnl deteriorating", priority, metric);
   if(minutes >= 30 && minutes <= 60 &&
      postHedgeDiagBestFloatingAfterHedge <= postHedgeDiagFloatingAtHedge &&
      ps.floatingProfit < postHedgeDiagFloatingAtHedge)
      LogHardStopPrecursorDryRunPlan(ps, "E1_HEDGE_30M_NO_IMPROVE_EXPANDING", "DefenseHedgeFailure",
                                     "within 30-60min no improvement and floating loss expanding", priority, metric);
   if(minutes >= 5 && minutes <= 60 &&
      postHedgeDiagBestFloatingAfterHedge < postHedgeDiagFloatingAtHedge + 500.0 &&
      ps.floatingProfit <= postHedgeDiagWorstFloatingAfterHedge + 0.1)
      LogHardStopPrecursorDryRunPlan(ps, "E2_HEDGE_60M_WEAK_BEST_WORST_UPDATE", "DefenseHedgeFailure",
                                     "within 60min best improvement < +500 and worst floating updating", priority, metric);

   if(EnableCorrectedLeadTimeDryRunDiagnostic)
   {
      if(m5Ratio >= 1.2 && m5LargeAdverse)
         LogHardStopPrecursorDryRunPlan(ps, "L1_M5_R12_LARGE_ADVERSE", "CorrectedLeadTime",
                                        "M5 tick volume ratio >= 1.2 and adverse large body", priority, metric);
      if(m5Same >= 2 && m5BodyRatio >= 1.0 && pnl15 < 0.0)
         LogHardStopPrecursorDryRunPlan(ps, "L6_M5_2BAR_CUM_ADVERSE", "CorrectedLeadTime",
                                        "M5 adverse candles >= 2 and body ATR ratio >= 1.0", priority, metric);
      if(m5Ratio >= 2.0 && m5LargeAdverse)
         LogHardStopPrecursorDryRunPlan(ps, "B2_RAW_HIGH_RETURN_ROUTE", "CorrectedLeadTime",
                                        "B2 raw route: M5 ratio >= 2.0 and adverse large body", priority, metric);
      if(m5Ratio >= 2.0 && m5LargeAdverse && ps.floatingProfit < B2G5HteLossBandYen)
         LogHardStopPrecursorDryRunPlan(ps, "B2_G5_BALANCED_SIMPLE_GUARD", "CorrectedLeadTime",
                                        "B2 raw route with HTE loss-band guard", priority,
                                        metric + "|B2G5HteLossBandYen=" + DoubleToString(B2G5HteLossBandYen, 2));
   }
}

void ResetL1State(const PositionState &ps, string reason)
{
   if(l1Active || l1RawTriggered || l1PriorityBlocked || l1PriorityOk || l1ExitExecuted)
   {
      string detail = "BasketId=" + l1BasketId +
                      "|BasketUid=" + CurrentPostHedgeBasketUid(ps) +
                      "|Reason=" + reason +
                      "|EndOpenPositionCount=" + IntegerToString(ps.total) +
                      "|FinalBasketProfit=" + DoubleToString(ps.floatingProfit, 2);
      WriteTradeEventLog("L1_RESET", 0, 0, "", detail, "", 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, ps.floatingProfit);
   }
   l1Active = false;
   l1BasketId = "";
   l1HedgeTime = 0;
   l1TriggerTime = 0;
   l1RawTriggered = false;
   l1PriorityBlocked = false;
   l1PriorityOk = false;
   l1ExitExecuted = false;
}

void StartL1Track(const PositionState &ps, datetime firstHedgeTime)
{
   l1BasketSeq++;
   l1BasketId = "L1" + IntegerToString(l1BasketSeq, 4, '0');
   l1HedgeTime = firstHedgeTime;
   l1TriggerTime = 0;
   l1RawTriggered = false;
   l1PriorityBlocked = false;
   l1PriorityOk = false;
   l1ExitExecuted = false;
   l1Active = true;

   string detail = "BasketId=" + l1BasketId +
                   "|BasketUid=" + CurrentPostHedgeBasketUid(ps) +
                   "|DefenseHedgeTime=" + TimeToString(firstHedgeTime, TIME_DATE | TIME_SECONDS) +
                   "|FloatingPnLYen=" + DoubleToString(ps.floatingProfit, 2);
   WriteTradeEventLog("L1_TRACK", 0, 0, "", detail, "", 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, ps.floatingProfit);
}

string L1EventDetail(const PositionState &ps,
                     double m5Ratio,
                     double m5BodyRatio,
                     double pnl15,
                     bool hardStop,
                     string closePriorityReason,
                     string extra="")
{
   int minutesAfterHedge = 0;
   if(l1HedgeTime > 0)
      minutesAfterHedge = (int)MathFloor((TimeCurrent() - l1HedgeTime) / 60.0);
   bool closePriorityOk = (closePriorityReason == "" || closePriorityReason == "OK");
   double hteDistance = ps.floatingProfit + 1800.0;
   string detail = "BasketId=" + l1BasketId +
                   "|BasketUid=" + CurrentPostHedgeBasketUid(ps) +
                   "|TriggerTime=" + TimeToString(TimeCurrent(), TIME_DATE | TIME_SECONDS) +
                   "|MinutesAfterHedge=" + IntegerToString(minutesAfterHedge) +
                   "|HardStopNow=" + BoolText(hardStop) +
                   "|ClosePriorityOK=" + BoolText(closePriorityOk) +
                   "|ClosePriorityBlocked=" + BoolText(!closePriorityOk) +
                   "|ClosePriorityReason=" + (closePriorityReason == "" ? "OK" : closePriorityReason) +
                   "|MinutesBeforeHardStopNow=-1" +
                   "|MinutesBeforeActualHardStopClose=-1" +
                   "|FloatingPnLYen=" + DoubleToString(ps.floatingProfit, 2) +
                   "|M5TickVolumeRatio=" + DoubleToString(m5Ratio, 3) +
                   "|M5BodyAtrRatio=" + DoubleToString(m5BodyRatio, 3) +
                   "|M5CandleDirection=ADVERSE" +
                   "|AdverseDirection=true" +
                   "|SpreadPrice=" + DoubleToString(SymbolInfoInteger(_Symbol, SYMBOL_SPREAD) * _Point, 3) +
                   "|HteNearState=" + BoolText(ps.floatingProfit >= -1800.0) +
                   "|HteConditionDistance=" + DoubleToString(hteDistance, 2) +
                   "|PnlChange15m=" + DoubleToString(pnl15, 2) +
                   "|CloseProfitYen=" + DoubleToString(ps.floatingProfit, 2);
   if(extra != "")
      detail += "|" + extra;
   return detail;
}

bool IsL1RawTrigger(const PositionState &ps,
                    double &m5Ratio,
                    double &m5BodyRatio,
                    double &pnl15)
{
   m5Ratio = 0.0;
   m5BodyRatio = 0.0;
   pnl15 = 0.0;
   if(!postHedgeDiagActive || CountDefenseHedges() <= 0)
      return false;
   if(PostHedgeDiagDistanceToHardStop(ps) <= 0.0)
      return false;

   long m5Volume = 0;
   double m5Average = 0.0;
   m5Ratio = PostHedgeDryRunTickVolumeRatio(PERIOD_M5, m5Volume, m5Average);
   m5BodyRatio = HardStopPrecursorBodyAtrRatio(PERIOD_M5);
   pnl15 = HardStopPrecursorPnlChangeMinutes(15);
   bool m5LargeAdverse = (pnl15 < 0.0 && m5BodyRatio >= 1.0);
   return (m5Ratio >= L1M5TickVolumeRatioThreshold && m5LargeAdverse);
}

bool CheckL1M5R12LargeAdverseExit(const PositionState &ps,
                                  bool hardStop,
                                  bool recoveryCloseEligible,
                                  bool recoveryLossCutEligible,
                                  bool hteEligibleNow)
{
   if(!UseL1M5R12LargeAdverseExit)
   {
      if(l1Active)
         ResetL1State(ps, "L1Disabled");
      return false;
   }

   if(ps.total <= 0 || CountDefenseHedges() <= 0)
   {
      if(l1Active)
         ResetL1State(ps, "BasketFlatOrNoDefenseHedge");
      return false;
   }

   datetime firstHedgeTime = GetFirstDefenseHedgeTime();
   if(firstHedgeTime <= 0)
      return false;
   if(!l1Active || l1HedgeTime != firstHedgeTime)
      StartL1Track(ps, firstHedgeTime);

   if(l1RawTriggered || l1PriorityBlocked || l1ExitExecuted)
      return false;

   double m5Ratio = 0.0;
   double m5BodyRatio = 0.0;
   double pnl15 = 0.0;
   if(!IsL1RawTrigger(ps, m5Ratio, m5BodyRatio, pnl15))
      return false;

   l1RawTriggered = true;
   l1RawTriggerCount++;
   l1TriggerTime = TimeCurrent();
   bool basketCloseEligibleNow = PostHedgeDiagBasketCloseEligible(ps);
   ClosePriorityState priority = BuildRuntimeClosePriorityState(ps,
                                                                hardStop,
                                                                recoveryCloseEligible,
                                                                recoveryLossCutEligible,
                                                                hteEligibleNow);
   string snapshotId = WritePrioritySnapshot(ps,
                                             l1BasketId,
                                             "RUNTIME_IMPL",
                                             priority,
                                             "L1_M5_R12_LARGE_ADVERSE");

   string common = "|BasketCloseNow=" + BoolText(basketCloseEligibleNow) +
                   "|RecoveryCloseNow=" + BoolText(recoveryCloseEligible) +
                   "|RecoveryLossCutNow=" + BoolText(recoveryLossCutEligible) +
                   "|HteEligibleNow=" + BoolText(hteEligibleNow) +
                   "|PrioritySnapshotId=" + snapshotId +
                   "|CloseIntentState=" + priority.closeIntentState;
   WriteTradeEventLog("L1_RAW_TRIGGER",
                      0,
                      0,
                      "",
                      L1EventDetail(ps, m5Ratio, m5BodyRatio, pnl15, hardStop,
                                    priority.closePriorityReason,
                                    "L1RawTriggered=true" + common),
                      "",
                      0.0,
                      0.0,
                      0.0,
                      0.0,
                      0.0,
                      0.0,
                      ps.floatingProfit);

   if(priority.closePriorityBlocked)
   {
      l1PriorityBlocked = true;
      l1PriorityBlockCount++;
      WriteTradeEventLog("L1_PRIORITY_BLOCK",
                         0,
                         0,
                         "",
                         L1EventDetail(ps, m5Ratio, m5BodyRatio, pnl15, hardStop,
                                       priority.closePriorityReason,
                                       "L1Blocked=true" + common),
                         "",
                         0.0,
                         0.0,
                         0.0,
                         0.0,
                         0.0,
                         0.0,
                         ps.floatingProfit);
      return false;
   }

   l1PriorityOk = true;
   l1PriorityOkCount++;
   WriteTradeEventLog("L1_PRIORITY_OK",
                      0,
                      0,
                      "",
                      L1EventDetail(ps, m5Ratio, m5BodyRatio, pnl15, hardStop, "OK",
                                    "L1PriorityOk=true" + common),
                      "",
                      0.0,
                      0.0,
                      0.0,
                      0.0,
                      0.0,
                      0.0,
                      ps.floatingProfit);

   string closeReason = "L1_M5_R12_LARGE_ADVERSE_EXIT";
   WriteTradeEventLog("L1_EXIT_INTENT",
                      0,
                      0,
                      "",
                      L1EventDetail(ps, m5Ratio, m5BodyRatio, pnl15, hardStop, "OK",
                                    "CloseReason=" + closeReason +
                                    "|L1ExitDryRunOnly=" + BoolText(L1ExitDryRunOnly) + common),
                      "CLOSE",
                      0.0,
                      0.0,
                      0.0,
                      0.0,
                      0.0,
                      0.0,
                      ps.floatingProfit);

   if(L1ExitDryRunOnly)
      return false;

   bool closed = CloseAllEaPositions(closeReason);
   PositionState afterClose;
   GetPositionState(afterClose);
   if(closed && afterClose.total <= 0)
   {
      l1ExitExecuted = true;
      l1ExitCount++;
      l1ExitProfitTotal += ps.floatingProfit;
      WriteTradeEventLog("L1_EXIT_DONE",
                         0,
                         trade.ResultRetcode(),
                         trade.ResultRetcodeDescription(),
                         L1EventDetail(ps, m5Ratio, m5BodyRatio, pnl15, hardStop, "OK",
                                       "CloseReason=" + closeReason +
                                       "|EndOpenPositionCount=0|EndOpenBasketCount=0"),
                         "CLOSE",
                         0.0,
                         0.0,
                         0.0,
                         0.0,
                         0.0,
                         ps.floatingProfit,
                         ps.floatingProfit);
      ResetL1State(afterClose, "L1_EXIT_DONE");
      return true;
   }

   l1ExitFailedCount++;
   uint retcode = trade.ResultRetcode();
   WriteTradeEventLog("L1_EXIT_FAILED",
                      0,
                      retcode,
                      trade.ResultRetcodeDescription(),
                      L1EventDetail(afterClose, m5Ratio, m5BodyRatio, pnl15, hardStop, "OK",
                                    "CloseReason=" + closeReason +
                                    "|WasMarketClosed10018=" + BoolText(IsMarketClosedRetcode(retcode)) +
                                    "|EndOpenPositionCount=" + IntegerToString(afterClose.total) +
                                    "|EndOpenBasketCount=" + (afterClose.total > 0 ? "1" : "0")),
                      "CLOSE",
                      0.0,
                      0.0,
                      0.0,
                      0.0,
                      0.0,
                      0.0,
                      afterClose.floatingProfit);
   return closed;
}

void ResetS2PreHardStopState(const PositionState &ps, string reason)
{
   if(s2PreHsActive || s2PreHsStageCheckLogged || s2PreHsConditionTrueLogged ||
      s2PreHsGuardBlockLogged || s2PreHsExitIntentLogged || s2PreHsExitExecuted)
   {
      string detail = "BasketId=" + s2PreHsBasketId +
                      "|BasketUid=" + CurrentPostHedgeBasketUid(ps) +
                      "|Reason=" + reason +
                      "|EndOpenPositionCount=" + IntegerToString(ps.total) +
                      "|FinalBasketProfit=" + DoubleToString(ps.floatingProfit, 2);
      WriteTradeEventLog("S2_PRE_HS_RESET", 0, 0, "", detail, "", 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, ps.floatingProfit);
   }
   s2PreHsActive = false;
   s2PreHsBasketId = "";
   s2PreHsHedgeTime = 0;
   s2PreHsTriggerTime = 0;
   s2PreHsStageCheckLogged = false;
   s2PreHsConditionTrueLogged = false;
   s2PreHsGuardBlockLogged = false;
   s2PreHsExitIntentLogged = false;
   s2PreHsExitExecuted = false;
}

void StartS2PreHardStopTrack(const PositionState &ps, datetime firstHedgeTime)
{
   s2PreHsBasketSeq++;
   s2PreHsBasketId = "S2PHS" + IntegerToString(s2PreHsBasketSeq, 4, '0');
   s2PreHsHedgeTime = firstHedgeTime;
   s2PreHsTriggerTime = 0;
   s2PreHsStageCheckLogged = false;
   s2PreHsConditionTrueLogged = false;
   s2PreHsGuardBlockLogged = false;
   s2PreHsExitIntentLogged = false;
   s2PreHsExitExecuted = false;
   s2PreHsActive = true;

   string detail = "BasketId=" + s2PreHsBasketId +
                   "|BasketUid=" + CurrentPostHedgeBasketUid(ps) +
                   "|OldBasketId=" + postHedgeDiagBasketId +
                   "|DefenseHedgeTime=" + TimeToString(firstHedgeTime, TIME_DATE | TIME_SECONDS) +
                   "|FloatingPnLYen=" + DoubleToString(ps.floatingProfit, 2) +
                   "|EvalStageName=BEFORE_HARDSTOP_EVALUATION";
   WriteTradeEventLog("S2_PRE_HS_TRACK", 0, 0, "", detail, "", 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, ps.floatingProfit);
}

void RefreshTradeEventContextForS2(const PositionState &ps, double marginLevel, string newsState)
{
   MqlTick tick;
   if(SymbolInfoTick(_Symbol, tick))
      tradeEventTick = tick;
   tradeEventPosition = ps;
   tradeEventMarginLevel = marginLevel;
   tradeEventDailyPL = CalculateTodayRealizedPL();
   tradeEventConsecutiveLosses = CalculateConsecutiveLosses();
   tradeEventNewsState = newsState;
   tradeEventContextReady = true;
}

string S2PreHardStopEventDetail(const PositionState &ps,
                                const ClosePriorityState &priority,
                                string snapshotId,
                                string extra="")
{
   int minutesAfterHedge = 0;
   if(s2PreHsHedgeTime > 0)
      minutesAfterHedge = (int)MathFloor((TimeCurrent() - s2PreHsHedgeTime) / 60.0);

   MqlTick tick;
   datetime tickTime = runtimeEvalTickTime > 0 ? runtimeEvalTickTime : TimeCurrent();
   double spread = 0.0;
   if(SymbolInfoTick(_Symbol, tick))
   {
      tickTime = (datetime)tick.time;
      spread = tick.ask - tick.bid;
   }
   datetime barTime = iTime(_Symbol, PERIOD_M5, 0);
   if(barTime <= 0)
      barTime = TimeCurrent();

   double hteDistance = ps.floatingProfit - S2HteLossBandYen;
   bool hteNearState = (ps.floatingProfit >= S2HteLossBandYen);
   bool recentWorstUpdate = (ps.floatingProfit <= postHedgeDiagWorstFloatingAfterHedge + 0.1);
   double improvementFromHedgeBest = postHedgeDiagBestFloatingAfterHedge - postHedgeDiagFloatingAtHedge;
   double pnl15 = HardStopPrecursorPnlChangeMinutes(15);
   double pnl30 = HardStopPrecursorPnlChangeMinutes(30);
   double pnl60 = HardStopPrecursorPnlChangeMinutes(60);

   string detail = "BasketId=" + s2PreHsBasketId +
                   "|BasketUid=" + CurrentPostHedgeBasketUid(ps) +
                   "|OldBasketId=" + postHedgeDiagBasketId +
                   "|PrioritySnapshotId=" + snapshotId +
                   "|EvalStageName=BEFORE_HARDSTOP_EVALUATION" +
                   "|EvalStageIndex=3" +
                   "|TickSequenceId=" + IntegerToString(runtimeEvalTickSequenceId) +
                   "|ServerTime=" + TimeToString(TimeCurrent(), TIME_DATE | TIME_SECONDS) +
                   "|JstTime=" + TimeToString(TimeGMT() + 9 * 3600, TIME_DATE | TIME_SECONDS) +
                   "|BarTime=" + TimeToString(barTime, TIME_DATE | TIME_SECONDS) +
                   "|TickTime=" + TimeToString(tickTime, TIME_DATE | TIME_SECONDS) +
                   "|MinutesAfterHedge=" + IntegerToString(minutesAfterHedge) +
                   "|HardStopNow=" + BoolText(priority.hardStopNow) +
                   "|ClosePriorityOK=" + BoolText(priority.closePriorityOk) +
                   "|ClosePriorityBlocked=" + BoolText(priority.closePriorityBlocked) +
                   "|ClosePriorityReason=" + priority.closePriorityReason +
                   "|CloseIntentState=" + priority.closeIntentState +
                   "|ActiveCloseReason=" + priority.activeCloseReason +
                   "|PositionCount=" + IntegerToString(ps.total) +
                   "|HedgeState=" + (CountDefenseHedges() > 0 ? "HEDGED" : "NO_HEDGE") +
                   "|FloatingPnLYen=" + DoubleToString(ps.floatingProfit, 2) +
                   "|BestFloatingPnLYen=" + DoubleToString(postHedgeDiagBestFloatingAfterHedge, 2) +
                   "|WorstFloatingPnLYen=" + DoubleToString(postHedgeDiagWorstFloatingAfterHedge, 2) +
                   "|S2HteLossBandYen=" + DoubleToString(S2HteLossBandYen, 2) +
                   "|HteNearState=" + BoolText(hteNearState) +
                   "|HteConditionDistance=" + DoubleToString(hteDistance, 2) +
                   "|RecentWorstUpdate=" + BoolText(recentWorstUpdate) +
                   "|ImprovementFromHedgeBestYen=" + DoubleToString(improvementFromHedgeBest, 2) +
                   "|S2MinWeakImproveYen=" + DoubleToString(S2MinWeakImproveYen, 2) +
                   "|PnlChange15m=" + DoubleToString(pnl15, 2) +
                   "|PnlChange30m=" + DoubleToString(pnl30, 2) +
                   "|PnlChange60m=" + DoubleToString(pnl60, 2) +
                   "|SpreadPrice=" + DoubleToString(spread, 3) +
                   "|MarketClosedState=" + CurrentMarketClosedState() +
                   "|CloseProfitYen=" + DoubleToString(ps.floatingProfit, 2);
   if(extra != "")
      detail += "|" + extra;
   return detail;
}

bool CheckPreHardStopS2StrictGuardExit(const PositionState &ps,
                                       bool hardStop,
                                       double marginLevel,
                                       string newsState,
                                       string &action,
                                       string &noEntryReason)
{
   if(!UsePreHardStopS2StrictGuardExit)
   {
      if(s2PreHsActive)
         ResetS2PreHardStopState(ps, "S2Disabled");
      return false;
   }

   RefreshTradeEventContextForS2(ps, marginLevel, newsState);

   if(ps.total <= 0 || CountDefenseHedges() <= 0)
   {
      if(s2PreHsActive)
         ResetS2PreHardStopState(ps, "BasketFlatOrNoDefenseHedge");
      return false;
   }

   datetime firstHedgeTime = GetFirstDefenseHedgeTime();
   if(firstHedgeTime <= 0 || !postHedgeDiagActive)
      return false;
   if(!s2PreHsActive || s2PreHsHedgeTime != firstHedgeTime)
      StartS2PreHardStopTrack(ps, firstHedgeTime);

   if(s2PreHsExitExecuted || s2PreHsExitIntentLogged)
      return false;

   bool recoveryCloseEligible = PostHedgeDiagRecoveryCloseEligible(ps);
   bool recoveryLossCutEligible = PostHedgeDiagRecoveryLossCutEligible(ps);
   bool hteEligibleNow = PostHedgeDiagTimeExitEligible(ps);
   ClosePriorityState priority = BuildRuntimeClosePriorityState(ps,
                                                                hardStop,
                                                                recoveryCloseEligible,
                                                                recoveryLossCutEligible,
                                                                hteEligibleNow);
   string snapshotId = WritePrioritySnapshot(ps,
                                             s2PreHsBasketId,
                                             "RUNTIME_IMPL",
                                             priority,
                                             "S2_PRE_HARDSTOP_STRICT_GUARD");

   MqlTick tick;
   double spread = 0.0;
   if(SymbolInfoTick(_Symbol, tick))
      spread = tick.ask - tick.bid;
   bool outsideHteLossBand = (ps.floatingProfit < S2HteLossBandYen);
   bool weakImprovement = (postHedgeDiagBestFloatingAfterHedge < postHedgeDiagFloatingAtHedge + S2MinWeakImproveYen);
   bool recentWorstUpdate = (ps.floatingProfit <= postHedgeDiagWorstFloatingAfterHedge + 0.1);
   bool spreadOk = (MaxSpreadPrice <= 0.0 || spread <= MaxSpreadPrice);
   bool noActiveCloseIntent = (priority.closeIntentState == "NONE");
   bool marketClosed = IsMarketClosedRetryActive();
   bool baseStageCheck = outsideHteLossBand && ps.total > 0 && CountDefenseHedges() > 0;
   string common = "|RecoveryCloseNow=" + BoolText(recoveryCloseEligible) +
                   "|RecoveryLossCutNow=" + BoolText(recoveryLossCutEligible) +
                   "|HteEligibleNow=" + BoolText(hteEligibleNow) +
                   "|OutsideHteLossBand=" + BoolText(outsideHteLossBand) +
                   "|WeakImprovement=" + BoolText(weakImprovement) +
                   "|RecentWorstUpdate=" + BoolText(recentWorstUpdate) +
                   "|SpreadOk=" + BoolText(spreadOk) +
                   "|NoActiveCloseIntent=" + BoolText(noActiveCloseIntent);

   if(baseStageCheck && !s2PreHsStageCheckLogged)
   {
      s2PreHsStageCheckLogged = true;
      s2PreHsStageCheckCount++;
      WriteTradeEventLog("S2_PRE_HS_STAGE_CHECK",
                         0,
                         0,
                         "",
                         S2PreHardStopEventDetail(ps, priority, snapshotId, "StageCheck=true" + common),
                         "",
                         0.0,
                         0.0,
                         0.0,
                         0.0,
                         0.0,
                         0.0,
                         ps.floatingProfit);
   }

   string guardReason = "";
   if(hardStop)
      guardReason = "HARDSTOP_NOW_TRUE";
   else if(priority.closePriorityBlocked)
      guardReason = priority.closePriorityReason;
   else if(marketClosed)
      guardReason = "MARKET_CLOSED_RETRY";
   else if(!outsideHteLossBand)
      guardReason = "HTE_LOSS_BAND";
   else if(!weakImprovement)
      guardReason = "IMPROVED_MORE_THAN_S2_LIMIT";
   else if(S2RequireRecentWorstUpdate && !recentWorstUpdate)
      guardReason = "RECENT_WORST_NOT_UPDATED";
   else if(!spreadOk)
      guardReason = "SPREAD_NOT_OK";
   else if(!noActiveCloseIntent)
      guardReason = "ACTIVE_CLOSE_INTENT";

   if(guardReason != "")
   {
      if(guardReason == "HARDSTOP_NOW_TRUE")
         s2PreHsHardStopNowTrueBlockCount++;
      if(baseStageCheck && !s2PreHsGuardBlockLogged)
      {
         s2PreHsGuardBlockLogged = true;
         s2PreHsGuardBlockCount++;
         WriteTradeEventLog("S2_PRE_HS_GUARD_BLOCK",
                            0,
                            0,
                            "",
                            S2PreHardStopEventDetail(ps,
                                                     priority,
                                                     snapshotId,
                                                     "GuardReason=" + guardReason +
                                                     "|S2Blocked=true" + common),
                            "",
                            0.0,
                            0.0,
                            0.0,
                            0.0,
                            0.0,
                            0.0,
                            ps.floatingProfit);
      }
      return false;
   }

   if(!s2PreHsConditionTrueLogged)
   {
      s2PreHsConditionTrueLogged = true;
      s2PreHsConditionTrueCount++;
      s2PreHsTriggerTime = TimeCurrent();
      WriteTradeEventLog("S2_PRE_HS_CONDITION_TRUE",
                         0,
                         0,
                         "",
                         S2PreHardStopEventDetail(ps, priority, snapshotId, "S2ConditionTrue=true" + common),
                         "",
                         0.0,
                         0.0,
                         0.0,
                         0.0,
                         0.0,
                         0.0,
                         ps.floatingProfit);
   }

   if(hardStop)
   {
      s2PreHsHardStopSafetyViolationCount++;
      WriteTradeEventLog("S2_PRE_HS_EXIT_FAILED",
                         0,
                         0,
                         "HardStopNow true safety violation",
                         S2PreHardStopEventDetail(ps,
                                                  priority,
                                                  snapshotId,
                                                  "CloseFailedReason=HARDSTOP_NOW_TRUE_SAFETY_BLOCK" + common),
                         "CLOSE",
                         0.0,
                         0.0,
                         0.0,
                         0.0,
                         0.0,
                         0.0,
                         ps.floatingProfit);
      return false;
   }

   string closeReason = "S2_PRE_HARDSTOP_STRICT_GUARD_EXIT";
   s2PreHsExitIntentLogged = true;
   s2PreHsExitIntentCount++;
   WriteTradeEventLog("S2_PRE_HS_EXIT_INTENT",
                      0,
                      0,
                      "",
                      S2PreHardStopEventDetail(ps,
                                               priority,
                                               snapshotId,
                                               "CloseReason=" + closeReason +
                                               "|S2ExitDryRunOnly=" + BoolText(S2ExitDryRunOnly) +
                                               "|ActualCloseProfitYen=" + DoubleToString(ps.floatingProfit, 2) +
                                               "|CloseRetcode=0|CloseComment=INTENT" +
                                               "|PositionsClosedCount=0|CloseFailedReason=" + common),
                      "CLOSE",
                      0.0,
                      0.0,
                      0.0,
                      0.0,
                      0.0,
                      0.0,
                      ps.floatingProfit);

   if(S2ExitDryRunOnly)
      return false;

   int preClosePositions = ps.total;
   bool closed = CloseAllEaPositions(closeReason);
   PositionState afterClose;
   GetPositionState(afterClose);
   int positionsClosed = preClosePositions - afterClose.total;
   if(positionsClosed < 0)
      positionsClosed = 0;

   if(closed && afterClose.total <= 0)
   {
      s2PreHsExitExecuted = true;
      s2PreHsExitDoneCount++;
      s2PreHsExitProfitTotal += ps.floatingProfit;
      WriteTradeEventLog("S2_PRE_HS_EXIT_DONE",
                         0,
                         trade.ResultRetcode(),
                         trade.ResultRetcodeDescription(),
                         S2PreHardStopEventDetail(ps,
                                                  priority,
                                                  snapshotId,
                                                  "CloseReason=" + closeReason +
                                                  "|ActualCloseProfitYen=" + DoubleToString(ps.floatingProfit, 2) +
                                                  "|CloseRetcode=" + IntegerToString((int)trade.ResultRetcode()) +
                                                  "|CloseComment=" + trade.ResultRetcodeDescription() +
                                                  "|PositionsClosedCount=" + IntegerToString(positionsClosed) +
                                                  "|CloseFailedReason=" +
                                                  "|EndOpenPositionCount=0|EndOpenBasketCount=0"),
                         "CLOSE",
                         0.0,
                         0.0,
                         0.0,
                         0.0,
                         0.0,
                         ps.floatingProfit,
                         ps.floatingProfit);
      action = "S2 pre-hardstop strict guard exit";
      noEntryReason = "S2 pre-hardstop strict guard exit";
      ResetS2PreHardStopState(afterClose, "S2_EXIT_DONE");
      return true;
   }

   s2PreHsExitFailedCount++;
   uint retcode = trade.ResultRetcode();
   WriteTradeEventLog("S2_PRE_HS_EXIT_FAILED",
                      0,
                      retcode,
                      trade.ResultRetcodeDescription(),
                      S2PreHardStopEventDetail(afterClose,
                                               priority,
                                               snapshotId,
                                               "CloseReason=" + closeReason +
                                               "|ActualCloseProfitYen=" + DoubleToString(ps.floatingProfit, 2) +
                                               "|WasMarketClosed10018=" + BoolText(IsMarketClosedRetcode(retcode)) +
                                               "|CloseRetcode=" + IntegerToString((int)retcode) +
                                               "|CloseComment=" + trade.ResultRetcodeDescription() +
                                               "|PositionsClosedCount=" + IntegerToString(positionsClosed) +
                                               "|CloseFailedReason=" + trade.ResultRetcodeDescription() +
                                               "|EndOpenPositionCount=" + IntegerToString(afterClose.total) +
                                               "|EndOpenBasketCount=" + IntegerToString(afterClose.total > 0 ? 1 : 0)),
                      "CLOSE",
                      0.0,
                      0.0,
                      0.0,
                      0.0,
                      0.0,
                      ps.floatingProfit,
                      afterClose.floatingProfit);
   return false;
}

void ResetB2G5State(const PositionState &ps, string reason)
{
   if(b2G5Active || b2G5RawTriggered || b2G5GuardBlocked || b2G5ExitExecuted)
   {
      string detail = "BasketId=" + b2G5BasketId +
                      "|BasketUid=" + CurrentPostHedgeBasketUid(ps) +
                      "|Reason=" + reason +
                      "|EndOpenPositionCount=" + IntegerToString(ps.total) +
                      "|FinalBasketProfit=" + DoubleToString(ps.floatingProfit, 2);
      WriteTradeEventLog("B2_G5_RESET", 0, 0, "", detail, "", 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, ps.floatingProfit);
   }
   b2G5Active = false;
   b2G5BasketId = "";
   b2G5HedgeTime = 0;
   b2G5TriggerTime = 0;
   b2G5RawTriggered = false;
   b2G5GuardBlocked = false;
   b2G5ExitExecuted = false;
}

void StartB2G5Track(const PositionState &ps, datetime firstHedgeTime)
{
   b2G5BasketSeq++;
   b2G5BasketId = "B2G5" + IntegerToString(b2G5BasketSeq, 4, '0');
   b2G5HedgeTime = firstHedgeTime;
   b2G5TriggerTime = 0;
   b2G5RawTriggered = false;
   b2G5GuardBlocked = false;
   b2G5ExitExecuted = false;
   b2G5Active = true;

   string detail = "BasketId=" + b2G5BasketId +
                   "|BasketUid=" + CurrentPostHedgeBasketUid(ps) +
                   "|DefenseHedgeTime=" + TimeToString(firstHedgeTime, TIME_DATE | TIME_SECONDS) +
                   "|FloatingPnLYen=" + DoubleToString(ps.floatingProfit, 2);
   WriteTradeEventLog("B2_G5_TRACK", 0, 0, "", detail, "", 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, ps.floatingProfit);
}

string B2G5EventDetail(const PositionState &ps,
                       double m5Ratio,
                       double m5BodyRatio,
                       string extra="")
{
   int minutesAfterHedge = 0;
   if(b2G5HedgeTime > 0)
      minutesAfterHedge = (int)MathFloor((TimeCurrent() - b2G5HedgeTime) / 60.0);
   MqlTick tick;
   datetime tickTime = TimeCurrent();
   double spread = 0.0;
   if(SymbolInfoTick(_Symbol, tick))
   {
      tickTime = (datetime)tick.time;
      spread = tick.ask - tick.bid;
   }
   datetime barTime = iTime(_Symbol, PERIOD_M5, 0);
   if(barTime <= 0)
      barTime = TimeCurrent();
   double hteDistance = ps.floatingProfit - B2G5HteLossBandYen;
   string detail = "BasketId=" + b2G5BasketId +
                   "|BasketUid=" + CurrentPostHedgeBasketUid(ps) +
                   "|TriggerTime=" + TimeToString(TimeCurrent(), TIME_DATE | TIME_SECONDS) +
                   "|ServerTime=" + TimeToString(TimeCurrent(), TIME_DATE | TIME_SECONDS) +
                   "|JstTime=" + TimeToString(TimeGMT() + 9 * 3600, TIME_DATE | TIME_SECONDS) +
                   "|BarTime=" + TimeToString(barTime, TIME_DATE | TIME_SECONDS) +
                   "|TickTime=" + TimeToString(tickTime, TIME_DATE | TIME_SECONDS) +
                   "|MinutesAfterHedge=" + IntegerToString(minutesAfterHedge) +
                   "|FloatingPnLYen=" + DoubleToString(ps.floatingProfit, 2) +
                   "|B2G5HteLossBandYen=" + DoubleToString(B2G5HteLossBandYen, 2) +
                   "|HteNearState=" + BoolText(ps.floatingProfit >= B2G5HteLossBandYen) +
                   "|HteConditionDistance=" + DoubleToString(hteDistance, 2) +
                   "|M5TickVolumeRatio=" + DoubleToString(m5Ratio, 3) +
                   "|M5BodyAtrRatio=" + DoubleToString(m5BodyRatio, 3) +
                   "|M5CandleDirection=ADVERSE" +
                   "|AdverseDirection=true" +
                   "|SpreadPrice=" + DoubleToString(spread, 3) +
                   "|CloseProfitYen=" + DoubleToString(ps.floatingProfit, 2);
   if(extra != "")
      detail += "|" + extra;
   return detail;
}

bool IsB2G5RawTrigger(const PositionState &ps,
                      double &m5Ratio,
                      double &m5BodyRatio,
                      double &pnl15)
{
   m5Ratio = 0.0;
   m5BodyRatio = 0.0;
   pnl15 = 0.0;
   if(!postHedgeDiagActive || CountDefenseHedges() <= 0)
      return false;
   if(PostHedgeDiagDistanceToHardStop(ps) <= 0.0)
      return false;

   long m5Volume = 0;
   double m5Average = 0.0;
   m5Ratio = PostHedgeDryRunTickVolumeRatio(PERIOD_M5, m5Volume, m5Average);
   m5BodyRatio = HardStopPrecursorBodyAtrRatio(PERIOD_M5);
   pnl15 = HardStopPrecursorPnlChangeMinutes(15);
   bool m5LargeAdverse = (pnl15 < 0.0 && m5BodyRatio >= 1.0);
   return (m5Ratio >= 2.0 && m5LargeAdverse);
}

bool CheckB2G5BalancedSimpleGuardExit(const PositionState &ps,
                                      bool hardStop,
                                      bool recoveryCloseEligible,
                                      bool recoveryLossCutEligible,
                                      bool hteEligibleNow)
{
   if(!UseB2M5TickVolLargeAdverseExit)
   {
      if(b2G5Active)
         ResetB2G5State(ps, "B2Disabled");
      return false;
   }

   if(ps.total <= 0 || CountDefenseHedges() <= 0)
   {
      if(b2G5Active)
         ResetB2G5State(ps, "BasketFlatOrNoDefenseHedge");
      return false;
   }

   datetime firstHedgeTime = GetFirstDefenseHedgeTime();
   if(firstHedgeTime <= 0)
      return false;
   if(!b2G5Active || b2G5HedgeTime != firstHedgeTime)
      StartB2G5Track(ps, firstHedgeTime);

   if(b2G5RawTriggered || b2G5GuardBlocked || b2G5ExitExecuted)
      return false;

   double m5Ratio = 0.0;
   double m5BodyRatio = 0.0;
   double pnl15 = 0.0;
   if(!IsB2G5RawTrigger(ps, m5Ratio, m5BodyRatio, pnl15))
      return false;

   b2G5RawTriggered = true;
   b2G5RawTriggerCount++;
   b2G5TriggerTime = TimeCurrent();
   bool basketCloseEligibleNow = PostHedgeDiagBasketCloseEligible(ps);
   ClosePriorityState priority = BuildRuntimeClosePriorityState(ps,
                                                                hardStop,
                                                                recoveryCloseEligible,
                                                                recoveryLossCutEligible,
                                                                hteEligibleNow);
   string snapshotId = WritePrioritySnapshot(ps,
                                             b2G5BasketId,
                                             "RUNTIME_IMPL",
                                             priority,
                                             "B2_G5_BALANCED_SIMPLE_GUARD");
   string common = "|PnlChange15m=" + DoubleToString(pnl15, 2) +
                   "|HardStopNow=" + BoolText(hardStop) +
                   "|ClosePriorityOK=" + BoolText(priority.closePriorityOk) +
                   "|ClosePriorityBlocked=" + BoolText(priority.closePriorityBlocked) +
                   "|ClosePriorityReason=" + priority.closePriorityReason +
                   "|BasketCloseNow=" + BoolText(basketCloseEligibleNow) +
                   "|RecoveryCloseNow=" + BoolText(recoveryCloseEligible) +
                   "|RecoveryLossCutNow=" + BoolText(recoveryLossCutEligible) +
                   "|HteEligibleNow=" + BoolText(hteEligibleNow) +
                   "|PrioritySnapshotId=" + snapshotId +
                   "|CloseIntentState=" + priority.closeIntentState;
   WriteTradeEventLog("B2_G5_RAW_TRIGGER",
                      0,
                      0,
                      "",
                      B2G5EventDetail(ps, m5Ratio, m5BodyRatio, "B2RawTriggered=true" + common),
                      "",
                      0.0,
                      0.0,
                      0.0,
                      0.0,
                      0.0,
                      0.0,
                      ps.floatingProfit);

   if(priority.closePriorityBlocked)
   {
      b2G5GuardBlocked = true;
      WriteTradeEventLog("B2_G5_PRIORITY_BLOCK",
                         0,
                         0,
                         "",
                         B2G5EventDetail(ps, m5Ratio, m5BodyRatio,
                                         "BlockReason=" + priority.closePriorityReason +
                                         "|B2Blocked=true" + common),
                         "",
                         0.0,
                         0.0,
                         0.0,
                         0.0,
                         0.0,
                         0.0,
                         ps.floatingProfit);
      return false;
   }

   WriteTradeEventLog("B2_G5_PRIORITY_OK",
                      0,
                      0,
                      "",
                      B2G5EventDetail(ps, m5Ratio, m5BodyRatio,
                                      "B2PriorityOK=true" + common),
                      "",
                      0.0,
                      0.0,
                      0.0,
                      0.0,
                      0.0,
                      0.0,
                      ps.floatingProfit);

   if(UseB2G5HteLossBandGuard && ps.floatingProfit >= B2G5HteLossBandYen)
   {
      b2G5GuardBlocked = true;
      b2G5GuardBlockCount++;
      WriteTradeEventLog("B2_G5_GUARD_BLOCK",
                         0,
                         0,
                         "",
                         B2G5EventDetail(ps, m5Ratio, m5BodyRatio,
                                         "GuardReason=HTE_LOSS_BAND_GUARD" +
                                         "|B2Blocked=true" + common),
                         "",
                         0.0,
                         0.0,
                         0.0,
                         0.0,
                         0.0,
                         0.0,
                         ps.floatingProfit);
      return false;
   }

   string closeReason = "B2_G5_BALANCED_SIMPLE_GUARD_EXIT";
   WriteTradeEventLog("B2_G5_EXIT_INTENT",
                      0,
                      0,
                      "",
                      B2G5EventDetail(ps, m5Ratio, m5BodyRatio,
                                      "CloseReason=" + closeReason +
                                      "|B2ExitDryRunOnly=" + BoolText(B2ExitDryRunOnly) + common),
                      "CLOSE",
                      0.0,
                      0.0,
                      0.0,
                      0.0,
                      0.0,
                      0.0,
                      ps.floatingProfit);

   if(B2ExitDryRunOnly)
      return false;

   bool closed = CloseAllEaPositions(closeReason);
   PositionState afterClose;
   GetPositionState(afterClose);
   if(closed && afterClose.total <= 0)
   {
      b2G5ExitExecuted = true;
      b2G5ExitCount++;
      b2G5ExitProfitTotal += ps.floatingProfit;
      WriteTradeEventLog("B2_G5_EXIT_DONE",
                         0,
                         trade.ResultRetcode(),
                         trade.ResultRetcodeDescription(),
                         B2G5EventDetail(ps, m5Ratio, m5BodyRatio,
                                         "CloseReason=" + closeReason +
                                         "|EndOpenPositionCount=0|EndOpenBasketCount=0"),
                         "CLOSE",
                         0.0,
                         0.0,
                         0.0,
                         0.0,
                         0.0,
                         ps.floatingProfit,
                         ps.floatingProfit);
      ResetB2G5State(afterClose, "B2_G5_EXIT_DONE");
      return true;
   }

   b2G5ExitFailedCount++;
   uint retcode = trade.ResultRetcode();
   WriteTradeEventLog("B2_G5_EXIT_FAILED",
                      0,
                      retcode,
                      trade.ResultRetcodeDescription(),
                      B2G5EventDetail(afterClose, m5Ratio, m5BodyRatio,
                                      "CloseReason=" + closeReason +
                                      "|WasMarketClosed10018=" + BoolText(IsMarketClosedRetcode(retcode)) +
                                      "|EndOpenPositionCount=" + IntegerToString(afterClose.total) +
                                      "|EndOpenBasketCount=" + (afterClose.total > 0 ? "1" : "0")),
                      "CLOSE",
                      0.0,
                      0.0,
                      0.0,
                      0.0,
                      0.0,
                      0.0,
                      afterClose.floatingProfit);
   return closed;
}

void ResetCW8State(const PositionState &ps, string reason)
{
   if(cw8Active || cw8RawTriggered || cw8PriorityBlocked || cw8PriorityOk ||
      cw8HteGuardBlocked || cw8ExitIntentLogged || cw8ExitExecuted)
   {
      string detail = "BasketId=" + cw8BasketId +
                      "|BasketUid=" + CurrentPostHedgeBasketUid(ps) +
                      "|Reason=" + reason +
                      "|EndOpenPositionCount=" + IntegerToString(ps.total) +
                      "|FinalBasketProfit=" + DoubleToString(ps.floatingProfit, 2);
      WriteTradeEventLog("CW8_RESET", 0, 0, "", detail, "", 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, ps.floatingProfit);
   }
   cw8Active = false;
   cw8BasketId = "";
   cw8HedgeTime = 0;
   cw8TriggerTime = 0;
   cw8RawTriggered = false;
   cw8PriorityBlocked = false;
   cw8PriorityOk = false;
   cw8HteGuardBlocked = false;
   cw8ExitIntentLogged = false;
   cw8ExitExecuted = false;
}

void StartCW8Track(const PositionState &ps, datetime firstHedgeTime)
{
   cw8BasketSeq++;
   cw8BasketId = "CW8" + IntegerToString(cw8BasketSeq, 4, '0');
   cw8HedgeTime = firstHedgeTime;
   cw8TriggerTime = 0;
   cw8RawTriggered = false;
   cw8PriorityBlocked = false;
   cw8PriorityOk = false;
   cw8HteGuardBlocked = false;
   cw8ExitIntentLogged = false;
   cw8ExitExecuted = false;
   cw8Active = true;

   string detail = "BasketId=" + cw8BasketId +
                   "|BasketUid=" + CurrentPostHedgeBasketUid(ps) +
                   "|DefenseHedgeTime=" + TimeToString(firstHedgeTime, TIME_DATE | TIME_SECONDS) +
                   "|FloatingPnLYen=" + DoubleToString(ps.floatingProfit, 2);
   WriteTradeEventLog("CW8_TRACK", 0, 0, "", detail, "", 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, ps.floatingProfit);
}

string CW8EventDetail(const PositionState &ps,
                      const ClosePriorityState &priority,
                      string extra="")
{
   int minutesAfterHedge = 0;
   if(cw8HedgeTime > 0)
      minutesAfterHedge = (int)MathFloor((TimeCurrent() - cw8HedgeTime) / 60.0);
   MqlTick tick;
   datetime tickTime = TimeCurrent();
   double spread = 0.0;
   if(SymbolInfoTick(_Symbol, tick))
   {
      tickTime = (datetime)tick.time;
      spread = tick.ask - tick.bid;
   }
   datetime barTime = iTime(_Symbol, PERIOD_M5, 0);
   if(barTime <= 0)
      barTime = TimeCurrent();
   double hteDistance = ps.floatingProfit - CW8HteLossBandYen;
   string detail = "BasketId=" + cw8BasketId +
                   "|BasketUid=" + CurrentPostHedgeBasketUid(ps) +
                   "|TriggerTime=" + TimeToString(TimeCurrent(), TIME_DATE | TIME_SECONDS) +
                   "|ServerTime=" + TimeToString(TimeCurrent(), TIME_DATE | TIME_SECONDS) +
                   "|JstTime=" + TimeToString(TimeGMT() + 9 * 3600, TIME_DATE | TIME_SECONDS) +
                   "|BarTime=" + TimeToString(barTime, TIME_DATE | TIME_SECONDS) +
                   "|TickTime=" + TimeToString(tickTime, TIME_DATE | TIME_SECONDS) +
                   "|MinutesAfterHedge=" + IntegerToString(minutesAfterHedge) +
                   "|HardStopNow=" + BoolText(priority.hardStopNow) +
                   "|ClosePriorityOK=" + BoolText(priority.closePriorityOk) +
                   "|ClosePriorityBlocked=" + BoolText(priority.closePriorityBlocked) +
                   "|ClosePriorityReason=" + priority.closePriorityReason +
                   "|CloseIntentState=" + priority.closeIntentState +
                   "|FloatingPnLYen=" + DoubleToString(ps.floatingProfit, 2) +
                   "|BestFloatingPnLYen=" + DoubleToString(postHedgeDiagBestFloatingAfterHedge, 2) +
                   "|WorstFloatingPnLYen=" + DoubleToString(postHedgeDiagWorstFloatingAfterHedge, 2) +
                   "|CW8HteLossBandYen=" + DoubleToString(CW8HteLossBandYen, 2) +
                   "|HteNearState=" + BoolText(ps.floatingProfit >= CW8HteLossBandYen) +
                   "|HteConditionDistance=" + DoubleToString(hteDistance, 2) +
                   "|SpreadPrice=" + DoubleToString(spread, 3) +
                   "|CloseProfitYen=" + DoubleToString(ps.floatingProfit, 2) +
                   "|ActualCloseProfitYen=" + DoubleToString(ps.floatingProfit, 2);
   if(extra != "")
      detail += "|" + extra;
   return detail;
}

bool IsCW8RawTrigger(const PositionState &ps)
{
   if(!postHedgeDiagActive || CountDefenseHedges() <= 0)
      return false;
   return (ps.floatingProfit < 0.0);
}

bool CheckCW8OutsideHteBandExit(const PositionState &ps,
                                bool hardStop,
                                bool recoveryCloseEligible,
                                bool recoveryLossCutEligible,
                                bool hteEligibleNow)
{
   if(!UseCW8OutsideHteBandExit)
   {
      if(cw8Active)
         ResetCW8State(ps, "CW8Disabled");
      return false;
   }

   if(ps.total <= 0 || CountDefenseHedges() <= 0)
   {
      if(cw8Active)
         ResetCW8State(ps, "BasketFlatOrNoDefenseHedge");
      return false;
   }

   datetime firstHedgeTime = GetFirstDefenseHedgeTime();
   if(firstHedgeTime <= 0)
      return false;
   if(!cw8Active || cw8HedgeTime != firstHedgeTime)
      StartCW8Track(ps, firstHedgeTime);

   if(cw8ExitExecuted || cw8ExitIntentLogged)
      return false;

   if(!IsCW8RawTrigger(ps))
      return false;

   if(cw8PriorityBlocked)
      return false;

   bool outsideHteLossBand = (ps.floatingProfit < CW8HteLossBandYen);
   if(cw8RawTriggered && cw8HteGuardBlocked && !outsideHteLossBand)
      return false;

   ClosePriorityState priority = BuildRuntimeClosePriorityState(ps,
                                                                hardStop,
                                                                recoveryCloseEligible,
                                                                recoveryLossCutEligible,
                                                                hteEligibleNow);
   string snapshotId = WritePrioritySnapshot(ps,
                                             cw8BasketId,
                                             "RUNTIME_IMPL",
                                             priority,
                                             "CW8_OUTSIDE_HTE_BAND");
   bool basketCloseEligibleNow = PostHedgeDiagBasketCloseEligible(ps);
   string common = "|BasketCloseNow=" + BoolText(basketCloseEligibleNow) +
                   "|RecoveryCloseNow=" + BoolText(recoveryCloseEligible) +
                   "|RecoveryLossCutNow=" + BoolText(recoveryLossCutEligible) +
                   "|HteEligibleNow=" + BoolText(hteEligibleNow) +
                   "|PrioritySnapshotId=" + snapshotId +
                   "|MarketClosedState=" + CurrentMarketClosedState();

   if(!cw8RawTriggered)
   {
      cw8RawTriggered = true;
      cw8RawTriggerCount++;
      cw8TriggerTime = TimeCurrent();
      WriteTradeEventLog("CW8_RAW_TRIGGER",
                         0,
                         0,
                         "",
                         CW8EventDetail(ps, priority, "CW8RawTriggered=true" + common),
                         "",
                         0.0,
                         0.0,
                         0.0,
                         0.0,
                         0.0,
                         0.0,
                         ps.floatingProfit);
   }

   if(priority.closePriorityBlocked || IsMarketClosedRetryActive())
   {
      if(!cw8PriorityBlocked)
      {
         cw8PriorityBlocked = true;
         cw8PriorityBlockCount++;
         string reason = priority.closePriorityBlocked ? priority.closePriorityReason : "MARKET_CLOSED_RETRY";
         WriteTradeEventLog("CW8_PRIORITY_BLOCK",
                            0,
                            0,
                            "",
                            CW8EventDetail(ps,
                                           priority,
                                           "BlockReason=" + reason +
                                           "|CW8Blocked=true" + common),
                            "",
                            0.0,
                            0.0,
                            0.0,
                            0.0,
                            0.0,
                            0.0,
                            ps.floatingProfit);
      }
      return false;
   }

   if(!cw8PriorityOk)
   {
      cw8PriorityOk = true;
      cw8PriorityOkCount++;
      WriteTradeEventLog("CW8_PRIORITY_OK",
                         0,
                         0,
                         "",
                         CW8EventDetail(ps, priority, "CW8PriorityOK=true" + common),
                         "",
                         0.0,
                         0.0,
                         0.0,
                         0.0,
                         0.0,
                         0.0,
                         ps.floatingProfit);
   }

   if(!outsideHteLossBand)
   {
      if(!cw8HteGuardBlocked)
      {
         cw8HteGuardBlocked = true;
         cw8HteGuardBlockCount++;
         WriteTradeEventLog("CW8_HTE_GUARD_BLOCK",
                            0,
                            0,
                            "",
                            CW8EventDetail(ps,
                                           priority,
                                           "GuardReason=HTE_LOSS_BAND_GUARD" +
                                           "|CW8Blocked=true" +
                                           "|CW8HteLossBandYen=" + DoubleToString(CW8HteLossBandYen, 2) +
                                           common),
                            "",
                            0.0,
                            0.0,
                            0.0,
                            0.0,
                            0.0,
                            0.0,
                            ps.floatingProfit);
      }
      return false;
   }

   string closeReason = "CW8_OUTSIDE_HTE_BAND_EXIT";
   cw8ExitIntentLogged = true;
   WriteTradeEventLog("CW8_EXIT_INTENT",
                      0,
                      0,
                      "",
                      CW8EventDetail(ps,
                                     priority,
                                     "CloseReason=" + closeReason +
                                     "|CW8ExitDryRunOnly=" + BoolText(CW8ExitDryRunOnly) +
                                     "|CloseRetcode=0|CloseComment=INTENT" +
                                     "|PositionsClosedCount=0|CloseFailedReason=" + common),
                      "CLOSE",
                      0.0,
                      0.0,
                      0.0,
                      0.0,
                      0.0,
                      0.0,
                      ps.floatingProfit);

   if(CW8ExitDryRunOnly)
      return false;

   int preClosePositions = ps.total;
   bool closed = CloseAllEaPositions(closeReason);
   PositionState afterClose;
   GetPositionState(afterClose);
   int positionsClosed = preClosePositions - afterClose.total;
   if(positionsClosed < 0)
      positionsClosed = 0;
   if(closed && afterClose.total <= 0)
   {
      cw8ExitExecuted = true;
      cw8ExitCount++;
      cw8ExitProfitTotal += ps.floatingProfit;
      WriteTradeEventLog("CW8_EXIT_DONE",
                         0,
                         trade.ResultRetcode(),
                         trade.ResultRetcodeDescription(),
                         CW8EventDetail(ps,
                                        priority,
                                        "CloseReason=" + closeReason +
                                        "|CloseRetcode=" + IntegerToString((int)trade.ResultRetcode()) +
                                        "|CloseComment=" + trade.ResultRetcodeDescription() +
                                        "|PositionsClosedCount=" + IntegerToString(positionsClosed) +
                                        "|CloseFailedReason=" +
                                        "|EndOpenPositionCount=0|EndOpenBasketCount=0"),
                         "CLOSE",
                         0.0,
                         0.0,
                         0.0,
                         0.0,
                         0.0,
                         ps.floatingProfit,
                         ps.floatingProfit);
      ResetCW8State(afterClose, "CW8_EXIT_DONE");
      return true;
   }

   cw8ExitFailedCount++;
   uint retcode = trade.ResultRetcode();
   WriteTradeEventLog("CW8_EXIT_FAILED",
                      0,
                      retcode,
                      trade.ResultRetcodeDescription(),
                      CW8EventDetail(afterClose,
                                     priority,
                                     "CloseReason=" + closeReason +
                                     "|WasMarketClosed10018=" + BoolText(IsMarketClosedRetcode(retcode)) +
                                     "|CloseRetcode=" + IntegerToString((int)retcode) +
                                     "|CloseComment=" + trade.ResultRetcodeDescription() +
                                     "|PositionsClosedCount=" + IntegerToString(positionsClosed) +
                                     "|CloseFailedReason=" + trade.ResultRetcodeDescription() +
                                     "|EndOpenPositionCount=" + IntegerToString(afterClose.total) +
                                     "|EndOpenBasketCount=" + (afterClose.total > 0 ? "1" : "0")),
                      "CLOSE",
                      0.0,
                      0.0,
                      0.0,
                      0.0,
                      0.0,
                      0.0,
                      afterClose.floatingProfit);
   return closed;
}

bool PostHedgeDryRunCandidateAlreadyLogged(string candidateName)
{
   return (StringFind(postHedgeDryRunLoggedCandidates, "|" + candidateName + "|") >= 0);
}

void PostHedgeDryRunMarkCandidate(string candidateName)
{
   if(PostHedgeDryRunCandidateAlreadyLogged(candidateName))
      return;
   postHedgeDryRunLoggedCandidates += "|" + candidateName + "|";
}

void LogPostHedgeDryRunCandidate(const PositionState &ps,
                                 string candidateName,
                                 string candidateGroup,
                                 string condition,
                                 string extra = "")
{
   if(!EnablePostHedgeDryRunDiagnostic || !postHedgeDiagActive)
      return;
   if(PostHedgeDryRunCandidateAlreadyLogged(candidateName))
      return;
   PostHedgeDryRunMarkCandidate(candidateName);

   long m1Volume = 0;
   long m5Volume = 0;
   double m1Average = 0.0;
   double m5Average = 0.0;
   double m1Ratio = PostHedgeDryRunTickVolumeRatio(PERIOD_M1, m1Volume, m1Average);
   double m5Ratio = PostHedgeDryRunTickVolumeRatio(PERIOD_M5, m5Volume, m5Average);
   int tick10 = PostHedgeDryRunTickCountWindow(10, 0);
   int tick30 = PostHedgeDryRunTickCountWindow(30, 0);
   int tick60 = PostHedgeDryRunTickCountWindow(60, 0);
   double tick10Ratio = PostHedgeDryRunTickCountRatio(10);
   double tick30Ratio = PostHedgeDryRunTickCountRatio(30);
   double tick60Ratio = PostHedgeDryRunTickCountRatio(60);

   MqlTick tick;
   double spread = 0.0;
   if(SymbolInfoTick(_Symbol, tick))
      spread = tick.ask - tick.bid;

   bool adverseVsHedge = (ps.floatingProfit < postHedgeDiagFloatingAtHedge);
   bool worstUpdated = (ps.floatingProfit <= postHedgeDiagWorstFloatingAfterHedge);
   bool spreadExpanded = (spread >= MaxSpreadPrice * 0.80);
   bool dxyVixDanger = false;
   if(tradeEventContextReady)
      dxyVixDanger = (tradeEventDxy.stop || tradeEventDxy.extreme || tradeEventVix.stop || tradeEventVix.extreme || tradeEventVix.caution);

   bool hardStopNow = IsHardStopTriggeredByBasis(ps, AccountInfoDouble(ACCOUNT_MARGIN_LEVEL));
   bool recoveryCloseEligible = PostHedgeDiagRecoveryCloseEligible(ps);
   bool recoveryLossCutEligible = PostHedgeDiagRecoveryLossCutEligible(ps);
   bool timeExitEligible = PostHedgeDiagTimeExitEligible(ps);
   ClosePriorityState priority = BuildRuntimeClosePriorityState(ps,
                                                                hardStopNow,
                                                                recoveryCloseEligible,
                                                                recoveryLossCutEligible,
                                                                timeExitEligible);
   string snapshotId = WritePrioritySnapshot(ps,
                                             postHedgeDiagBasketId,
                                             "DRYRUN_DIAG",
                                             priority,
                                             candidateName);

   string reason = "CandidateName=" + candidateName +
                   "|CandidateGroup=" + candidateGroup +
                   "|Condition=" + condition +
                   "|BasketUid=" + CurrentPostHedgeBasketUid(ps) +
                   "|PrioritySnapshotId=" + snapshotId +
                   "|HardStopNow=" + BoolText(priority.hardStopNow) +
                   "|ClosePriorityOK=" + BoolText(priority.closePriorityOk) +
                   "|ClosePriorityBlocked=" + BoolText(priority.closePriorityBlocked) +
                   "|ClosePriorityReason=" + priority.closePriorityReason +
                   "|CloseIntentState=" + priority.closeIntentState +
                   "|ExecutableCandidate=" + BoolText(priority.closePriorityOk) +
                   "|VirtualExitTime=" + TimeToString(TimeCurrent(), TIME_DATE | TIME_SECONDS) +
                   "|VirtualExitMinutesAfterHedge=" + IntegerToString(PostHedgeDiagMinutesAfterHedge()) +
                   "|VirtualExitFloatingPnL=" + DoubleToString(ps.floatingProfit, 2) +
                   "|VirtualLossVsHedge=" + DoubleToString(ps.floatingProfit - postHedgeDiagFloatingAtHedge, 2) +
                   "|ImprovementFromWorstAfterHedge=" + DoubleToString(ps.floatingProfit - postHedgeDiagWorstFloatingAfterHedge, 2) +
                   "|M1TickVolume=" + IntegerToString((int)m1Volume) +
                   "|AvgTickVolume20_M1=" + DoubleToString(m1Average, 2) +
                   "|M1TickVolumeRatio=" + DoubleToString(m1Ratio, 3) +
                   "|M5TickVolume=" + IntegerToString((int)m5Volume) +
                   "|AvgTickVolume20_M5=" + DoubleToString(m5Average, 2) +
                   "|M5TickVolumeRatio=" + DoubleToString(m5Ratio, 3) +
                   "|RecentTickCount10Sec=" + IntegerToString(tick10) +
                   "|TickCountRatio10Sec=" + DoubleToString(tick10Ratio, 3) +
                   "|RecentTickCount30Sec=" + IntegerToString(tick30) +
                   "|TickCountRatio30Sec=" + DoubleToString(tick30Ratio, 3) +
                   "|RecentTickCount60Sec=" + IntegerToString(tick60) +
                   "|TickCountRatio60Sec=" + DoubleToString(tick60Ratio, 3) +
                   "|SpreadAtCandidate=" + DoubleToString(spread, 2) +
                   "|SpreadExpanded=" + BoolText(spreadExpanded) +
                   "|AdverseVsHedge=" + BoolText(adverseVsHedge) +
                   "|WorstFloatingUpdated=" + BoolText(worstUpdated) +
                   "|DxyVixDanger=" + BoolText(dxyVixDanger) +
                   "|NearNewsWindowAtCandidate=" + BoolText(currentNewsBlockActive) +
                   "|NearMarketCloseAtCandidate=" + BoolText(MinutesToEstimatedDailyMarketClose() >= 0 && MinutesToEstimatedDailyMarketClose() <= 180);
   if(extra != "")
      reason += "|" + extra;

   WritePostHedgeDiagEvent("POST_HEDGE_DRYRUN_CANDIDATE", ps, reason);
}

double PostHedgeDiagDistanceToBasketClose(const PositionState &ps)
{
   double target = CurrentBasketCloseTargetYen();
   if(!UseBasketClose || ps.total < BasketMinPositions || target <= 0.0)
      return 999999999.0;
   return target - ps.floatingProfit;
}

double PostHedgeDiagDistanceToRecoveryClose(const PositionState &ps)
{
   if(!UseBasketRecoveryClose || ps.total < 2 || CountDefenseHedges() <= 0)
      return 999999999.0;
   double target = CloseBasketWhenNetProfitPositiveAfterHedge ? 0.0 : BasketRecoveryProfitYen;
   return target - ps.floatingProfit;
}

double PostHedgeDiagDistanceToRecoveryLossCut(const PositionState &ps)
{
   if(!UseBasketRecoveryLossCut || !CloseHedgedBasketWhenLossImproves ||
      BasketRecoveryAcceptLossYen <= 0.0 || postHedgeDiagHedgeTime <= 0)
      return 999999999.0;
   double acceptableTarget = -BasketRecoveryAcceptLossYen;
   double target = acceptableTarget;
   if(UseBasketRecoveryImprovementCheck && BasketRecoveryRequiredImprovementYen > 0.0)
   {
      double referenceProfit = UseWorstBasketAfterHedgeAsReference ?
                               postHedgeDiagWorstFloatingAfterHedge :
                               postHedgeDiagFloatingAtHedge;
      target = MathMax(acceptableTarget, referenceProfit + BasketRecoveryRequiredImprovementYen);
   }
   return target - ps.floatingProfit;
}

double PostHedgeDiagDistanceToHardStop(const PositionState &ps)
{
   double threshold = GetHardStopThresholdYen();
   if(threshold <= 0.0)
      return 999999999.0;
   return threshold - GetFloatingLossYen(ps);
}

bool PostHedgeDiagBasketCloseEligible(const PositionState &ps)
{
   return (PostHedgeDiagDistanceToBasketClose(ps) <= 0.0);
}

bool PostHedgeDiagRecoveryCloseEligible(const PositionState &ps)
{
   if(!UseBasketRecoveryClose || ps.total < 2 || CountDefenseHedges() <= 0)
      return false;
   return (ps.floatingProfit >= BasketRecoveryProfitYen ||
           (CloseBasketWhenNetProfitPositiveAfterHedge && ps.floatingProfit >= 0.0));
}

bool PostHedgeDiagRecoveryLossCutEligible(const PositionState &ps)
{
   if(!UseBasketRecoveryLossCut || !CloseHedgedBasketWhenLossImproves ||
      BasketRecoveryAcceptLossYen <= 0.0 || postHedgeDiagHedgeTime <= 0 ||
      TimeCurrent() <= postHedgeDiagHedgeTime)
      return false;
   bool lossCutMinHoldPassed = (!UseBasketRecoveryLossCutMinHold ||
                                BasketRecoveryLossCutMinHoldMinutes <= 0 ||
                                TimeCurrent() - postHedgeDiagHedgeTime >= BasketRecoveryLossCutMinHoldMinutes * 60);
   if(!lossCutMinHoldPassed)
      return false;
   bool improvementReached = true;
   if(UseBasketRecoveryImprovementCheck && BasketRecoveryRequiredImprovementYen > 0.0)
   {
      double referenceProfit = UseWorstBasketAfterHedgeAsReference ?
                               postHedgeDiagWorstFloatingAfterHedge :
                               postHedgeDiagFloatingAtHedge;
      improvementReached = (ps.floatingProfit >= referenceProfit + BasketRecoveryRequiredImprovementYen);
   }
   return (ps.floatingProfit >= -BasketRecoveryAcceptLossYen && improvementReached);
}

bool PostHedgeDiagTimeExitEligible(const PositionState &ps)
{
   if(!UseHedgedBasketTimeExit || postHedgeDiagHedgeTime <= 0 ||
      HedgedBasketMaxHoldMinutes <= 0 || HedgedBasketTimeExitAcceptLossYen <= 0.0)
      return false;
   return (TimeCurrent() - postHedgeDiagHedgeTime >= HedgedBasketMaxHoldMinutes * 60 &&
           ps.floatingProfit >= -HedgedBasketTimeExitAcceptLossYen);
}

void PostHedgeDiagMarkFirstEligible(string exitName, const PositionState &ps)
{
   if(postHedgeDiagFirstEligibleExit != "")
      return;
   postHedgeDiagFirstEligibleExit = exitName;
   postHedgeDiagFirstEligibleExitTime = TimeCurrent();
   postHedgeDiagFirstEligibleExitProfit = ps.floatingProfit;
   postHedgeDiagFirstEligibleExitMinutes = PostHedgeDiagMinutesAfterHedge();
}

string PostHedgeDiagBaseDetail(const PositionState &ps)
{
   int minutesToClose = MinutesToEstimatedDailyMarketClose();
   string detail = "";
   PostHedgeDiagAppend(detail, "BasketId", postHedgeDiagBasketId);
   PostHedgeDiagAppend(detail, "BasketUid", CurrentPostHedgeBasketUid(ps));
   PostHedgeDiagAppendD(detail, "InitialDeposit", initialBalanceAtOnInit, 2);
   PostHedgeDiagAppendT(detail, "BasketStartTime", postHedgeDiagBasketStartTime);
   PostHedgeDiagAppendT(detail, "DefenseHedgeTime", postHedgeDiagHedgeTime);
   PostHedgeDiagAppendI(detail, "MinutesAfterHedge", PostHedgeDiagMinutesAfterHedge());
   PostHedgeDiagAppendD(detail, "FloatingPnL", ps.floatingProfit, 2);
   PostHedgeDiagAppendD(detail, "FloatingPnLAtHedge", postHedgeDiagFloatingAtHedge, 2);
   PostHedgeDiagAppendD(detail, "BestFloatingPnLAfterHedge", postHedgeDiagBestFloatingAfterHedge, 2);
   PostHedgeDiagAppendD(detail, "WorstFloatingPnLAfterHedge", postHedgeDiagWorstFloatingAfterHedge, 2);
   PostHedgeDiagAppendI(detail, "PositionCountTotal", ps.total);
   PostHedgeDiagAppendI(detail, "PositionCountBuy", ps.buys);
   PostHedgeDiagAppendI(detail, "PositionCountSell", ps.sells);
   PostHedgeDiagAppendI(detail, "NetPositionAtEvent", ps.net);
   PostHedgeDiagAppendD(detail, "GrossBuyLots", GetGrossLotsByType(POSITION_TYPE_BUY), 2);
   PostHedgeDiagAppendD(detail, "GrossSellLots", GetGrossLotsByType(POSITION_TYPE_SELL), 2);
   PostHedgeDiagAppend(detail, "BasketState", GetCurrentBasketState(ps));
   MqlTick detailTick;
   if(SymbolInfoTick(_Symbol, detailTick))
      PostHedgeDiagAppendD(detail, "SpreadAtEvent", detailTick.ask - detailTick.bid, 2);
   PostHedgeDiagAppendD(detail, "DistanceToBasketCloseYen", PostHedgeDiagDistanceToBasketClose(ps), 2);
   PostHedgeDiagAppendD(detail, "DistanceToRecoveryCloseYen", PostHedgeDiagDistanceToRecoveryClose(ps), 2);
   PostHedgeDiagAppendD(detail, "DistanceToRecoveryLossCutYen", PostHedgeDiagDistanceToRecoveryLossCut(ps), 2);
   PostHedgeDiagAppendD(detail, "DistanceToHardStopYen", PostHedgeDiagDistanceToHardStop(ps), 2);
   PostHedgeDiagAppend(detail, "IsTimeExitEligible", BoolText(PostHedgeDiagTimeExitEligible(ps)));
   PostHedgeDiagAppend(detail, "FirstEligibleExitAfterHedge", postHedgeDiagFirstEligibleExit == "" ? "None" : postHedgeDiagFirstEligibleExit);
   PostHedgeDiagAppendT(detail, "FirstEligibleExitTime", postHedgeDiagFirstEligibleExitTime);
   PostHedgeDiagAppendI(detail, "FirstEligibleExitMinutesAfterHedge", postHedgeDiagFirstEligibleExitMinutes);
   PostHedgeDiagAppendD(detail, "DXYAtEvent", tradeEventContextReady ? tradeEventDxy.value : 0.0, 4);
   PostHedgeDiagAppend(detail, "DxyState", tradeEventContextReady ? tradeEventDxy.state : "");
   PostHedgeDiagAppendD(detail, "VIXAtEvent", tradeEventContextReady ? tradeEventVix.value : 0.0, 4);
   PostHedgeDiagAppend(detail, "VixState", tradeEventContextReady ? tradeEventVix.state : "");
   PostHedgeDiagAppend(detail, "SessionAtEvent", GetPostHedgeDiagSessionJst());
   MqlDateTime jst;
   TimeToStruct(TimeGMT() + 9 * 3600, jst);
   PostHedgeDiagAppendI(detail, "WeekdayAtEvent", jst.day_of_week);
   PostHedgeDiagAppendI(detail, "HourAtEvent", jst.hour);
   PostHedgeDiagAppend(detail, "NearNewsWindow", BoolText(currentNewsBlockActive));
   PostHedgeDiagAppend(detail, "NearMarketClose", BoolText(minutesToClose >= 0 && minutesToClose <= 180));
   PostHedgeDiagAppendI(detail, "MinutesToEstimatedMarketClose", minutesToClose);
   return detail;
}

void WritePostHedgeDiagEvent(string eventType,
                             const PositionState &ps,
                             string reason,
                             uint retcode = 0,
                             string retcodeDescription = "")
{
   if(!IsPostHedgeDiagnosticEnabled())
      return;
   string detail = PostHedgeDiagBaseDetail(ps);
   PostHedgeDiagAppend(detail, "Reason", reason);
   WriteTradeEventLog(eventType, 0, retcode, retcodeDescription, detail, "",
                      0.0, 0.0, 0.0, 0.0, 0.0, 0.0, ps.floatingProfit);
}

void ResetPostHedgeTimeExitPriorityDiagnostic()
{
   postHedgeDiagActive = false;
   postHedgeDiagBasketId = "";
   postHedgeDiagBasketUid = "";
   postHedgeDiagBasketStartTime = 0;
   postHedgeDiagHedgeTime = 0;
   postHedgeDiagEndTime = 0;
   postHedgeDiagFloatingAtHedge = 0.0;
   postHedgeDiagBestFloatingAfterHedge = 0.0;
   postHedgeDiagWorstFloatingAfterHedge = 0.0;
   postHedgeDiagNearestBasketCloseDistance = 999999999.0;
   postHedgeDiagNearestRecoveryCloseDistance = 999999999.0;
   postHedgeDiagNearestRecoveryLossCutDistance = 999999999.0;
   postHedgeDiagNearestBasketCloseTime = 0;
   postHedgeDiagNearestRecoveryCloseTime = 0;
   postHedgeDiagNearestRecoveryLossCutTime = 0;
   postHedgeDiagNearestBasketCloseProfit = 0.0;
   postHedgeDiagNearestRecoveryCloseProfit = 0.0;
   postHedgeDiagNearestRecoveryLossCutProfit = 0.0;
   postHedgeDiagCheckpoint30 = false;
   postHedgeDiagCheckpoint60 = false;
   postHedgeDiagCheckpoint120 = false;
   postHedgeDiagCheckpoint240 = false;
   postHedgeDiagCheckpoint480 = false;
   postHedgeDiagCheckpoint720 = false;
   postHedgeDiagTimeExitLogged = false;
   postHedgeDiagHardStopLogged = false;
   postHedgeDiagMarketClosedLogged = false;
   postHedgeDiagEndLogged = false;
   postHedgeDiagFirstEligibleExit = "";
   postHedgeDiagFirstEligibleExitTime = 0;
   postHedgeDiagFirstEligibleExitProfit = 0.0;
   postHedgeDiagFirstEligibleExitMinutes = 0;
   postHedgeDiagActualFinalExit = "";
   postHedgeDiagFinalBasketProfit = 0.0;
   postHedgeDryRunLoggedCandidates = "";
   ArrayResize(postHedgeDryRunTickTimes, 0);
   ResetHardStopPrecursorDiagnostic();
   preHardStopCwLastSnapshotBucket = -1;
   preHardStopCwWindowActive = false;
   preHardStopCwStartLogged = false;
   preHardStopCwHardStopEnterLogged = false;
   preHardStopCwWindowStartTime = 0;
   preHardStopCwLastCloseableTime = 0;
   preHardStopCwLastCloseableProfit = 0.0;
}

void StartPostHedgeTimeExitPriorityDiagnostic(const PositionState &ps, string reason)
{
   if(!IsPostHedgeDiagnosticEnabled() || postHedgeDiagActive)
      return;
   postHedgeDiagBasketSeq++;
   postHedgeDiagActive = true;
   postHedgeDiagBasketId = StringFormat("PHB%04d", postHedgeDiagBasketSeq);
   postHedgeDiagBasketStartTime = GetEarliestEaPositionTime();
   postHedgeDiagHedgeTime = GetFirstDefenseHedgeTime();
   if(postHedgeDiagHedgeTime <= 0)
      postHedgeDiagHedgeTime = TimeCurrent();
   if(postHedgeDiagBasketStartTime <= 0)
      postHedgeDiagBasketStartTime = postHedgeDiagHedgeTime;
   postHedgeDiagFloatingAtHedge = ps.floatingProfit;
   postHedgeDiagBestFloatingAfterHedge = ps.floatingProfit;
   postHedgeDiagWorstFloatingAfterHedge = ps.floatingProfit;
   postHedgeDiagBasketUid = BuildPostHedgeBasketUid(ps);
   postHedgeDryRunLoggedCandidates = "";
   ArrayResize(postHedgeDryRunTickTimes, 0);
   ResetHardStopPrecursorDiagnostic();
   HardStopPrecursorAppendSample(ps);
   WritePostHedgeDiagEvent("POST_HEDGE_DIAG_START", ps, reason);
}

void UpdatePostHedgeDiagNearest(const PositionState &ps)
{
   double basketCloseDistance = PostHedgeDiagDistanceToBasketClose(ps);
   if(MathAbs(basketCloseDistance) < MathAbs(postHedgeDiagNearestBasketCloseDistance))
   {
      postHedgeDiagNearestBasketCloseDistance = basketCloseDistance;
      postHedgeDiagNearestBasketCloseTime = TimeCurrent();
      postHedgeDiagNearestBasketCloseProfit = ps.floatingProfit;
   }
   double recoveryCloseDistance = PostHedgeDiagDistanceToRecoveryClose(ps);
   if(MathAbs(recoveryCloseDistance) < MathAbs(postHedgeDiagNearestRecoveryCloseDistance))
   {
      postHedgeDiagNearestRecoveryCloseDistance = recoveryCloseDistance;
      postHedgeDiagNearestRecoveryCloseTime = TimeCurrent();
      postHedgeDiagNearestRecoveryCloseProfit = ps.floatingProfit;
   }
   double lossCutDistance = PostHedgeDiagDistanceToRecoveryLossCut(ps);
   if(MathAbs(lossCutDistance) < MathAbs(postHedgeDiagNearestRecoveryLossCutDistance))
   {
      postHedgeDiagNearestRecoveryLossCutDistance = lossCutDistance;
      postHedgeDiagNearestRecoveryLossCutTime = TimeCurrent();
      postHedgeDiagNearestRecoveryLossCutProfit = ps.floatingProfit;
   }
}

void LogPostHedgeDiagCheckpointIfNeeded(const PositionState &ps, int checkpointMinutes, bool &checkpointFlag)
{
   if(checkpointFlag || PostHedgeDiagMinutesAfterHedge() < checkpointMinutes)
      return;
   checkpointFlag = true;
   WritePostHedgeDiagEvent("POST_HEDGE_DIAG_CHECKPOINT", ps,
                           "CheckpointMinutesAfterHedge=" + IntegerToString(checkpointMinutes));
}

void LogPostHedgeDiagNearestEvents(const PositionState &ps)
{
   if(postHedgeDiagNearestBasketCloseTime > 0)
   {
      string reason = "NearestBasketCloseTime=" + TimeToString(postHedgeDiagNearestBasketCloseTime, TIME_DATE | TIME_SECONDS) +
                      "|NearestDistanceToBasketCloseYen=" + DoubleToString(postHedgeDiagNearestBasketCloseDistance, 2) +
                      "|NearestBasketCloseProfitYen=" + DoubleToString(postHedgeDiagNearestBasketCloseProfit, 2);
      WritePostHedgeDiagEvent("POST_HEDGE_DIAG_NEAREST_BASKETCLOSE", ps, reason);
   }
   if(postHedgeDiagNearestRecoveryCloseTime > 0)
   {
      string reason = "NearestRecoveryCloseTime=" + TimeToString(postHedgeDiagNearestRecoveryCloseTime, TIME_DATE | TIME_SECONDS) +
                      "|NearestDistanceToRecoveryCloseYen=" + DoubleToString(postHedgeDiagNearestRecoveryCloseDistance, 2) +
                      "|NearestRecoveryCloseProfitYen=" + DoubleToString(postHedgeDiagNearestRecoveryCloseProfit, 2);
      WritePostHedgeDiagEvent("POST_HEDGE_DIAG_NEAREST_RECOVERYCLOSE", ps, reason);
   }
   if(postHedgeDiagNearestRecoveryLossCutTime > 0)
   {
      string reason = "NearestRecoveryLossCutTime=" + TimeToString(postHedgeDiagNearestRecoveryLossCutTime, TIME_DATE | TIME_SECONDS) +
                      "|NearestDistanceToRecoveryLossCutYen=" + DoubleToString(postHedgeDiagNearestRecoveryLossCutDistance, 2) +
                      "|NearestRecoveryLossCutProfitYen=" + DoubleToString(postHedgeDiagNearestRecoveryLossCutProfit, 2);
      WritePostHedgeDiagEvent("POST_HEDGE_DIAG_NEAREST_RECOVERYLOSSCUT", ps, reason);
   }
}

void EvaluatePostHedgeRecoveryFailureDryRun(const PositionState &ps)
{
   if(!EnablePostHedgeDryRunDiagnostic)
      return;
   int minutes = PostHedgeDiagMinutesAfterHedge();
   int checkpoints[] = {30, 45, 60, 75, 90, 105, 120, 240, 480, 720, 1440};
   double improvements[] = {0.0, 500.0, 1000.0, 1500.0};
   for(int i = 0; i < ArraySize(checkpoints); i++)
   {
      if(minutes < checkpoints[i])
         continue;
      for(int j = 0; j < ArraySize(improvements); j++)
      {
         double required = postHedgeDiagFloatingAtHedge + improvements[j];
         if(postHedgeDiagBestFloatingAfterHedge < required)
         {
            string candidateName = "RF_" + IntegerToString(checkpoints[i]) + "_NO_IMPROVE_" + IntegerToString((int)improvements[j]);
            string condition = IntegerToString(checkpoints[i]) + "min no improvement >= " + DoubleToString(improvements[j], 0) + " yen";
            string extra = "RequiredImprovementYen=" + DoubleToString(improvements[j], 2) +
                           "|RequiredFloatingPnL=" + DoubleToString(required, 2) +
                           "|BestFloatingPnLAfterHedge=" + DoubleToString(postHedgeDiagBestFloatingAfterHedge, 2);
            LogPostHedgeDryRunCandidate(ps, candidateName, "RecoveryFailure", condition, extra);
         }
      }
   }
}

void EvaluatePostHedgeBeforeHardStopBufferDryRun(const PositionState &ps)
{
   if(!EnablePostHedgeDryRunDiagnostic)
      return;

   double distanceToHardStop = PostHedgeDiagDistanceToHardStop(ps);
   if(distanceToHardStop <= 0.0)
      return;

   double buffers[] = {500.0, 1000.0, 1500.0, 2000.0};
   for(int i = 0; i < ArraySize(buffers); i++)
   {
      if(distanceToHardStop > buffers[i])
         continue;
      string candidateName = "RF_BUFFER_" + IntegerToString((int)buffers[i]);
      string condition = "DistanceToHardStopYen <= " + DoubleToString(buffers[i], 0) + " before hard stop";
      string extra = "DistanceToHardStopYen=" + DoubleToString(distanceToHardStop, 2) +
                     "|HardStopNow=false|RequiredBufferYen=" + DoubleToString(buffers[i], 2) +
                     "|BestFloatingPnLAfterHedge=" + DoubleToString(postHedgeDiagBestFloatingAfterHedge, 2);
      LogPostHedgeDryRunCandidate(ps, candidateName, "BeforeHardStopBuffer", condition, extra);
   }
}

void EvaluatePostHedgeMaxHoldingDryRun(const PositionState &ps)
{
   if(!EnablePostHedgeDryRunDiagnostic)
      return;
   int minutes = PostHedgeDiagMinutesAfterHedge();
   int checkpoints[] = {240, 480, 720, 1440, 2880};
   for(int i = 0; i < ArraySize(checkpoints); i++)
   {
      if(minutes < checkpoints[i])
         continue;
      string candidateName = "MH_" + IntegerToString(checkpoints[i]);
      string condition = "holding minutes >= " + IntegerToString(checkpoints[i]);
      LogPostHedgeDryRunCandidate(ps, candidateName, "MaxHolding", condition);
   }
}

void EvaluatePostHedgeAdverseTickVolumeDryRun(const PositionState &ps)
{
   if(!EnablePostHedgeDryRunDiagnostic)
      return;

   long m1Volume = 0;
   long m5Volume = 0;
   double m1Average = 0.0;
   double m5Average = 0.0;
   double m1Ratio = PostHedgeDryRunTickVolumeRatio(PERIOD_M1, m1Volume, m1Average);
   double m5Ratio = PostHedgeDryRunTickVolumeRatio(PERIOD_M5, m5Volume, m5Average);
   double tick10Ratio = PostHedgeDryRunTickCountRatio(10);
   double tick30Ratio = PostHedgeDryRunTickCountRatio(30);
   double tick60Ratio = PostHedgeDryRunTickCountRatio(60);
   bool adverse = (ps.floatingProfit < postHedgeDiagFloatingAtHedge);
   bool worstUpdated = (ps.floatingProfit <= postHedgeDiagWorstFloatingAfterHedge);
   if(!adverse)
      return;

   MqlTick tick;
   double spread = 0.0;
   if(SymbolInfoTick(_Symbol, tick))
      spread = tick.ask - tick.bid;
   bool spreadExpanded = (spread >= MaxSpreadPrice * 0.80);
   bool dxyVixDanger = false;
   if(tradeEventContextReady)
      dxyVixDanger = (tradeEventDxy.stop || tradeEventDxy.extreme || tradeEventVix.stop || tradeEventVix.extreme || tradeEventVix.caution);
   bool marketCloseNear = (MinutesToEstimatedDailyMarketClose() >= 0 && MinutesToEstimatedDailyMarketClose() <= 180);

   if(m1Ratio >= 2.0)
      LogPostHedgeDryRunCandidate(ps, "ATV_M1_R2_ADVERSE", "AdverseTickVolume", "M1 ratio >= 2.0 and FloatingPnL adverse");
   if(m1Ratio >= 3.0)
      LogPostHedgeDryRunCandidate(ps, "ATV_M1_R3_ADVERSE", "AdverseTickVolume", "M1 ratio >= 3.0 and FloatingPnL adverse");
   if(m5Ratio >= 2.0)
      LogPostHedgeDryRunCandidate(ps, "ATV_M5_R2_ADVERSE", "AdverseTickVolume", "M5 ratio >= 2.0 and FloatingPnL adverse");
   if(m5Ratio >= 3.0)
      LogPostHedgeDryRunCandidate(ps, "ATV_M5_R3_ADVERSE", "AdverseTickVolume", "M5 ratio >= 3.0 and FloatingPnL adverse");
   if(tick10Ratio >= 2.0)
      LogPostHedgeDryRunCandidate(ps, "ATV_TICK10_R2_ADVERSE", "AdverseTickVolume", "10sec tick ratio >= 2.0 and FloatingPnL adverse");
   if(tick30Ratio >= 2.0)
      LogPostHedgeDryRunCandidate(ps, "ATV_TICK30_R2_ADVERSE", "AdverseTickVolume", "30sec tick ratio >= 2.0 and FloatingPnL adverse");
   if(tick60Ratio >= 2.0)
      LogPostHedgeDryRunCandidate(ps, "ATV_TICK60_R2_ADVERSE", "AdverseTickVolume", "60sec tick ratio >= 2.0 and FloatingPnL adverse");

   double maxRatio = MathMax(MathMax(m1Ratio, m5Ratio), MathMax(tick30Ratio, tick60Ratio));
   if(maxRatio >= 2.0 && worstUpdated)
      LogPostHedgeDryRunCandidate(ps, "ATV_R2_WORST_UPDATE", "AdverseTickVolume", "ratio >= 2.0 and worst floating updated");
   if(maxRatio >= 2.0 && spreadExpanded)
      LogPostHedgeDryRunCandidate(ps, "ATV_R2_SPREAD_ADVERSE", "AdverseTickVolume", "ratio >= 2.0 and spread expanded");
   if(maxRatio >= 2.0 && dxyVixDanger)
      LogPostHedgeDryRunCandidate(ps, "ATV_R2_DXYVIX_ADVERSE", "AdverseTickVolume", "ratio >= 2.0 and DXY/VIX danger");
   if(maxRatio >= 2.0 && currentNewsBlockActive)
      LogPostHedgeDryRunCandidate(ps, "ATV_R2_NEWS_ADVERSE", "AdverseTickVolume", "ratio >= 2.0 and news window");
   if(maxRatio >= 2.0 && marketCloseNear)
      LogPostHedgeDryRunCandidate(ps, "ATV_R2_MARKETCLOSE_ADVERSE", "AdverseTickVolume", "ratio >= 2.0 and market close near");
}

void EvaluatePostHedgeCompositeDryRun(const PositionState &ps)
{
   if(!EnablePostHedgeDryRunDiagnostic)
      return;
   int minutes = PostHedgeDiagMinutesAfterHedge();
   double tick30Ratio = PostHedgeDryRunTickCountRatio(30);
   long m1Volume = 0;
   long m5Volume = 0;
   double m1Average = 0.0;
   double m5Average = 0.0;
   double m1Ratio = PostHedgeDryRunTickVolumeRatio(PERIOD_M1, m1Volume, m1Average);
   double m5Ratio = PostHedgeDryRunTickVolumeRatio(PERIOD_M5, m5Volume, m5Average);
   double maxBarRatio = MathMax(m1Ratio, m5Ratio);
   bool adverse = (ps.floatingProfit < postHedgeDiagFloatingAtHedge);
   int checkpoints[] = {120, 240, 480};
   for(int i = 0; i < ArraySize(checkpoints); i++)
   {
      if(minutes < checkpoints[i])
         continue;
      bool noImprove = (postHedgeDiagBestFloatingAfterHedge < postHedgeDiagFloatingAtHedge);
      if(noImprove && maxBarRatio >= 2.0)
         LogPostHedgeDryRunCandidate(ps, "CMP_" + IntegerToString(checkpoints[i]) + "_NOIMPROVE_BAR_R2",
                                     "Composite", IntegerToString(checkpoints[i]) + "min no improvement + bar ratio >= 2.0");
      if(noImprove && maxBarRatio >= 2.0 && adverse)
         LogPostHedgeDryRunCandidate(ps, "CMP_" + IntegerToString(checkpoints[i]) + "_NOIMPROVE_BAR_R2_ADVERSE",
                                     "Composite", IntegerToString(checkpoints[i]) + "min no improvement + bar ratio >= 2.0 + adverse");
      if(noImprove && tick30Ratio >= 2.0 && adverse)
         LogPostHedgeDryRunCandidate(ps, "CMP_" + IntegerToString(checkpoints[i]) + "_NOIMPROVE_TICK30_R2_ADVERSE",
                                     "Composite", IntegerToString(checkpoints[i]) + "min no improvement + 30sec ratio >= 2.0 + adverse");
   }
}

void EvaluatePostHedgeDryRunDiagnostics(const PositionState &ps)
{
   if(!EnablePostHedgeDryRunDiagnostic || !postHedgeDiagActive)
      return;
   EvaluatePostHedgeRecoveryFailureDryRun(ps);
   EvaluatePostHedgeBeforeHardStopBufferDryRun(ps);
   EvaluatePostHedgeMaxHoldingDryRun(ps);
   EvaluatePostHedgeAdverseTickVolumeDryRun(ps);
   EvaluatePostHedgeCompositeDryRun(ps);
}

void EndPostHedgeTimeExitPriorityDiagnostic(const PositionState &ps, string finalExitReason)
{
   if(!IsPostHedgeDiagnosticEnabled() || !postHedgeDiagActive || postHedgeDiagEndLogged)
      return;
   postHedgeDiagEndLogged = true;
   postHedgeDiagEndTime = TimeCurrent();
   postHedgeDiagActualFinalExit = TradeEventTypeFromCloseReason(finalExitReason);
   postHedgeDiagFinalBasketProfit = ps.floatingProfit;
   LogPostHedgeDiagNearestEvents(ps);
   if(EnablePreHardStopCloseableWindowDiagnostic)
   {
      bool finalHardStop = (TradeEventTypeFromCloseReason(finalExitReason) == "HARDSTOP_CLOSE");
      LogPreHardStopCloseableWindowSnapshot(ps,
                                            finalHardStop,
                                            finalHardStop ? "ACTUAL_HARDSTOP_CLOSE" : "SUCCESS_CONTROL_SNAPSHOT",
                                            true);
   }
   string reason = "FinalCloseReason=" + finalExitReason +
                   "|ActualFinalExit=" + postHedgeDiagActualFinalExit +
                   "|ActualFinalExitTime=" + TimeToString(postHedgeDiagEndTime, TIME_DATE | TIME_SECONDS) +
                   "|FinalBasketProfit=" + DoubleToString(ps.floatingProfit, 2) +
                   "|TotalBasketHoldingMinutes=" + IntegerToString((int)MathFloor((postHedgeDiagEndTime - postHedgeDiagBasketStartTime) / 60.0)) +
                   "|HoldingMinutesAfterHedge=" + IntegerToString(PostHedgeDiagMinutesAfterHedge()) +
                   "|DidActualExitMatchFirstEligible=" + BoolText(postHedgeDiagActualFinalExit == postHedgeDiagFirstEligibleExit);
   WritePostHedgeDiagEvent("POST_HEDGE_DIAG_END", ps, reason);
   ResetPostHedgeTimeExitPriorityDiagnostic();
}

void UpdatePostHedgeTimeExitPriorityDiagnostic(const PositionState &ps, bool hardStop)
{
   if(!IsPostHedgeDiagnosticEnabled())
   {
      if(postHedgeDiagActive)
         ResetPostHedgeTimeExitPriorityDiagnostic();
      return;
   }
   if(!postHedgeDiagActive && CountDefenseHedges() > 0)
      StartPostHedgeTimeExitPriorityDiagnostic(ps, "existing defense hedge diagnostic start");
   if(!postHedgeDiagActive)
      return;
   PostHedgeDryRunAppendTickTime();
   HardStopPrecursorAppendSample(ps);
   if(ps.total <= 0)
   {
      EndPostHedgeTimeExitPriorityDiagnostic(ps, "basket flat");
      return;
   }
   if(ps.floatingProfit > postHedgeDiagBestFloatingAfterHedge)
      postHedgeDiagBestFloatingAfterHedge = ps.floatingProfit;
   if(ps.floatingProfit < postHedgeDiagWorstFloatingAfterHedge)
      postHedgeDiagWorstFloatingAfterHedge = ps.floatingProfit;
   UpdatePostHedgeDiagNearest(ps);

   bool basketCloseEligible = PostHedgeDiagBasketCloseEligible(ps);
   bool recoveryCloseEligible = PostHedgeDiagRecoveryCloseEligible(ps);
   bool recoveryLossCutEligible = PostHedgeDiagRecoveryLossCutEligible(ps);
   bool timeExitEligible = PostHedgeDiagTimeExitEligible(ps);
   if(basketCloseEligible)
      PostHedgeDiagMarkFirstEligible("BasketClose", ps);
   else if(recoveryCloseEligible)
      PostHedgeDiagMarkFirstEligible("RecoveryClose", ps);
   else if(recoveryLossCutEligible)
      PostHedgeDiagMarkFirstEligible("RecoveryLossCut", ps);
   else if(timeExitEligible)
      PostHedgeDiagMarkFirstEligible("TimeExit", ps);
   else if(hardStop)
      PostHedgeDiagMarkFirstEligible("HardStop", ps);

   LogPostHedgeDiagCheckpointIfNeeded(ps, 30, postHedgeDiagCheckpoint30);
   LogPostHedgeDiagCheckpointIfNeeded(ps, 60, postHedgeDiagCheckpoint60);
   LogPostHedgeDiagCheckpointIfNeeded(ps, 120, postHedgeDiagCheckpoint120);
   LogPostHedgeDiagCheckpointIfNeeded(ps, 240, postHedgeDiagCheckpoint240);
   LogPostHedgeDiagCheckpointIfNeeded(ps, 480, postHedgeDiagCheckpoint480);
   LogPostHedgeDiagCheckpointIfNeeded(ps, 720, postHedgeDiagCheckpoint720);
   EvaluatePostHedgeDryRunDiagnostics(ps);
   LogHardStopPrecursorSnapshotIfNeeded(ps, hardStop);
   EvaluateHardStopPrecursorDryRunPlans(ps, hardStop);
   EvaluatePreHardStopCloseableWindowDiagnostic(ps, hardStop);

   if(timeExitEligible && !postHedgeDiagTimeExitLogged)
   {
      postHedgeDiagTimeExitLogged = true;
      WritePostHedgeDiagEvent("POST_HEDGE_DIAG_TIMEEXIT_ELIGIBLE", ps, "TimeExit base condition eligible");
   }
   if(hardStop && !postHedgeDiagHardStopLogged)
   {
      postHedgeDiagHardStopLogged = true;
      LogHardStopPrecursorSnapshotIfNeeded(ps, hardStop, true);
      WritePostHedgeDiagEvent("POST_HEDGE_DIAG_HARDSTOP_REACHED", ps, "HardStop reached after DefenseHedge");
   }
}

void LogPostHedgeTimeExitPriorityMarketClosed(const PositionState &ps,
                                              string closeReason,
                                              uint retcode,
                                              string retcodeDescription)
{
   if(!IsPostHedgeDiagnosticEnabled() || !postHedgeDiagActive)
      return;
   postHedgeDiagMarketClosedLogged = true;
   string reason = "CloseReason=" + closeReason +
                   "|Retcode=" + UintToText(retcode) +
                   "|RetcodeDescription=" + retcodeDescription;
   WritePostHedgeDiagEvent("POST_HEDGE_DIAG_MARKETCLOSED_10018", ps, reason, retcode, retcodeDescription);
}

bool IsPostHedgeNewEntryFreezeActive()
{
   return (UsePostHedgeNewEntryFreeze && postHedgeNewEntryFreezeActive);
}

void StartPostHedgeNewEntryFreeze(const PositionState &ps, string reason)
{
   if(!UsePostHedgeNewEntryFreeze)
      return;
   if(postHedgeNewEntryFreezeActive)
      return;

   postHedgeNewEntryFreezeActive = true;
   postHedgeNewEntryFreezeStartTime = TimeCurrent();
   WriteTradeEventLog("POST_HEDGE_FREEZE_START",
                      0,
                      0,
                      "",
                      reason,
                      "",
                      0.0,
                      0.0,
                      0.0,
                      0.0,
                      0.0,
                      0.0,
                      ps.floatingProfit);
}

void EndPostHedgeNewEntryFreeze(const PositionState &ps, string reason)
{
   if(!postHedgeNewEntryFreezeActive)
      return;

   string detail = reason +
                   "|FreezeStartTime=" + TimeToString(postHedgeNewEntryFreezeStartTime, TIME_DATE | TIME_SECONDS) +
                   "|BlockedCount=" + IntegerToString(postHedgeNewEntryFreezeBlockedCount);
   WriteTradeEventLog("POST_HEDGE_FREEZE_END",
                      0,
                      0,
                      "",
                      detail,
                      "",
                      0.0,
                      0.0,
                      0.0,
                      0.0,
                      0.0,
                      0.0,
                      ps.floatingProfit);

   postHedgeNewEntryFreezeActive = false;
   postHedgeNewEntryFreezeStartTime = 0;
}

void UpdatePostHedgeNewEntryFreezeState(const PositionState &ps)
{
   if(!UsePostHedgeNewEntryFreeze)
   {
      postHedgeNewEntryFreezeActive = false;
      postHedgeNewEntryFreezeStartTime = 0;
      return;
   }

   if(postHedgeNewEntryFreezeActive && ps.total <= 0)
   {
      EndPostHedgeNewEntryFreeze(ps, "post hedge freeze end: basket flat");
      return;
   }

   if(!postHedgeNewEntryFreezeActive && CountDefenseHedges() > 0)
      StartPostHedgeNewEntryFreeze(ps, "post hedge freeze start: existing defense hedge");
}

void LogPostHedgeNewEntryFreezeBlock(bool isBuy, const ScoreState &score, const PositionState &ps, string blockedReason)
{
   postHedgeNewEntryFreezeBlockedCount++;
   if(isBuy)
      postHedgeNewEntryFreezeBlockedBuyCount++;
   else
      postHedgeNewEntryFreezeBlockedSellCount++;

   string detail = "PostHedgeFreezeActive=true" +
                   "|FreezeStartTime=" + TimeToString(postHedgeNewEntryFreezeStartTime, TIME_DATE | TIME_SECONDS) +
                   "|BlockedEntryDirection=" + (isBuy ? "BUY" : "SELL") +
                   "|BlockedEntryScore=" + DoubleToString(isBuy ? score.longScore : score.shortScore, 2) +
                   "|BlockedEntryReason=" + blockedReason +
                   "|FloatingPnLAtBlockedEntry=" + DoubleToString(ps.floatingProfit, 2) +
                   "|BlockedCount=" + IntegerToString(postHedgeNewEntryFreezeBlockedCount);

   WriteTradeEventLog("POST_HEDGE_FREEZE_BLOCK_NEW_ENTRY",
                      0,
                      0,
                      "",
                      detail,
                      isBuy ? "BUY" : "SELL",
                      0.0,
                      0.0,
                      0.0,
                      0.0,
                      0.0,
                      0.0,
                      ps.floatingProfit);
   lastPostHedgeNewEntryFreezeBlockLogTime = TimeCurrent();
}

bool CanEnter(bool isBuy,
              const MqlTick &tick,
              const ScoreState &score,
              const PositionState &ps,
              const FilterState &dxy,
              const FilterState &vix,
              bool newsBlock,
              string newsReason,
              bool htfBlock,
              bool goldOk,
              string goldReason,
              bool pullbackOk,
              string pullbackReason,
              bool maOk,
              string maReason,
              bool isDefenseEntry,
              double marginLevel,
              bool dailyStop,
              bool consecutiveStop,
              bool hardStop,
              string &reason)
{
   int direction = isBuy ? 1 : -1;

   if(_Symbol != TargetSymbol)
   {
      reason = "chart symbol does not match TargetSymbol";
      return false;
   }
   if(IsMarketClosedRetryActive())
   {
      reason = "market closed retry cooldown";
      return false;
   }
   if(TimeCurrent() < hardStopCooldownUntil)
   {
      reason = "HardStop cooldown active";
      return false;
   }
   if(!isDefenseEntry && IsSingleEarlyExitPostCooldownBlocked(isBuy, reason))
      return false;
   if(!isDefenseEntry && BlockNewEntryDuringReactiveDefenseHedge && CountReactiveDefenseHedges() > 0)
   {
      reason = "reactive defense hedge active";
      return false;
   }
   if(GetAfterCloseCooldownRemaining() > 0)
   {
      reason = "after EA close cooldown";
      return false;
   }
   if(!AutoTradeMode)
   {
      reason = "AutoTradeMode false";
      return false;
   }
   if(SignalOnlyMode || ManualBiasMode == 4)
   {
      reason = "signal only mode";
      return false;
   }
   if(UseManualBias && ManualBiasMode == 3)
   {
      reason = "manual bias stop new entries";
      return false;
   }
   if(isBuy && (!AllowBuy || ManualBiasMode == 2))
   {
      reason = "BUY blocked by manual bias";
      return false;
   }
   if(!isBuy && (!AllowSell || ManualBiasMode == 1))
   {
      reason = "SELL blocked by manual bias";
      return false;
   }
   if(BlockOppositeEntryWhilePositionExists && !isDefenseEntry)
   {
      if(isBuy && ps.sells > 0)
      {
         reason = "BUY blocked: SELL position exists";
         return false;
      }
      if(!isBuy && ps.buys > 0)
      {
         reason = "SELL blocked: BUY position exists";
         return false;
      }
   }
   if(lastEntryDirection != 0 && lastEntryDirection != direction && !isDefenseEntry)
   {
      if(RequireFlatBeforeOppositeEntry && ps.total > 0)
      {
         reason = "opposite entry requires flat";
         return false;
      }
      if(GetOppositeCooldownRemaining() > 0)
      {
         reason = "opposite direction cooldown";
         return false;
      }
   }
   if(!isDefenseEntry && lastEntryDirection == direction && SameDirectionReentryCooldownSeconds > 0 &&
      TimeCurrent() - lastEntryTime < SameDirectionReentryCooldownSeconds)
   {
      reason = "same direction reentry cooldown";
      return false;
   }
   if((tick.ask - tick.bid) > MaxSpreadPrice)
   {
      reason = "spread too high";
      return false;
   }
   if(!IsTradingTimeAllowed(reason))
      return false;
   string closeWindowReason = "";
   if(IsNoNewTradeCloseWindow(closeWindowReason))
   {
      reason = closeWindowReason;
      return false;
   }
   if(newsBlock && BlockNewEntryDuringNews && !isDefenseEntry)
   {
      reason = newsReason;
      blockedByNewsCount++;
      blockedNewEntryByNewsCount++;
      return false;
   }
   if(IsHistoricalTimeRiskEntryBlocked(isBuy, isDefenseEntry, reason))
      return false;
   if(!dxy.ok || dxy.stop)
   {
      reason = dxy.reason;
      return false;
   }
   if(UseDxyFilter && UseDxyHardBlock && !isDefenseEntry)
   {
      if(isBuy && dxy.state == "bullish")
      {
         reason = "Blocked: DXY bullish blocks GOLD BUY";
         return false;
      }
      if(!isBuy && dxy.state == "bearish")
      {
         reason = "Blocked: DXY bearish blocks GOLD SELL";
         return false;
      }
   }
   if(!vix.ok || vix.stop || vix.extreme)
   {
      reason = vix.reason;
      return false;
   }
   if(htfBlock)
   {
      reason = isBuy ? "BUY blocked: higher timeframe opposite" : "SELL blocked: higher timeframe opposite";
      return false;
   }
   if(!goldOk)
   {
      reason = goldReason;
      return false;
   }
   string technicalReason = "";
   if(UseTechnicalDangerBlock && IsTechnicalDangerBlockedCached(isBuy, technicalReason, true))
   {
      reason = technicalReason;
      return false;
   }
   if(!isDefenseEntry && !CheckStructureEntryGate(isBuy, score, reason))
      return false;
   if(!pullbackOk)
   {
      reason = pullbackReason;
      return false;
   }
   if(!maOk)
   {
      reason = maReason;
      return false;
   }
   if(!isDefenseEntry && ps.floatingLossPercent >= StopNewEntryFloatingLossPercent)
   {
      reason = "floating drawdown stop new entries";
      return false;
   }
   if(!isDefenseEntry && marginLevel <= StopNewEntryMarginLevel)
   {
      reason = "margin level stop new entries";
      return false;
   }
   if(dailyStop)
   {
      reason = "daily loss stop";
      return false;
   }
   if(consecutiveStop)
   {
      reason = "consecutive loss stop";
      return false;
   }
   if(TimeCurrent() < manualCloseStopUntil)
   {
      reason = "manual close protection active";
      return false;
   }
   if(!isDefenseEntry && BlockNewEntryWhilePostHedgeExitPending && postHedgeCloseIntentPending)
   {
      reason = "post hedge close intent pending";
      return false;
   }
   if(BlockNewEntryWhileCloseRetryPending && globalCloseIntentPending)
   {
      globalCloseRetryBlockNewEntryCount++;
      if(lastGlobalCloseRetryBlockLogTime <= 0 || TimeCurrent() - lastGlobalCloseRetryBlockLogTime >= 60)
      {
         lastGlobalCloseRetryBlockLogTime = TimeCurrent();
         WriteTradeEventLog("GLOBAL_CLOSE_RETRY_BLOCK_NEW_ENTRY",
                            0,
                            0,
                            "",
                            globalCloseIntentReason,
                            isBuy ? "BUY" : "SELL",
                            0.0,
                            0.0,
                            0.0,
                            0.0,
                            0.0,
                            0.0,
                            ps.floatingProfit);
      }
      reason = "global close retry pending";
      return false;
   }
   if(hardStop)
   {
      reason = "hard stop mode";
      return false;
   }
   if(!isDefenseEntry && TimeCurrent() - lastEntryTime < EntryCooldownSeconds)
   {
      reason = "entry cooldown";
      return false;
   }
   if(isDefenseEntry)
   {
      if(!CheckDefenseHedgePositionLimits(isBuy, ps, reason))
         return false;
   }
   else if(!CheckPositionLimits(isBuy, ps, reason))
      return false;
   if(AllowMartingale || !UseFixedLotOnly)
   {
      reason = "martingale disabled by survival rule";
      return false;
   }
   if(!isDefenseEntry && IsPostHedgeNewEntryFreezeActive())
   {
      reason = "post hedge new entry freeze active";
      LogPostHedgeNewEntryFreezeBlock(isBuy, score, ps, reason);
      return false;
   }

   reason = "entry allowed";
   return true;
}

bool CheckDefenseHedgePositionLimits(bool isBuy, const PositionState &ps, string &reason)
{
   if(!UseDefenseHedge)
   {
      reason = "HEDGE blocked: UseDefenseHedge false";
      return false;
   }
   if(CountDefenseHedges() >= MaxDefenseHedgePositions)
   {
      reason = "HEDGE blocked: max hedge positions reached";
      return false;
   }
   if(isBuy && ps.sells <= 0)
   {
      reason = "HEDGE BUY blocked: no losing SELL exposure";
      return false;
   }
   if(!isBuy && ps.buys <= 0)
   {
      reason = "HEDGE SELL blocked: no losing BUY exposure";
      return false;
   }
   if(isBuy && ps.buys >= MaxBuyPositions)
   {
      reason = "HEDGE BUY blocked: max buy positions";
      return false;
   }
   if(!isBuy && ps.sells >= MaxSellPositions)
   {
      reason = "HEDGE SELL blocked: max sell positions";
      return false;
   }
   if(ps.total >= MaxTotalPositions)
   {
      reason = "HEDGE blocked: max total positions";
      return false;
   }

   reason = "defense hedge position limit allowed";
   return true;
}

bool CheckPositionLimits(bool isBuy, const PositionState &ps, string &reason)
{
   int maxTotal = MaxTotalPositions;
   int maxNet = MaxNetPositions;
   double balance = AccountInfoDouble(ACCOUNT_BALANCE);

   if(UseBalanceBasedPositionLimit)
   {
      if(balance < BalanceTier2)
      {
         maxTotal = MathMin(MaxTotalPositions, Tier1MaxTotalPositions);
         maxNet = MathMin(MaxNetPositions, Tier1MaxNetPositions);
      }
      else if(balance < BalanceTier3)
      {
         maxTotal = MathMin(MaxTotalPositions, Tier2MaxTotalPositions);
         maxNet = MathMin(MaxNetPositions, Tier2MaxNetPositions);
      }
      else
      {
         maxTotal = MathMin(MaxTotalPositions, Tier3MaxTotalPositions);
         maxNet = MathMin(MaxNetPositions, Tier3MaxNetPositions);
      }
   }

   if(ps.total >= maxTotal)
   {
      reason = "max total positions";
      return false;
   }
   if(isBuy && ps.buys >= MaxBuyPositions)
   {
      reason = "max buy positions";
      return false;
   }
   if(!isBuy && ps.sells >= MaxSellPositions)
   {
      reason = "max sell positions";
      return false;
   }
   if(MathAbs(ps.net + (isBuy ? 1 : -1)) > maxNet)
   {
      reason = "max net positions";
      return false;
   }

   return true;
}

bool TryOpen(bool isBuy, double lot, string comment)
{
   double normalizedLot = NormalizeLot(lot);
   if(normalizedLot <= 0.0)
      return false;

   if(IsMarketClosedRetryActive())
   {
      lastStopReason = "market closed retry cooldown";
      LogMarketClosedRetryBlock(comment, isBuy ? "BUY" : "SELL", normalizedLot);
      return false;
   }

   bool ok = isBuy ? trade.Buy(normalizedLot, _Symbol, 0.0, 0.0, 0.0, comment)
                   : trade.Sell(normalizedLot, _Symbol, 0.0, 0.0, 0.0, comment);

   uint retcode = trade.ResultRetcode();
   string eventType = TradeEventTypeFromOpenComment(isBuy, comment);
   if(!ok || (retcode != TRADE_RETCODE_DONE && retcode != TRADE_RETCODE_PLACED))
   {
      if(UseEntryOpportunityAudit)
      {
         ResetAuditDailyIfNeeded();
         auditOrderSendFailedCount++;
         auditDailyOrderSendFailedCount++;
      }
      Print(EA_NAME, ": trade failed retcode=", retcode, " ", trade.ResultRetcodeDescription());
      HandleTradeRetcode(retcode);
      string failType = ok ? "ORDER_RETCODE_ERROR" : "ORDER_FAILED";
      if(ShouldLogTradeRetcodeEvent(retcode))
         WriteTradeEventLog(failType,
                            trade.ResultOrder(),
                            retcode,
                            trade.ResultRetcodeDescription(),
                            comment,
                            isBuy ? "BUY" : "SELL",
                            normalizedLot,
                            0.0,
                            0.0,
                            0.0,
                            0.0,
                            0.0,
                            tradeEventContextReady ? tradeEventPosition.floatingProfit : 0.0);
      return false;
   }

   lastEntryTime = TimeCurrent();
   lastTradeActionTime = TimeCurrent();
   lastEntryDirection = isBuy ? 1 : -1;
   InvalidateSameTickPositionCache();
   if(UseEntryOpportunityAudit)
   {
      ResetAuditDailyIfNeeded();
      auditActualOrderSendCount++;
      auditDailyActualOrderSendCount++;
   }
   WriteTradeEventLog(eventType,
                      trade.ResultOrder(),
                      retcode,
                      trade.ResultRetcodeDescription(),
                      comment,
                      isBuy ? "BUY" : "SELL",
                      normalizedLot,
                      trade.ResultPrice(),
                      0.0,
                      0.0,
                      0.0,
                      0.0,
                      tradeEventContextReady ? tradeEventPosition.floatingProfit : 0.0);
   return true;
}

void HandleTradeRetcode(uint retcode)
{
   if(IsMarketClosedRetcode(retcode))
   {
      lastMarketClosedErrorTime = TimeCurrent();
      marketClosedRetryUntil = TimeCurrent() + MarketClosedRetryCooldownSeconds;
      lastStopReason = "market closed retry cooldown";
   }
}

bool IsMarketClosedRetcode(uint retcode)
{
   return (retcode == TRADE_RETCODE_MARKET_CLOSED ||
           retcode == TRADE_RETCODE_TRADE_DISABLED ||
           retcode == TRADE_RETCODE_SERVER_DISABLES_AT ||
           retcode == TRADE_RETCODE_CLIENT_DISABLES_AT ||
           retcode == TRADE_RETCODE_PRICE_OFF ||
           retcode == TRADE_RETCODE_TIMEOUT ||
           retcode == 10018);
}

bool IsMarketClosedRetryActive()
{
   if(lastMarketClosedErrorTime <= 0)
      return false;
   if(TimeCurrent() - lastMarketClosedErrorTime < MarketClosedRetryCooldownSeconds)
      return true;
   return TimeCurrent() < marketClosedRetryUntil;
}

bool ShouldLogTradeRetcodeEvent(uint retcode)
{
   if(!IsMarketClosedRetcode(retcode))
      return true;
   if(lastMarketClosedEventLogTime > 0 && TimeCurrent() - lastMarketClosedEventLogTime < 60)
      return false;
   lastMarketClosedEventLogTime = TimeCurrent();
   return true;
}

void LogMarketClosedRetryBlock(string comment, string direction, double lot)
{
   if(lastMarketClosedEventLogTime > 0 && TimeCurrent() - lastMarketClosedEventLogTime < 60)
      return;
   lastMarketClosedEventLogTime = TimeCurrent();
   WriteTradeEventLog("MARKET_CLOSED_RETRY_BLOCK",
                      0,
                      TRADE_RETCODE_MARKET_CLOSED,
                      "market closed retry cooldown",
                      comment,
                      direction,
                      lot,
                      0.0,
                      0.0,
                      0.0,
                      0.0,
                      0.0,
                      tradeEventContextReady ? tradeEventPosition.floatingProfit : 0.0);
}

string CollectEaPositionTickets()
{
   string tickets = "";
   for(int i = 0; i < PerfPositionsTotal(); i++)
   {
      ulong ticket = PositionGetTicket(i);
      if(ticket == 0 || !PositionSelectByTicket(ticket) || !IsEaPosition())
         continue;
      if(tickets != "")
         tickets += "|";
      tickets += IntegerToString((long)ticket);
   }
   return tickets;
}

bool ShouldGlobalRetryCloseReason(string reason)
{
   string r = reason;
   StringToLower(r);

   if(StringFind(r, "hard stop") >= 0 || StringFind(r, "hardstop") >= 0)
      return RetryHardStopClose;
   if(StringFind(r, "basket recovery losscut") >= 0 || StringFind(r, "recovery losscut") >= 0 ||
      StringFind(r, "recovery losscut close") >= 0)
      return RetryBasketRecoveryLossCutClose;
   if(StringFind(r, "basket recovery close") >= 0)
      return RetryBasketRecoveryClose;
   if(StringFind(r, "hedged basket") >= 0 || StringFind(r, "time exit") >= 0 ||
      StringFind(r, "loss compression") >= 0)
      return RetryHedgedBasketTimeExitClose;
   if(StringFind(r, "defense hedge") >= 0 || StringFind(r, "post hedge") >= 0 ||
      StringFind(r, "reactive hedge") >= 0)
      return RetryDefenseHedgeExitClose;
   if(StringFind(r, "force") >= 0 || StringFind(r, "manual") >= 0 ||
      StringFind(r, "structure based early exit") >= 0)
      return RetryManualForceClose;
   if(StringFind(r, "basket close") >= 0)
      return RetryBasketClose;

   return RetryManualForceClose;
}

void ClearGlobalCloseIntent()
{
   globalCloseIntentPending = false;
   globalCloseIntentTimedOut = false;
   globalCloseIntentReason = "";
   globalCloseIntentTargetTickets = "";
   globalCloseIntentExpectedAction = "";
   globalCloseIntentFirstTime = 0;
   globalCloseIntentLastRetryTime = 0;
   globalCloseIntentOriginalRetcode = 0;
   globalCloseIntentOriginalRetcodeDescription = "";
   globalCloseIntentRetryCount = 0;
}

void StartGlobalCloseIntent(string reason,
                            uint failedRetcode,
                            string failedRetcodeDescription,
                            const PositionState &ps)
{
   if(!UseGlobalMarketClosedRetry || !ShouldGlobalRetryCloseReason(reason))
      return;
   if(globalCloseIntentPending)
      return;

   globalCloseIntentPending = true;
   globalCloseIntentTimedOut = false;
   globalCloseIntentReason = reason;
   globalCloseIntentFirstTime = TimeCurrent();
   globalCloseIntentLastRetryTime = 0;
   globalCloseIntentOriginalRetcode = failedRetcode;
   globalCloseIntentOriginalRetcodeDescription = failedRetcodeDescription;
   globalCloseIntentRetryCount = 0;
   globalCloseIntentTargetTickets = CollectEaPositionTickets();
   globalCloseIntentExpectedAction = "CLOSE";
   globalCloseRetryPendingCount++;

   WriteTradeEventLog("GLOBAL_CLOSE_RETRY_PENDING",
                      0,
                      failedRetcode,
                      failedRetcodeDescription,
                      reason + "|TargetTickets=" + globalCloseIntentTargetTickets,
                      "CLOSE",
                      0.0,
                      0.0,
                      0.0,
                      0.0,
                      0.0,
                      0.0,
                      ps.floatingProfit);
}

bool ExecuteGlobalCloseIntent(const PositionState &ps, string &action, string &reason)
{
   if(!UseGlobalMarketClosedRetry || !globalCloseIntentPending)
      return false;

   if(ps.total <= 0)
   {
      globalCloseRetrySuccessCount++;
      WriteTradeEventLog("GLOBAL_CLOSE_RETRY_SUCCESS",
                         0,
                         0,
                         "",
                         globalCloseIntentReason + "|RetryCount=" + IntegerToString(globalCloseIntentRetryCount) +
                         "|MinutesSinceFirstIntent=" + DoubleToString((TimeCurrent() - globalCloseIntentFirstTime) / 60.0, 1),
                         "CLOSE",
                         0.0,
                         0.0,
                         0.0,
                         0.0,
                         0.0,
                         ps.floatingProfit,
                         ps.floatingProfit);
      ClearGlobalCloseIntent();
      action = "global close retry success";
      reason = "global close retry success";
      return true;
   }

   int maxRetryMinutes = MathMax(1, GlobalMarketClosedMaxRetryMinutes);
   if(TimeCurrent() - globalCloseIntentFirstTime > maxRetryMinutes * 60)
   {
      if(!globalCloseIntentTimedOut)
      {
         globalCloseIntentTimedOut = true;
         globalCloseRetryTimeoutCount++;
         WriteTradeEventLog("GLOBAL_CLOSE_RETRY_TIMEOUT",
                            0,
                            globalCloseIntentOriginalRetcode,
                            globalCloseIntentOriginalRetcodeDescription,
                            globalCloseIntentReason + "|RetryCount=" + IntegerToString(globalCloseIntentRetryCount) +
                            "|PositionCountRemaining=" + IntegerToString(ps.total),
                            "CLOSE",
                            0.0,
                            0.0,
                            0.0,
                            0.0,
                            0.0,
                            0.0,
                            ps.floatingProfit);
      }
      action = "global close retry timeout";
      reason = globalCloseIntentReason;
      return true;
   }

   int retrySeconds = MathMax(1, GlobalMarketClosedRetrySeconds);
   if(globalCloseIntentLastRetryTime > 0 && TimeCurrent() - globalCloseIntentLastRetryTime < retrySeconds)
   {
      action = "global close retry pending";
      reason = globalCloseIntentReason;
      return true;
   }

   globalCloseIntentLastRetryTime = TimeCurrent();
   globalCloseIntentRetryCount++;
   globalCloseRetryAttemptCount++;

   WriteTradeEventLog("GLOBAL_CLOSE_RETRY_ATTEMPT",
                      0,
                      globalCloseIntentOriginalRetcode,
                      globalCloseIntentOriginalRetcodeDescription,
                      globalCloseIntentReason + "|RetryCount=" + IntegerToString(globalCloseIntentRetryCount) +
                      "|TargetTickets=" + globalCloseIntentTargetTickets,
                      "CLOSE",
                      0.0,
                      0.0,
                      0.0,
                      0.0,
                      0.0,
                      0.0,
                      ps.floatingProfit);

   globalCloseRetryInProgress = true;
   bool closeAttempt = CloseAllEaPositions(globalCloseIntentReason);
   globalCloseRetryInProgress = false;

   PositionState afterClose;
   GetPositionState(afterClose);
   if(afterClose.total <= 0)
   {
      globalCloseRetrySuccessCount++;
      WriteTradeEventLog("GLOBAL_CLOSE_RETRY_SUCCESS",
                         0,
                         trade.ResultRetcode(),
                         trade.ResultRetcodeDescription(),
                         globalCloseIntentReason + "|RetryCount=" + IntegerToString(globalCloseIntentRetryCount) +
                         "|MinutesSinceFirstIntent=" + DoubleToString((TimeCurrent() - globalCloseIntentFirstTime) / 60.0, 1),
                         "CLOSE",
                         0.0,
                         0.0,
                         0.0,
                         0.0,
                         0.0,
                         afterClose.floatingProfit,
                         afterClose.floatingProfit);
      ClearGlobalCloseIntent();
      action = "global close retry success";
      reason = "global close retry success";
      return true;
   }

   action = closeAttempt ? "global close partial retry" : "global close retry pending";
   reason = globalCloseIntentReason;
   return true;
}

datetime EstimatedNextDailyMarketClose(datetime now)
{
   datetime day = DayStart(now);
   datetime closeTime = day + 60 * 60;
   if(now > closeTime)
      closeTime = day + 24 * 60 * 60 + 60 * 60;
   return closeTime;
}

bool IsMarketClosePreWindow(int &minutesToClose)
{
   minutesToClose = 999999;
   if(!UseMarketClosePreControl || MarketClosePreBlockMinutes <= 0)
      return false;

   datetime now = TimeCurrent();
   datetime closeTime = EstimatedNextDailyMarketClose(now);
   int secondsToClose = (int)(closeTime - now);
   minutesToClose = (int)MathFloor(secondsToClose / 60.0);
   if(secondsToClose < 0)
      return false;
   return (secondsToClose <= MarketClosePreBlockMinutes * 60);
}

bool IsMarketClosePreControlActive(const PositionState &ps, int &minutesToClose)
{
   if(!IsMarketClosePreWindow(minutesToClose))
      return false;
   return true;
}

string MarketClosePreBasketState(const PositionState &ps)
{
   int hedgePositions = CountDefenseHedges();
   if(ps.total <= 0)
      return "flat";
   if(hedgePositions > 0)
      return "hedged";
   if(ps.total == 1)
      return "single";
   return "multi";
}

void WriteMarketClosePreEvent(string eventType,
                              const PositionState &ps,
                              int minutesToClose,
                              string reason,
                              string direction = "",
                              uint retcode = 0,
                              string retcodeDescription = "")
{
   string comment = "MinutesToEstimatedClose=" + IntegerToString(minutesToClose) +
                    "|MarketClosePreBlockMinutes=" + IntegerToString(MarketClosePreBlockMinutes) +
                    "|BasketState=" + MarketClosePreBasketState(ps) +
                    "|Reason=" + reason;
   WriteTradeEventLog(eventType,
                      0,
                      retcode,
                      retcodeDescription,
                      comment,
                      direction,
                      0.0,
                      0.0,
                      0.0,
                      0.0,
                      0.0,
                      0.0,
                      ps.floatingProfit);
}

void LogMarketClosePreControlActive(const PositionState &ps, int minutesToClose)
{
   if(MarketClosePreOnlyWhenPositionsExist && ps.total <= 0)
      return;
   if(lastMarketClosePreControlActiveLogTime > 0 && TimeCurrent() - lastMarketClosePreControlActiveLogTime < 60)
      return;
   lastMarketClosePreControlActiveLogTime = TimeCurrent();
   marketClosePreControlActiveCount++;
   WriteMarketClosePreEvent("MARKET_CLOSE_PRE_CONTROL_ACTIVE", ps, minutesToClose, "market close pre-control window active");
}

bool IsMarketClosePreNewEntryBlocked(const PositionState &ps,
                                     bool isBuy,
                                     const ScoreState &score,
                                     string &action,
                                     string &reason)
{
   int minutesToClose = 0;
   if(!IsMarketClosePreWindow(minutesToClose) || !MarketClosePreBlockNewEntry)
      return false;

   if(MarketClosePreBlockNewBasketOnly && ps.total > 0)
      return false;

   reason = "MARKET_CLOSE_PRE blocked: new basket entry near estimated market close";
   if(lastMarketClosePreEntryBlockLogTime <= 0 || TimeCurrent() - lastMarketClosePreEntryBlockLogTime >= 60)
   {
      lastMarketClosePreEntryBlockLogTime = TimeCurrent();
      marketClosePreBlockNewEntryCount++;
      WriteMarketClosePreEvent("MARKET_CLOSE_PRE_BLOCK_NEW_ENTRY", ps, minutesToClose, reason, isBuy ? "BUY" : "SELL");
   }

   if(MarketClosePreLogOnlyMode)
      return false;
   return true;
}

double CurrentBasketCloseTargetYen()
{
   double balance = AccountInfoDouble(ACCOUNT_BALANCE);
   double fixedTarget = BasketProfitYen;

   if(UseBalanceBasedBasketProfit)
   {
      if(balance < BalanceTier2)
         fixedTarget = Tier1BasketProfitYen;
      else if(balance < BalanceTier3)
         fixedTarget = Tier2BasketProfitYen;
      else
         fixedTarget = Tier3BasketProfitYen;
   }

   double percentTarget = balance * BasketProfitBalancePercent / 100.0;
   double target = 0.0;
   if(fixedTarget > 0.0 && percentTarget > 0.0)
      target = UseBasketCloseByEitherCondition ? MathMin(fixedTarget, percentTarget) : MathMax(fixedTarget, percentTarget);
   else if(fixedTarget > 0.0)
      target = fixedTarget;
   else if(percentTarget > 0.0)
      target = percentTarget;

   if(target <= 0.0)
      return 0.0;

   if(UseBasketCloseHistoricalTimeAdaptive)
   {
      double multiplier = 1.0;
      if(currentHistoricalTimeHighRisk || currentHistoricalWeekdayHourBlock)
         multiplier = BasketCloseHighRiskMultiplier;
      else if(currentHistoricalTimeCaution)
         multiplier = BasketCloseCautionMultiplier;
      else if(currentHistoricalTimeQuiet)
         multiplier = BasketCloseQuietMultiplier;
      else
         multiplier = BasketCloseClearMultiplier;

      if(multiplier > 0.0)
         target *= multiplier;
   }

   return target;
}

bool MarketClosePreRecoveryLossCutEligible(const PositionState &ps, datetime firstHedgeTime)
{
   if(!UseBasketRecoveryLossCut || !CloseHedgedBasketWhenLossImproves)
      return false;
   if(BasketRecoveryAcceptLossYen <= 0.0 || firstHedgeTime <= 0 || TimeCurrent() <= firstHedgeTime)
      return false;

   bool lossCutMinHoldPassed = (!UseBasketRecoveryLossCutMinHold ||
                                BasketRecoveryLossCutMinHoldMinutes <= 0 ||
                                TimeCurrent() - firstHedgeTime >= BasketRecoveryLossCutMinHoldMinutes * 60);
   double referenceProfit = GetBasketRecoveryReferenceProfit();
   bool improvementReached = (!UseBasketRecoveryImprovementCheck ||
                              BasketRecoveryRequiredImprovementYen <= 0.0 ||
                              (basketRecoveryReferenceActive &&
                               ps.floatingProfit >= referenceProfit + BasketRecoveryRequiredImprovementYen));
   return (lossCutMinHoldPassed &&
           ps.floatingProfit >= -BasketRecoveryAcceptLossYen &&
           improvementReached);
}

bool CheckMarketClosePreCloseIntent(const PositionState &ps, string &action, string &reason)
{
   if(!UseMarketClosePreControl || !MarketClosePrePrioritizeExistingCloseIntent)
      return false;
   if(MarketClosePreOnlyWhenPositionsExist && ps.total <= 0)
      return false;

   int minutesToClose = 0;
   if(!IsMarketClosePreWindow(minutesToClose))
      return false;

   string eventType = "";
   string closeReason = "";
   bool closeIntent = false;

   double basketTarget = CurrentBasketCloseTargetYen();
   if(!closeIntent && UseBasketClose && ps.total >= BasketMinPositions && basketTarget > 0.0 &&
      ps.floatingProfit > 0.0 &&
      ps.floatingProfit < basketTarget &&
      basketTarget - ps.floatingProfit <= MarketClosePreBasketCloseNearYen)
   {
      eventType = "MARKET_CLOSE_PRE_BASKET_CLOSE_NEAR";
      closeReason = "Market close pre basket close near";
      marketClosePreBasketCloseNearCount++;
      closeIntent = true;
   }

   int hedgePositions = CountDefenseHedges();
   datetime firstHedgeTime = GetFirstDefenseHedgeTime();
   if(hedgePositions > 0 && firstHedgeTime > 0)
      UpdateBasketRecoveryReference(ps, firstHedgeTime, hedgePositions);

   if(!closeIntent && UseBasketRecoveryClose && ps.total >= 2 && hedgePositions > 0 &&
      BasketRecoveryProfitYen > 0.0 &&
      ps.floatingProfit < BasketRecoveryProfitYen &&
      BasketRecoveryProfitYen - ps.floatingProfit <= MarketClosePreRecoveryCloseNearYen)
   {
      eventType = "MARKET_CLOSE_PRE_RECOVERY_CLOSE_NEAR";
      closeReason = "Market close pre recovery close near";
      marketClosePreRecoveryCloseNearCount++;
      closeIntent = true;
   }

   if(!closeIntent && UseHedgedBasketTimeExit && ps.total >= 2 && hedgePositions > 0 &&
      firstHedgeTime > 0 && HedgedBasketMaxHoldMinutes > 0 && HedgedBasketTimeExitAcceptLossYen > 0.0 &&
      TimeCurrent() - firstHedgeTime >= HedgedBasketMaxHoldMinutes * 60 &&
      ps.floatingProfit < -HedgedBasketTimeExitAcceptLossYen &&
      ps.floatingProfit >= -(HedgedBasketTimeExitAcceptLossYen + MarketClosePreHteNearYen))
   {
      eventType = "MARKET_CLOSE_PRE_HTE_NEAR";
      closeReason = "Market close pre HTE near";
      marketClosePreHteNearCount++;
      closeIntent = true;
   }

   if(!closeIntent && MarketClosePreAllowLossCutOnlyIfAlreadyEligible && ps.total >= 2 && hedgePositions > 0 &&
      MarketClosePreRecoveryLossCutEligible(ps, firstHedgeTime))
   {
      eventType = "MARKET_CLOSE_PRE_EXISTING_LOSSCUT_ELIGIBLE";
      closeReason = "Basket recovery losscut close";
      marketClosePreExistingLossCutEligibleCount++;
      closeIntent = true;
   }

   if(!closeIntent)
      return false;

   if(lastMarketClosePreNearLogTime <= 0 || TimeCurrent() - lastMarketClosePreNearLogTime >= 60)
   {
      lastMarketClosePreNearLogTime = TimeCurrent();
      WriteMarketClosePreEvent(eventType, ps, minutesToClose, closeReason);
   }

   if(MarketClosePreLogOnlyMode)
      return false;

   marketClosePreCloseIntentSentCount++;
   WriteMarketClosePreEvent("MARKET_CLOSE_PRE_CLOSE_INTENT", ps, minutesToClose, closeReason);
   bool closed = CloseAllEaPositions(closeReason);
   if(closed)
   {
      marketClosePreCloseIntentSucceededCount++;
      WriteMarketClosePreEvent("MARKET_CLOSE_PRE_CLOSE_SUCCESS", ps, minutesToClose, closeReason);
      action = closeReason;
      reason = "market close pre close intent succeeded";
      return true;
   }

   marketClosePreCloseIntentFailedCount++;
   WriteMarketClosePreEvent("MARKET_CLOSE_PRE_CLOSE_FAILED", ps, minutesToClose, closeReason, "CLOSE", trade.ResultRetcode(), trade.ResultRetcodeDescription());
   action = "market close pre close failed";
   reason = "market close pre close intent failed";
   return false;
}

void UpdateOneTimePlannedAddDailyCounter()
{
   datetime today = DayStart(TimeCurrent());
   if(oneTimePlannedAddCountDay != today)
   {
      oneTimePlannedAddCountDay = today;
      oneTimePlannedAddCountToday = 0;
   }
}

int CountOneTimeSameLotPlannedAddPositions()
{
   int count = 0;
   for(int i = PerfPositionsTotal() - 1; i >= 0; i--)
   {
      ulong ticket = PositionGetTicket(i);
      if(ticket == 0 || !PositionSelectByTicket(ticket) || !IsEaPosition())
         continue;

      string comment = PositionGetString(POSITION_COMMENT);
      if(StringFind(comment, "one time planned add") >= 0)
         count++;
   }
   return count;
}

bool PlannedAddTrendStillValid(bool isBuy, const MaStructureState &ma)
{
   if(isBuy)
      return (StringFind(ma.trendDirection, "bullish") >= 0 || StringFind(ma.trendDirection, "BUY") >= 0 || ma.okBuy);
   return (StringFind(ma.trendDirection, "bearish") >= 0 || StringFind(ma.trendDirection, "SELL") >= 0 || ma.okSell);
}

bool PlannedAddMaStructureStillValid(bool isBuy, const MaStructureState &ma)
{
   if(isBuy)
   {
      if(StringFind(ma.trendDirection, "bearish") >= 0 || ma.fastSlopeState == "strong down" || ma.middleSlopeState == "strong down")
         return false;
      return ma.okBuy || StringFind(ma.trendDirection, "bullish") >= 0;
   }

   if(StringFind(ma.trendDirection, "bullish") >= 0 || ma.fastSlopeState == "strong up" || ma.middleSlopeState == "strong up")
      return false;
   return ma.okSell || StringFind(ma.trendDirection, "bearish") >= 0;
}

bool TryOneTimeSameLotPlannedAdd(const MqlTick &tick,
                                 const ScoreState &score,
                                 const PositionState &ps,
                                 const FilterState &dxy,
                                 const FilterState &vix,
                                 bool newsBlock,
                                 string newsReason,
                                 bool htfBuyBlock,
                                 bool htfSellBlock,
                                 bool goldBuyOk,
                                 bool goldSellOk,
                                 string goldBuyReason,
                                 string goldSellReason,
                                 const PullbackState &pullback,
                                 const MaStructureState &ma,
                                 double marginLevel,
                                 bool dailyStop,
                                 bool consecutiveStop,
                                 bool hardStop,
                                 string &action,
                                 string &reason)
{
   if(!UseOneTimeSameLotPlannedAdd)
      return false;
   if(hardStop || dailyStop || consecutiveStop)
      return false;
   if(AllowMartingale || !UseFixedLotOnly)
   {
      reason = "PLANNED_ADD blocked: fixed lot only";
      return false;
   }
   if(PlannedAddOnlySingleOriginalPosition && ps.total != 1)
      return false;
   if(PlannedAddOnlyBeforeDefenseHedge && CountDefenseHedges() > 0)
      return false;
   if(CountOneTimeSameLotPlannedAddPositions() >= MaxPlannedAddPerBasket)
      return false;
   if(BlockFurtherAddAfterPlannedAdd && CountAddPositions(true) + CountAddPositions(false) > 0)
      return false;

   UpdateOneTimePlannedAddDailyCounter();
   if(MaxPlannedAddPerDay >= 0 && oneTimePlannedAddCountToday >= MaxPlannedAddPerDay)
   {
      reason = "PLANNED_ADD blocked: daily limit";
      return false;
   }

   if(PlannedAddRequireDxyVixSafe && (dxy.stop || dxy.extreme || vix.caution || vix.stop || vix.extreme))
   {
      reason = "PLANNED_ADD blocked: DXY/VIX risk";
      return false;
   }

   if(PlannedAddBlockNearNews && newsBlock)
   {
      reason = "PLANNED_ADD blocked: " + newsReason;
      return false;
   }

   if(currentTechnicalDangerActive)
   {
      reason = "PLANNED_ADD blocked: technical danger";
      return false;
   }

   ulong originalTicket = 0;
   int positionType = -1;
   datetime openTime = 0;
   double originalLots = 0.0;
   double originalPrice = 0.0;
   double currentFloatingProfitYen = 0.0;
   if(!GetSingleEaPosition(originalTicket, positionType, openTime, originalLots, originalPrice, currentFloatingProfitYen))
      return false;

   bool isBuy = (positionType == POSITION_TYPE_BUY);
   if(isBuy && (ps.buys != 1 || ps.sells != 0))
      return false;
   if(!isBuy && (ps.sells != 1 || ps.buys != 0))
      return false;

   double floatingLossYen = currentFloatingProfitYen < 0.0 ? -currentFloatingProfitYen : 0.0;
   if(floatingLossYen < PlannedAddTriggerLossYen || floatingLossYen > PlannedAddMaxLossYen)
      return false;

   double sameDirectionScore = isBuy ? score.longScore : score.shortScore;
   double oppositeScore = isBuy ? score.shortScore : score.longScore;
   double scoreDiff = sameDirectionScore - oppositeScore;
   if(sameDirectionScore < PlannedAddSameDirectionTickScore || scoreDiff < PlannedAddMinScoreDiff)
      return false;

   if(PlannedAddRequireTrendStillValid && !PlannedAddTrendStillValid(isBuy, ma))
   {
      reason = "PLANNED_ADD blocked: trend no longer valid";
      return false;
   }

   if(PlannedAddRequireMaStructureStillValid && !PlannedAddMaStructureStillValid(isBuy, ma))
   {
      reason = "PLANNED_ADD blocked: MA structure no longer valid";
      return false;
   }

   string canEnterReason = "";
   bool finalAllowed = CanEnter(isBuy, tick, score, ps, dxy, vix, newsBlock, newsReason,
                                isBuy ? htfBuyBlock : htfSellBlock,
                                isBuy ? goldBuyOk : goldSellOk,
                                isBuy ? goldBuyReason : goldSellReason,
                                isBuy ? pullback.okBuy : pullback.okSell,
                                isBuy ? pullback.reasonBuy : pullback.reasonSell,
                                isBuy ? ma.okBuy : ma.okSell,
                                isBuy ? ma.reasonBuy : ma.reasonSell,
                                false, marginLevel, dailyStop, consecutiveStop, hardStop, canEnterReason);
   if(!finalAllowed)
   {
      reason = "PLANNED_ADD blocked: " + canEnterReason;
      return false;
   }

   double addLot = PlannedAddUseSameLotOnly ? originalLots : BaseLot;
   if(PlannedAddUseSameLotOnly && MathAbs(addLot - originalLots) > 0.0000001)
   {
      reason = "PLANNED_ADD blocked: same lot check failed";
      return false;
   }

   string openComment = isBuy ? "one time planned add buy" : "one time planned add sell";
   if(!TryOpen(isBuy, addLot, openComment))
   {
      reason = "PLANNED_ADD failed";
      return false;
   }

   oneTimeSameLotPlannedAddCount++;
   oneTimePlannedAddCountToday++;
   plannedAddPositionCount++;

   ulong addTicket = trade.ResultOrder();
   string detail = "OriginalTicket=" + IntegerToString((long)originalTicket) +
                   "|AddTicket=" + IntegerToString((long)addTicket) +
                   "|OriginalEntryPrice=" + DoubleToString(originalPrice, _Digits) +
                   "|FloatingLossYenAtAdd=" + DoubleToString(floatingLossYen, 2) +
                   "|BasketProfitBeforeAdd=" + DoubleToString(ps.floatingProfit, 2) +
                   "|TickScoreBuy=" + DoubleToString(score.longScore, 2) +
                   "|TickScoreSell=" + DoubleToString(score.shortScore, 2) +
                   "|TickScoreDifference=" + DoubleToString(scoreDiff, 2) +
                   "|TrendMainDirection=" + ma.trendDirection +
                   "|MaStructureState=" + ma.mode +
                   "|MaFastSlopeState=" + ma.fastSlopeState +
                   "|MaMiddleSlopeState=" + ma.middleSlopeState +
                   "|DxyState=" + dxy.state +
                   "|VixState=" + vix.state +
                   "|NewsBlockActive=" + (newsBlock ? "true" : "false");
   WriteTradeEventLog("ONE_TIME_SAME_LOT_PLANNED_ADD",
                      addTicket,
                      trade.ResultRetcode(),
                      trade.ResultRetcodeDescription(),
                      detail,
                      isBuy ? "BUY" : "SELL",
                      addLot,
                      trade.ResultPrice(),
                      0.0,
                      0.0,
                      0.0,
                      0.0,
                      ps.floatingProfit);

   action = isBuy ? "ONE TIME ADD BUY opened" : "ONE TIME ADD SELL opened";
   reason = "one time same lot planned add";
   return true;
}

bool TryAddPosition(const MqlTick &tick,
                    const ScoreState &score,
                    const PositionState &ps,
                    const FilterState &dxy,
                    const FilterState &vix,
                    bool newsBlock,
                    string newsReason,
                    bool htfBuyBlock,
                    bool htfSellBlock,
                    string htfState,
                    bool goldBuyOk,
                    bool goldSellOk,
                    string goldBuyReason,
                    string goldSellReason,
                    const PullbackState &pullback,
                    const MaStructureState &ma,
                    double marginLevel,
                    bool dailyStop,
                    bool consecutiveStop,
                    bool hardStop,
                    string &action,
                    string &reason)
{
   if(!UseAddPosition || vix.caution || vix.stop || vix.extreme || hardStop)
      return false;

   if(newsBlock && BlockAddPositionDuringNews)
   {
      blockedByNewsCount++;
      blockedAddPositionByNewsCount++;
      reason = "ADD blocked: " + newsReason;
      return false;
   }

   if(UseHistoricalTimeRiskFilter && BlockAddPositionInRiskHours &&
      (currentHistoricalTimeQuiet || currentHistoricalTimeHighRisk || currentHistoricalTimeCaution || currentHistoricalWeekdayHourBlock))
   {
      blockedByHistoricalTimeRiskCount++;
      blockedAddByHistoricalTimeRiskCount++;
      reason = "ADD blocked: " + currentHistoricalTimeRiskReason;
      return false;
   }

   if(AddPositionMustUseFixedLot && (AllowMartingale || !UseFixedLotOnly))
      return false;

   if(ps.buys > 0 && ps.sells == 0 && CountAddPositions(true) < MaxAddPositionsPerDirection)
   {
      if(StringFind(htfState, "bullish") < 0)
      {
         reason = "ADD blocked: trend pullback not confirmed";
         return false;
      }
      double adverse = ps.avgBuy - tick.bid;
      if(adverse >= AddPositionDistanceDollars && score.longScore >= AddPositionScoreThreshold &&
         score.longScore - score.shortScore >= MinimumScoreDifference)
      {
         string r = "";
         if(!CheckPlannedAddPositionGate(true, r))
         {
            reason = r;
            return false;
         }
         if(CanEnter(true, tick, score, ps, dxy, vix, newsBlock, newsReason, htfBuyBlock, goldBuyOk, goldBuyReason,
                     pullback.okBuy, pullback.reasonBuy, ma.okBuy, ma.reasonBuy, false,
                     marginLevel, dailyStop, consecutiveStop, hardStop, r))
         {
            if(TryOpen(true, BaseLot, UsePlannedAddPositionOnly ? "planned add buy" : "fixed add buy"))
            {
               if(UsePlannedAddPositionOnly)
                  plannedAddPositionCount++;
               action = "ADD BUY opened";
               reason = r;
               return true;
            }
         }
      }
   }

   if(ps.sells > 0 && ps.buys == 0 && CountAddPositions(false) < MaxAddPositionsPerDirection)
   {
      if(StringFind(htfState, "bearish") < 0)
      {
         reason = "ADD blocked: trend pullback not confirmed";
         return false;
      }
      double adverse = tick.ask - ps.avgSell;
      if(adverse >= AddPositionDistanceDollars && score.shortScore >= AddPositionScoreThreshold &&
         score.shortScore - score.longScore >= MinimumScoreDifference)
      {
         string r = "";
         if(!CheckPlannedAddPositionGate(false, r))
         {
            reason = r;
            return false;
         }
         if(CanEnter(false, tick, score, ps, dxy, vix, newsBlock, newsReason, htfSellBlock, goldSellOk, goldSellReason,
                     pullback.okSell, pullback.reasonSell, ma.okSell, ma.reasonSell, false,
                     marginLevel, dailyStop, consecutiveStop, hardStop, r))
         {
            if(TryOpen(false, BaseLot, UsePlannedAddPositionOnly ? "planned add sell" : "fixed add sell"))
            {
               if(UsePlannedAddPositionOnly)
                  plannedAddPositionCount++;
               action = "ADD SELL opened";
               reason = r;
               return true;
            }
         }
      }
   }

   return false;
}

bool TryDefenseHedge(const MqlTick &tick,
                     const ScoreState &score,
                     const PositionState &ps,
                     const FilterState &dxy,
                     const FilterState &vix,
                     bool newsBlock,
                     string newsReason,
                     bool htfBuyBlock,
                     bool htfSellBlock,
                     double marginLevel,
                     bool defenseMode,
                     bool hardStop,
                     string &action,
                     string &reason)
{
   lastDefenseHedgeAllowed = false;
   lastDefenseHedgeBlockReason = "HEDGE blocked: not evaluated";

   if(!UseDefenseHedge)
   {
      lastDefenseHedgeBlockReason = "HEDGE blocked: UseDefenseHedge false";
      reason = lastDefenseHedgeBlockReason;
      return false;
   }

   if(DefenseHedgeOnlyInDefenseMode && !defenseMode)
   {
      lastDefenseHedgeBlockReason = "HEDGE blocked: not in defense mode";
      reason = lastDefenseHedgeBlockReason;
      return false;
   }

   if(hardStop)
   {
      lastDefenseHedgeBlockReason = "HEDGE blocked: hard stop mode";
      reason = lastDefenseHedgeBlockReason;
      return false;
   }

   if(newsBlock && BlockDefenseHedgeDuringNews)
   {
      lastDefenseHedgeBlockReason = "HEDGE blocked: " + newsReason;
      reason = lastDefenseHedgeBlockReason;
      blockedByNewsCount++;
      blockedDefenseHedgeByNewsCount++;
      return false;
   }

   if(vix.stop || vix.extreme)
   {
      lastDefenseHedgeBlockReason = "HEDGE blocked: " + vix.reason;
      reason = lastDefenseHedgeBlockReason;
      return false;
   }

   if(CountDefenseHedges() >= MaxDefenseHedgePositions)
   {
      lastDefenseHedgeBlockReason = "HEDGE blocked: max hedge positions reached";
      reason = lastDefenseHedgeBlockReason;
      return false;
   }

   if(ps.total <= 0)
   {
      lastDefenseHedgeBlockReason = "HEDGE blocked: no EA position";
      reason = lastDefenseHedgeBlockReason;
      return false;
   }

   if(ps.floatingProfit >= 0.0)
   {
      lastDefenseHedgeBlockReason = "HEDGE blocked: basket not losing";
      reason = lastDefenseHedgeBlockReason;
      return false;
   }

   PullbackState defensePullback;
   CheckPullbackState(defensePullback, "neutral", true);

   if(ps.net > 0 && score.shortScore >= DefenseHedgeScoreThreshold)
   {
      lastDefenseHedgeAllowed = true;
      string goldReason = "";
      bool goldBuyOk = true;
      bool goldSellOk = true;
      string goldBuyReason = "";
      bool goldOk = true;
      GetGoldLocationCached(goldBuyOk, goldBuyReason, goldOk, goldReason);
      string r = "";
      if(CanEnter(false, tick, score, ps, dxy, vix, newsBlock, newsReason, false, goldOk, goldReason,
                  true, "defense hedge pullback bypass", true, "defense hedge MA bypass", true,
                  marginLevel, false, false, hardStop, r))
      {
         if(TryOpen(false, BaseLot, "defense hedge sell"))
         {
            StartPostHedgeNewEntryFreeze(ps, "post hedge freeze start: DEFENSE_HEDGE_SELL");
            PositionState diagPs;
            GetPositionState(diagPs);
            StartPostHedgeTimeExitPriorityDiagnostic(diagPs, "post hedge diagnostic start: DEFENSE_HEDGE_SELL");
            if(EnableMultilayerShadowLogging && MultilayerShadowLogLevel > 0)
               ObserveMultilayerHedgeTransitionShadow(ps, diagPs, false, BaseLot);
            action = "DEFENSE SELL opened";
            reason = r;
            lastDefenseHedgeBlockReason = "DEFENSE_HEDGE_SELL opened";
            return true;
         }
         lastDefenseHedgeBlockReason = "HEDGE SELL order failed";
         reason = lastDefenseHedgeBlockReason;
      }
      else
      {
         lastDefenseHedgeBlockReason = r;
         reason = r;
      }
   }
   else if(ps.net < 0 && score.longScore >= DefenseHedgeScoreThreshold)
   {
      lastDefenseHedgeAllowed = true;
      string goldReason = "";
      bool goldOk = true;
      bool goldSellOk = true;
      string goldSellReason = "";
      GetGoldLocationCached(goldOk, goldReason, goldSellOk, goldSellReason);
      string r = "";
      if(CanEnter(true, tick, score, ps, dxy, vix, newsBlock, newsReason, false, goldOk, goldReason,
                  true, "defense hedge pullback bypass", true, "defense hedge MA bypass", true,
                  marginLevel, false, false, hardStop, r))
      {
         if(TryOpen(true, BaseLot, "defense hedge buy"))
         {
            StartPostHedgeNewEntryFreeze(ps, "post hedge freeze start: DEFENSE_HEDGE_BUY");
            PositionState diagPs;
            GetPositionState(diagPs);
            StartPostHedgeTimeExitPriorityDiagnostic(diagPs, "post hedge diagnostic start: DEFENSE_HEDGE_BUY");
            if(EnableMultilayerShadowLogging && MultilayerShadowLogLevel > 0)
               ObserveMultilayerHedgeTransitionShadow(ps, diagPs, true, BaseLot);
            action = "DEFENSE BUY opened";
            reason = r;
            lastDefenseHedgeBlockReason = "DEFENSE_HEDGE_BUY opened";
            return true;
         }
         lastDefenseHedgeBlockReason = "HEDGE BUY order failed";
         reason = lastDefenseHedgeBlockReason;
      }
      else
      {
         lastDefenseHedgeBlockReason = r;
         reason = r;
      }
   }
   else
   {
      if(ps.net > 0)
         lastDefenseHedgeBlockReason = "HEDGE SELL blocked: ShortScore below DefenseHedgeScoreThreshold";
      else if(ps.net < 0)
         lastDefenseHedgeBlockReason = "HEDGE BUY blocked: LongScore below DefenseHedgeScoreThreshold";
      else
         lastDefenseHedgeBlockReason = "HEDGE blocked: no net exposure";
      reason = lastDefenseHedgeBlockReason;
   }

   return false;
}

int CountAddPositions(bool isBuy)
{
   int count = 0;
   for(int i = PerfPositionsTotal() - 1; i >= 0; i--)
   {
      ulong ticket = PositionGetTicket(i);
      if(ticket == 0 || !PositionSelectByTicket(ticket) || !IsEaPosition())
         continue;

      int type = (int)PositionGetInteger(POSITION_TYPE);
      if(isBuy && type != POSITION_TYPE_BUY)
         continue;
      if(!isBuy && type != POSITION_TYPE_SELL)
         continue;

      string comment = PositionGetString(POSITION_COMMENT);
      if(StringFind(comment, "fixed add") >= 0 || StringFind(comment, "planned add") >= 0)
         count++;
   }
   return count;
}

int CountDefenseHedges()
{
   int count = 0;
   for(int i = PerfPositionsTotal() - 1; i >= 0; i--)
   {
      ulong ticket = PositionGetTicket(i);
      if(ticket == 0 || !PositionSelectByTicket(ticket) || !IsEaPosition())
         continue;

      if(StringFind(PositionGetString(POSITION_COMMENT), "defense hedge") >= 0)
         count++;
   }
   return count;
}

datetime GetFirstDefenseHedgeTime()
{
   datetime firstTime = 0;
   for(int i = PerfPositionsTotal() - 1; i >= 0; i--)
   {
      ulong ticket = PositionGetTicket(i);
      if(ticket == 0 || !PositionSelectByTicket(ticket) || !IsEaPosition())
         continue;

      if(StringFind(PositionGetString(POSITION_COMMENT), "defense hedge") < 0)
         continue;

      datetime openTime = (datetime)PositionGetInteger(POSITION_TIME);
      if(openTime <= 0)
         continue;

      if(firstTime == 0 || openTime < firstTime)
         firstTime = openTime;
   }
   return firstTime;
}

void UpdateBasketRecoveryReference(const PositionState &ps, datetime firstHedgeTime, int hedgePositions)
{
   if(hedgePositions <= 0 || ps.total < 2 || firstHedgeTime <= 0)
   {
      basketRecoveryReferenceActive = false;
      basketRecoveryReferenceHedgeTime = 0;
      basketRecoveryInitialProfit = 0.0;
      basketRecoveryWorstProfit = 0.0;
      return;
   }

   if(!basketRecoveryReferenceActive || basketRecoveryReferenceHedgeTime != firstHedgeTime)
   {
      basketRecoveryReferenceActive = true;
      basketRecoveryReferenceHedgeTime = firstHedgeTime;
      basketRecoveryInitialProfit = ps.floatingProfit;
      basketRecoveryWorstProfit = ps.floatingProfit;
      return;
   }

   if(ps.floatingProfit < basketRecoveryWorstProfit)
      basketRecoveryWorstProfit = ps.floatingProfit;
}

double GetBasketRecoveryReferenceProfit()
{
   if(!basketRecoveryReferenceActive)
      return 0.0;
   return UseWorstBasketAfterHedgeAsReference ? basketRecoveryWorstProfit : basketRecoveryInitialProfit;
}

bool IsTradingTimeAllowed(string &reason)
{
   reason = "";
   if(!UseTradingTimeFilter)
      return true;

   MqlDateTime jst;
   TimeToStruct(TimeGMT() + 9 * 3600, jst);

   int minuteOfDay = jst.hour * 60 + jst.min;
   int start = TradingStartHourJST * 60;
   int end = TradingEndHourJST * 60;
   bool allowed = start <= end ? (minuteOfDay >= start && minuteOfDay < end) : (minuteOfDay >= start || minuteOfDay < end);

   if(!allowed)
   {
      reason = "outside trading time JST";
      return false;
   }
   if(AvoidEarlyMorningJST && jst.hour >= 3 && jst.hour < 7)
   {
      reason = "avoid early morning JST";
      return false;
   }
   if(AvoidLondonOpenFirstMinutes)
   {
      int london = LondonOpenHourJST * 60;
      if(minuteOfDay >= london && minuteOfDay < london + LondonOpenAvoidMinutes)
      {
         reason = "London open first minutes blocked";
         return false;
      }
   }
   if(AvoidNYOpenFirstMinutes)
   {
      int ny = NYOpenHourJST * 60;
      if(minuteOfDay >= ny && minuteOfDay < ny + NYOpenAvoidMinutes)
      {
         reason = "NY open first minutes blocked";
         return false;
      }
   }
   return true;
}

bool IsNoNewTradeCloseWindow(string &reason)
{
   reason = "";
   MqlDateTime jst;
   TimeToStruct(TimeGMT() + 9 * 3600, jst);

   int minuteOfDay = jst.hour * 60 + jst.min;

   if(UseGoldDailyCloseFilter)
   {
      int start = GoldDailyCloseStartHourJST * 60 + GoldDailyCloseStartMinuteJST;
      int finish = GoldDailyCloseEndHourJST * 60 + GoldDailyCloseEndMinuteJST;
      bool blocked = start <= finish ? (minuteOfDay >= start && minuteOfDay < finish) : (minuteOfDay >= start || minuteOfDay < finish);
      if(blocked)
      {
         reason = "GOLD daily close filter";
         return true;
      }
   }

   if(UseFridayLateStopJST && jst.day_of_week == 5)
   {
      int fridayStop = FridayLateStopHourJST * 60 + FridayLateStopMinuteJST;
      if(minuteOfDay >= fridayStop)
      {
         reason = "Friday late stop JST";
         return true;
      }
   }

   return false;
}

void GetPositionState(PositionState &ps)
{
   ps.total = 0;
   ps.buys = 0;
   ps.sells = 0;
   ps.net = 0;
   ps.floatingProfit = 0.0;
   ps.floatingLossPercent = 0.0;
   ps.avgBuy = 0.0;
   ps.avgSell = 0.0;

   double buyLots = 0.0;
   double sellLots = 0.0;
   double buyWeighted = 0.0;
   double sellWeighted = 0.0;

   for(int i = PerfPositionsTotal() - 1; i >= 0; i--)
   {
      ulong ticket = PositionGetTicket(i);
      if(ticket == 0 || !PositionSelectByTicket(ticket) || !IsEaPosition())
         continue;

      int type = (int)PositionGetInteger(POSITION_TYPE);
      double lot = PositionGetDouble(POSITION_VOLUME);
      double open = PositionGetDouble(POSITION_PRICE_OPEN);
      double profit = PositionGetDouble(POSITION_PROFIT) + PositionGetDouble(POSITION_SWAP);

      ps.total++;
      ps.floatingProfit += profit;

      if(type == POSITION_TYPE_BUY)
      {
         ps.buys++;
         buyLots += lot;
         buyWeighted += open * lot;
      }
      else if(type == POSITION_TYPE_SELL)
      {
         ps.sells++;
         sellLots += lot;
         sellWeighted += open * lot;
      }
   }

   ps.net = ps.buys - ps.sells;
   double balance = AccountInfoDouble(ACCOUNT_BALANCE);
   if(balance > 0.0 && ps.floatingProfit < 0.0)
      ps.floatingLossPercent = -ps.floatingProfit / balance * 100.0;

   if(buyLots > 0.0)
      ps.avgBuy = buyWeighted / buyLots;
   if(sellLots > 0.0)
      ps.avgSell = sellWeighted / sellLots;
}

bool IsEaPosition()
{
   return (PositionGetString(POSITION_SYMBOL) == _Symbol &&
           (ulong)PositionGetInteger(POSITION_MAGIC) == MagicNumber);
}

bool GetSingleEaPosition(ulong &ticket,
                         int &positionType,
                         datetime &openTime,
                         double &lots,
                         double &openPrice,
                         double &floatingProfit)
{
   ticket = 0;
   positionType = -1;
   openTime = 0;
   lots = 0.0;
   openPrice = 0.0;
   floatingProfit = 0.0;

   int count = 0;
   for(int i = PerfPositionsTotal() - 1; i >= 0; i--)
   {
      ulong t = PositionGetTicket(i);
      if(t == 0 || !PositionSelectByTicket(t) || !IsEaPosition())
         continue;

      count++;
      ticket = t;
      positionType = (int)PositionGetInteger(POSITION_TYPE);
      openTime = (datetime)PositionGetInteger(POSITION_TIME);
      lots = PositionGetDouble(POSITION_VOLUME);
      openPrice = PositionGetDouble(POSITION_PRICE_OPEN);
      floatingProfit = PositionGetDouble(POSITION_PROFIT) + PositionGetDouble(POSITION_SWAP);
   }

   return (count == 1 && ticket > 0);
}

bool TrendMainReversedForSingleExit(bool isBuyPosition, const MaStructureState &ma)
{
   if(isBuyPosition)
      return (StringFind(ma.trendDirection, "bearish") >= 0 || StringFind(ma.trendDirection, "SELL") >= 0);
   return (StringFind(ma.trendDirection, "bullish") >= 0 || StringFind(ma.trendDirection, "BUY") >= 0);
}

bool MaSlopeReversedForSingleExit(bool isBuyPosition, const MaStructureState &ma)
{
   if(isBuyPosition)
      return (ma.fastSlopeState == "strong down" && ma.middleSlopeState == "strong down");
   return (ma.fastSlopeState == "strong up" && ma.middleSlopeState == "strong up");
}

void UpdateSingleEarlyExitDailyCounter()
{
   datetime today = DayStart(TimeCurrent());
   if(singleEarlyExitCountDay != today)
   {
      singleEarlyExitCountDay = today;
      singleEarlyExitCountToday = 0;
   }
}

bool CheckSingleEarlyExitM5Confirmation(bool isBuyPosition, int bars, string &reason)
{
   if(bars < 1)
      bars = 1;

   MqlRates rates[];
   ArraySetAsSeries(rates, true);
   int copied = CopyRates(_Symbol, PERIOD_M5, 1, bars, rates);
   if(copied < bars)
   {
      reason = "single early exit blocked: M5 confirmation data unavailable";
      return false;
   }

   for(int i = 0; i < bars; i++)
   {
      double body = rates[i].close - rates[i].open;
      if(isBuyPosition)
      {
         if(body >= 0.0)
         {
            reason = "single early exit blocked: M5 bearish confirmation failed";
            return false;
         }
      }
      else
      {
         if(body <= 0.0)
         {
            reason = "single early exit blocked: M5 bullish confirmation failed";
            return false;
         }
      }
   }

   reason = "M5 confirmation passed";
   return true;
}

bool IsSingleEarlyExitPostCooldownBlocked(bool isBuy, string &reason)
{
   if(!UseSingleEarlyExitPostCooldown || singleEarlyExitPostCooldownUntil <= TimeCurrent())
      return false;

   int direction = isBuy ? 1 : -1;
   bool block = false;
   if(BlockAllNewEntryAfterSingleEarlyExit)
      block = true;
   else if(BlockSameDirectionReentryAfterSingleEarlyExit && lastSingleEarlyExitDirection == direction)
      block = true;

   if(!block)
      return false;

   singleEarlyExitPostCooldownBlockCount++;
   if(BlockSameDirectionReentryAfterSingleEarlyExit && lastSingleEarlyExitDirection == direction)
      sameDirectionReentryBlockedAfterSingleEarlyExitCount++;

   int remaining = (int)MathMax(0, singleEarlyExitPostCooldownUntil - TimeCurrent());
   reason = "single early exit post cooldown";

   if(lastSingleEarlyExitPostCooldownBlockLogTime == 0 || TimeCurrent() - lastSingleEarlyExitPostCooldownBlockLogTime >= 60)
   {
      lastSingleEarlyExitPostCooldownBlockLogTime = TimeCurrent();
      lastSingleEarlyExitPostCooldownActive = true;
      lastSingleEarlyExitPostCooldownUntil = singleEarlyExitPostCooldownUntil;
      WriteTradeEventLog("SINGLE_EARLY_EXIT_POST_COOLDOWN_BLOCK",
                         0,
                         0,
                         "",
                         "single early exit post cooldown block",
                         isBuy ? "BUY" : "SELL",
                         0.0,
                         0.0,
                         0.0,
                         0.0,
                         0.0,
                         0.0,
                         tradeEventContextReady ? tradeEventPosition.floatingProfit : 0.0);
      lastStopReason = "single early exit post cooldown remaining " + IntegerToString(remaining);
   }

   return true;
}

string LargeCandleDirectionM5()
{
   double open = iOpen(_Symbol, PERIOD_M5, 1);
   double close = iClose(_Symbol, PERIOD_M5, 1);
   if(open <= 0.0 || close <= 0.0)
      return "UNKNOWN";
   if(close > open)
      return "BUY";
   if(close < open)
      return "SELL";
   return "UNKNOWN";
}

int SecondsAfterLastM5Close()
{
   datetime barOpen = iTime(_Symbol, PERIOD_M5, 1);
   if(barOpen <= 0)
      return 999999;
   int periodSeconds = PeriodSeconds(PERIOD_M5);
   if(periodSeconds <= 0)
      periodSeconds = 300;
   datetime closeTime = barOpen + periodSeconds;
   int seconds = (int)(TimeCurrent() - closeTime);
   if(seconds < 0)
      seconds = 0;
   return seconds;
}

bool TrendWeakOrMixedForHardStopOrigin(const MaStructureState &ma)
{
   string trend = ma.trendDirection;
   if(trend == "" || trend == "none" || trend == "neutral" || trend == "disabled")
      return true;
   if(StringFind(trend, "mixed") >= 0 || StringFind(trend, "weak") >= 0 || StringFind(trend, "range") >= 0)
      return true;
   if(StringFind(trend, "strong bullish") >= 0 || StringFind(trend, "strong bearish") >= 0)
      return false;
   return true;
}

bool IsHardStopOriginEntryBlocked(bool isBuy,
                                  const ScoreState &score,
                                  const PositionState &ps,
                                  const PullbackState &pullback,
                                  const MaStructureState &ma,
                                  double threshold,
                                  string &reason)
{
   lastHardStopOriginBlockReason = "";
   lastHardStopOriginLargeCandleDirection = "";
   lastHardStopOriginEntryDirection = isBuy ? "BUY" : "SELL";
   lastHardStopOriginSecondsAfterLargeCandle = 0;
   lastHardStopOriginHasPullbackConfirmation = false;
   lastHardStopOriginHasStructureConfirmation = false;
   lastHardStopOriginEntryScore = isBuy ? score.longScore : score.shortScore;
   lastHardStopOriginEntryScoreThreshold = threshold;
   lastHardStopOriginEntryScoreBuffer = lastHardStopOriginEntryScore - threshold;

   if(!UseHardStopOriginEntryBlock || !BlockPureTickEntryAfterLargeCandleChase)
      return false;
   if(LargeCandleChaseOnlyInitialEntry && ps.total > 0)
      return false;
   if(LargeCandleChaseRequireSinglePositionFlat && ps.total != 0)
      return false;
   if(!AllowPureTickEntry)
      return false;
   if(!currentStructureGate.largeCandleDetected)
      return false;

   string largeDirection = LargeCandleDirectionM5();
   int secondsAfterLargeCandle = SecondsAfterLastM5Close();
   lastHardStopOriginLargeCandleDirection = largeDirection;
   lastHardStopOriginSecondsAfterLargeCandle = secondsAfterLargeCandle;

   if(secondsAfterLargeCandle > LargeCandleChaseBlockSeconds)
      return false;
   if((isBuy && largeDirection != "BUY") || (!isBuy && largeDirection != "SELL"))
      return false;

   bool hasPullbackConfirmation = (isBuy ? pullback.okBuy : pullback.okSell) && ma.priceNearMaPullback;
   bool hasStructureConfirmation = isBuy ? currentStructureGate.structurePermissionBuy : currentStructureGate.structurePermissionSell;
   lastHardStopOriginHasPullbackConfirmation = hasPullbackConfirmation;
   lastHardStopOriginHasStructureConfirmation = hasStructureConfirmation;

   if(LargeCandleChaseRequireNoPullback && hasPullbackConfirmation)
      return false;
   if(LargeCandleChaseRequireNoStructureConfirmation && hasStructureConfirmation && UseStructureBeforeTickEntry)
      return false;
   if(LargeCandleChaseBlockOnlyWhenTrendWeakOrMixed && !TrendWeakOrMixedForHardStopOrigin(ma))
      return false;
   if(lastHardStopOriginEntryScoreBuffer > LargeCandleChaseMinEntryScoreBuffer)
      return false;

   hardStopOriginEntryBlockCount++;
   reason = "HardStop origin entry block: large candle chase pure tick";
   lastHardStopOriginBlockReason = reason;

   if(lastHardStopOriginBlockLogTime == 0 || TimeCurrent() - lastHardStopOriginBlockLogTime >= 60)
   {
      lastHardStopOriginBlockLogTime = TimeCurrent();
      WriteTradeEventLog("HARDSTOP_ORIGIN_ENTRY_BLOCK",
                         0,
                         0,
                         "",
                         reason,
                         isBuy ? "BUY" : "SELL",
                         0.0,
                         0.0,
                         0.0,
                         0.0,
                         0.0,
                         0.0,
                         tradeEventContextReady ? tradeEventPosition.floatingProfit : 0.0);
   }

   return true;
}

void UpdateReactiveHedgeDailyCounter()
{
   datetime today = DayStart(TimeCurrent());
   if(reactiveHedgeCountDay != today)
   {
      reactiveHedgeCountDay = today;
      reactiveHedgeCountToday = 0;
   }
}

int CountReactiveDefenseHedges()
{
   int count = 0;
   for(int i = PerfPositionsTotal() - 1; i >= 0; i--)
   {
      ulong ticket = PositionGetTicket(i);
      if(ticket == 0 || !PositionSelectByTicket(ticket) || !IsEaPosition())
         continue;

      if(StringFind(PositionGetString(POSITION_COMMENT), "reactive defense hedge") >= 0)
         count++;
   }
   return count;
}

datetime GetFirstReactiveDefenseHedgeTime()
{
   datetime firstTime = 0;
   for(int i = PerfPositionsTotal() - 1; i >= 0; i--)
   {
      ulong ticket = PositionGetTicket(i);
      if(ticket == 0 || !PositionSelectByTicket(ticket) || !IsEaPosition())
         continue;

      if(StringFind(PositionGetString(POSITION_COMMENT), "reactive defense hedge") < 0)
         continue;

      datetime openTime = (datetime)PositionGetInteger(POSITION_TIME);
      if(openTime <= 0)
         continue;
      if(firstTime == 0 || openTime < firstTime)
         firstTime = openTime;
   }
   return firstTime;
}

bool CheckReactiveHedgeExit(const PositionState &ps, string &action, string &reason)
{
   if(CountReactiveDefenseHedges() <= 0 || ps.total < 2)
      return false;

   datetime firstTime = GetFirstReactiveDefenseHedgeTime();
   bool closeNow = false;
   string closeReason = "";
   if(ps.floatingProfit >= ReactiveHedgeBasketCloseTargetYen)
   {
      closeNow = true;
      closeReason = "Reactive hedge basket close";
      reactiveHedgeBasketCloseCount++;
   }
   else if(ps.floatingProfit <= ReactiveHedgeBasketMaxLossYen)
   {
      closeNow = true;
      closeReason = "Reactive hedge max loss close";
      reactiveHedgeMaxLossCloseCount++;
   }
   else if(ReactiveHedgeCloseAllAtMaxHold && firstTime > 0 && TimeCurrent() - firstTime >= ReactiveHedgeMaxHoldMinutes * 60)
   {
      closeNow = true;
      closeReason = "Reactive hedge time close";
      reactiveHedgeTimeCloseCount++;
   }

   if(!closeNow)
      return false;

   lastReactiveHedgeCloseTime = TimeCurrent();
   lastReactiveHedgeCloseReason = closeReason;
   reactiveHedgeProfitTotal += ps.floatingProfit;
   if(CloseAllEaPositions(closeReason))
   {
      action = closeReason;
      reason = closeReason;
      return true;
   }
   return false;
}

bool TrySinglePositionReactiveDefenseHedge(const MqlTick &tick,
                                           const ScoreState &score,
                                           const PositionState &ps,
                                           const FilterState &dxy,
                                           const FilterState &vix,
                                           bool newsBlock,
                                           string newsReason,
                                           const MaStructureState &ma,
                                           double marginLevel,
                                           bool hardStop,
                                           string &action,
                                           string &reason)
{
   lastReactiveHedgeReason = "";
   lastReactiveHedgeCurrentFloatingProfitYen = 0.0;
   lastReactiveHedgeFloatingLossYen = 0.0;
   lastReactiveHedgeOppositeTickScore = 0.0;
   lastReactiveHedgeOppositeScoreDiff = 0.0;
   lastReactiveHedgeM5ConfirmationPassed = false;
   lastReactiveHedgeM5ConfirmationBars = 0;

   if(!UseSinglePositionReactiveDefenseHedge)
      return false;
   if(hardStop)
      return false;
   if(newsBlock && BlockDefenseHedgeDuringNews)
   {
      reason = "reactive hedge blocked: " + newsReason;
      return false;
   }
   if(vix.stop || vix.extreme)
   {
      reason = "reactive hedge blocked: " + vix.reason;
      return false;
   }
   if(ReactiveHedgeOnlySinglePosition && ps.total != 1)
      return false;
   if(ReactiveHedgeOnlyWhenNoHedge && CountDefenseHedges() > 0)
      return false;
   if(ps.total <= 0 || ps.buys == ps.sells || ps.floatingProfit >= 0.0)
      return false;

   UpdateReactiveHedgeDailyCounter();
   if(MaxReactiveDefenseHedgePerDay > 0 && reactiveHedgeCountToday >= MaxReactiveDefenseHedgePerDay)
   {
      reason = "reactive hedge blocked: max per day reached";
      return false;
   }
   if(MaxReactiveDefenseHedgePerSegment > 0 && reactiveHedgeCountSegment >= MaxReactiveDefenseHedgePerSegment)
   {
      reason = "reactive hedge blocked: max per segment reached";
      return false;
   }

   ulong ticket = 0;
   int positionType = -1;
   datetime openTime = 0;
   double lots = 0.0;
   double openPrice = 0.0;
   double currentFloatingProfitYen = 0.0;
   if(!GetSingleEaPosition(ticket, positionType, openTime, lots, openPrice, currentFloatingProfitYen))
      return false;

   double floatingLossYen = currentFloatingProfitYen < 0.0 ? -currentFloatingProfitYen : 0.0;
   if(floatingLossYen < ReactiveHedgeTriggerLossYen)
      return false;

   bool isBuyPosition = (positionType == POSITION_TYPE_BUY);
   double oppositeTickScore = isBuyPosition ? score.shortScore : score.longScore;
   double sameTickScore = isBuyPosition ? score.longScore : score.shortScore;
   double oppositeScoreDiff = oppositeTickScore - sameTickScore;
   bool tickReverse = (oppositeTickScore >= ReactiveHedgeOppositeTickScore &&
                       oppositeScoreDiff >= ReactiveHedgeOppositeScoreDiff);
   bool maReverse = MaSlopeReversedForSingleExit(isBuyPosition, ma);
   bool trendReverse = TrendMainReversedForSingleExit(isBuyPosition, ma);

   lastReactiveHedgeCurrentFloatingProfitYen = currentFloatingProfitYen;
   lastReactiveHedgeFloatingLossYen = floatingLossYen;
   lastReactiveHedgeOppositeTickScore = oppositeTickScore;
   lastReactiveHedgeOppositeScoreDiff = oppositeScoreDiff;

   if(!tickReverse)
      return false;
   if(ReactiveHedgeRequireMaSlopeReverse && !maReverse)
      return false;
   if(ReactiveHedgeRequireTrendMainReverse && !trendReverse)
      return false;

   if(ReactiveHedgeRequireM5CloseConfirmation)
   {
      string m5Reason = "";
      lastReactiveHedgeM5ConfirmationBars = ReactiveHedgeConfirmBars;
      if(!CheckSingleEarlyExitM5Confirmation(isBuyPosition, ReactiveHedgeConfirmBars, m5Reason))
      {
         reason = m5Reason;
         return false;
      }
      lastReactiveHedgeM5ConfirmationPassed = true;
   }

   bool hedgeBuy = !isBuyPosition;
   string goldReason = "";
   bool goldBuyOk = true;
   bool goldSellOk = true;
   string goldBuyReason = "";
   string goldSellReason = "";
   GetGoldLocationCached(goldBuyOk, goldBuyReason, goldSellOk, goldSellReason);
   bool goldOk = hedgeBuy ? goldBuyOk : goldSellOk;
   goldReason = hedgeBuy ? goldBuyReason : goldSellReason;
   string r = "";
   if(!CanEnter(hedgeBuy, tick, score, ps, dxy, vix, newsBlock, newsReason, false, goldOk, goldReason,
                true, "reactive hedge pullback bypass", true, "reactive hedge MA bypass", true,
                marginLevel, false, false, hardStop, r))
   {
      reason = r;
      lastReactiveHedgeReason = "reactive hedge CanEnter blocked: " + r;
      if(EffectiveReactiveHedgeTraceEnabled())
      {
         WriteTradeEventLog("REACTIVE_HEDGE_CANENTER_BLOCK",
                            0,
                            0,
                            "",
                            lastReactiveHedgeReason,
                            hedgeBuy ? "BUY" : "SELL",
                            BaseLot,
                            0.0,
                            0.0,
                            0.0,
                            0.0,
                            0.0,
                            tradeEventContextReady ? tradeEventPosition.floatingProfit : 0.0);
      }
      return false;
   }

   string hedgeReason = "single reactive defense hedge";
   lastReactiveHedgeReason = hedgeReason;
   if(TryOpen(hedgeBuy, BaseLot, hedgeBuy ? "reactive defense hedge buy" : "reactive defense hedge sell"))
   {
      singleReactiveDefenseHedgeCount++;
      reactiveHedgeCountToday++;
      reactiveHedgeCountSegment++;
      lastReactiveHedgeOpenTime = TimeCurrent();
      action = hedgeBuy ? "REACTIVE DEFENSE BUY opened" : "REACTIVE DEFENSE SELL opened";
      reason = hedgeReason;
      return true;
   }

   reason = "reactive hedge order failed";
   return false;
}

bool TrySinglePositionContraryEarlyExit(const ScoreState &score,
                                        const PositionState &ps,
                                        const MaStructureState &ma,
                                        const FilterState &vix,
                                        bool newsBlock,
                                        string &action,
                                        string &reason)
{
   lastSingleEarlyExitReason = "";
   lastSingleEarlyExitCurrentFloatingProfitYen = 0.0;
   lastSingleEarlyExitFloatingLossYen = 0.0;
   lastSingleEarlyExitOppositeTickScore = 0.0;
   lastSingleEarlyExitOppositeScoreDiff = 0.0;
   lastSingleEarlyExitPositionDirection = "";
   lastSingleEarlyExitHoldSeconds = 0;
   lastSingleEarlyExitMaReverse = false;
   lastSingleEarlyExitTrendReverse = false;
   lastSingleEarlyExitTickReverse = false;
   lastSingleEarlyExitM5ConfirmationPassed = false;
   lastSingleEarlyExitM5ConfirmationBars = 0;
   lastSingleEarlyExitVixCautionAdjustmentApplied = false;
   lastSingleEarlyExitEffectiveOppositeTickScoreThreshold = SingleEarlyExitOppositeTickScore;
   lastSingleEarlyExitEffectiveSoftLossYen = SingleEarlyExitSoftLossYen;
   lastSingleEarlyExitEffectiveHardLossYen = SingleEarlyExitHardLossYen;

   if(!UseSinglePositionContraryEarlyExit)
      return false;
   if(SingleEarlyExitBlockIfNewsActive && newsBlock)
   {
      reason = "single early exit blocked: news active";
      return false;
   }
   if(SingleEarlyExitOnlySinglePosition && ps.total != 1)
      return false;
   if(SingleEarlyExitOnlyWhenNoHedge && CountDefenseHedges() > 0)
      return false;
   if(ps.total <= 0 || ps.buys == ps.sells)
      return false;

   UpdateSingleEarlyExitDailyCounter();
   if(MaxSingleEarlyExitPerDay > 0 && singleEarlyExitCountToday >= MaxSingleEarlyExitPerDay)
   {
      maxSingleEarlyExitPerDayHitCount++;
      reason = "single early exit blocked: max per day reached";
      return false;
   }
   if(MaxSingleEarlyExitPerSegment > 0 && singleEarlyExitCountSegment >= MaxSingleEarlyExitPerSegment)
   {
      reason = "single early exit blocked: max per segment reached";
      return false;
   }

   ulong ticket = 0;
   int positionType = -1;
   datetime openTime = 0;
   double lots = 0.0;
   double openPrice = 0.0;
   double currentFloatingProfitYen = 0.0;
   if(!GetSingleEaPosition(ticket, positionType, openTime, lots, openPrice, currentFloatingProfitYen))
      return false;

   bool isBuyPosition = (positionType == POSITION_TYPE_BUY);
   int holdSeconds = (openTime > 0) ? (int)(TimeCurrent() - openTime) : 0;
   if(holdSeconds < SingleEarlyExitMinHoldSeconds)
   {
      reason = "single early exit blocked: min hold seconds";
      return false;
   }

   double floatingLossYen = 0.0;
   if(currentFloatingProfitYen < 0.0)
      floatingLossYen = -currentFloatingProfitYen;

   double effectiveSoftLossYen = SingleEarlyExitSoftLossYen;
   double effectiveHardLossYen = SingleEarlyExitHardLossYen;
   double effectiveOppositeTickScore = SingleEarlyExitOppositeTickScore;
   bool vixAdjustment = (SingleEarlyExitStricterWhenVixCaution && (vix.caution || vix.stop || vix.extreme));
   if(vixAdjustment)
   {
      effectiveSoftLossYen += SingleEarlyExitVixCautionLossAddYen;
      effectiveHardLossYen += SingleEarlyExitVixCautionLossAddYen;
      effectiveOppositeTickScore += SingleEarlyExitVixCautionScoreAdd;
   }

   lastSingleEarlyExitVixCautionAdjustmentApplied = vixAdjustment;
   lastSingleEarlyExitEffectiveOppositeTickScoreThreshold = effectiveOppositeTickScore;
   lastSingleEarlyExitEffectiveSoftLossYen = effectiveSoftLossYen;
   lastSingleEarlyExitEffectiveHardLossYen = effectiveHardLossYen;

   if(floatingLossYen < effectiveSoftLossYen)
      return false;

   double oppositeTickScore = isBuyPosition ? score.shortScore : score.longScore;
   double sameTickScore = isBuyPosition ? score.longScore : score.shortScore;
   double oppositeScoreDiff = oppositeTickScore - sameTickScore;
   bool tickReverse = (oppositeTickScore >= effectiveOppositeTickScore &&
                       oppositeScoreDiff >= SingleEarlyExitOppositeScoreDiff);
   bool maReverse = MaSlopeReversedForSingleExit(isBuyPosition, ma);
   bool trendReverse = TrendMainReversedForSingleExit(isBuyPosition, ma);
   bool hardLoss = (floatingLossYen >= effectiveHardLossYen);

   lastSingleEarlyExitCurrentFloatingProfitYen = currentFloatingProfitYen;
   lastSingleEarlyExitFloatingLossYen = floatingLossYen;
   lastSingleEarlyExitOppositeTickScore = oppositeTickScore;
   lastSingleEarlyExitOppositeScoreDiff = oppositeScoreDiff;
   lastSingleEarlyExitPositionDirection = isBuyPosition ? "BUY" : "SELL";
   lastSingleEarlyExitHoldSeconds = holdSeconds;
   lastSingleEarlyExitMaReverse = maReverse;
   lastSingleEarlyExitTrendReverse = trendReverse;
   lastSingleEarlyExitTickReverse = tickReverse;

   if(!tickReverse)
      return false;
   if(SingleEarlyExitRequireMaSlopeReverse && !maReverse)
      return false;
   if(!hardLoss && SingleEarlyExitRequireTrendMainReverse && !trendReverse)
      return false;
   if(hardLoss && SingleEarlyExitRequireHardTrendReverseToo && !trendReverse)
      return false;

   if(SingleEarlyExitRequireM5CloseConfirmation)
   {
      string m5Reason = "";
      lastSingleEarlyExitM5ConfirmationBars = SingleEarlyExitConfirmBars;
      if(!CheckSingleEarlyExitM5Confirmation(isBuyPosition, SingleEarlyExitConfirmBars, m5Reason))
      {
         m5ConfirmationFailedCount++;
         reason = m5Reason;
         return false;
      }
      m5ConfirmationPassedCount++;
      lastSingleEarlyExitM5ConfirmationPassed = true;
   }

   if(IsMarketClosedRetryActive())
   {
      reason = "market closed retry cooldown";
      LogMarketClosedRetryBlock("single contrary early exit", isBuyPosition ? "BUY_CLOSE" : "SELL_CLOSE", lots);
      return false;
   }

   string exitReason = hardLoss ? "single contrary early exit hard loss" : "single contrary early exit soft loss";
   lastSingleEarlyExitReason = exitReason;

   double closePrice = 0.0;
   MqlTick closeTick;
   if(SymbolInfoTick(_Symbol, closeTick))
      closePrice = isBuyPosition ? closeTick.bid : closeTick.ask;

   bool ok = trade.PositionClose(ticket);
   uint retcode = trade.ResultRetcode();
   if(ok)
   {
      singlePositionContraryEarlyExitCount++;
      singleEarlyExitCountToday++;
      singleEarlyExitCountSegment++;
      singlePositionContraryEarlyExitProfitTotal += currentFloatingProfitYen;
      lastSingleEarlyExitTime = TimeCurrent();
      lastSingleEarlyExitDirection = isBuyPosition ? 1 : -1;
      if(UseSingleEarlyExitPostCooldown)
      {
         singleEarlyExitPostCooldownUntil = TimeCurrent() + SingleEarlyExitPostCooldownMinutes * 60;
         lastSingleEarlyExitPostCooldownActive = true;
         lastSingleEarlyExitPostCooldownUntil = singleEarlyExitPostCooldownUntil;
      }
      lastTradeActionTime = TimeCurrent();
      InvalidateSameTickPositionCache();
      WriteTradeEventLog("SINGLE_CONTRARY_EARLY_EXIT",
                         ticket,
                         retcode,
                         trade.ResultRetcodeDescription(),
                         exitReason,
                         isBuyPosition ? "BUY_CLOSE" : "SELL_CLOSE",
                         lots,
                         openPrice,
                         0.0,
                         0.0,
                         closePrice,
                         currentFloatingProfitYen,
                         ps.floatingProfit);
      MarkEaClose(exitReason);
      action = "single contrary early exit";
      reason = exitReason;
      return true;
   }

   Print(EA_NAME, ": single contrary early exit close failed ticket=", ticket, " retcode=", retcode);
   HandleTradeRetcode(retcode);
   if(ShouldLogTradeRetcodeEvent(retcode))
      WriteTradeEventLog("ORDER_RETCODE_ERROR",
                         ticket,
                         retcode,
                         trade.ResultRetcodeDescription(),
                         exitReason,
                         isBuyPosition ? "BUY_CLOSE" : "SELL_CLOSE",
                         lots,
                         openPrice,
                         0.0,
                         0.0,
                         closePrice,
                         currentFloatingProfitYen,
                         ps.floatingProfit);
   return false;
}

bool CheckBasketClose(const PositionState &ps)
{
   if(ps.total < BasketMinPositions)
      return false;

   double balance = AccountInfoDouble(ACCOUNT_BALANCE);
   double fixedTarget = BasketProfitYen;

   if(UseBalanceBasedBasketProfit)
   {
      if(balance < BalanceTier2)
         fixedTarget = Tier1BasketProfitYen;
      else if(balance < BalanceTier3)
         fixedTarget = Tier2BasketProfitYen;
      else
         fixedTarget = Tier3BasketProfitYen;
   }

   double percentTarget = balance * BasketProfitBalancePercent / 100.0;
   double target = 0.0;

   if(fixedTarget > 0.0 && percentTarget > 0.0)
      target = UseBasketCloseByEitherCondition ? MathMin(fixedTarget, percentTarget) : MathMax(fixedTarget, percentTarget);
   else if(fixedTarget > 0.0)
      target = fixedTarget;
   else if(percentTarget > 0.0)
      target = percentTarget;

   if(target <= 0.0)
      return false;

   if(UseBasketCloseHistoricalTimeAdaptive)
   {
      double multiplier = 1.0;
      if(currentHistoricalTimeHighRisk || currentHistoricalWeekdayHourBlock)
         multiplier = BasketCloseHighRiskMultiplier;
      else if(currentHistoricalTimeCaution)
         multiplier = BasketCloseCautionMultiplier;
      else if(currentHistoricalTimeQuiet)
         multiplier = BasketCloseQuietMultiplier;
      else
         multiplier = BasketCloseClearMultiplier;

      if(multiplier > 0.0)
         target *= multiplier;
   }

   if(ps.floatingProfit >= target)
      return CloseAllEaPositions("basket close");

   return false;
}

void UpdatePostHedgeReference(const PositionState &ps, datetime firstHedgeTime, int hedgePositions)
{
   if(hedgePositions <= 0 || ps.total < 2 || firstHedgeTime <= 0)
   {
      postHedgeReferenceActive = false;
      postHedgeReferenceHedgeTime = 0;
      postHedgeInitialProfit = 0.0;
      postHedgeWorstProfit = 0.0;
      postHedgeImprovingAnchorHedgeTime = 0;
      postHedgeImprovingAnchorTime = 0;
      postHedgeImprovingAnchorProfit = 0.0;
      postHedgeCloseIntentPending = false;
      postHedgeCloseIntentReason = "";
      postHedgeCloseIntentFirstTime = 0;
      postHedgeCloseIntentLastRetryTime = 0;
      return;
   }

   if(!postHedgeReferenceActive || postHedgeReferenceHedgeTime != firstHedgeTime)
   {
      postHedgeReferenceActive = true;
      postHedgeReferenceHedgeTime = firstHedgeTime;
      postHedgeInitialProfit = ps.floatingProfit;
      postHedgeWorstProfit = ps.floatingProfit;
      postHedgeImprovingAnchorHedgeTime = firstHedgeTime;
      postHedgeImprovingAnchorTime = TimeCurrent();
      postHedgeImprovingAnchorProfit = ps.floatingProfit;
      postHedgeCloseIntentPending = false;
      postHedgeCloseIntentReason = "";
      postHedgeCloseIntentFirstTime = 0;
      postHedgeCloseIntentLastRetryTime = 0;
      return;
   }

   if(ps.floatingProfit < postHedgeWorstProfit)
      postHedgeWorstProfit = ps.floatingProfit;
}

string GetFirstDefenseHedgeDirection()
{
   datetime firstTime = 0;
   string direction = "";
   for(int i = PerfPositionsTotal() - 1; i >= 0; i--)
   {
      ulong ticket = PositionGetTicket(i);
      if(ticket == 0 || !PositionSelectByTicket(ticket) || !IsEaPosition())
         continue;
      string comment = PositionGetString(POSITION_COMMENT);
      if(StringFind(comment, "defense hedge") < 0)
         continue;
      datetime openTime = (datetime)PositionGetInteger(POSITION_TIME);
      if(openTime <= 0)
         continue;
      if(firstTime == 0 || openTime < firstTime)
      {
         firstTime = openTime;
         int type = (int)PositionGetInteger(POSITION_TYPE);
         direction = (type == POSITION_TYPE_BUY) ? "BUY" : "SELL";
      }
   }
   return direction;
}

bool IsPostHedgeAgainstStrongTrend(const MaStructureState &ma)
{
   string hedgeDirection = GetFirstDefenseHedgeDirection();
   if(hedgeDirection == "BUY")
   {
      bool bearishTrend = (StringFind(ma.trendDirection, "bearish") >= 0 || StringFind(ma.trendDirection, "SELL") >= 0);
      bool fallingMa = (ma.fastSlopeState == "strong down" || ma.middleSlopeState == "strong down");
      return (bearishTrend && fallingMa);
   }
   if(hedgeDirection == "SELL")
   {
      bool bullishTrend = (StringFind(ma.trendDirection, "bullish") >= 0 || StringFind(ma.trendDirection, "BUY") >= 0);
      bool risingMa = (ma.fastSlopeState == "strong up" || ma.middleSlopeState == "strong up");
      return (bullishTrend && risingMa);
   }
   return false;
}

bool IsPostHedgeSelectiveAgainstStrongTrend(const MaStructureState &ma, string &state)
{
   state = "not strong trend against hedge";
   string hedgeDirection = GetFirstDefenseHedgeDirection();
   string trend = ma.trendDirection;
   string structure = ma.mode;

   if(hedgeDirection == "BUY" && PostHedgeDetectBuyHedgeInStrongBearish)
   {
      bool bearishTrend = (StringFind(trend, "bearish") >= 0 || StringFind(trend, "SELL") >= 0);
      bool bearishStructure = (StringFind(structure, "bearish") >= 0 || StringFind(structure, "SELL") >= 0 || (structure == "enabled" && bearishTrend));
      bool strongDown = (ma.fastSlopeState == "strong down" && ma.middleSlopeState == "strong down");
      if(bearishTrend && bearishStructure && strongDown)
      {
         state = "BUY hedge in strong bearish";
         return true;
      }
   }

   if(hedgeDirection == "SELL" && PostHedgeDetectSellHedgeInStrongBullish)
   {
      bool bullishTrend = (StringFind(trend, "bullish") >= 0 || StringFind(trend, "BUY") >= 0);
      bool bullishStructure = (StringFind(structure, "bullish") >= 0 || StringFind(structure, "BUY") >= 0 || (structure == "enabled" && bullishTrend));
      bool strongUp = (ma.fastSlopeState == "strong up" && ma.middleSlopeState == "strong up");
      if(bullishTrend && bullishStructure && strongUp)
      {
         state = "SELL hedge in strong bullish";
         return true;
      }
   }

   return false;
}

void RefreshPostHedgeSelectiveLossDay()
{
   datetime today = DayStart(TimeCurrent());
   if(postHedgeSelectiveLossCloseDay != today)
   {
      postHedgeSelectiveLossCloseDay = today;
      postHedgeSelectiveLossCloseCountToday = 0;
   }
}

bool IsPostHedgeSelectiveLossLimitReached()
{
   RefreshPostHedgeSelectiveLossDay();
   if(MaxPostHedgeLossClosePerDay > 0 && postHedgeSelectiveLossCloseCountToday >= MaxPostHedgeLossClosePerDay)
      return true;
   if(MaxPostHedgeLossClosePerSegment > 0 && postHedgeSelectiveLossCloseCountSegment >= MaxPostHedgeLossClosePerSegment)
      return true;
   return false;
}

bool IsPostHedgeNearBasketRecovery(const PositionState &ps)
{
   if(!PostHedgeDoNotCloseIfNearBasketRecovery)
      return false;
   if(!UseBasketRecoveryClose)
      return false;
   double distance = BasketRecoveryProfitYen - ps.floatingProfit;
   return (distance >= 0.0 && distance <= PostHedgeNearRecoveryDistanceYen);
}

bool IsPostHedgeBasketImproving(const PositionState &ps, datetime firstHedgeTime)
{
   if(!PostHedgeDoNotCloseIfBasketImproving)
      return false;
   int lookbackSeconds = MathMax(1, PostHedgeImprovingLookbackMinutes) * 60;
   if(postHedgeImprovingAnchorHedgeTime != firstHedgeTime ||
      postHedgeImprovingAnchorTime <= 0 ||
      TimeCurrent() - postHedgeImprovingAnchorTime < lookbackSeconds)
      return false;

   double improvement = ps.floatingProfit - postHedgeImprovingAnchorProfit;
   bool improving = (improvement >= PostHedgeImprovingMinYen);
   postHedgeImprovingAnchorTime = TimeCurrent();
   postHedgeImprovingAnchorProfit = ps.floatingProfit;
   return improving;
}

bool CanPostHedgeSelectiveLossClose(const PositionState &ps, datetime firstHedgeTime, bool ignoreNearRecovery, string &guardReason)
{
   guardReason = "";
   if(IsPostHedgeSelectiveLossLimitReached())
   {
      guardReason = "selective loss close limit reached";
      return false;
   }
   if(!ignoreNearRecovery && IsPostHedgeNearBasketRecovery(ps))
   {
      guardReason = "near basket recovery";
      return false;
   }
   if(IsPostHedgeBasketImproving(ps, firstHedgeTime))
   {
      guardReason = "basket improving";
      return false;
   }
   return true;
}

bool SelectiveReasonIsLossClose(string reason)
{
   return (reason == "Post hedge selective max loss close" ||
           reason == "Post hedge selective no improvement close" ||
           reason == "Post hedge selective hard time close");
}

void CountPostHedgeCloseReason(string reason)
{
   if(reason == "Post hedge good enough close")
      postHedgeGoodEnoughCloseCount++;
   else if(reason == "Post hedge max loss close")
      postHedgeMaxLossCloseCount++;
   else if(reason == "Post hedge no improvement close")
      postHedgeNoImprovementCloseCount++;
   else if(reason == "Post hedge hard time close")
      postHedgeHardTimeCloseCount++;
   else if(reason == "Post hedge against strong trend close")
      postHedgeAgainstStrongTrendCloseCount++;
   else if(reason == "Post hedge selective good enough close")
      postHedgeSelectiveGoodEnoughCloseCount++;
   else if(reason == "Post hedge selective max loss close")
   {
      postHedgeSelectiveMaxLossCloseCount++;
      RefreshPostHedgeSelectiveLossDay();
      postHedgeSelectiveLossCloseCountToday++;
      postHedgeSelectiveLossCloseCountSegment++;
   }
   else if(reason == "Post hedge selective no improvement close")
   {
      postHedgeSelectiveNoImprovementCloseCount++;
      RefreshPostHedgeSelectiveLossDay();
      postHedgeSelectiveLossCloseCountToday++;
      postHedgeSelectiveLossCloseCountSegment++;
   }
   else if(reason == "Post hedge selective hard time close")
   {
      postHedgeSelectiveHardTimeCloseCount++;
      RefreshPostHedgeSelectiveLossDay();
      postHedgeSelectiveLossCloseCountToday++;
      postHedgeSelectiveLossCloseCountSegment++;
   }
}

void StartPostHedgeCloseIntent(string reason, const PositionState &ps)
{
   if(!postHedgeCloseIntentPending)
   {
      postHedgeCloseIntentPending = true;
      postHedgeCloseIntentReason = reason;
      postHedgeCloseIntentFirstTime = TimeCurrent();
      postHedgeCloseIntentLastRetryTime = 0;
      CountPostHedgeCloseReason(reason);
      postHedgeCloseRetryPendingCount++;
      WriteTradeEventLog("POST_HEDGE_CLOSE_RETRY_PENDING",
                         0,
                         0,
                         "",
                         reason,
                         "CLOSE",
                         0.0,
                         0.0,
                         0.0,
                         0.0,
                         0.0,
                         0.0,
                         ps.floatingProfit);
   }
}

bool ExecutePostHedgeCloseIntent(const PositionState &ps, string &action, string &reason)
{
   if(!postHedgeCloseIntentPending)
      return false;

   if(ps.total <= 0 || CountDefenseHedges() <= 0)
   {
      postHedgeCloseIntentPending = false;
      postHedgeCloseIntentReason = "";
      postHedgeCloseIntentFirstTime = 0;
      postHedgeCloseIntentLastRetryTime = 0;
      return false;
   }

   int retrySeconds = MathMax(1, PostHedgeMarketClosedRetrySeconds);
   if(postHedgeCloseIntentLastRetryTime > 0 && TimeCurrent() - postHedgeCloseIntentLastRetryTime < retrySeconds)
   {
      action = "post hedge close retry pending";
      reason = postHedgeCloseIntentReason;
      return true;
   }

   if(PostHedgeMarketClosedMaxRetryMinutes > 0 &&
      postHedgeCloseIntentFirstTime > 0 &&
      TimeCurrent() - postHedgeCloseIntentFirstTime > PostHedgeMarketClosedMaxRetryMinutes * 60)
   {
      postHedgeCloseRetryFailedCount++;
      WriteTradeEventLog("POST_HEDGE_CLOSE_RETRY_FAILED",
                         0,
                         0,
                         "",
                         postHedgeCloseIntentReason,
                         "CLOSE",
                         0.0,
                         0.0,
                         0.0,
                         0.0,
                         0.0,
                         0.0,
                         ps.floatingProfit);
      postHedgeCloseIntentPending = false;
      postHedgeCloseIntentReason = "";
      postHedgeCloseIntentFirstTime = 0;
      postHedgeCloseIntentLastRetryTime = 0;
      return false;
   }

   postHedgeCloseIntentLastRetryTime = TimeCurrent();
   postHedgeCloseRetryInProgress = true;
   bool closeAttempt = CloseAllEaPositions(postHedgeCloseIntentReason);
   postHedgeCloseRetryInProgress = false;

   PositionState afterClose;
   GetPositionState(afterClose);
   if(afterClose.total <= 0)
   {
      postHedgeCloseRetrySuccessCount++;
      WriteTradeEventLog("POST_HEDGE_CLOSE_RETRY_SUCCESS",
                         0,
                         0,
                         "",
                         postHedgeCloseIntentReason,
                         "CLOSE",
                         0.0,
                         0.0,
                         0.0,
                         0.0,
                         0.0,
                         0.0,
                         ps.floatingProfit);
      postHedgeCloseIntentPending = false;
      postHedgeCloseIntentReason = "";
      postHedgeCloseIntentFirstTime = 0;
      postHedgeCloseIntentLastRetryTime = 0;
      action = "post hedge close";
      reason = "post hedge close success";
      return true;
   }

   action = closeAttempt ? "post hedge partial close" : "post hedge close retry pending";
   reason = postHedgeCloseIntentReason;
   return true;
}

bool CheckPostDefenseHedgeExitControl(const PositionState &ps,
                                      const MaStructureState &ma,
                                      string &action,
                                      string &reason)
{
   if(!UsePostDefenseHedgeExitControl)
      return false;

   int hedgePositions = CountDefenseHedges();
   datetime firstHedgeTime = GetFirstDefenseHedgeTime();
   UpdatePostHedgeReference(ps, firstHedgeTime, hedgePositions);

   if(postHedgeCloseIntentPending)
      return ExecutePostHedgeCloseIntent(ps, action, reason);

   if(hedgePositions <= 0 || ps.total < 2 || firstHedgeTime <= 0)
      return false;

   int minHoldSeconds = MathMax(0, PostHedgeMinHoldMinutes) * 60;
   int secondsSinceHedge = (int)(TimeCurrent() - firstHedgeTime);
   if(secondsSinceHedge < minHoldSeconds)
      return false;

   string closeReason = "";

   if(UsePostHedgeSelectiveExitOnly)
   {
      string selectiveState = "";
      bool againstStrongTrend = IsPostHedgeSelectiveAgainstStrongTrend(ma, selectiveState);
      if(PostHedgeExitOnlyAgainstStrongTrend && !againstStrongTrend)
         return false;

      int selectiveMinHoldSeconds = MathMax(0, PostHedgeSelectiveMinHoldMinutes) * 60;
      if(secondsSinceHedge < selectiveMinHoldSeconds)
         return false;

      string guardReason = "";
      if(PostHedgeSelectiveGoodEnoughCloseYen > -999000.0 &&
         ps.floatingProfit >= PostHedgeSelectiveGoodEnoughCloseYen)
      {
         closeReason = "Post hedge selective good enough close";
      }
      else if(PostHedgeSelectiveMaxLossCloseYen > -999000.0 &&
              ps.floatingProfit <= PostHedgeSelectiveMaxLossCloseYen)
      {
         if(CanPostHedgeSelectiveLossClose(ps, firstHedgeTime, false, guardReason))
            closeReason = "Post hedge selective max loss close";
      }
      else if(PostHedgeSelectiveSoftMaxHoldMinutes > 0 &&
              secondsSinceHedge >= PostHedgeSelectiveSoftMaxHoldMinutes * 60)
      {
         double referenceProfit = PostHedgeSelectiveUseWorstAfterHedgeReference ? postHedgeWorstProfit : postHedgeInitialProfit;
         double requiredLevel = referenceProfit + PostHedgeSelectiveRequiredImprovementYen;
         bool noImprove = (PostHedgeSelectiveRequiredImprovementYen <= 0.0 || ps.floatingProfit < requiredLevel);
         bool lossStillLarge = (PostHedgeSelectiveNoImproveCloseYen <= -999000.0 ||
                                ps.floatingProfit <= PostHedgeSelectiveNoImproveCloseYen);
         if(noImprove && lossStillLarge &&
            CanPostHedgeSelectiveLossClose(ps, firstHedgeTime, false, guardReason))
            closeReason = "Post hedge selective no improvement close";
      }

      if(closeReason == "" &&
         PostHedgeSelectiveHardMaxHoldMinutes > 0 &&
         secondsSinceHedge >= PostHedgeSelectiveHardMaxHoldMinutes * 60)
      {
         int graceSeconds = 30 * 60;
         if(IsPostHedgeNearBasketRecovery(ps) &&
            secondsSinceHedge < (PostHedgeSelectiveHardMaxHoldMinutes * 60 + graceSeconds))
         {
            if(postHedgeSelectiveLastHardTimeGraceHedgeTime != firstHedgeTime)
            {
               postHedgeSelectiveLastHardTimeGraceHedgeTime = firstHedgeTime;
               postHedgeSelectiveHardTimeGraceCount++;
               WriteTradeEventLog("POST_HEDGE_SELECTIVE_HARD_TIME_GRACE",
                                  0,
                                  0,
                                  "",
                                  "Post hedge selective hard time grace",
                                  "HOLD",
                                  0.0,
                                  0.0,
                                  0.0,
                                  0.0,
                                  0.0,
                                  0.0,
                                  ps.floatingProfit);
            }
            return false;
         }
         if(CanPostHedgeSelectiveLossClose(ps, firstHedgeTime, true, guardReason))
            closeReason = "Post hedge selective hard time close";
      }

      if(closeReason == "")
         return false;

      lastStopReason = closeReason + " / " + selectiveState;
      StartPostHedgeCloseIntent(closeReason, ps);
      return ExecutePostHedgeCloseIntent(ps, action, reason);
   }

   if(PostHedgeGoodEnoughCloseYen > -999000.0 && ps.floatingProfit >= PostHedgeGoodEnoughCloseYen)
      closeReason = "Post hedge good enough close";
   else if(PostHedgeMaxLossCloseYen > -999000.0 && ps.floatingProfit <= PostHedgeMaxLossCloseYen)
      closeReason = "Post hedge max loss close";
   else if(UsePostHedgeAgainstStrongTrendFastExit &&
           PostHedgeAgainstStrongTrendMaxHoldMinutes > 0 &&
           secondsSinceHedge >= PostHedgeAgainstStrongTrendMaxHoldMinutes * 60 &&
           ps.floatingProfit <= PostHedgeAgainstStrongTrendCloseYen &&
           IsPostHedgeAgainstStrongTrend(ma))
      closeReason = "Post hedge against strong trend close";
   else if(PostHedgeSoftMaxHoldMinutes > 0 &&
           PostHedgeSoftMaxHoldMinutes < 9999 &&
           secondsSinceHedge >= PostHedgeSoftMaxHoldMinutes * 60)
   {
      double referenceProfit = UseWorstBasketAfterHedgeReferenceForPostExit ? postHedgeWorstProfit : postHedgeInitialProfit;
      double requiredLevel = referenceProfit + PostHedgeRequiredImprovementYen;
      bool noImprove = (PostHedgeRequiredImprovementYen <= 0.0 || ps.floatingProfit < requiredLevel);
      bool lossStillLarge = (PostHedgeNoImproveCloseYen <= -999000.0 || ps.floatingProfit <= PostHedgeNoImproveCloseYen);
      if(noImprove && lossStillLarge)
         closeReason = "Post hedge no improvement close";
   }

   if(closeReason == "" &&
      PostHedgeHardMaxHoldMinutes > 0 &&
      PostHedgeHardMaxHoldMinutes < 9999 &&
      secondsSinceHedge >= PostHedgeHardMaxHoldMinutes * 60)
      closeReason = "Post hedge hard time close";

   if(closeReason == "")
      return false;

   lastStopReason = closeReason;
   StartPostHedgeCloseIntent(closeReason, ps);
   return ExecutePostHedgeCloseIntent(ps, action, reason);
}

void ResetPostHedgeRecoveryFailureState(const PositionState &ps, string reason)
{
   if(postHedgeRfActive || postHedgeRfExecuted || postHedgeRfEligible)
   {
      string detail = "BasketId=" + postHedgeRfBasketId +
                      "|Reason=" + reason +
                      "|EndOpenPositionCount=" + IntegerToString(ps.total) +
                      "|FinalBasketProfit=" + DoubleToString(ps.floatingProfit, 2);
      WriteTradeEventLog("POST_HEDGE_RF60_RESET", 0, 0, "", detail, "", 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, ps.floatingProfit);
   }

   postHedgeRfActive = false;
   postHedgeRfBasketId = "";
   postHedgeRfBasketStartTime = 0;
   postHedgeRfHedgeTime = 0;
   postHedgeRfFloatingAtHedge = 0.0;
   postHedgeRfBestFloatingAfterHedge = 0.0;
   postHedgeRfWorstFloatingAfterHedge = 0.0;
   postHedgeRfLastBestLogged = 0.0;
   postHedgeRfEligible = false;
   postHedgeRfExecuted = false;
   postHedgeRf60MinLogged = false;
   postHedgeRf120ReachedLogged = false;
   postHedgeRf120EvaluateLogged = false;
   postHedgeRfEligibleResultLogged = false;
}

string PostHedgeRecoveryFailureDetail(const PositionState &ps, string extra)
{
   double actualImprove = postHedgeRfBestFloatingAfterHedge - postHedgeRfFloatingAtHedge;
   int minutesAfterHedge = 0;
   if(postHedgeRfHedgeTime > 0)
      minutesAfterHedge = (int)((TimeCurrent() - postHedgeRfHedgeTime) / 60);
   int noImproveMinutes = 0;
   if(postHedgeRfHedgeTime > 0 &&
      postHedgeRfBestFloatingAfterHedge < postHedgeRfFloatingAtHedge + PostHedgeRecoveryFailureImproveYen)
      noImproveMinutes = minutesAfterHedge;

   string detail = "BasketId=" + postHedgeRfBasketId +
                   "|DefenseHedgeTime=" + (postHedgeRfHedgeTime > 0 ? TimeToString(postHedgeRfHedgeTime, TIME_DATE | TIME_SECONDS) : "") +
                   "|MinutesAfterHedge=" + IntegerToString(minutesAfterHedge) +
                   "|FloatingPnLAtHedge=" + DoubleToString(postHedgeRfFloatingAtHedge, 2) +
                   "|BestFloatingPnLAfterHedge=" + DoubleToString(postHedgeRfBestFloatingAfterHedge, 2) +
                   "|WorstFloatingPnLAfterHedge=" + DoubleToString(postHedgeRfWorstFloatingAfterHedge, 2) +
                   "|RequiredImproveYen=" + DoubleToString(PostHedgeRecoveryFailureImproveYen, 2) +
                   "|ActualImproveYen=" + DoubleToString(actualImprove, 2) +
                   "|NoImproveMinutes=" + IntegerToString(noImproveMinutes) +
                   "|CurrentFloatingPnL=" + DoubleToString(ps.floatingProfit, 2) +
                   "|EndOpenPositionCount=" + IntegerToString(ps.total);
   if(extra != "")
      detail += "|" + extra;
   return detail;
}

void WritePostHedgeRecoveryFailureEvent(string eventType, const PositionState &ps, string extra="")
{
   WriteTradeEventLog(eventType,
                      0,
                      0,
                      "",
                      PostHedgeRecoveryFailureDetail(ps, extra),
                      "",
                      0.0,
                      0.0,
                      0.0,
                      0.0,
                      0.0,
                      0.0,
                      ps.floatingProfit);
}

bool IsPostHedgeRfHteGuardActive(const PositionState &ps,
                                 bool hteEligibleNow,
                                 bool &hteWithinGuardWindow,
                                 bool &hteAcceptableLoss,
                                 int &minutesToHte)
{
   hteWithinGuardWindow = false;
   hteAcceptableLoss = false;
   minutesToHte = -1;

   if(!UsePostHedgeRfHteGuard)
      return false;
   if(!UseHedgedBasketTimeExit || postHedgeRfHedgeTime <= 0 ||
      HedgedBasketMaxHoldMinutes <= 0 || HedgedBasketTimeExitAcceptLossYen <= 0.0 ||
      PostHedgeRfHteGuardLookaheadMinutes < 0)
      return false;

   int elapsedSeconds = (int)(TimeCurrent() - postHedgeRfHedgeTime);
   int hteSeconds = HedgedBasketMaxHoldMinutes * 60;
   int secondsToHte = hteSeconds - elapsedSeconds;
   minutesToHte = (secondsToHte > 0 ? (int)MathCeil((double)secondsToHte / 60.0) : 0);

   hteAcceptableLoss = (ps.floatingProfit >= -HedgedBasketTimeExitAcceptLossYen);
   hteWithinGuardWindow = (secondsToHte <= PostHedgeRfHteGuardLookaheadMinutes * 60);

   return (hteAcceptableLoss && (hteEligibleNow || hteWithinGuardWindow));
}

void StartPostHedgeRecoveryFailureTrack(const PositionState &ps, datetime firstHedgeTime)
{
   postHedgeRfBasketSeq++;
   postHedgeRfBasketId = "RF" + IntegerToString(postHedgeRfBasketSeq, 4, '0');
   postHedgeRfBasketStartTime = GetEarliestEaPositionTime();
   postHedgeRfHedgeTime = firstHedgeTime;
   postHedgeRfFloatingAtHedge = ps.floatingProfit;
   postHedgeRfBestFloatingAfterHedge = ps.floatingProfit;
   postHedgeRfWorstFloatingAfterHedge = ps.floatingProfit;
   postHedgeRfLastBestLogged = ps.floatingProfit;
   postHedgeRfEligible = false;
   postHedgeRfExecuted = false;
   postHedgeRf60MinLogged = false;
   postHedgeRf120ReachedLogged = false;
   postHedgeRf120EvaluateLogged = false;
   postHedgeRfEligibleResultLogged = false;
   postHedgeRfActive = true;
   WritePostHedgeRecoveryFailureEvent("POST_HEDGE_RF60_TRACK_START", ps, "DefenseHedgeTriggered=true");
}

bool IsPostHedgeRfTrackingEnabled()
{
   return (UsePostHedgeRecoveryFailureExit || EnablePostHedgeRfReachabilityDiagnostic);
}

void UpdatePostHedgeRecoveryFailureState(const PositionState &ps)
{
   if(!IsPostHedgeRfTrackingEnabled())
   {
      if(postHedgeRfActive)
         ResetPostHedgeRecoveryFailureState(ps, "PostHedgeRfTrackingDisabled");
      return;
   }

   if(ps.total <= 0 || CountDefenseHedges() <= 0)
   {
      if(postHedgeRfActive)
         ResetPostHedgeRecoveryFailureState(ps, "BasketFlatOrNoDefenseHedge");
      return;
   }

   datetime firstHedgeTime = GetFirstDefenseHedgeTime();
   if(firstHedgeTime <= 0)
      return;

   if(!postHedgeRfActive || postHedgeRfHedgeTime != firstHedgeTime)
      StartPostHedgeRecoveryFailureTrack(ps, firstHedgeTime);

   if(ps.floatingProfit > postHedgeRfBestFloatingAfterHedge)
   {
      postHedgeRfBestFloatingAfterHedge = ps.floatingProfit;
      if(postHedgeRfBestFloatingAfterHedge >= postHedgeRfLastBestLogged + 100.0 ||
         postHedgeRfBestFloatingAfterHedge >= postHedgeRfFloatingAtHedge + PostHedgeRecoveryFailureImproveYen)
      {
         postHedgeRfLastBestLogged = postHedgeRfBestFloatingAfterHedge;
         WritePostHedgeRecoveryFailureEvent("POST_HEDGE_RF60_BEST_UPDATE", ps);
      }
   }
   if(ps.floatingProfit < postHedgeRfWorstFloatingAfterHedge)
      postHedgeRfWorstFloatingAfterHedge = ps.floatingProfit;
}

bool CheckPostHedgeRecoveryFailureExit(const PositionState &ps,
                                       bool recoveryCloseEligible,
                                       bool hardStop)
{
   if(!IsPostHedgeRfTrackingEnabled())
      return false;

   UpdatePostHedgeRecoveryFailureState(ps);

   if(!postHedgeRfActive || postHedgeRfExecuted || ps.total <= 0)
      return false;
   if(postHedgeRfHedgeTime <= 0 || PostHedgeRecoveryFailureMinutes <= 0)
      return false;

   int minutesAfterHedge = (int)((TimeCurrent() - postHedgeRfHedgeTime) / 60);
   if(EnablePostHedgeRfReachabilityDiagnostic && !postHedgeRf60MinLogged && minutesAfterHedge >= 60)
   {
      postHedgeRf60MinLogged = true;
      WritePostHedgeRecoveryFailureEvent("POST_HEDGE_RF60_CANDIDATE", ps, "EvaluationCalled=false|SkipReason=MINUTE_CHECK_ONLY");
   }

   if((TimeCurrent() - postHedgeRfHedgeTime) < PostHedgeRecoveryFailureMinutes * 60)
      return false;

   double requiredBest = postHedgeRfFloatingAtHedge + PostHedgeRecoveryFailureImproveYen;
   double bestImprove = postHedgeRfBestFloatingAfterHedge - postHedgeRfFloatingAtHedge;
   double currentImprove = ps.floatingProfit - postHedgeRfFloatingAtHedge;
   bool candidateConditionElapsedOk = true;
   bool candidateConditionNoImproveOk = (postHedgeRfBestFloatingAfterHedge < requiredBest);
   bool candidateConditionLossOk = (ps.floatingProfit < 0.0);
   bool basketCloseEligibleNow = PostHedgeDiagBasketCloseEligible(ps);
   bool hteEligibleNow = (UseHedgedBasketTimeExit &&
                          postHedgeRfHedgeTime > 0 &&
                          HedgedBasketMaxHoldMinutes > 0 &&
                          HedgedBasketTimeExitAcceptLossYen > 0.0 &&
                          TimeCurrent() - postHedgeRfHedgeTime >= HedgedBasketMaxHoldMinutes * 60 &&
                          ps.floatingProfit >= -HedgedBasketTimeExitAcceptLossYen);
   bool hteWithinGuardWindow = false;
   bool hteAcceptableLoss = false;
   int minutesToHte = -1;
   bool hteGuardActive = IsPostHedgeRfHteGuardActive(ps,
                                                     hteEligibleNow,
                                                     hteWithinGuardWindow,
                                                     hteAcceptableLoss,
                                                     minutesToHte);

   if(EnablePostHedgeRfReachabilityDiagnostic && !postHedgeRf120ReachedLogged)
   {
      postHedgeRf120ReachedLogged = true;
      WritePostHedgeRecoveryFailureEvent("POST_HEDGE_RF60_CANDIDATE",
                                         ps,
                                         "ReachedRfMinutes=true|EvaluationCalled=false|BestImproveYen=" + DoubleToString(bestImprove, 2) +
                                         "|CurrentImproveYen=" + DoubleToString(currentImprove, 2) +
                                         "|CandidateConditionElapsedOk=" + BoolText(candidateConditionElapsedOk) +
                                         "|CandidateConditionNoImproveOk=" + BoolText(candidateConditionNoImproveOk) +
                                         "|CandidateConditionLossOk=" + BoolText(candidateConditionLossOk));
   }

   string skipReason = "";
   if(hardStop)
      skipReason = "CLOSE_PRIORITY_BLOCKED";
   else if(basketCloseEligibleNow || recoveryCloseEligible)
      skipReason = "CLOSE_PRIORITY_BLOCKED";
   else if(hteEligibleNow)
      skipReason = "CLOSE_PRIORITY_BLOCKED";
   else if(postHedgeRfBestFloatingAfterHedge >= requiredBest)
      skipReason = "BEST_IMPROVE_REACHED_1000";
   else if(hteGuardActive)
      skipReason = "HTE_GUARD_ACTIVE";

   if(EnablePostHedgeRfReachabilityDiagnostic && !postHedgeRf120EvaluateLogged)
   {
      postHedgeRf120EvaluateLogged = true;
      WritePostHedgeRecoveryFailureEvent("POST_HEDGE_RF60_CANDIDATE",
                                         ps,
                                         "EvaluationCalled=true|HardStopNow=" + BoolText(hardStop) +
                                         "|BasketCloseEligible=" + BoolText(basketCloseEligibleNow) +
                                         "|RecoveryCloseEligible=" + BoolText(recoveryCloseEligible) +
                                         "|HteEligibleNow=" + BoolText(hteEligibleNow) +
                                         "|HteWithinGuardWindow=" + BoolText(hteWithinGuardWindow) +
                                         "|HteAcceptableLoss=" + BoolText(hteAcceptableLoss) +
                                         "|HteGuardActive=" + BoolText(hteGuardActive) +
                                         "|MinutesToHte=" + IntegerToString(minutesToHte) +
                                         "|BestImproveYen=" + DoubleToString(bestImprove, 2) +
                                         "|CurrentImproveYen=" + DoubleToString(currentImprove, 2) +
                                         "|WouldBestRfTrigger=" + BoolText(postHedgeRfBestFloatingAfterHedge < requiredBest) +
                                         "|WouldCurrentRfTrigger=" + BoolText(ps.floatingProfit < requiredBest) +
                                         "|CandidateConditionElapsedOk=" + BoolText(candidateConditionElapsedOk) +
                                         "|CandidateConditionNoImproveOk=" + BoolText(candidateConditionNoImproveOk) +
                                         "|CandidateConditionLossOk=" + BoolText(candidateConditionLossOk) +
                                         "|SkipReason=" + (skipReason == "" ? "NONE" : skipReason));
   }

   if(skipReason != "")
   {
      if(skipReason == "HTE_GUARD_ACTIVE")
         WritePostHedgeRecoveryFailureEvent("POST_HEDGE_RF60_HTE_GUARD_BLOCK",
                                            ps,
                                            "RfCandidate=true|RfBlockedByHteGuard=true|HardStopNow=" + BoolText(hardStop) +
                                            "|BasketCloseNow=" + BoolText(basketCloseEligibleNow) +
                                            "|RecoveryCloseNow=" + BoolText(recoveryCloseEligible) +
                                            "|HteEligibleNow=" + BoolText(hteEligibleNow) +
                                            "|HteWithinGuardWindow=" + BoolText(hteWithinGuardWindow) +
                                            "|HteAcceptableLoss=" + BoolText(hteAcceptableLoss) +
                                            "|HteGuardActive=true|MinutesToHte=" + IntegerToString(minutesToHte));
      if(EnablePostHedgeRfReachabilityDiagnostic && !postHedgeRfEligibleResultLogged)
      {
         postHedgeRfEligibleResultLogged = true;
         WritePostHedgeRecoveryFailureEvent("POST_HEDGE_RF60_CANDIDATE",
                                            ps,
                                            "EligibleResult=false|SkipReason=" + skipReason);
         WritePostHedgeRecoveryFailureEvent("POST_HEDGE_RF60_CANDIDATE",
                                            ps,
                                            "SkipReason=" + skipReason +
                                            "|HardStopNow=" + BoolText(hardStop) +
                                            "|BasketCloseEligible=" + BoolText(basketCloseEligibleNow) +
                                            "|RecoveryCloseEligible=" + BoolText(recoveryCloseEligible) +
                                            "|HteEligibleNow=" + BoolText(hteEligibleNow) +
                                            "|HteWithinGuardWindow=" + BoolText(hteWithinGuardWindow) +
                                            "|HteAcceptableLoss=" + BoolText(hteAcceptableLoss) +
                                            "|HteGuardActive=" + BoolText(hteGuardActive) +
                                            "|BestImproveYen=" + DoubleToString(bestImprove, 2) +
                                            "|CurrentImproveYen=" + DoubleToString(currentImprove, 2) +
                                            "|CandidateConditionElapsedOk=" + BoolText(candidateConditionElapsedOk) +
                                            "|CandidateConditionNoImproveOk=" + BoolText(candidateConditionNoImproveOk) +
                                            "|CandidateConditionLossOk=" + BoolText(candidateConditionLossOk));
      }
      return false;
   }

   if(!postHedgeRfEligible)
   {
      postHedgeRfEligible = true;
      WritePostHedgeRecoveryFailureEvent("POST_HEDGE_RF60_CANDIDATE",
                                         ps,
                                         "RfCandidate=true|HteGuardActive=false|HardStopNow=" + BoolText(hardStop) +
                                         "|BasketCloseNow=" + BoolText(basketCloseEligibleNow) +
                                         "|RecoveryCloseNow=" + BoolText(recoveryCloseEligible) +
                                         "|HteEligibleNow=" + BoolText(hteEligibleNow) +
                                         "|HteWithinGuardWindow=" + BoolText(hteWithinGuardWindow) +
                                         "|HteAcceptableLoss=" + BoolText(hteAcceptableLoss) +
                                         "|CandidateConditionElapsedOk=" + BoolText(candidateConditionElapsedOk) +
                                         "|CandidateConditionNoImproveOk=" + BoolText(candidateConditionNoImproveOk) +
                                         "|CandidateConditionLossOk=" + BoolText(candidateConditionLossOk));
      if(EnablePostHedgeRfReachabilityDiagnostic && !postHedgeRfEligibleResultLogged)
      {
         postHedgeRfEligibleResultLogged = true;
         WritePostHedgeRecoveryFailureEvent("POST_HEDGE_RF60_CANDIDATE",
                                            ps,
                                            "EligibleResult=true|SkipReason=NONE|BestImproveYen=" + DoubleToString(bestImprove, 2) +
                                            "|CurrentImproveYen=" + DoubleToString(currentImprove, 2));
      }
   }

   if(!UsePostHedgeRecoveryFailureExit)
      return false;

   string closeReason = "POST_HEDGE_RF60_HTE_GUARD_EXIT";
   WritePostHedgeRecoveryFailureEvent("POST_HEDGE_RF60_EXIT_INTENT",
                                      ps,
                                      "FinalCloseReason=" + closeReason +
                                      "|RfCandidate=true|RfBlockedByHteGuard=false|HardStopNow=" + BoolText(hardStop) +
                                      "|BasketCloseNow=" + BoolText(basketCloseEligibleNow) +
                                      "|RecoveryCloseNow=" + BoolText(recoveryCloseEligible) +
                                      "|HteEligibleNow=" + BoolText(hteEligibleNow) +
                                      "|HteWithinGuardWindow=" + BoolText(hteWithinGuardWindow) +
                                      "|HteAcceptableLoss=" + BoolText(hteAcceptableLoss) +
                                      "|HteGuardActive=false");
   bool closed = CloseAllEaPositions(closeReason);

   PositionState afterClose;
   GetPositionState(afterClose);
   if(closed && afterClose.total <= 0)
   {
      postHedgeRfExecuted = true;
      postHedgeRfExitCount++;
      postHedgeRfExitProfitTotal += ps.floatingProfit;
      if(postHedgeRfExitCount == 1 || ps.floatingProfit < postHedgeRfExitWorstLoss)
         postHedgeRfExitWorstLoss = ps.floatingProfit;
      WritePostHedgeRecoveryFailureEvent("POST_HEDGE_RF60_EXIT_DONE",
                                         ps,
                                         "FinalCloseReason=" + closeReason +
                                         "|WasHardStopAvoided=true|EndOpenBasketCount=0");
      ResetPostHedgeRecoveryFailureState(afterClose, "POST_HEDGE_RF60_EXIT_DONE");
      return true;
   }

   uint retcode = trade.ResultRetcode();
   WriteTradeEventLog("POST_HEDGE_RF60_EXIT_FAILED",
                      0,
                      retcode,
                      trade.ResultRetcodeDescription(),
                      PostHedgeRecoveryFailureDetail(afterClose,
                                                     "FinalCloseReason=" + closeReason +
                                                     "|WasMarketClosed10018=" + BoolText(IsMarketClosedRetcode(retcode)) +
                                                     "|EndOpenBasketCount=" + (afterClose.total > 0 ? "1" : "0")),
                      "",
                      0.0,
                      0.0,
                      0.0,
                      0.0,
                      0.0,
                      0.0,
                      afterClose.floatingProfit);
   return closed;
}

bool CheckBasketRecoveryClose(const PositionState &ps)
{
   if(!UseBasketRecoveryClose)
      return false;
   if(ps.total < 2)
      return false;
   int hedgePositions = CountDefenseHedges();
   if(hedgePositions <= 0)
      return false;
   datetime firstHedgeTime = GetFirstDefenseHedgeTime();
   UpdateBasketRecoveryReference(ps, firstHedgeTime, hedgePositions);

   bool recoveryProfitReached = (ps.floatingProfit >= BasketRecoveryProfitYen);
   bool netPositiveAfterHedge = (CloseBasketWhenNetProfitPositiveAfterHedge && ps.floatingProfit >= 0.0);
   bool lossCutMinHoldPassed = (!UseBasketRecoveryLossCutMinHold ||
                                BasketRecoveryLossCutMinHoldMinutes <= 0 ||
                                (firstHedgeTime > 0 && TimeCurrent() - firstHedgeTime >= BasketRecoveryLossCutMinHoldMinutes * 60));
   double referenceProfit = GetBasketRecoveryReferenceProfit();
   bool improvementReached = (!UseBasketRecoveryImprovementCheck ||
                              BasketRecoveryRequiredImprovementYen <= 0.0 ||
                              (basketRecoveryReferenceActive &&
                               ps.floatingProfit >= referenceProfit + BasketRecoveryRequiredImprovementYen));
   bool acceptableLossReached = (UseBasketRecoveryLossCut &&
                                 CloseHedgedBasketWhenLossImproves &&
                                 BasketRecoveryAcceptLossYen > 0.0 &&
                                 firstHedgeTime > 0 &&
                                 TimeCurrent() > firstHedgeTime &&
                                 lossCutMinHoldPassed &&
                                 ps.floatingProfit >= -BasketRecoveryAcceptLossYen &&
                                 improvementReached);
   bool hedgedTimeExitReached = (UseHedgedBasketTimeExit &&
                                 firstHedgeTime > 0 &&
                                 HedgedBasketMaxHoldMinutes > 0 &&
                                 HedgedBasketTimeExitAcceptLossYen > 0.0 &&
                                 TimeCurrent() - firstHedgeTime >= HedgedBasketMaxHoldMinutes * 60 &&
                                 ps.floatingProfit >= -HedgedBasketTimeExitAcceptLossYen);

   TraceRuntimeEvaluationStage("CHECK_RECOVERY_BEFORE_HARDSTOP_EVALUATION",
                               ps,
                               false,
                               recoveryProfitReached || netPositiveAfterHedge,
                               acceptableLossReached,
                               hedgedTimeExitReached,
                               true,
                               true,
                               "inside_CheckBasketRecoveryClose_before_local_hardstop_eval");

   if(recoveryProfitReached || netPositiveAfterHedge)
      return CloseAllEaPositions("basket recovery close");
   bool hardStopNow = IsHardStopTriggeredByBasis(ps, AccountInfoDouble(ACCOUNT_MARGIN_LEVEL));
   TraceRuntimeEvaluationStage("CHECK_RECOVERY_AFTER_HARDSTOP_EVALUATION",
                               ps,
                               hardStopNow,
                               recoveryProfitReached || netPositiveAfterHedge,
                               acceptableLossReached,
                               hedgedTimeExitReached,
                               false,
                               false,
                               "inside_CheckBasketRecoveryClose_after_local_hardstop_eval");
   if(CheckPostHedgeRecoveryFailureExit(ps, recoveryProfitReached || netPositiveAfterHedge, hardStopNow))
      return true;
   if(CheckL1M5R12LargeAdverseExit(ps,
                                   hardStopNow,
                                   recoveryProfitReached || netPositiveAfterHedge,
                                   acceptableLossReached,
                                   hedgedTimeExitReached))
      return true;
   if(CheckB2G5BalancedSimpleGuardExit(ps,
                                       hardStopNow,
                                       recoveryProfitReached || netPositiveAfterHedge,
                                       acceptableLossReached,
                                       hedgedTimeExitReached))
      return true;
   bool runtimePostHedgeExitGateOpen = (!hardStopNow &&
                                        !(recoveryProfitReached || netPositiveAfterHedge) &&
                                        !acceptableLossReached &&
                                        !hedgedTimeExitReached);
   TraceRuntimeEvaluationStage("RUNTIME_EXIT_GATE",
                               ps,
                               hardStopNow,
                               recoveryProfitReached || netPositiveAfterHedge,
                               acceptableLossReached,
                               hedgedTimeExitReached,
                               runtimePostHedgeExitGateOpen,
                               false,
                               "existing_posthedge_exit_gate_before_cw8_call");
   if(CheckCW8OutsideHteBandExit(ps,
                                 hardStopNow,
                                 recoveryProfitReached || netPositiveAfterHedge,
                                 acceptableLossReached,
                                 hedgedTimeExitReached))
      return true;
   if(acceptableLossReached)
   {
      lastStopReason = "Hedged basket improved within acceptable loss";
      lastRecoveryLossCutCloseTime = TimeCurrent();
      lastRecoveryLossCutBasketProfit = ps.floatingProfit;
      return CloseAllEaPositions("Basket recovery losscut close");
   }
   if(CheckHedgedBasketLossCompression(ps, firstHedgeTime))
      return true;
   if(hedgedTimeExitReached)
   {
      bool dangerMode = (UseHedgedBasketTimeExitDangerControl &&
                         (currentNewsBlockActive || currentTechnicalDangerActive || currentVixDangerActive || IsAtrExpansion()));
      if(dangerMode)
      {
         bool emergencyLoss = (HedgedBasketDangerEmergencyLossYen > 0.0 &&
                               ps.floatingProfit <= -HedgedBasketDangerEmergencyLossYen);
         bool extraHoldExpired = (HedgedBasketDangerExtraHoldMinutes > 0 &&
                                  TimeCurrent() - firstHedgeTime >= (HedgedBasketMaxHoldMinutes + HedgedBasketDangerExtraHoldMinutes) * 60);
         bool acceptableAfterExtraHold = (HedgedBasketDangerMaxAcceptLossYen > 0.0 &&
                                          ps.floatingProfit >= -HedgedBasketDangerMaxAcceptLossYen);

         if(currentNewsBlockActive && BlockHedgedBasketTimeExitDuringNewsShock && !emergencyLoss && !extraHoldExpired)
         {
            blockedByNewsCount++;
            blockedHedgedBasketTimeExitByNewsCount++;
            lastStopReason = "Hedged basket time exit blocked by news shock";
            return false;
         }

         if(currentTechnicalDangerActive && !emergencyLoss && !extraHoldExpired)
         {
            blockedHedgedBasketTimeExitByTechnicalDangerCount++;
            lastStopReason = "Hedged basket time exit held by technical danger";
            return false;
         }

         if(!emergencyLoss && !extraHoldExpired)
         {
            lastStopReason = "Hedged basket time exit danger hold";
            return false;
         }

         if(extraHoldExpired && !emergencyLoss && !acceptableAfterExtraHold)
         {
            lastStopReason = "Hedged basket danger extra hold expired";
            return CloseAllEaPositions("Hedged basket danger time exit");
         }

         lastStopReason = emergencyLoss ? "Hedged basket danger emergency exit" : "Hedged basket danger controlled exit";
         return CloseAllEaPositions("Hedged basket danger exit");
      }
      lastStopReason = "Hedged basket closed within acceptable loss";
      return CloseAllEaPositions("Hedged basket time exit");
   }

   return false;
}

bool CloseAllEaPositions(string reason)
{
   if(IsMarketClosedRetryActive() && !postHedgeCloseRetryInProgress && !globalCloseRetryInProgress)
   {
      lastStopReason = "market closed retry cooldown";
      LogMarketClosedRetryBlock(reason, "CLOSE", 0.0);
      return false;
   }

   bool closedAny = false;
   PositionState preCloseState;
   preCloseState.total = 0;
   preCloseState.buys = 0;
   preCloseState.sells = 0;
   preCloseState.net = 0;
   preCloseState.floatingProfit = 0.0;
   preCloseState.floatingLossPercent = 0.0;
   preCloseState.avgBuy = 0.0;
   preCloseState.avgSell = 0.0;
   bool preCloseStateReady = false;
   if(IsPostHedgeDiagnosticEnabled() && postHedgeDiagActive)
   {
      if(tradeEventContextReady)
      {
         preCloseState = tradeEventPosition;
         preCloseStateReady = true;
      }
      else
      {
         GetPositionState(preCloseState);
         preCloseStateReady = true;
      }
   }
   for(int i = PerfPositionsTotal() - 1; i >= 0; i--)
   {
      ulong ticket = PositionGetTicket(i);
      if(ticket == 0 || !PositionSelectByTicket(ticket) || !IsEaPosition())
         continue;

      int positionType = (int)PositionGetInteger(POSITION_TYPE);
      string positionComment = PositionGetString(POSITION_COMMENT);
      double lots = PositionGetDouble(POSITION_VOLUME);
      double openPrice = PositionGetDouble(POSITION_PRICE_OPEN);
      double closeProfit = PositionGetDouble(POSITION_PROFIT) + PositionGetDouble(POSITION_SWAP);
      double closePrice = 0.0;
      MqlTick closeTick;
      if(SymbolInfoTick(_Symbol, closeTick))
         closePrice = (positionType == POSITION_TYPE_BUY) ? closeTick.bid : closeTick.ask;

      bool ok = trade.PositionClose(ticket);
      uint retcode = trade.ResultRetcode();
      if(ok)
      {
         closedAny = true;
         if(StringFind(positionComment, "planned add") >= 0)
            plannedAddPositionProfitTotal += closeProfit;
         lastTradeActionTime = TimeCurrent();
         InvalidateSameTickPositionCache();
         WriteTradeEventLog(TradeEventTypeFromCloseReason(reason),
                            ticket,
                            retcode,
                            trade.ResultRetcodeDescription(),
                            reason,
                            positionType == POSITION_TYPE_BUY ? "BUY_CLOSE" : "SELL_CLOSE",
                            lots,
                            openPrice,
                            0.0,
                            0.0,
                            closePrice,
                            closeProfit,
                            tradeEventContextReady ? tradeEventPosition.floatingProfit : closeProfit);
      }
      else
      {
         Print(EA_NAME, ": close failed ticket=", ticket, " retcode=", retcode);
         HandleTradeRetcode(retcode);
         if(UsePostDefenseHedgeExitControl &&
            UsePostHedgeMarketClosedRetry &&
            IsMarketClosedRetcode(retcode) &&
            CountDefenseHedges() > 0)
         {
            PositionState retryState;
            GetPositionState(retryState);
            StartPostHedgeCloseIntent(reason, retryState);
         }
         if(UseGlobalMarketClosedRetry &&
            IsMarketClosedRetcode(retcode) &&
            ShouldGlobalRetryCloseReason(reason))
         {
            PositionState retryState;
            GetPositionState(retryState);
            StartGlobalCloseIntent(reason, retcode, trade.ResultRetcodeDescription(), retryState);
         }
         if(ShouldLogTradeRetcodeEvent(retcode))
            WriteTradeEventLog("ORDER_RETCODE_ERROR",
                               ticket,
                               retcode,
                               trade.ResultRetcodeDescription(),
                               reason,
                               positionType == POSITION_TYPE_BUY ? "BUY_CLOSE" : "SELL_CLOSE",
                               lots,
                               openPrice,
                               0.0,
                               0.0,
                               closePrice,
                               closeProfit,
                               tradeEventContextReady ? tradeEventPosition.floatingProfit : closeProfit);
         if(IsMarketClosedRetcode(retcode))
         {
            PositionState failState;
            GetPositionState(failState);
            LogPostHedgeTimeExitPriorityMarketClosed(failState, reason, retcode, trade.ResultRetcodeDescription());
         }
      }
   }

   if(closedAny)
   {
      if(IsPostHedgeDiagnosticEnabled() && postHedgeDiagActive && preCloseStateReady)
      {
         PositionState afterCloseState;
         GetPositionState(afterCloseState);
         if(afterCloseState.total <= 0)
            EndPostHedgeTimeExitPriorityDiagnostic(preCloseState, reason);
      }
      MarkEaClose(reason);
   }

   return closedAny;
}

void MarkEaClose(string reason)
{
   lastEaCloseTime = TimeCurrent();
   lastAnyEaCloseTime = TimeCurrent();
   lastEaCloseReason = reason;
   InvalidateSameTickPositionCache();
   WriteTradeEventLog("AFTER_CLOSE_COOLDOWN_START",
                      0,
                      0,
                      "",
                      reason,
                      "",
                      0.0,
                      0.0,
                      0.0,
                      0.0,
                      0.0,
                      0.0,
                      tradeEventContextReady ? tradeEventPosition.floatingProfit : 0.0);
   if(EnableMultilayerShadowLogging && MultilayerShadowLogLevel > 0)
      ObserveMultilayerBasketSummaryShadow(reason);
}

void ApplyHardStopAfterMode()
{
   lastHardStopTime = TimeCurrent();
   if(HardStopAfterMode == 1)
   {
      hardStopCooldownUntil = TimeCurrent() + HardStopCooldownMinutes * 60;
      WriteTradeEventLog("HARDSTOP_COOLDOWN_START", 0, 0, "", "hard stop cooldown start", "", 0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
                         tradeEventContextReady ? tradeEventPosition.floatingProfit : 0.0);
      return;
   }

   MqlDateTime jst;
   TimeToStruct(TimeGMT() + 9 * 3600, jst);

   if(HardStopAfterMode == 0)
   {
      jst.hour = 23;
      jst.min = 59;
      jst.sec = 59;
      hardStopCooldownUntil = StructToTime(jst) - 9 * 3600;
      WriteTradeEventLog("HARDSTOP_COOLDOWN_START", 0, 0, "", "hard stop cooldown start", "", 0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
                         tradeEventContextReady ? tradeEventPosition.floatingProfit : 0.0);
      return;
   }

   if(HardStopAfterMode == 2)
   {
      int currentMinutes = jst.hour * 60 + jst.min;
      int sessionMinutes = TradingStartHourJST * 60;
      if(currentMinutes >= sessionMinutes)
      {
         datetime jstNow = StructToTime(jst);
         jstNow += 24 * 60 * 60;
         TimeToStruct(jstNow, jst);
      }
      jst.hour = TradingStartHourJST;
      jst.min = 0;
      jst.sec = 0;
      hardStopCooldownUntil = StructToTime(jst) - 9 * 3600;
      WriteTradeEventLog("HARDSTOP_COOLDOWN_START", 0, 0, "", "hard stop cooldown start", "", 0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
                         tradeEventContextReady ? tradeEventPosition.floatingProfit : 0.0);
   }
}

double CalculateTodayRealizedPL()
{
   MqlDateTime dt;
   TimeToStruct(TimeCurrent(), dt);
   dt.hour = 0;
   dt.min = 0;
   dt.sec = 0;
   datetime dayStart = StructToTime(dt);

   if(UseSafePerformanceOptimization && UseDailyPlIncrementalCache &&
      cachedDailyPlValid &&
      cachedDailyPlDay == dayStart &&
      cachedDailyPlActionTime == lastTradeActionTime)
      return cachedDailyPlValue;

   if(!PerfHistorySelect(dayStart, TimeCurrent()))
      return 0.0;

   double result = 0.0;
   for(int i = 0; i < HistoryDealsTotal(); i++)
   {
      ulong deal = HistoryDealGetTicket(i);
      if(deal == 0)
         continue;
      if(HistoryDealGetString(deal, DEAL_SYMBOL) != _Symbol)
         continue;
      if((ulong)HistoryDealGetInteger(deal, DEAL_MAGIC) != MagicNumber)
         continue;
      if((int)HistoryDealGetInteger(deal, DEAL_ENTRY) != DEAL_ENTRY_OUT)
         continue;

      result += HistoryDealGetDouble(deal, DEAL_PROFIT);
      result += HistoryDealGetDouble(deal, DEAL_SWAP);
      result += HistoryDealGetDouble(deal, DEAL_COMMISSION);
   }
   if(UseSafePerformanceOptimization && UseDailyPlIncrementalCache)
   {
      cachedDailyPlValid = true;
      cachedDailyPlDay = dayStart;
      cachedDailyPlActionTime = lastTradeActionTime;
      cachedDailyPlValue = result;
      if(CountPerformanceStats)
         perfDailyPlCacheUpdateCount++;
   }
   return result;
}

bool IsDailyLossStop(double dailyPL)
{
   if(!UseDailyLossStop)
      return false;

   double balance = AccountInfoDouble(ACCOUNT_BALANCE);
   double percentLoss = (DailyLossStopPercent > 0.0 && balance > 0.0) ? balance * DailyLossStopPercent / 100.0 : 0.0;
   double stopLoss = 0.0;

   if(percentLoss > 0.0 && DailyLossStopYen > 0.0)
      stopLoss = MathMin(percentLoss, DailyLossStopYen);
   else if(percentLoss > 0.0)
      stopLoss = percentLoss;
   else if(DailyLossStopYen > 0.0)
      stopLoss = DailyLossStopYen;
   else
      return false;

   return dailyPL <= -stopLoss;
}

int CalculateConsecutiveLosses()
{
   if(UseSafePerformanceOptimization && UseDailyPlIncrementalCache &&
      cachedConsecutiveLossesValid &&
      cachedConsecutiveLossesActionTime == lastTradeActionTime)
      return cachedConsecutiveLossesValue;

   if(!PerfHistorySelect(0, TimeCurrent()))
      return 0;

   int losses = 0;
   for(int i = HistoryDealsTotal() - 1; i >= 0; i--)
   {
      ulong deal = HistoryDealGetTicket(i);
      if(deal == 0)
         continue;
      if(HistoryDealGetString(deal, DEAL_SYMBOL) != _Symbol)
         continue;
      if((ulong)HistoryDealGetInteger(deal, DEAL_MAGIC) != MagicNumber)
         continue;
      if((int)HistoryDealGetInteger(deal, DEAL_ENTRY) != DEAL_ENTRY_OUT)
         continue;

      double pl = HistoryDealGetDouble(deal, DEAL_PROFIT) +
                  HistoryDealGetDouble(deal, DEAL_SWAP) +
                  HistoryDealGetDouble(deal, DEAL_COMMISSION);

      if(pl < 0.0)
      {
         if(CountRecoveryLossCutAsConsecutiveLoss &&
            lastRecoveryLossCutCloseTime > 0 &&
            RecoveryLossCutConsecutiveLossMinYen > 0.0)
         {
            datetime dealTime = (datetime)HistoryDealGetInteger(deal, DEAL_TIME);
            if(MathAbs((double)(dealTime - lastRecoveryLossCutCloseTime)) <= 10 &&
               MathAbs(lastRecoveryLossCutBasketProfit) < RecoveryLossCutConsecutiveLossMinYen)
               continue;
         }
         losses++;
      }
      else if(pl > 0.0)
         break;
   }
   if(UseSafePerformanceOptimization && UseDailyPlIncrementalCache)
   {
      cachedConsecutiveLossesValid = true;
      cachedConsecutiveLossesActionTime = lastTradeActionTime;
      cachedConsecutiveLossesValue = losses;
      if(CountPerformanceStats)
         perfDailyPlCacheUpdateCount++;
   }
   return losses;
}

bool IsConsecutiveLossStop(int losses)
{
   if(!UseConsecutiveLossStop)
      return false;

   if(losses >= MaxConsecutiveLosses && consecutiveLossStopUntil < TimeCurrent())
      consecutiveLossStopUntil = TimeCurrent() + ConsecutiveLossStopMinutes * 60;

   return TimeCurrent() < consecutiveLossStopUntil;
}

bool DetectManualClose(int currentEaPositions)
{
   if(lastKnownEaPositions > 0 && currentEaPositions == 0)
   {
      if(eaClosingPositions)
         return false;
      if(lastEaCloseTime > 0 && TimeCurrent() - lastEaCloseTime <= ManualCloseStopMinutes * 60)
         return false;

      manualCloseStopUntil = TimeCurrent() + ManualCloseStopMinutes * 60;
      lastAnyEaCloseTime = TimeCurrent();
      lastTradeActionTime = TimeCurrent();
      lastStopReason = "manual close protection active";
      WriteTradeEventLog("MANUAL_CLOSE_DETECTED",
                         0,
                         0,
                         "",
                         "manual close protection active",
                         "",
                         0.0,
                         0.0,
                         0.0,
                         0.0,
                         0.0,
                         0.0,
                         tradeEventContextReady ? tradeEventPosition.floatingProfit : 0.0);
      WriteTradeEventLog("AFTER_CLOSE_COOLDOWN_START",
                         0,
                         0,
                         "",
                         "manual close cooldown start",
                         "",
                         0.0,
                         0.0,
                         0.0,
                         0.0,
                         0.0,
                         0.0,
                         tradeEventContextReady ? tradeEventPosition.floatingProfit : 0.0);
      return true;
   }
   return false;
}

double GetSafeMarginLevel()
{
   double margin = AccountInfoDouble(ACCOUNT_MARGIN_LEVEL);
   if(!MathIsValidNumber(margin) || margin <= 0.0)
      return 999999.0;
   return margin;
}

double NormalizeLot(double lot)
{
   double minLot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
   double maxLot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX);
   double step = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);
   if(step <= 0.0)
      step = 0.01;

   lot = MathMax(minLot, MathMin(maxLot, lot));
   lot = MathFloor(lot / step) * step;
   return NormalizeDouble(lot, 2);
}

int GetAfterCloseCooldownRemaining()
{
   if(lastAnyEaCloseTime <= 0 || AfterCloseCooldownSeconds <= 0)
      return 0;
   return MathMax(0, AfterCloseCooldownSeconds - (int)(TimeCurrent() - lastAnyEaCloseTime));
}

int GetOppositeCooldownRemaining()
{
   if(lastEntryDirection == 0 || lastEntryTime <= 0 || OppositeDirectionCooldownSeconds <= 0)
      return 0;
   return MathMax(0, OppositeDirectionCooldownSeconds - (int)(TimeCurrent() - lastEntryTime));
}

int GetHardStopCooldownRemaining()
{
   if(hardStopCooldownUntil <= 0)
      return 0;
   return MathMax(0, (int)(hardStopCooldownUntil - TimeCurrent()));
}

string DirectionToString(int direction)
{
   if(direction > 0)
      return "BUY";
   if(direction < 0)
      return "SELL";
   return "NONE";
}

string CsvEscape(string value)
{
   StringReplace(value, "\"", "\"\"");
   return "\"" + value + "\"";
}

void CsvAppend(string &line, string value)
{
   if(line != "")
      line += ",";
   line += CsvEscape(value);
}

string BoolText(bool value)
{
   return value ? "true" : "false";
}

string UlongToText(ulong value)
{
   return StringFormat("%I64u", value);
}

string UintToText(uint value)
{
   return StringFormat("%u", value);
}

datetime DayStart(datetime timeValue)
{
   MqlDateTime dt;
   TimeToStruct(timeValue, dt);
   dt.hour = 0;
   dt.min = 0;
   dt.sec = 0;
   return StructToTime(dt);
}

void ResetTraceDailyCountersIfNeeded()
{
   datetime today = DayStart(TimeCurrent());
   if(entryDecisionTraceDay != today)
   {
      entryDecisionTraceDay = today;
      entryDecisionTraceRowsToday = 0;
   }
   if(reactiveHedgeTraceDay != today)
   {
      reactiveHedgeTraceDay = today;
      reactiveHedgeTraceRowsToday = 0;
   }
}

bool CanWriteEntryDecisionTrace()
{
   if(!EffectiveEntryDecisionTraceEnabled())
      return false;
   ResetTraceDailyCountersIfNeeded();
   if(MaxEntryDecisionTraceRowsPerDay > 0 && entryDecisionTraceRowsToday >= MaxEntryDecisionTraceRowsPerDay)
      return false;
   return true;
}

bool CanWriteReactiveHedgeTrace()
{
   if(!EffectiveReactiveHedgeTraceEnabled())
      return false;
   ResetTraceDailyCountersIfNeeded();
   if(MaxReactiveHedgeTraceRowsPerDay > 0 && reactiveHedgeTraceRowsToday >= MaxReactiveHedgeTraceRowsPerDay)
      return false;
   return true;
}

long NextEntryDecisionTraceCandidateId()
{
   entryDecisionTraceCandidateSeq++;
   return entryDecisionTraceCandidateSeq;
}

void WriteEntryDecisionTraceHeader()
{
   int handle = FileOpen(EntryDecisionTraceFileName, FILE_READ | FILE_WRITE | FILE_CSV | FILE_ANSI | FILE_SHARE_READ | FILE_SHARE_WRITE);
   if(handle == INVALID_HANDLE)
   {
      Print(EA_NAME, ": entry decision trace header open failed. error=", GetLastError());
      return;
   }

   if(FileSize(handle) == 0)
   {
      string line = "";
      CsvAppend(line, "Pattern");
      CsvAppend(line, "Time");
      CsvAppend(line, "CandidateId");
      CsvAppend(line, "OrderTicket");
      CsvAppend(line, "IsActualOrderSend");
      CsvAppend(line, "IsHardStopOriginEntry");
      CsvAppend(line, "LaterHardStopTicket");
      CsvAppend(line, "LaterHardStopTime");
      CsvAppend(line, "Direction");
      CsvAppend(line, "Price");
      CsvAppend(line, "Lot");
      CsvAppend(line, "EntryScore");
      CsvAppend(line, "EntryScoreThreshold");
      CsvAppend(line, "EntryScoreBuffer");
      CsvAppend(line, "TickScoreBuy");
      CsvAppend(line, "TickScoreSell");
      CsvAppend(line, "TickScoreDifference");
      CsvAppend(line, "MinimumScoreDifference");
      CsvAppend(line, "AllowPureTickEntry");
      CsvAppend(line, "UseStructureBeforeTickEntry");
      CsvAppend(line, "RequireTickScoreAfterStructure");
      CsvAppend(line, "HasPullbackConfirmation");
      CsvAppend(line, "HasStructureConfirmation");
      CsvAppend(line, "TrendMainDirection");
      CsvAppend(line, "TrendMainDirectionStrength");
      CsvAppend(line, "MaStructureState");
      CsvAppend(line, "MaFastSlopeState");
      CsvAppend(line, "MaMiddleSlopeState");
      CsvAppend(line, "LargeCandleDetected");
      CsvAppend(line, "LargeCandleDirection");
      CsvAppend(line, "SecondsAfterLargeCandle");
      CsvAppend(line, "HistoricalTimeRiskState");
      CsvAppend(line, "NewsBlockActive");
      CsvAppend(line, "DxyState");
      CsvAppend(line, "VixState");
      CsvAppend(line, "Spread");
      CsvAppend(line, "SpreadOk");
      CsvAppend(line, "EntryCooldownOk");
      CsvAppend(line, "SameDirectionCooldownOk");
      CsvAppend(line, "OppositeDirectionCooldownOk");
      CsvAppend(line, "MaxPositionsOk");
      CsvAppend(line, "BasketStateOk");
      CsvAppend(line, "HardStopOriginEntryBlockEligible");
      CsvAppend(line, "HardStopOriginEntryBlockFired");
      CsvAppend(line, "HardStopOriginEntryBlockReason");
      CsvAppend(line, "ReactiveHedgeEligibleAtEntry");
      CsvAppend(line, "ReactiveHedgeEligibleLater");
      CsvAppend(line, "FinalEntryAllowed");
      CsvAppend(line, "FinalBlockReason");
      CsvAppend(line, "OrderSendRetcode");
      CsvAppend(line, "Comment");
      PerfFileWriteString(handle, line + "\r\n");
   }
   FileClose(handle);
}

bool EvaluateHardStopOriginEntryBlockEligibility(bool isBuy,
                                                 const ScoreState &score,
                                                 const PositionState &ps,
                                                 const PullbackState &pullback,
                                                 const MaStructureState &ma,
                                                 double threshold,
                                                 string &reason,
                                                 string &largeDirection,
                                                 int &secondsAfterLargeCandle,
                                                 bool &hasPullbackConfirmation,
                                                 bool &hasStructureConfirmation,
                                                 double &entryScore,
                                                 double &entryScoreBuffer)
{
   reason = "";
   largeDirection = "";
   secondsAfterLargeCandle = 0;
   hasPullbackConfirmation = false;
   hasStructureConfirmation = false;
   entryScore = isBuy ? score.longScore : score.shortScore;
   entryScoreBuffer = entryScore - threshold;

   if(!UseHardStopOriginEntryBlock)
   {
      reason = "UseHardStopOriginEntryBlock false";
      return false;
   }
   if(!BlockPureTickEntryAfterLargeCandleChase)
   {
      reason = "BlockPureTickEntryAfterLargeCandleChase false";
      return false;
   }
   if(LargeCandleChaseOnlyInitialEntry && ps.total > 0)
   {
      reason = "not initial entry";
      return false;
   }
   if(LargeCandleChaseRequireSinglePositionFlat && ps.total != 0)
   {
      reason = "not flat";
      return false;
   }
   if(!AllowPureTickEntry)
   {
      reason = "AllowPureTickEntry false";
      return false;
   }
   if(!currentStructureGate.largeCandleDetected)
   {
      reason = "LargeCandleDetected false";
      return false;
   }

   largeDirection = LargeCandleDirectionM5();
   secondsAfterLargeCandle = SecondsAfterLastM5Close();

   if(secondsAfterLargeCandle > LargeCandleChaseBlockSeconds)
   {
      reason = "large candle window expired";
      return false;
   }
   if((isBuy && largeDirection != "BUY") || (!isBuy && largeDirection != "SELL"))
   {
      reason = "large candle direction mismatch";
      return false;
   }

   hasPullbackConfirmation = (isBuy ? pullback.okBuy : pullback.okSell) && ma.priceNearMaPullback;
   hasStructureConfirmation = isBuy ? currentStructureGate.structurePermissionBuy : currentStructureGate.structurePermissionSell;

   if(LargeCandleChaseRequireNoPullback && hasPullbackConfirmation)
   {
      reason = "pullback confirmation exists";
      return false;
   }
   if(LargeCandleChaseRequireNoStructureConfirmation && hasStructureConfirmation && UseStructureBeforeTickEntry)
   {
      reason = "structure confirmation exists";
      return false;
   }
   if(LargeCandleChaseBlockOnlyWhenTrendWeakOrMixed && !TrendWeakOrMixedForHardStopOrigin(ma))
   {
      reason = "trend not weak or mixed";
      return false;
   }
   if(entryScoreBuffer > LargeCandleChaseMinEntryScoreBuffer)
   {
      reason = "entry score buffer too large";
      return false;
   }

   reason = "eligible";
   return true;
}

void WriteEntryDecisionTrace(bool isBuy,
                             long candidateId,
                             ulong orderTicket,
                             bool isActualOrderSend,
                             bool finalEntryAllowed,
                             string finalBlockReason,
                             uint orderSendRetcode,
                             string comment,
                             const MqlTick &tick,
                             const ScoreState &score,
                             const PositionState &ps,
                             const FilterState &dxy,
                             const FilterState &vix,
                             bool newsBlock,
                             const PullbackState &pullback,
                             const MaStructureState &ma,
                             double threshold,
                             bool hardStopOriginEligible,
                             bool hardStopOriginFired,
                             string hardStopOriginReason,
                             bool reactiveHedgeEligibleAtEntry)
{
   if(!TraceAllFinalEntryDecisions && !hardStopOriginEligible && !hardStopOriginFired && !isActualOrderSend)
      return;
   if(TraceOnlyNearHardStopOrigin && !currentStructureGate.largeCandleDetected && ps.total == 0)
      return;
   if(!CanWriteEntryDecisionTrace())
      return;

   WriteEntryDecisionTraceHeader();
   int handle = FileOpen(EntryDecisionTraceFileName, FILE_READ | FILE_WRITE | FILE_CSV | FILE_ANSI | FILE_SHARE_READ | FILE_SHARE_WRITE);
   if(handle == INVALID_HANDLE)
   {
      Print(EA_NAME, ": entry decision trace open failed. error=", GetLastError());
      return;
   }
   FileSeek(handle, 0, SEEK_END);

   string largeDirection = "";
   int secondsAfterLargeCandle = 0;
   bool hasPullbackConfirmation = false;
   bool hasStructureConfirmation = false;
   double entryScore = 0.0;
   double entryScoreBuffer = 0.0;
   string eligibilityReason = "";
   bool currentEligible = EvaluateHardStopOriginEntryBlockEligibility(isBuy, score, ps, pullback, ma, threshold,
                                                                      eligibilityReason, largeDirection, secondsAfterLargeCandle,
                                                                      hasPullbackConfirmation, hasStructureConfirmation,
                                                                      entryScore, entryScoreBuffer);
   if(hardStopOriginReason == "")
      hardStopOriginReason = eligibilityReason;
   if(!hardStopOriginEligible)
      hardStopOriginEligible = currentEligible;

   int direction = isBuy ? 1 : -1;
   bool spreadOk = (tick.ask - tick.bid) <= MaxSpreadPrice;
   bool entryCooldownOk = (TimeCurrent() - lastEntryTime >= EntryCooldownSeconds);
   bool sameDirectionCooldownOk = !(lastEntryDirection == direction && SameDirectionReentryCooldownSeconds > 0 &&
                                    TimeCurrent() - lastEntryTime < SameDirectionReentryCooldownSeconds);
   bool oppositeDirectionCooldownOk = !(lastEntryDirection != 0 && lastEntryDirection != direction && GetOppositeCooldownRemaining() > 0);
   string maxReason = "";
   bool maxPositionsOk = CheckPositionLimits(isBuy, ps, maxReason);
   bool basketStateOk = (CountReactiveDefenseHedges() <= 0 && !(UseBasketRecoveryClose && CountDefenseHedges() > 0 && ps.total >= 2));
   double price = isBuy ? tick.ask : tick.bid;
   bool directionStructurePermission = isBuy ? currentStructureGate.structurePermissionBuy : currentStructureGate.structurePermissionSell;
   string trendStrength = TrendWeakOrMixedForHardStopOrigin(ma) ? "weak_or_mixed" : "strong";

   string line = "";
   CsvAppend(line, "");
   CsvAppend(line, TimeToString(TimeCurrent(), TIME_DATE | TIME_SECONDS));
   CsvAppend(line, IntegerToString((int)candidateId));
   CsvAppend(line, UlongToText(orderTicket));
   CsvAppend(line, BoolText(isActualOrderSend));
   CsvAppend(line, "false");
   CsvAppend(line, "");
   CsvAppend(line, "");
   CsvAppend(line, isBuy ? "BUY" : "SELL");
   CsvAppend(line, DoubleToString(price, _Digits));
   CsvAppend(line, DoubleToString(BaseLot, 2));
   CsvAppend(line, DoubleToString(entryScore, 2));
   CsvAppend(line, DoubleToString(threshold, 2));
   CsvAppend(line, DoubleToString(entryScoreBuffer, 2));
   CsvAppend(line, DoubleToString(score.longScore, 2));
   CsvAppend(line, DoubleToString(score.shortScore, 2));
   CsvAppend(line, DoubleToString(MathAbs(score.longScore - score.shortScore), 2));
   CsvAppend(line, DoubleToString(MinimumScoreDifference, 2));
   CsvAppend(line, BoolText(AllowPureTickEntry));
   CsvAppend(line, BoolText(UseStructureBeforeTickEntry));
   CsvAppend(line, BoolText(RequireTickScoreAfterStructure));
   CsvAppend(line, BoolText(hasPullbackConfirmation));
   CsvAppend(line, BoolText(hasStructureConfirmation));
   CsvAppend(line, ma.trendDirection);
   CsvAppend(line, trendStrength);
   CsvAppend(line, ma.mode);
   CsvAppend(line, ma.fastSlopeState);
   CsvAppend(line, ma.middleSlopeState);
   CsvAppend(line, BoolText(currentStructureGate.largeCandleDetected));
   CsvAppend(line, largeDirection);
   CsvAppend(line, IntegerToString(secondsAfterLargeCandle));
   CsvAppend(line, currentHistoricalTimeRiskState);
   CsvAppend(line, BoolText(newsBlock));
   CsvAppend(line, dxy.state);
   CsvAppend(line, vix.state);
   CsvAppend(line, DoubleToString(tick.ask - tick.bid, 2));
   CsvAppend(line, BoolText(spreadOk));
   CsvAppend(line, BoolText(entryCooldownOk));
   CsvAppend(line, BoolText(sameDirectionCooldownOk));
   CsvAppend(line, BoolText(oppositeDirectionCooldownOk));
   CsvAppend(line, BoolText(maxPositionsOk));
   CsvAppend(line, BoolText(basketStateOk));
   CsvAppend(line, BoolText(hardStopOriginEligible));
   CsvAppend(line, BoolText(hardStopOriginFired));
   CsvAppend(line, hardStopOriginReason);
   CsvAppend(line, BoolText(reactiveHedgeEligibleAtEntry));
   CsvAppend(line, "false");
   CsvAppend(line, BoolText(finalEntryAllowed));
   CsvAppend(line, finalBlockReason);
   CsvAppend(line, UintToText(orderSendRetcode));
   CsvAppend(line, comment + "; structurePermission=" + BoolText(directionStructurePermission) + "; maxReason=" + maxReason);
   PerfFileWriteString(handle, line + "\r\n");
   FileClose(handle);
   entryDecisionTraceRowsToday++;
}

void WriteReactiveHedgeEligibilityTraceHeader()
{
   int handle = FileOpen(ReactiveHedgeEligibilityTraceFileName, FILE_READ | FILE_WRITE | FILE_CSV | FILE_ANSI | FILE_SHARE_READ | FILE_SHARE_WRITE);
   if(handle == INVALID_HANDLE)
   {
      Print(EA_NAME, ": reactive hedge trace header open failed. error=", GetLastError());
      return;
   }

   if(FileSize(handle) == 0)
   {
      string line = "";
      CsvAppend(line, "Pattern");
      CsvAppend(line, "Time");
      CsvAppend(line, "PositionDirection");
      CsvAppend(line, "PositionCountTotal");
      CsvAppend(line, "FloatingProfitYen");
      CsvAppend(line, "FloatingLossYen");
      CsvAppend(line, "ReactiveHedgeTriggerLossYen");
      CsvAppend(line, "LossConditionOk");
      CsvAppend(line, "OppositeTickScore");
      CsvAppend(line, "ReactiveHedgeOppositeTickScore");
      CsvAppend(line, "OppositeTickOk");
      CsvAppend(line, "OppositeScoreDiff");
      CsvAppend(line, "ReactiveHedgeOppositeScoreDiff");
      CsvAppend(line, "ScoreDiffOk");
      CsvAppend(line, "MaFastSlopeState");
      CsvAppend(line, "MaFastSlopeOk");
      CsvAppend(line, "MaMiddleSlopeState");
      CsvAppend(line, "MaMiddleSlopeOk");
      CsvAppend(line, "TrendMainDirection");
      CsvAppend(line, "TrendMainOk");
      CsvAppend(line, "M5ConfirmationPassed");
      CsvAppend(line, "M5ConfirmationOk");
      CsvAppend(line, "OnlySinglePositionOk");
      CsvAppend(line, "NoHedgeOk");
      CsvAppend(line, "BasketStateOk");
      CsvAppend(line, "DailyLimitOk");
      CsvAppend(line, "SegmentLimitOk");
      CsvAppend(line, "ReactiveHedgeFinalEligible");
      CsvAppend(line, "ReactiveHedgeNotFiredReason");
      CsvAppend(line, "HardStopAlreadyTriggered");
      CsvAppend(line, "Comment");
      PerfFileWriteString(handle, line + "\r\n");
   }
   FileClose(handle);
}

bool TraceReactiveHedgeEligibilityState(const ScoreState &score,
                                        const PositionState &ps,
                                        const FilterState &vix,
                                        bool newsBlock,
                                        string newsReason,
                                        const MaStructureState &ma,
                                        bool hardStop)
{
   if(!TraceReactiveHedgeEligibility)
      return false;
   if(ps.total != 1 && ps.floatingProfit >= 0.0)
      return false;
   if(!CanWriteReactiveHedgeTrace())
      return false;

   ulong ticket = 0;
   int positionType = -1;
   datetime openTime = 0;
   double lots = 0.0;
   double openPrice = 0.0;
   double currentFloatingProfitYen = ps.floatingProfit;
   bool singlePositionFound = GetSingleEaPosition(ticket, positionType, openTime, lots, openPrice, currentFloatingProfitYen);
   bool isBuyPosition = (positionType == POSITION_TYPE_BUY);
   string positionDirection = singlePositionFound ? (isBuyPosition ? "BUY" : "SELL") : "none";
   double floatingLossYen = currentFloatingProfitYen < 0.0 ? -currentFloatingProfitYen : 0.0;
   double oppositeTickScore = isBuyPosition ? score.shortScore : score.longScore;
   double sameTickScore = isBuyPosition ? score.longScore : score.shortScore;
   double oppositeScoreDiff = oppositeTickScore - sameTickScore;
   bool lossOk = floatingLossYen >= ReactiveHedgeTriggerLossYen;
   bool oppositeTickOk = oppositeTickScore >= ReactiveHedgeOppositeTickScore;
   bool scoreDiffOk = oppositeScoreDiff >= ReactiveHedgeOppositeScoreDiff;
   bool maFastOk = isBuyPosition ? (ma.fastSlopeState == "strong down") : (ma.fastSlopeState == "strong up");
   bool maMiddleOk = isBuyPosition ? (ma.middleSlopeState == "strong down") : (ma.middleSlopeState == "strong up");
   bool maReverse = MaSlopeReversedForSingleExit(isBuyPosition, ma);
   bool trendReverse = TrendMainReversedForSingleExit(isBuyPosition, ma);
   bool m5Ok = true;
   string m5Reason = "";
   if(ReactiveHedgeRequireM5CloseConfirmation && singlePositionFound)
      m5Ok = CheckSingleEarlyExitM5Confirmation(isBuyPosition, ReactiveHedgeConfirmBars, m5Reason);

   bool onlySingleOk = (!ReactiveHedgeOnlySinglePosition || ps.total == 1);
   bool noHedgeOk = (!ReactiveHedgeOnlyWhenNoHedge || CountDefenseHedges() <= 0);
   bool basketStateOk = (CountReactiveDefenseHedges() <= 0 && !(UseBasketRecoveryClose && CountDefenseHedges() > 0 && ps.total >= 2));
   UpdateReactiveHedgeDailyCounter();
   bool dailyLimitOk = (MaxReactiveDefenseHedgePerDay <= 0 || reactiveHedgeCountToday < MaxReactiveDefenseHedgePerDay);
   bool segmentLimitOk = (MaxReactiveDefenseHedgePerSegment <= 0 || reactiveHedgeCountSegment < MaxReactiveDefenseHedgePerSegment);
   bool newsOk = !(newsBlock && BlockDefenseHedgeDuringNews);
   bool vixOk = !(vix.stop || vix.extreme);
   bool enabledOk = UseSinglePositionReactiveDefenseHedge;
   bool positionShapeOk = (singlePositionFound && ps.total > 0 && ps.buys != ps.sells && currentFloatingProfitYen < 0.0);
   bool maOk = (!ReactiveHedgeRequireMaSlopeReverse || maReverse);
   bool trendOk = (!ReactiveHedgeRequireTrendMainReverse || trendReverse);
   bool m5FinalOk = (!ReactiveHedgeRequireM5CloseConfirmation || m5Ok);
   bool finalEligible = (enabledOk && !hardStop && newsOk && vixOk && onlySingleOk && noHedgeOk && positionShapeOk &&
                         dailyLimitOk && segmentLimitOk && lossOk && oppositeTickOk && scoreDiffOk &&
                         maOk && trendOk && m5FinalOk && basketStateOk);

   string reason = "eligible";
   if(!enabledOk) reason = "disabled";
   else if(hardStop) reason = "hard stop already triggered";
   else if(!newsOk) reason = newsReason;
   else if(!vixOk) reason = vix.reason;
   else if(!onlySingleOk) reason = "not single position";
   else if(!noHedgeOk) reason = "hedge already exists";
   else if(!positionShapeOk) reason = "position shape/profit not eligible";
   else if(!dailyLimitOk) reason = "daily reactive hedge limit";
   else if(!segmentLimitOk) reason = "segment reactive hedge limit";
   else if(!lossOk) reason = "loss below trigger";
   else if(!oppositeTickOk) reason = "opposite tick score below threshold";
   else if(!scoreDiffOk) reason = "opposite score diff below threshold";
   else if(!maOk) reason = "MA slope reverse not confirmed";
   else if(!trendOk) reason = "TrendMainDirection reverse not confirmed";
   else if(!m5FinalOk) reason = m5Reason;
   else if(!basketStateOk) reason = "basket state not eligible";

   WriteReactiveHedgeEligibilityTraceHeader();
   int handle = FileOpen(ReactiveHedgeEligibilityTraceFileName, FILE_READ | FILE_WRITE | FILE_CSV | FILE_ANSI | FILE_SHARE_READ | FILE_SHARE_WRITE);
   if(handle == INVALID_HANDLE)
   {
      Print(EA_NAME, ": reactive hedge trace open failed. error=", GetLastError());
      return finalEligible;
   }
   FileSeek(handle, 0, SEEK_END);

   string line = "";
   CsvAppend(line, "");
   CsvAppend(line, TimeToString(TimeCurrent(), TIME_DATE | TIME_SECONDS));
   CsvAppend(line, positionDirection);
   CsvAppend(line, IntegerToString(ps.total));
   CsvAppend(line, DoubleToString(currentFloatingProfitYen, 2));
   CsvAppend(line, DoubleToString(floatingLossYen, 2));
   CsvAppend(line, DoubleToString(ReactiveHedgeTriggerLossYen, 2));
   CsvAppend(line, BoolText(lossOk));
   CsvAppend(line, DoubleToString(oppositeTickScore, 2));
   CsvAppend(line, DoubleToString(ReactiveHedgeOppositeTickScore, 2));
   CsvAppend(line, BoolText(oppositeTickOk));
   CsvAppend(line, DoubleToString(oppositeScoreDiff, 2));
   CsvAppend(line, DoubleToString(ReactiveHedgeOppositeScoreDiff, 2));
   CsvAppend(line, BoolText(scoreDiffOk));
   CsvAppend(line, ma.fastSlopeState);
   CsvAppend(line, BoolText(maFastOk));
   CsvAppend(line, ma.middleSlopeState);
   CsvAppend(line, BoolText(maMiddleOk));
   CsvAppend(line, ma.trendDirection);
   CsvAppend(line, BoolText(trendReverse));
   CsvAppend(line, BoolText(m5Ok));
   CsvAppend(line, BoolText(m5FinalOk));
   CsvAppend(line, BoolText(onlySingleOk));
   CsvAppend(line, BoolText(noHedgeOk));
   CsvAppend(line, BoolText(basketStateOk));
   CsvAppend(line, BoolText(dailyLimitOk));
   CsvAppend(line, BoolText(segmentLimitOk));
   CsvAppend(line, BoolText(finalEligible));
   CsvAppend(line, reason);
   CsvAppend(line, BoolText(hardStop));
   CsvAppend(line, "ticket=" + UlongToText(ticket) + "; open=" + TimeToString(openTime, TIME_DATE | TIME_SECONDS));
   PerfFileWriteString(handle, line + "\r\n");
   FileClose(handle);
   reactiveHedgeTraceRowsToday++;
   return finalEligible;
}

void ResetAuditDailyIfNeeded()
{
   datetime today = DayStart(TimeCurrent());
   if(auditCurrentDay == today)
      return;

   if(auditCurrentDay > 0)
      WriteEntryOpportunityAuditSummary("DAILY_SUMMARY");

   auditCurrentDay = today;
   auditRejectedLogsToday = 0;
   auditDailyRawTickSignalCount = 0;
   auditDailyRawBuyTickSignalCount = 0;
   auditDailyRawSellTickSignalCount = 0;
   auditDailyFinalEntryApprovedCount = 0;
   auditDailyActualOrderSendCount = 0;
   auditDailyOrderSendFailedCount = 0;
}

void WriteEntryOpportunityAuditSummary(string auditType)
{
   if(!EffectiveAuditSummaryEnabled())
      return;

   WriteEntryOpportunityAuditHeader();
   int handle = FileOpen(EntryOpportunityAuditFileName, FILE_READ | FILE_WRITE | FILE_CSV | FILE_ANSI | FILE_SHARE_READ | FILE_SHARE_WRITE);
   if(handle == INVALID_HANDLE)
   {
      Print(EA_NAME, ": entry opportunity audit summary open failed. error=", GetLastError());
      return;
   }
   FileSeek(handle, 0, SEEK_END);

   string line = "";
   CsvAppend(line, auditType);
   CsvAppend(line, TimeToString(TimeCurrent(), TIME_DATE | TIME_SECONDS));
   CsvAppend(line, _Symbol);
   CsvAppend(line, "ALL");
   CsvAppend(line, "");
   CsvAppend(line, "");
   CsvAppend(line, "");
   CsvAppend(line, "");
   CsvAppend(line, "");
   CsvAppend(line, DoubleToString(MinimumScoreDifference, 2));
   CsvAppend(line, "");
   CsvAppend(line, IntegerToString(currentHistoricalTimeSourceHour));
   CsvAppend(line, currentHistoricalTimeRiskState);
   CsvAppend(line, BoolText(currentNewsBlockActive));
   CsvAppend(line, tradeEventDxy.state);
   CsvAppend(line, tradeEventVix.state);
   CsvAppend(line, "");
   CsvAppend(line, "");
   CsvAppend(line, "");
   CsvAppend(line, "");
   CsvAppend(line, "");
   CsvAppend(line, "");
   CsvAppend(line, auditType);
   CsvAppend(line, "");
   CsvAppend(line, "");
   CsvAppend(line, "");
   CsvAppend(line, "");
   CsvAppend(line, "");
   CsvAppend(line, "");
   CsvAppend(line, "");
   CsvAppend(line, IntegerToString((int)auditRawTickSignalCount));
   CsvAppend(line, IntegerToString((int)auditRawBuyTickSignalCount));
   CsvAppend(line, IntegerToString((int)auditRawSellTickSignalCount));
   CsvAppend(line, IntegerToString((int)auditSpreadOkCandidateCount));
   CsvAppend(line, IntegerToString((int)auditBlockedBySpreadCount));
   CsvAppend(line, IntegerToString((int)auditBlockedByNewsCount));
   CsvAppend(line, IntegerToString((int)auditBlockedByDxyCount));
   CsvAppend(line, IntegerToString((int)auditBlockedByVixCount));
   CsvAppend(line, IntegerToString((int)auditBlockedByHistoricalTimeRiskCount));
   CsvAppend(line, IntegerToString((int)auditBlockedByQuietHourCount));
   CsvAppend(line, IntegerToString((int)auditBlockedByHighRiskHourCount));
   CsvAppend(line, IntegerToString((int)auditBlockedByWeekdayHourRiskCount));
   CsvAppend(line, IntegerToString((int)auditBlockedByEntryCooldownCount));
   CsvAppend(line, IntegerToString((int)auditBlockedBySameDirectionCooldownCount));
   CsvAppend(line, IntegerToString((int)auditBlockedByOppositeDirectionCooldownCount));
   CsvAppend(line, IntegerToString((int)auditBlockedByMaxPositionsCount));
   CsvAppend(line, IntegerToString((int)auditBlockedByTrendPullbackCount));
   CsvAppend(line, IntegerToString((int)auditBlockedByMaStructureCount));
   CsvAppend(line, IntegerToString((int)auditBlockedByMaSlopeCount));
   CsvAppend(line, IntegerToString((int)auditBlockedByEntryScoreCount));
   CsvAppend(line, IntegerToString((int)auditBlockedByMinimumScoreDifferenceCount));
   CsvAppend(line, IntegerToString((int)auditBlockedByFloatingLossStopCount));
   CsvAppend(line, IntegerToString((int)auditBlockedByDailyLossStopCount));
   CsvAppend(line, IntegerToString((int)auditBlockedByConsecutiveLossStopCount));
   CsvAppend(line, IntegerToString((int)auditBlockedByBasketStateCount));
   CsvAppend(line, IntegerToString((int)auditFinalEntryApprovedCount));
   CsvAppend(line, IntegerToString((int)auditActualOrderSendCount));
   CsvAppend(line, IntegerToString((int)auditOrderSendFailedCount));
   CsvAppend(line, IntegerToString((int)auditDailyRawTickSignalCount));
   CsvAppend(line, IntegerToString((int)auditDailyRawBuyTickSignalCount));
   CsvAppend(line, IntegerToString((int)auditDailyRawSellTickSignalCount));
   CsvAppend(line, IntegerToString((int)auditDailyFinalEntryApprovedCount));
   CsvAppend(line, IntegerToString((int)auditDailyActualOrderSendCount));
   CsvAppend(line, IntegerToString((int)auditDailyOrderSendFailedCount));
   PerfFileWriteString(handle, line + "\r\n");
   FileClose(handle);
}

void WriteEntryOpportunityAuditHeader()
{
   int handle = FileOpen(EntryOpportunityAuditFileName, FILE_READ | FILE_WRITE | FILE_CSV | FILE_ANSI | FILE_SHARE_READ | FILE_SHARE_WRITE);
   if(handle == INVALID_HANDLE)
   {
      Print(EA_NAME, ": entry opportunity audit header open failed. error=", GetLastError());
      return;
   }

   if(FileSize(handle) == 0)
   {
      string line = "";
      CsvAppend(line, "AuditType"); CsvAppend(line, "Time"); CsvAppend(line, "Symbol"); CsvAppend(line, "Direction");
      CsvAppend(line, "RawTickScoreBuy"); CsvAppend(line, "RawTickScoreSell"); CsvAppend(line, "TickScoreDifference");
      CsvAppend(line, "EntryScore"); CsvAppend(line, "EntryScoreThreshold"); CsvAppend(line, "MinimumScoreDifference"); CsvAppend(line, "Spread");
      CsvAppend(line, "HistoricalTimeSourceHour"); CsvAppend(line, "HistoricalTimeRiskState");
      CsvAppend(line, "NewsBlockActive"); CsvAppend(line, "DxyState"); CsvAppend(line, "VixState");
      CsvAppend(line, "PositionCountTotal"); CsvAppend(line, "PositionCountBuy"); CsvAppend(line, "PositionCountSell"); CsvAppend(line, "CurrentBasketState");
      CsvAppend(line, "RejectedReasonPrimary"); CsvAppend(line, "RejectedReasonSecondary"); CsvAppend(line, "RejectedReasonAll");
      CsvAppend(line, "OpenPrice"); CsvAppend(line, "FutureM5RangeAfter30Min"); CsvAppend(line, "FutureM5RangeAfter60Min");
      CsvAppend(line, "FutureCloseMoveAfter30Min"); CsvAppend(line, "FutureCloseMoveAfter60Min");
      CsvAppend(line, "WouldHitSmallTpEstimate"); CsvAppend(line, "WouldHitDangerMoveEstimate");
      CsvAppend(line, "RawTickSignalCount"); CsvAppend(line, "RawBuyTickSignalCount"); CsvAppend(line, "RawSellTickSignalCount"); CsvAppend(line, "SpreadOkCandidateCount");
      CsvAppend(line, "BlockedBySpreadCount"); CsvAppend(line, "BlockedByNewsCount"); CsvAppend(line, "BlockedByDxyCount"); CsvAppend(line, "BlockedByVixCount");
      CsvAppend(line, "BlockedByHistoricalTimeRiskCount"); CsvAppend(line, "BlockedByQuietHourCount"); CsvAppend(line, "BlockedByHighRiskHourCount"); CsvAppend(line, "BlockedByWeekdayHourRiskCount");
      CsvAppend(line, "BlockedByEntryCooldownCount"); CsvAppend(line, "BlockedBySameDirectionCooldownCount"); CsvAppend(line, "BlockedByOppositeDirectionCooldownCount");
      CsvAppend(line, "BlockedByMaxPositionsCount"); CsvAppend(line, "BlockedByTrendPullbackCount"); CsvAppend(line, "BlockedByMaStructureCount"); CsvAppend(line, "BlockedByMaSlopeCount");
      CsvAppend(line, "BlockedByEntryScoreCount"); CsvAppend(line, "BlockedByMinimumScoreDifferenceCount"); CsvAppend(line, "BlockedByFloatingLossStopCount");
      CsvAppend(line, "BlockedByDailyLossStopCount"); CsvAppend(line, "BlockedByConsecutiveLossStopCount"); CsvAppend(line, "BlockedByBasketStateCount");
      CsvAppend(line, "FinalEntryApprovedCount"); CsvAppend(line, "ActualOrderSendCount"); CsvAppend(line, "OrderSendFailedCount");
      CsvAppend(line, "DailyRawTickSignalCount"); CsvAppend(line, "DailyRawBuyTickSignalCount"); CsvAppend(line, "DailyRawSellTickSignalCount");
      CsvAppend(line, "DailyFinalEntryApprovedCount"); CsvAppend(line, "DailyActualOrderSendCount"); CsvAppend(line, "DailyOrderSendFailedCount");
      PerfFileWriteString(handle, line + "\r\n");
   }

   FileClose(handle);
}

string AuditAppendReason(string reasons, string reason)
{
   if(reason == "")
      return reasons;
   if(reasons == "")
      return reason;
   if(StringFind(reasons, reason) >= 0)
      return reasons;
   return reasons + "|" + reason;
}

string AuditReasonAt(string reasons, int index)
{
   string parts[];
   int count = StringSplit(reasons, '|', parts);
   if(index < 0 || index >= count)
      return "";
   return parts[index];
}

string GetCurrentBasketState(const PositionState &ps)
{
   if(CountDefenseHedges() > 0)
      return "hedged_basket";
   if(ps.total >= BasketMinPositions)
      return "basket_active";
   if(ps.total > 0)
      return "position_active";
   return "flat";
}

bool GetRawTickCandidateDirection(int &direction)
{
   direction = 0;
   int count = ArraySize(ticks);
   if(count < MinimumTicksInWindow)
      return false;

   double move = ticks[count - 1].mid - ticks[0].mid;
   double absMove = MathAbs(move);
   if(absMove < MinimumTickWindowMove || absMove > MaximumTickWindowMove)
      return false;

   if(move > 0.0)
      direction = 1;
   else if(move < 0.0)
      direction = -1;

   return direction != 0;
}

void WriteEntryOpportunityAuditLog(string auditType,
                                   string directionText,
                                   const MqlTick &tick,
                                   const ScoreState &score,
                                   double threshold,
                                   string rejectedReasonAll,
                                   const FilterState &dxy,
                                   const FilterState &vix,
                                   bool newsBlock,
                                   const PositionState &ps)
{
   if(!UseEntryOpportunityAudit)
      return;

   WriteEntryOpportunityAuditHeader();
   int handle = FileOpen(EntryOpportunityAuditFileName, FILE_READ | FILE_WRITE | FILE_CSV | FILE_ANSI | FILE_SHARE_READ | FILE_SHARE_WRITE);
   if(handle == INVALID_HANDLE)
   {
      Print(EA_NAME, ": entry opportunity audit open failed. error=", GetLastError());
      return;
   }
   FileSeek(handle, 0, SEEK_END);

   double entryScore = directionText == "BUY" ? score.longScore : score.shortScore;
   double spread = tick.ask - tick.bid;
   string primary = AuditReasonAt(rejectedReasonAll, 0);
   string secondary = AuditReasonAt(rejectedReasonAll, 1);
   double openPrice = directionText == "BUY" ? tick.ask : tick.bid;

   string line = "";
   CsvAppend(line, auditType);
   CsvAppend(line, TimeToString(TimeCurrent(), TIME_DATE | TIME_SECONDS));
   CsvAppend(line, _Symbol);
   CsvAppend(line, directionText);
   CsvAppend(line, DoubleToString(score.longScore, 2));
   CsvAppend(line, DoubleToString(score.shortScore, 2));
   CsvAppend(line, DoubleToString(MathAbs(score.longScore - score.shortScore), 2));
   CsvAppend(line, DoubleToString(entryScore, 2));
   CsvAppend(line, DoubleToString(threshold, 2));
   CsvAppend(line, DoubleToString(MinimumScoreDifference, 2));
   CsvAppend(line, DoubleToString(spread, 2));
   CsvAppend(line, IntegerToString(currentHistoricalTimeSourceHour));
   CsvAppend(line, currentHistoricalTimeRiskState);
   CsvAppend(line, BoolText(newsBlock));
   CsvAppend(line, dxy.state);
   CsvAppend(line, vix.state);
   CsvAppend(line, IntegerToString(ps.total));
   CsvAppend(line, IntegerToString(ps.buys));
   CsvAppend(line, IntegerToString(ps.sells));
   CsvAppend(line, GetCurrentBasketState(ps));
   CsvAppend(line, primary);
   CsvAppend(line, secondary);
   CsvAppend(line, rejectedReasonAll);
   CsvAppend(line, DoubleToString(openPrice, _Digits));
   CsvAppend(line, "");
   CsvAppend(line, "");
   CsvAppend(line, "");
   CsvAppend(line, "");
   CsvAppend(line, "");
   CsvAppend(line, "");
   CsvAppend(line, IntegerToString((int)auditRawTickSignalCount));
   CsvAppend(line, IntegerToString((int)auditRawBuyTickSignalCount));
   CsvAppend(line, IntegerToString((int)auditRawSellTickSignalCount));
   CsvAppend(line, IntegerToString((int)auditSpreadOkCandidateCount));
   CsvAppend(line, IntegerToString((int)auditBlockedBySpreadCount));
   CsvAppend(line, IntegerToString((int)auditBlockedByNewsCount));
   CsvAppend(line, IntegerToString((int)auditBlockedByDxyCount));
   CsvAppend(line, IntegerToString((int)auditBlockedByVixCount));
   CsvAppend(line, IntegerToString((int)auditBlockedByHistoricalTimeRiskCount));
   CsvAppend(line, IntegerToString((int)auditBlockedByQuietHourCount));
   CsvAppend(line, IntegerToString((int)auditBlockedByHighRiskHourCount));
   CsvAppend(line, IntegerToString((int)auditBlockedByWeekdayHourRiskCount));
   CsvAppend(line, IntegerToString((int)auditBlockedByEntryCooldownCount));
   CsvAppend(line, IntegerToString((int)auditBlockedBySameDirectionCooldownCount));
   CsvAppend(line, IntegerToString((int)auditBlockedByOppositeDirectionCooldownCount));
   CsvAppend(line, IntegerToString((int)auditBlockedByMaxPositionsCount));
   CsvAppend(line, IntegerToString((int)auditBlockedByTrendPullbackCount));
   CsvAppend(line, IntegerToString((int)auditBlockedByMaStructureCount));
   CsvAppend(line, IntegerToString((int)auditBlockedByMaSlopeCount));
   CsvAppend(line, IntegerToString((int)auditBlockedByEntryScoreCount));
   CsvAppend(line, IntegerToString((int)auditBlockedByMinimumScoreDifferenceCount));
   CsvAppend(line, IntegerToString((int)auditBlockedByFloatingLossStopCount));
   CsvAppend(line, IntegerToString((int)auditBlockedByDailyLossStopCount));
   CsvAppend(line, IntegerToString((int)auditBlockedByConsecutiveLossStopCount));
   CsvAppend(line, IntegerToString((int)auditBlockedByBasketStateCount));
   CsvAppend(line, IntegerToString((int)auditFinalEntryApprovedCount));
   CsvAppend(line, IntegerToString((int)auditActualOrderSendCount));
   CsvAppend(line, IntegerToString((int)auditOrderSendFailedCount));
   CsvAppend(line, IntegerToString((int)auditDailyRawTickSignalCount));
   CsvAppend(line, IntegerToString((int)auditDailyRawBuyTickSignalCount));
   CsvAppend(line, IntegerToString((int)auditDailyRawSellTickSignalCount));
   CsvAppend(line, IntegerToString((int)auditDailyFinalEntryApprovedCount));
   CsvAppend(line, IntegerToString((int)auditDailyActualOrderSendCount));
   CsvAppend(line, IntegerToString((int)auditDailyOrderSendFailedCount));
   PerfFileWriteString(handle, line + "\r\n");
   FileClose(handle);
}

void AuditEntryOpportunity(const MqlTick &tick,
                           const ScoreState &score,
                           const PositionState &ps,
                           const FilterState &dxy,
                           const FilterState &vix,
                           bool newsBlock,
                           string newsReason,
                           bool htfBuyBlock,
                           bool htfSellBlock,
                           bool goldBuyOk,
                           bool goldSellOk,
                           string goldBuyReason,
                           string goldSellReason,
                           const PullbackState &pullback,
                           const MaStructureState &ma,
                           double marginLevel,
                           bool dailyStop,
                           bool consecutiveStop,
                           bool hardStop,
                           double threshold)
{
   if(!UseEntryOpportunityAudit)
      return;

   ResetAuditDailyIfNeeded();

   int direction = 0;
   if(!GetRawTickCandidateDirection(direction))
      return;

   bool isBuy = direction > 0;
   string directionText = isBuy ? "BUY" : "SELL";
   double entryScore = isBuy ? score.longScore : score.shortScore;
   double oppositeScore = isBuy ? score.shortScore : score.longScore;
   double scoreDifference = MathAbs(score.longScore - score.shortScore);
   double spread = tick.ask - tick.bid;

   auditRawTickSignalCount++;
   auditDailyRawTickSignalCount++;
   if(isBuy)
   {
      auditRawBuyTickSignalCount++;
      auditDailyRawBuyTickSignalCount++;
   }
   else
   {
      auditRawSellTickSignalCount++;
      auditDailyRawSellTickSignalCount++;
   }

   string reasons = "";
   if(spread <= MaxSpreadPrice)
      auditSpreadOkCandidateCount++;
   else
   {
      auditBlockedBySpreadCount++;
      reasons = AuditAppendReason(reasons, "Spread");
   }

   if(entryScore < threshold || entryScore <= oppositeScore)
   {
      auditBlockedByEntryScoreCount++;
      reasons = AuditAppendReason(reasons, "EntryScore");
   }
   if(scoreDifference < MinimumScoreDifference)
   {
      auditBlockedByMinimumScoreDifferenceCount++;
      reasons = AuditAppendReason(reasons, "MinimumScoreDifference");
   }
   if(newsBlock && BlockNewEntryDuringNews)
   {
      auditBlockedByNewsCount++;
      reasons = AuditAppendReason(reasons, "News");
   }
   if(!dxy.ok || dxy.stop || (UseDxyFilter && UseDxyHardBlock && ((isBuy && dxy.state == "bullish") || (!isBuy && dxy.state == "bearish"))))
   {
      auditBlockedByDxyCount++;
      reasons = AuditAppendReason(reasons, "DXY");
   }
   if(!vix.ok || vix.stop || vix.extreme)
   {
      auditBlockedByVixCount++;
      reasons = AuditAppendReason(reasons, "VIX");
   }
   if(currentHistoricalTimeQuiet && BlockNewEntryInQuietHours)
   {
      auditBlockedByHistoricalTimeRiskCount++;
      auditBlockedByQuietHourCount++;
      reasons = AuditAppendReason(reasons, "QuietHour");
   }
   if(currentHistoricalTimeHighRisk)
   {
      auditBlockedByHighRiskHourCount++;
      if(BlockBreakoutChaseInHighRiskHours && currentTechnicalDangerActive)
      {
         auditBlockedByHistoricalTimeRiskCount++;
         reasons = AuditAppendReason(reasons, "HighRiskHour");
      }
   }
   if(currentHistoricalWeekdayHourBlock)
   {
      auditBlockedByWeekdayHourRiskCount++;
      if(BlockBreakoutChaseInHighRiskHours && currentTechnicalDangerActive)
      {
         auditBlockedByHistoricalTimeRiskCount++;
         reasons = AuditAppendReason(reasons, "WeekdayHourRisk");
      }
   }
   if(TimeCurrent() - lastEntryTime < EntryCooldownSeconds)
   {
      auditBlockedByEntryCooldownCount++;
      reasons = AuditAppendReason(reasons, "EntryCooldown");
   }
   int desiredDirection = isBuy ? 1 : -1;
   if(lastEntryDirection == desiredDirection && SameDirectionReentryCooldownSeconds > 0 &&
      TimeCurrent() - lastEntryTime < SameDirectionReentryCooldownSeconds)
   {
      auditBlockedBySameDirectionCooldownCount++;
      reasons = AuditAppendReason(reasons, "SameDirectionCooldown");
   }
   if(lastEntryDirection != 0 && lastEntryDirection != desiredDirection && GetOppositeCooldownRemaining() > 0)
   {
      auditBlockedByOppositeDirectionCooldownCount++;
      reasons = AuditAppendReason(reasons, "OppositeDirectionCooldown");
   }

   string limitReason = "";
   if(!CheckPositionLimits(isBuy, ps, limitReason))
   {
      auditBlockedByMaxPositionsCount++;
      reasons = AuditAppendReason(reasons, "MaxPositions");
   }
   if((isBuy && !pullback.okBuy) || (!isBuy && !pullback.okSell))
   {
      auditBlockedByTrendPullbackCount++;
      reasons = AuditAppendReason(reasons, "TrendPullback");
   }
   if((isBuy && !ma.okBuy) || (!isBuy && !ma.okSell))
   {
      auditBlockedByMaStructureCount++;
      reasons = AuditAppendReason(reasons, "MaStructure");
   }
   string slopeReason = isBuy ? ma.slopeReasonBuy : ma.slopeReasonSell;
   if(slopeReason != "" && StringFind(slopeReason, "slope") >= 0 && ((isBuy && !ma.okBuy) || (!isBuy && !ma.okSell)))
   {
      auditBlockedByMaSlopeCount++;
      reasons = AuditAppendReason(reasons, "MaSlope");
   }
   if((isBuy && htfBuyBlock) || (!isBuy && htfSellBlock))
      reasons = AuditAppendReason(reasons, "HigherTimeframe");
   if((isBuy && !goldBuyOk) || (!isBuy && !goldSellOk))
      reasons = AuditAppendReason(reasons, isBuy ? goldBuyReason : goldSellReason);
   if(ps.floatingLossPercent >= StopNewEntryFloatingLossPercent || marginLevel <= StopNewEntryMarginLevel)
   {
      auditBlockedByFloatingLossStopCount++;
      reasons = AuditAppendReason(reasons, "FloatingLossStop");
   }
   if(dailyStop)
   {
      auditBlockedByDailyLossStopCount++;
      reasons = AuditAppendReason(reasons, "DailyLossStop");
   }
   if(consecutiveStop)
   {
      auditBlockedByConsecutiveLossStopCount++;
      reasons = AuditAppendReason(reasons, "ConsecutiveLossStop");
   }
   if(hardStop || ps.total > 0 || CountDefenseHedges() > 0)
   {
      auditBlockedByBasketStateCount++;
      if(ps.total > 0 || CountDefenseHedges() > 0)
         reasons = AuditAppendReason(reasons, "BasketState");
   }

   bool approved = (reasons == "");
   if(approved)
   {
      auditFinalEntryApprovedCount++;
      auditDailyFinalEntryApprovedCount++;
   }

   int summaryIntervalSeconds = MathMax(60, AuditSummaryIntervalMinutes * 60);
   if((UseBacktestLightLogMode || IsFastCompareMode() || AuditSummaryOnlyMode) &&
      (lastAuditSummaryTime == 0 || TimeCurrent() - lastAuditSummaryTime >= summaryIntervalSeconds))
   {
      WriteEntryOpportunityAuditSummary("PERIODIC_SUMMARY");
      lastAuditSummaryTime = TimeCurrent();
   }

   bool logRejectedDetails = EffectiveRejectedEntryDetailLogEnabled();
   bool logShadowDetails = EffectiveShadowEntryCandidateLogEnabled();
   if(!UseBacktestLightLogMode && !IsFastCompareMode() && !AuditSummaryOnlyMode &&
      (logRejectedDetails || logShadowDetails) && auditRejectedLogsToday < MaxRejectedEntryLogsPerDay)
   {
      if(!approved && logRejectedDetails)
      {
         WriteEntryOpportunityAuditLog("REJECTED", directionText, tick, score, threshold, reasons, dxy, vix, newsBlock, ps);
         auditRejectedLogsToday++;
      }
      else if(approved && logShadowDetails)
      {
         WriteEntryOpportunityAuditLog("APPROVED_SHADOW", directionText, tick, score, threshold, "", dxy, vix, newsBlock, ps);
         auditRejectedLogsToday++;
      }
   }
}

double DailyLossPercentValue(double dailyPL)
{
   double balance = AccountInfoDouble(ACCOUNT_BALANCE);
   if(balance <= 0.0 || dailyPL >= 0.0)
      return 0.0;
   return MathAbs(dailyPL) / balance * 100.0;
}

string TradeEventTypeFromOpenComment(bool isBuy, string comment)
{
   if(StringFind(comment, "fixed add") >= 0 || StringFind(comment, "planned add") >= 0)
      return isBuy ? "ADD_BUY" : "ADD_SELL";
   if(StringFind(comment, "reactive defense hedge") >= 0)
      return "SINGLE_REACTIVE_DEFENSE_HEDGE";
   if(StringFind(comment, "defense hedge") >= 0)
      return isBuy ? "DEFENSE_HEDGE_BUY" : "DEFENSE_HEDGE_SELL";
   return isBuy ? "ENTRY_BUY" : "ENTRY_SELL";
}

string TradeEventTypeFromCloseReason(string reason)
{
   if(StringFind(reason, "S2_PRE_HARDSTOP_STRICT_GUARD_EXIT") >= 0)
      return "S2_PRE_HS_EXIT";
   if(StringFind(reason, "CW8_OUTSIDE_HTE_BAND_EXIT") >= 0)
      return "CW8_EXIT";
   if(StringFind(reason, "L1_M5_R12_LARGE_ADVERSE_EXIT") >= 0)
      return "L1_EXIT";
   if(StringFind(reason, "B2_G5_BALANCED_SIMPLE_GUARD_EXIT") >= 0)
      return "B2_G5_EXIT";
   if(StringFind(reason, "POST_HEDGE_RECOVERY_FAILURE_EXIT") >= 0 ||
      StringFind(reason, "Post hedge recovery failure exit") >= 0)
      return "POST_HEDGE_RECOVERY_FAILURE_EXIT";
   if(StringFind(reason, "Post hedge selective good enough close") >= 0)
      return "POST_HEDGE_SELECTIVE_GOOD_ENOUGH_CLOSE";
   if(StringFind(reason, "Post hedge selective max loss close") >= 0)
      return "POST_HEDGE_SELECTIVE_MAX_LOSS_CLOSE";
   if(StringFind(reason, "Post hedge selective no improvement close") >= 0)
      return "POST_HEDGE_SELECTIVE_NO_IMPROVEMENT_CLOSE";
   if(StringFind(reason, "Post hedge selective hard time close") >= 0)
      return "POST_HEDGE_SELECTIVE_HARD_TIME_CLOSE";
   if(StringFind(reason, "Post hedge good enough close") >= 0)
      return "POST_HEDGE_GOOD_ENOUGH_CLOSE";
   if(StringFind(reason, "Post hedge max loss close") >= 0)
      return "POST_HEDGE_MAX_LOSS_CLOSE";
   if(StringFind(reason, "Post hedge no improvement close") >= 0)
      return "POST_HEDGE_NO_IMPROVEMENT_CLOSE";
   if(StringFind(reason, "Post hedge hard time close") >= 0)
      return "POST_HEDGE_HARD_TIME_CLOSE";
   if(StringFind(reason, "Post hedge against strong trend close") >= 0)
      return "POST_HEDGE_AGAINST_STRONG_TREND_CLOSE";
   if(StringFind(reason, "Reactive hedge basket close") >= 0)
      return "REACTIVE_HEDGE_BASKET_CLOSE";
   if(StringFind(reason, "Reactive hedge max loss close") >= 0)
      return "REACTIVE_HEDGE_MAX_LOSS_CLOSE";
   if(StringFind(reason, "Reactive hedge time close") >= 0)
      return "REACTIVE_HEDGE_TIME_CLOSE";
   if(StringFind(reason, "Hedged basket time exit") >= 0 ||
      StringFind(reason, "Hedged basket danger") >= 0 ||
      StringFind(reason, "time exit") >= 0)
      return "HEDGED_BASKET_TIME_EXIT";
   if(StringFind(reason, "structure based early exit") >= 0)
      return "STRUCTURE_BASED_EARLY_EXIT";
   if(StringFind(reason, "Hedged basket loss compression") >= 0)
      return "HEDGED_BASKET_LOSS_COMPRESSION";
   if(StringFind(reason, "recovery losscut") >= 0 || StringFind(reason, "acceptable loss") >= 0)
      return "BASKET_RECOVERY_LOSSCUT_CLOSE";
   if(StringFind(reason, "basket recovery") >= 0)
      return "BASKET_RECOVERY_CLOSE";
   if(StringFind(reason, "basket close") >= 0)
      return "BASKET_CLOSE";
   if(StringFind(reason, "hard stop") >= 0)
      return "HARDSTOP_CLOSE";
   return "BASKET_CLOSE";
}

void UpdateTradeEventContext(const MqlTick &tick,
                             const ScoreState &score,
                             string signal,
                             const FilterState &dxy,
                             const FilterState &vix,
                             string newsState,
                             string htfState,
                             const PullbackState &pullback,
                             const MaStructureState &ma,
                             const PositionState &ps,
                             double marginLevel,
                             double dailyPL,
                             int consecutiveLosses,
                             double threshold)
{
   tradeEventTick = tick;
   tradeEventScore = score;
   tradeEventSignal = signal;
   tradeEventDxy = dxy;
   tradeEventVix = vix;
   tradeEventNewsState = newsState;
   tradeEventHtfState = htfState;
   tradeEventPullback = pullback;
   tradeEventMa = ma;
   tradeEventPosition = ps;
   tradeEventMarginLevel = marginLevel;
   tradeEventDailyPL = dailyPL;
   tradeEventConsecutiveLosses = consecutiveLosses;
   tradeEventThreshold = threshold;
   tradeEventContextReady = true;
}

void WriteTradeEventHeader()
{
   int handle = FileOpen(TradeEventLogFileName, FILE_READ | FILE_WRITE | FILE_CSV | FILE_ANSI | FILE_SHARE_READ | FILE_SHARE_WRITE);
   if(handle == INVALID_HANDLE)
   {
      Print(EA_NAME, ": trade event log header open failed. error=", GetLastError());
      return;
   }

   if(FileSize(handle) == 0)
   {
      string line = "";
      CsvAppend(line, "TesterTime"); CsvAppend(line, "ServerTime"); CsvAppend(line, "EventType"); CsvAppend(line, "Symbol"); CsvAppend(line, "MagicNumber");
      CsvAppend(line, "Ticket"); CsvAppend(line, "Retcode"); CsvAppend(line, "RetcodeDescription"); CsvAppend(line, "Comment");
      CsvAppend(line, "Bid"); CsvAppend(line, "Ask"); CsvAppend(line, "SpreadPrice");
      CsvAppend(line, "OrderDirection"); CsvAppend(line, "OrderLots"); CsvAppend(line, "OrderPrice"); CsvAppend(line, "OrderSL"); CsvAppend(line, "OrderTP");
      CsvAppend(line, "ClosePrice"); CsvAppend(line, "ProfitYen"); CsvAppend(line, "BasketNetProfitYen");
      CsvAppend(line, "Balance"); CsvAppend(line, "Equity"); CsvAppend(line, "MarginLevel"); CsvAppend(line, "FloatingProfitYen"); CsvAppend(line, "FloatingLossPercent");
      CsvAppend(line, "DailyProfitYen"); CsvAppend(line, "DailyLossPercent"); CsvAppend(line, "ConsecutiveLosses");
      CsvAppend(line, "LongScore"); CsvAppend(line, "ShortScore"); CsvAppend(line, "ScoreDifference"); CsvAppend(line, "EntryScoreThreshold"); CsvAppend(line, "MinimumScoreDifference");
      CsvAppend(line, "Signal"); CsvAppend(line, "LastStopReason"); CsvAppend(line, "LastEntryDirection"); CsvAppend(line, "LastTradeActionTime"); CsvAppend(line, "LastAnyEaCloseTime");
      CsvAppend(line, "LastHardStopTime"); CsvAppend(line, "HardStopAfterMode"); CsvAppend(line, "HardStopCooldownMinutes"); CsvAppend(line, "HardStopCooldownRemaining");
      CsvAppend(line, "HTFState"); CsvAppend(line, "HigherTimeframeDirection"); CsvAppend(line, "DxyValue"); CsvAppend(line, "DxyState"); CsvAppend(line, "VixValue"); CsvAppend(line, "VixState"); CsvAppend(line, "NewsState");
      CsvAppend(line, "PullbackMode"); CsvAppend(line, "PullbackDirection"); CsvAppend(line, "PullbackOkBuy"); CsvAppend(line, "PullbackOkSell");
      CsvAppend(line, "PullbackBlockReasonBuy"); CsvAppend(line, "PullbackBlockReasonSell"); CsvAppend(line, "PullbackRsiValue"); CsvAppend(line, "PullbackEma20"); CsvAppend(line, "PullbackEma50");
      CsvAppend(line, "RecentHigh"); CsvAppend(line, "RecentLow"); CsvAppend(line, "DistanceFromRecentHigh"); CsvAppend(line, "DistanceFromRecentLow");
      CsvAppend(line, "SpikeUpBlocked"); CsvAppend(line, "SpikeDownBlocked"); CsvAppend(line, "CounterTrendBlocked");
      CsvAppend(line, "MaStructureMode"); CsvAppend(line, "MaTrendDirection"); CsvAppend(line, "MaFastValue"); CsvAppend(line, "MaMiddleValue"); CsvAppend(line, "MaLongValue");
      CsvAppend(line, "MaFastAboveMiddle"); CsvAppend(line, "MaMiddleAboveLong"); CsvAppend(line, "DistanceToMaFast"); CsvAppend(line, "DistanceToMaMiddle");
      CsvAppend(line, "PriceTooFarFromMa"); CsvAppend(line, "PriceNearMaPullback"); CsvAppend(line, "MaFlatBlocked"); CsvAppend(line, "MaCrossState");
      CsvAppend(line, "MaCrossWaitBlocked"); CsvAppend(line, "MaStructureBlockReasonBuy"); CsvAppend(line, "MaStructureBlockReasonSell");
      CsvAppend(line, "MaFastSlope"); CsvAppend(line, "MaMiddleSlope"); CsvAppend(line, "MaLongSlope");
      CsvAppend(line, "MaFastSlopeState"); CsvAppend(line, "MaMiddleSlopeState"); CsvAppend(line, "MaLongSlopeState");
      CsvAppend(line, "MaSlopeBlockReasonBuy"); CsvAppend(line, "MaSlopeBlockReasonSell"); CsvAppend(line, "BuyingIntoFallingMa"); CsvAppend(line, "SellingIntoRisingMa");
      CsvAppend(line, "TrendMainDirection"); CsvAppend(line, "MainDirectionPositions"); CsvAppend(line, "DefenseHedgePositions");
      CsvAppend(line, "AddPositionAllowed"); CsvAppend(line, "AddPositionBlockReason"); CsvAppend(line, "DefenseHedgeAllowed"); CsvAppend(line, "DefenseHedgeBlockReason");
      CsvAppend(line, "BasketRecoveryCloseActive"); CsvAppend(line, "BasketRecoveryAcceptLossYen");
      CsvAppend(line, "HedgedBasketMaxHoldMinutes"); CsvAppend(line, "HedgedBasketTimeExitAcceptLossYen"); CsvAppend(line, "FirstDefenseHedgeTime");
      CsvAppend(line, "UseBasketRecoveryLossCutMinHold"); CsvAppend(line, "BasketRecoveryLossCutMinHoldMinutes");
      CsvAppend(line, "UseBasketRecoveryImprovementCheck"); CsvAppend(line, "BasketRecoveryRequiredImprovementYen");
      CsvAppend(line, "UseWorstBasketAfterHedgeAsReference"); CsvAppend(line, "BasketRecoveryInitialProfit"); CsvAppend(line, "BasketRecoveryWorstProfit");
      CsvAppend(line, "CountRecoveryLossCutAsConsecutiveLoss"); CsvAppend(line, "RecoveryLossCutConsecutiveLossMinYen");
      CsvAppend(line, "MaxNetPositions"); CsvAppend(line, "MaxConsecutiveLosses");
      CsvAppend(line, "NewsCsvLoaded"); CsvAppend(line, "NewsCsvFileName"); CsvAppend(line, "NewsCsvLoadError"); CsvAppend(line, "NewsCsvEventCount");
      CsvAppend(line, "NewsBlockActive"); CsvAppend(line, "NewsBlockReason"); CsvAppend(line, "NewsBlockEventName");
      CsvAppend(line, "NewsBlockStartTimeServer"); CsvAppend(line, "NewsBlockEndTimeServer");
      CsvAppend(line, "NewsBlockEventTimeJST"); CsvAppend(line, "NewsBlockEventTimeServer");
      CsvAppend(line, "BlockedByNewsCount"); CsvAppend(line, "BlockedNewEntryByNewsCount"); CsvAppend(line, "BlockedAddPositionByNewsCount");
      CsvAppend(line, "BlockedDefenseHedgeByNewsCount"); CsvAppend(line, "BlockedHedgedBasketTimeExitByNewsCount");
      CsvAppend(line, "TechnicalDangerBlockActive"); CsvAppend(line, "TechnicalDangerBlockReason");
      CsvAppend(line, "BlockedByTechnicalDangerCount"); CsvAppend(line, "BlockedHedgedBasketTimeExitByTechnicalDangerCount");
      CsvAppend(line, "AllowPureTickEntry"); CsvAppend(line, "UseStructureBeforeTickEntry"); CsvAppend(line, "StructurePermission"); CsvAppend(line, "CandlePatternPermission");
      CsvAppend(line, "TickTriggerPermission"); CsvAppend(line, "TickScoreBuy"); CsvAppend(line, "TickScoreSell"); CsvAppend(line, "TickScoreDifference"); CsvAppend(line, "TickScoreAtEntry");
      CsvAppend(line, "BlockedPureTickEntry"); CsvAppend(line, "BlockedPureTickEntryReason"); CsvAppend(line, "BlockedPureTickEntryCount");
      CsvAppend(line, "MacroFibDirection"); CsvAppend(line, "DayFibDirection"); CsvAppend(line, "EntryFibDirection");
      CsvAppend(line, "MacroFibStartPrice"); CsvAppend(line, "MacroFibEndPrice"); CsvAppend(line, "DayFibStartPrice"); CsvAppend(line, "DayFibEndPrice");
      CsvAppend(line, "EntryFibStartPrice"); CsvAppend(line, "EntryFibEndPrice"); CsvAppend(line, "CurrentFibZone"); CsvAppend(line, "IsPriceInFibZone");
      CsvAppend(line, "FibTrendAligned"); CsvAppend(line, "MacroDayFibAligned"); CsvAppend(line, "FibStructureBroken");
      CsvAppend(line, "StructureTrendState"); CsvAppend(line, "H1H4BreakoutState"); CsvAppend(line, "PreviousDayHighDistance"); CsvAppend(line, "PreviousDayLowDistance");
      CsvAppend(line, "PivotDistance"); CsvAppend(line, "NearestSupportResistance"); CsvAppend(line, "LargeCandleDetected"); CsvAppend(line, "ConsecutiveCandleDetected");
      CsvAppend(line, "CandlePatternDetected"); CsvAppend(line, "CandlePatternType"); CsvAppend(line, "CandlePatternDirection"); CsvAppend(line, "CandlePatternTimeframe");
      CsvAppend(line, "CandlePatternNearStructure"); CsvAppend(line, "CandlePatternConfirmed"); CsvAppend(line, "CandleDangerDetected"); CsvAppend(line, "CandleDangerReason");
      CsvAppend(line, "EarlyExitReason"); CsvAppend(line, "PlannedAddReason"); CsvAppend(line, "HedgedBasketLossCompressionReason");
      CsvAppend(line, "StructureBasedEarlyExitCount"); CsvAppend(line, "StructureBasedEarlyExitProfitTotal"); CsvAppend(line, "PlannedAddPositionCount"); CsvAppend(line, "PlannedAddPositionProfitTotal");
      CsvAppend(line, "HedgedBasketLossCompressionCount"); CsvAppend(line, "BlockedByGoldStructureCount"); CsvAppend(line, "BlockedByFibContextCount"); CsvAppend(line, "BlockedByMacroDayMismatchCount");
      CsvAppend(line, "BlockedByPreviousDayHighLowCount"); CsvAppend(line, "BlockedByPivotCount"); CsvAppend(line, "BlockedByH1H4BreakoutCount"); CsvAppend(line, "BlockedByLargeCandleCount");
      CsvAppend(line, "BlockedByConsecutiveCandleCount"); CsvAppend(line, "BlockedByCandlePatternCount"); CsvAppend(line, "CandlePatternConfirmationCount");
      CsvAppend(line, "BullishPinBarCount"); CsvAppend(line, "BearishPinBarCount"); CsvAppend(line, "EngulfingConfirmationCount"); CsvAppend(line, "SpikeReversalConfirmationCount"); CsvAppend(line, "DojiDangerBlockCount");
      CsvAppend(line, "UseHistoricalTimeRiskFilter"); CsvAppend(line, "HistoricalTimeOffsetHours"); CsvAppend(line, "HistoricalTimeSourceWeekday"); CsvAppend(line, "HistoricalTimeSourceHour");
      CsvAppend(line, "HistoricalTimeRiskState"); CsvAppend(line, "HistoricalTimeRiskReason"); CsvAppend(line, "HistoricalTimeScoreAdd");
      CsvAppend(line, "HistoricalTimeHighRisk"); CsvAppend(line, "HistoricalTimeCaution"); CsvAppend(line, "HistoricalTimeQuiet"); CsvAppend(line, "HistoricalWeekdayHourBlock");
      CsvAppend(line, "BlockedByHistoricalTimeRiskCount"); CsvAppend(line, "BlockedNewEntryByHistoricalTimeRiskCount"); CsvAppend(line, "BlockedAddByHistoricalTimeRiskCount");
      CsvAppend(line, "BlockedDefenseHedgeByHistoricalTimeRiskCount"); CsvAppend(line, "BlockedBreakoutChaseByHistoricalTimeRiskCount");
      CsvAppend(line, "HardStopOriginEntryBlockCount"); CsvAppend(line, "HardStopOriginBlockReason"); CsvAppend(line, "HardStopOriginLargeCandleDirection");
      CsvAppend(line, "HardStopOriginEntryDirection"); CsvAppend(line, "SecondsAfterLargeCandle"); CsvAppend(line, "HasPullbackConfirmation");
      CsvAppend(line, "HasStructureConfirmation"); CsvAppend(line, "HardStopOriginEntryScore"); CsvAppend(line, "HardStopOriginEntryScoreThreshold");
      CsvAppend(line, "HardStopOriginEntryScoreBuffer");
      CsvAppend(line, "SingleReactiveDefenseHedgeCount"); CsvAppend(line, "ReactiveHedgeBasketCloseCount"); CsvAppend(line, "ReactiveHedgeMaxLossCloseCount");
      CsvAppend(line, "ReactiveHedgeTimeCloseCount"); CsvAppend(line, "ReactiveHedgeProfitTotal"); CsvAppend(line, "ReactiveHedgeReason");
      CsvAppend(line, "ReactiveHedgeTriggerLossYen"); CsvAppend(line, "ReactiveHedgeCurrentFloatingProfitYen"); CsvAppend(line, "ReactiveHedgeFloatingLossYen");
      CsvAppend(line, "ReactiveHedgeOppositeTickScore"); CsvAppend(line, "ReactiveHedgeOppositeScoreDiff"); CsvAppend(line, "ReactiveHedgeM5ConfirmationPassed");
      CsvAppend(line, "ReactiveHedgeConfirmBars"); CsvAppend(line, "ReactiveHedgeBasketCloseTargetYen"); CsvAppend(line, "ReactiveHedgeBasketMaxLossYen");
      CsvAppend(line, "ReactiveHedgeMaxHoldMinutes"); CsvAppend(line, "ReactiveHedgeCloseReason");
      CsvAppend(line, "SinglePositionContraryEarlyExitCount"); CsvAppend(line, "SinglePositionContraryEarlyExitProfitTotal");
      CsvAppend(line, "SingleEarlyExitReason"); CsvAppend(line, "SingleEarlyExitSoftLossYen"); CsvAppend(line, "SingleEarlyExitHardLossYen");
      CsvAppend(line, "CurrentFloatingProfitYen"); CsvAppend(line, "FloatingLossYen"); CsvAppend(line, "OppositeTickScore"); CsvAppend(line, "OppositeScoreDiff");
      CsvAppend(line, "PositionDirection"); CsvAppend(line, "PositionHoldSeconds"); CsvAppend(line, "MAReverseAtEarlyExit"); CsvAppend(line, "TrendReverseAtEarlyExit"); CsvAppend(line, "TickReverseAtEarlyExit");
      CsvAppend(line, "SingleEarlyExitPostCooldownActive"); CsvAppend(line, "SingleEarlyExitPostCooldownUntil");
      CsvAppend(line, "SingleEarlyExitPostCooldownBlockCount"); CsvAppend(line, "SameDirectionReentryBlockedAfterSingleEarlyExitCount");
      CsvAppend(line, "MaxSingleEarlyExitPerDayHitCount"); CsvAppend(line, "M5ConfirmationPassed"); CsvAppend(line, "M5ConfirmationBars");
      CsvAppend(line, "M5ConfirmationPassedCount"); CsvAppend(line, "M5ConfirmationFailedCount"); CsvAppend(line, "VixCautionAdjustmentApplied");
      CsvAppend(line, "EffectiveOppositeTickScoreThreshold"); CsvAppend(line, "EffectiveSoftLossYen"); CsvAppend(line, "EffectiveHardLossYen");
      CsvAppend(line, "LargeCandleEntryCautionCount"); CsvAppend(line, "LargeCandleEntryBlockedCount");
      CsvAppend(line, "LARGE_CANDLE_ENTRY_CAUTION"); CsvAppend(line, "LARGE_CANDLE_ENTRY_BLOCK"); CsvAppend(line, "LargeCandleDirection"); CsvAppend(line, "EntryDirection");
      CsvAppend(line, "LargeCandleEntryScoreAddForSingle"); CsvAppend(line, "BlockEntryOnLargeCandleAgainstMaTrend");
      PerfFileWriteString(handle, line + "\r\n");
   }
   FileClose(handle);
}

void WriteTradeEventLog(string eventType,
                        ulong ticket,
                        uint retcode,
                        string retcodeDescription,
                        string comment,
                        string orderDirection,
                        double orderLots,
                        double orderPrice,
                        double orderSL,
                        double orderTP,
                        double closePrice,
                        double profitYen,
                        double basketNetProfitYen)
{
   if(!EffectiveTradeEventLogEnabled())
      return;
   if(ShouldSuppressTradeEventInFastCompare(eventType))
      return;

   WriteTradeEventHeader();

   int handle = FileOpen(TradeEventLogFileName, FILE_READ | FILE_WRITE | FILE_CSV | FILE_ANSI | FILE_SHARE_READ | FILE_SHARE_WRITE);
   if(handle == INVALID_HANDLE)
   {
      Print(EA_NAME, ": trade event log open failed. error=", GetLastError());
      return;
   }
   FileSeek(handle, 0, SEEK_END);

   MqlTick tick = tradeEventTick;
   if(!tradeEventContextReady)
      SymbolInfoTick(_Symbol, tick);

   ScoreState score = tradeEventScore;
   FilterState dxy = tradeEventDxy;
   FilterState vix = tradeEventVix;
   PullbackState pullback = tradeEventPullback;
   MaStructureState ma = tradeEventMa;
   PositionState ps = tradeEventPosition;

   bool counterBlocked = pullback.counterTrendBlockedBuy || pullback.counterTrendBlockedSell;
   bool priceTooFar = ma.priceTooFarFromMaBuy || ma.priceTooFarFromMaSell;
   bool maCrossWaitBlocked = ma.maCrossWaitBlockedBuy || ma.maCrossWaitBlockedSell;
   int mainDirectionPositions = MathMax(ps.buys, ps.sells);
   int hedgePositions = CountDefenseHedges();
   datetime firstDefenseHedgeTime = GetFirstDefenseHedgeTime();
   bool basketRecoveryActive = UseBasketRecoveryClose && hedgePositions > 0 && ps.total >= 2;
   bool addAllowed = UseAddPosition && CountAddPositions(true) < MaxAddPositionsPerDirection && CountAddPositions(false) < MaxAddPositionsPerDirection;
   string addBlockReason = addAllowed ? "add position possible" : "ADD blocked: max add positions reached";
   bool defenseAllowed = lastDefenseHedgeAllowed;
   string defenseBlockReason = lastDefenseHedgeBlockReason;
   bool eventIsBuy = (StringFind(orderDirection, "BUY") >= 0 || tradeEventSignal == "BUY");
   bool directionStructurePermission = eventIsBuy ? currentStructureGate.structurePermissionBuy : currentStructureGate.structurePermissionSell;
   bool directionCandlePermission = eventIsBuy ? currentStructureGate.candlePermissionBuy : currentStructureGate.candlePermissionSell;
   bool directionTickPermission = eventIsBuy ? currentStructureGate.tickTriggerPermissionBuy : currentStructureGate.tickTriggerPermissionSell;
   bool directionBlockedPureTick = eventIsBuy ? currentStructureGate.blockedPureTickEntryBuy : currentStructureGate.blockedPureTickEntrySell;
   string directionBlockedPureTickReason = eventIsBuy ? currentStructureGate.blockedPureTickReasonBuy : currentStructureGate.blockedPureTickReasonSell;

   datetime serverTime = TimeTradeServer();
   if(serverTime <= 0)
      serverTime = TimeCurrent();

   string line = "";
   CsvAppend(line, TimeToString(TimeCurrent(), TIME_DATE | TIME_SECONDS));
   CsvAppend(line, TimeToString(serverTime, TIME_DATE | TIME_SECONDS));
   CsvAppend(line, eventType);
   CsvAppend(line, _Symbol);
   CsvAppend(line, UlongToText(MagicNumber));
   CsvAppend(line, UlongToText(ticket));
   CsvAppend(line, UintToText(retcode));
   CsvAppend(line, retcodeDescription);
   CsvAppend(line, comment);
   CsvAppend(line, DoubleToString(tick.bid, _Digits));
   CsvAppend(line, DoubleToString(tick.ask, _Digits));
   CsvAppend(line, DoubleToString(tick.ask - tick.bid, 2));
   CsvAppend(line, orderDirection);
   CsvAppend(line, DoubleToString(orderLots, 2));
   CsvAppend(line, DoubleToString(orderPrice, _Digits));
   CsvAppend(line, DoubleToString(orderSL, _Digits));
   CsvAppend(line, DoubleToString(orderTP, _Digits));
   CsvAppend(line, DoubleToString(closePrice, _Digits));
   CsvAppend(line, DoubleToString(profitYen, 2));
   CsvAppend(line, DoubleToString(basketNetProfitYen, 2));
   CsvAppend(line, DoubleToString(AccountInfoDouble(ACCOUNT_BALANCE), 2));
   CsvAppend(line, DoubleToString(AccountInfoDouble(ACCOUNT_EQUITY), 2));
   CsvAppend(line, DoubleToString(tradeEventMarginLevel, 2));
   CsvAppend(line, DoubleToString(ps.floatingProfit, 2));
   CsvAppend(line, DoubleToString(ps.floatingLossPercent, 2));
   CsvAppend(line, DoubleToString(tradeEventDailyPL, 2));
   CsvAppend(line, DoubleToString(DailyLossPercentValue(tradeEventDailyPL), 2));
   CsvAppend(line, IntegerToString(tradeEventConsecutiveLosses));
   CsvAppend(line, DoubleToString(score.longScore, 2));
   CsvAppend(line, DoubleToString(score.shortScore, 2));
   CsvAppend(line, DoubleToString(MathAbs(score.longScore - score.shortScore), 2));
   CsvAppend(line, DoubleToString(tradeEventThreshold, 2));
   CsvAppend(line, DoubleToString(MinimumScoreDifference, 2));
   CsvAppend(line, tradeEventSignal);
   CsvAppend(line, lastStopReason);
   CsvAppend(line, DirectionToString(lastEntryDirection));
   CsvAppend(line, TimeToString(lastTradeActionTime, TIME_DATE | TIME_SECONDS));
   CsvAppend(line, TimeToString(lastAnyEaCloseTime, TIME_DATE | TIME_SECONDS));
   CsvAppend(line, TimeToString(lastHardStopTime, TIME_DATE | TIME_SECONDS));
   CsvAppend(line, IntegerToString(HardStopAfterMode));
   CsvAppend(line, IntegerToString(HardStopCooldownMinutes));
   CsvAppend(line, IntegerToString(GetHardStopCooldownRemaining()));
   CsvAppend(line, tradeEventHtfState);
   CsvAppend(line, tradeEventHtfState);
   CsvAppend(line, DoubleToString(dxy.value, 4));
   CsvAppend(line, dxy.state);
   CsvAppend(line, DoubleToString(vix.value, 4));
   CsvAppend(line, vix.state);
   CsvAppend(line, tradeEventNewsState);
   CsvAppend(line, pullback.mode);
   CsvAppend(line, pullback.direction);
   CsvAppend(line, BoolText(pullback.okBuy));
   CsvAppend(line, BoolText(pullback.okSell));
   CsvAppend(line, pullback.reasonBuy);
   CsvAppend(line, pullback.reasonSell);
   CsvAppend(line, DoubleToString(pullback.rsi, 2));
   CsvAppend(line, DoubleToString(pullback.emaFast, _Digits));
   CsvAppend(line, DoubleToString(pullback.emaSlow, _Digits));
   CsvAppend(line, DoubleToString(pullback.recentHigh, _Digits));
   CsvAppend(line, DoubleToString(pullback.recentLow, _Digits));
   CsvAppend(line, DoubleToString(pullback.distanceFromRecentHigh, 2));
   CsvAppend(line, DoubleToString(pullback.distanceFromRecentLow, 2));
   CsvAppend(line, BoolText(pullback.spikeUpBlocked));
   CsvAppend(line, BoolText(pullback.spikeDownBlocked));
   CsvAppend(line, BoolText(counterBlocked));
   CsvAppend(line, ma.mode);
   CsvAppend(line, ma.trendDirection);
   CsvAppend(line, DoubleToString(ma.fastValue, _Digits));
   CsvAppend(line, DoubleToString(ma.middleValue, _Digits));
   CsvAppend(line, DoubleToString(ma.longValue, _Digits));
   CsvAppend(line, BoolText(ma.fastAboveMiddle));
   CsvAppend(line, BoolText(ma.middleAboveLong));
   CsvAppend(line, DoubleToString(ma.distanceToFast, 2));
   CsvAppend(line, DoubleToString(ma.distanceToMiddle, 2));
   CsvAppend(line, BoolText(priceTooFar));
   CsvAppend(line, BoolText(ma.priceNearMaPullback));
   CsvAppend(line, BoolText(ma.maFlatBlocked));
   CsvAppend(line, ma.crossState);
   CsvAppend(line, BoolText(maCrossWaitBlocked));
   CsvAppend(line, ma.reasonBuy);
   CsvAppend(line, ma.reasonSell);
   CsvAppend(line, DoubleToString(ma.fastSlope, 2));
   CsvAppend(line, DoubleToString(ma.middleSlope, 2));
   CsvAppend(line, DoubleToString(ma.longSlope, 2));
   CsvAppend(line, ma.fastSlopeState);
   CsvAppend(line, ma.middleSlopeState);
   CsvAppend(line, ma.longSlopeState);
   CsvAppend(line, ma.slopeReasonBuy);
   CsvAppend(line, ma.slopeReasonSell);
   CsvAppend(line, BoolText(ma.buyingIntoFallingMa));
   CsvAppend(line, BoolText(ma.sellingIntoRisingMa));
   CsvAppend(line, ma.trendDirection);
   CsvAppend(line, IntegerToString(mainDirectionPositions));
   CsvAppend(line, IntegerToString(hedgePositions));
   CsvAppend(line, BoolText(addAllowed));
   CsvAppend(line, addBlockReason);
   CsvAppend(line, BoolText(defenseAllowed));
   CsvAppend(line, defenseBlockReason);
   CsvAppend(line, BoolText(basketRecoveryActive));
   CsvAppend(line, DoubleToString(BasketRecoveryAcceptLossYen, 2));
   CsvAppend(line, IntegerToString(HedgedBasketMaxHoldMinutes));
   CsvAppend(line, DoubleToString(HedgedBasketTimeExitAcceptLossYen, 2));
   CsvAppend(line, firstDefenseHedgeTime > 0 ? TimeToString(firstDefenseHedgeTime, TIME_DATE | TIME_SECONDS) : "");
   CsvAppend(line, BoolText(UseBasketRecoveryLossCutMinHold));
   CsvAppend(line, IntegerToString(BasketRecoveryLossCutMinHoldMinutes));
   CsvAppend(line, BoolText(UseBasketRecoveryImprovementCheck));
   CsvAppend(line, DoubleToString(BasketRecoveryRequiredImprovementYen, 2));
   CsvAppend(line, BoolText(UseWorstBasketAfterHedgeAsReference));
   CsvAppend(line, DoubleToString(basketRecoveryInitialProfit, 2));
   CsvAppend(line, DoubleToString(basketRecoveryWorstProfit, 2));
   CsvAppend(line, BoolText(CountRecoveryLossCutAsConsecutiveLoss));
   CsvAppend(line, DoubleToString(RecoveryLossCutConsecutiveLossMinYen, 2));
   CsvAppend(line, IntegerToString(MaxNetPositions));
   CsvAppend(line, IntegerToString(MaxConsecutiveLosses));
   CsvAppend(line, BoolText(newsCsvLoaded));
   CsvAppend(line, NewsCsvFileName);
   CsvAppend(line, newsCsvLoadError);
   CsvAppend(line, IntegerToString(newsCsvEventCount));
   CsvAppend(line, BoolText(currentNewsBlockActive));
   CsvAppend(line, currentNewsBlockActive ? currentNewsBlockReason : "");
   CsvAppend(line, currentNewsBlockEventName);
   CsvAppend(line, currentNewsBlockStartServer > 0 ? TimeToString(currentNewsBlockStartServer, TIME_DATE | TIME_SECONDS) : "");
   CsvAppend(line, currentNewsBlockEndServer > 0 ? TimeToString(currentNewsBlockEndServer, TIME_DATE | TIME_SECONDS) : "");
   CsvAppend(line, currentNewsBlockEventTimeJst);
   CsvAppend(line, currentNewsBlockEventTimeServer > 0 ? TimeToString(currentNewsBlockEventTimeServer, TIME_DATE | TIME_SECONDS) : "");
   CsvAppend(line, IntegerToString(blockedByNewsCount));
   CsvAppend(line, IntegerToString(blockedNewEntryByNewsCount));
   CsvAppend(line, IntegerToString(blockedAddPositionByNewsCount));
   CsvAppend(line, IntegerToString(blockedDefenseHedgeByNewsCount));
   CsvAppend(line, IntegerToString(blockedHedgedBasketTimeExitByNewsCount));
   CsvAppend(line, BoolText(currentTechnicalDangerActive));
   CsvAppend(line, currentTechnicalDangerReason);
   CsvAppend(line, IntegerToString(blockedByTechnicalDangerCount));
   CsvAppend(line, IntegerToString(blockedHedgedBasketTimeExitByTechnicalDangerCount));
   CsvAppend(line, BoolText(AllowPureTickEntry));
   CsvAppend(line, BoolText(UseStructureBeforeTickEntry));
   CsvAppend(line, BoolText(directionStructurePermission));
   CsvAppend(line, BoolText(directionCandlePermission));
   CsvAppend(line, BoolText(directionTickPermission));
   CsvAppend(line, DoubleToString(score.longScore, 2));
   CsvAppend(line, DoubleToString(score.shortScore, 2));
   CsvAppend(line, DoubleToString(MathAbs(score.longScore - score.shortScore), 2));
   CsvAppend(line, DoubleToString(eventIsBuy ? score.longScore : score.shortScore, 2));
   CsvAppend(line, BoolText(directionBlockedPureTick));
   CsvAppend(line, directionBlockedPureTickReason);
   CsvAppend(line, IntegerToString(blockedPureTickEntryCount));
   CsvAppend(line, currentStructureGate.macroFib.direction);
   CsvAppend(line, currentStructureGate.dayFib.direction);
   CsvAppend(line, currentStructureGate.entryFib.direction);
   CsvAppend(line, DoubleToString(currentStructureGate.macroFib.startPrice, _Digits));
   CsvAppend(line, DoubleToString(currentStructureGate.macroFib.endPrice, _Digits));
   CsvAppend(line, DoubleToString(currentStructureGate.dayFib.startPrice, _Digits));
   CsvAppend(line, DoubleToString(currentStructureGate.dayFib.endPrice, _Digits));
   CsvAppend(line, DoubleToString(currentStructureGate.entryFib.startPrice, _Digits));
   CsvAppend(line, DoubleToString(currentStructureGate.entryFib.endPrice, _Digits));
   CsvAppend(line, currentStructureGate.dayFib.currentZone);
   CsvAppend(line, BoolText(currentStructureGate.dayFib.inZone || currentStructureGate.entryFib.inZone));
   CsvAppend(line, BoolText(currentStructureGate.dayFib.trendAligned));
   CsvAppend(line, BoolText(currentStructureGate.macroDayFibAligned));
   CsvAppend(line, BoolText(currentStructureGate.dayFib.structureBroken || currentStructureGate.entryFib.structureBroken));
   CsvAppend(line, currentStructureGate.structureTrendState);
   CsvAppend(line, currentStructureGate.h1h4BreakoutState);
   CsvAppend(line, DoubleToString(currentStructureGate.previousDayHighDistance, 2));
   CsvAppend(line, DoubleToString(currentStructureGate.previousDayLowDistance, 2));
   CsvAppend(line, DoubleToString(currentStructureGate.pivotDistance, 2));
   CsvAppend(line, DoubleToString(currentStructureGate.nearestSupportResistance, 2));
   CsvAppend(line, BoolText(currentStructureGate.largeCandleDetected));
   CsvAppend(line, BoolText(currentStructureGate.consecutiveCandleDetected));
   CsvAppend(line, BoolText(currentStructureGate.candle.detected));
   CsvAppend(line, currentStructureGate.candle.patternType);
   CsvAppend(line, currentStructureGate.candle.direction);
   CsvAppend(line, currentStructureGate.candle.timeframeText);
   CsvAppend(line, BoolText(currentStructureGate.candle.nearStructure));
   CsvAppend(line, BoolText(currentStructureGate.candle.confirmed));
   CsvAppend(line, BoolText(currentStructureGate.candle.dangerDetected));
   CsvAppend(line, currentStructureGate.candle.dangerReason);
   CsvAppend(line, currentStructureGate.earlyExitReason);
   CsvAppend(line, currentStructureGate.plannedAddReason);
   CsvAppend(line, currentStructureGate.hedgedBasketLossCompressionReason);
   CsvAppend(line, IntegerToString(structureBasedEarlyExitCount));
   CsvAppend(line, DoubleToString(structureBasedEarlyExitProfitTotal, 2));
   CsvAppend(line, IntegerToString(plannedAddPositionCount));
   CsvAppend(line, DoubleToString(plannedAddPositionProfitTotal, 2));
   CsvAppend(line, IntegerToString(hedgedBasketLossCompressionCount));
   CsvAppend(line, IntegerToString(blockedByGoldStructureCount));
   CsvAppend(line, IntegerToString(blockedByFibContextCount));
   CsvAppend(line, IntegerToString(blockedByMacroDayMismatchCount));
   CsvAppend(line, IntegerToString(blockedByPreviousDayHighLowCount));
   CsvAppend(line, IntegerToString(blockedByPivotCount));
   CsvAppend(line, IntegerToString(blockedByH1H4BreakoutCount));
   CsvAppend(line, IntegerToString(blockedByLargeCandleCount));
   CsvAppend(line, IntegerToString(blockedByConsecutiveCandleCount));
   CsvAppend(line, IntegerToString(blockedByCandlePatternCount));
   CsvAppend(line, IntegerToString(candlePatternConfirmationCount));
   CsvAppend(line, IntegerToString(bullishPinBarCount));
   CsvAppend(line, IntegerToString(bearishPinBarCount));
   CsvAppend(line, IntegerToString(engulfingConfirmationCount));
   CsvAppend(line, IntegerToString(spikeReversalConfirmationCount));
   CsvAppend(line, IntegerToString(dojiDangerBlockCount));
   CsvAppend(line, BoolText(UseHistoricalTimeRiskFilter));
   CsvAppend(line, IntegerToString(HistoricalTimeOffsetHours));
   CsvAppend(line, IntegerToString(currentHistoricalTimeSourceWeekday));
   CsvAppend(line, IntegerToString(currentHistoricalTimeSourceHour));
   CsvAppend(line, currentHistoricalTimeRiskState);
   CsvAppend(line, currentHistoricalTimeRiskReason);
   CsvAppend(line, DoubleToString(currentHistoricalTimeScoreAdd, 2));
   CsvAppend(line, BoolText(currentHistoricalTimeHighRisk));
   CsvAppend(line, BoolText(currentHistoricalTimeCaution));
   CsvAppend(line, BoolText(currentHistoricalTimeQuiet));
   CsvAppend(line, BoolText(currentHistoricalWeekdayHourBlock));
   CsvAppend(line, IntegerToString(blockedByHistoricalTimeRiskCount));
   CsvAppend(line, IntegerToString(blockedNewEntryByHistoricalTimeRiskCount));
   CsvAppend(line, IntegerToString(blockedAddByHistoricalTimeRiskCount));
   CsvAppend(line, IntegerToString(blockedDefenseHedgeByHistoricalTimeRiskCount));
   CsvAppend(line, IntegerToString(blockedBreakoutChaseByHistoricalTimeRiskCount));
   CsvAppend(line, IntegerToString(hardStopOriginEntryBlockCount));
   CsvAppend(line, lastHardStopOriginBlockReason);
   CsvAppend(line, lastHardStopOriginLargeCandleDirection);
   CsvAppend(line, lastHardStopOriginEntryDirection);
   CsvAppend(line, IntegerToString(lastHardStopOriginSecondsAfterLargeCandle));
   CsvAppend(line, BoolText(lastHardStopOriginHasPullbackConfirmation));
   CsvAppend(line, BoolText(lastHardStopOriginHasStructureConfirmation));
   CsvAppend(line, DoubleToString(lastHardStopOriginEntryScore, 2));
   CsvAppend(line, DoubleToString(lastHardStopOriginEntryScoreThreshold, 2));
   CsvAppend(line, DoubleToString(lastHardStopOriginEntryScoreBuffer, 2));
   CsvAppend(line, IntegerToString(singleReactiveDefenseHedgeCount));
   CsvAppend(line, IntegerToString(reactiveHedgeBasketCloseCount));
   CsvAppend(line, IntegerToString(reactiveHedgeMaxLossCloseCount));
   CsvAppend(line, IntegerToString(reactiveHedgeTimeCloseCount));
   CsvAppend(line, DoubleToString(reactiveHedgeProfitTotal, 2));
   CsvAppend(line, lastReactiveHedgeReason);
   CsvAppend(line, DoubleToString(ReactiveHedgeTriggerLossYen, 2));
   CsvAppend(line, DoubleToString(lastReactiveHedgeCurrentFloatingProfitYen, 2));
   CsvAppend(line, DoubleToString(lastReactiveHedgeFloatingLossYen, 2));
   CsvAppend(line, DoubleToString(lastReactiveHedgeOppositeTickScore, 2));
   CsvAppend(line, DoubleToString(lastReactiveHedgeOppositeScoreDiff, 2));
   CsvAppend(line, BoolText(lastReactiveHedgeM5ConfirmationPassed));
   CsvAppend(line, IntegerToString(lastReactiveHedgeM5ConfirmationBars));
   CsvAppend(line, DoubleToString(ReactiveHedgeBasketCloseTargetYen, 2));
   CsvAppend(line, DoubleToString(ReactiveHedgeBasketMaxLossYen, 2));
   CsvAppend(line, IntegerToString(ReactiveHedgeMaxHoldMinutes));
   CsvAppend(line, lastReactiveHedgeCloseReason);
   CsvAppend(line, IntegerToString(singlePositionContraryEarlyExitCount));
   CsvAppend(line, DoubleToString(singlePositionContraryEarlyExitProfitTotal, 2));
   CsvAppend(line, lastSingleEarlyExitReason);
   CsvAppend(line, DoubleToString(SingleEarlyExitSoftLossYen, 2));
   CsvAppend(line, DoubleToString(SingleEarlyExitHardLossYen, 2));
   CsvAppend(line, DoubleToString(lastSingleEarlyExitCurrentFloatingProfitYen, 2));
   CsvAppend(line, DoubleToString(lastSingleEarlyExitFloatingLossYen, 2));
   CsvAppend(line, DoubleToString(lastSingleEarlyExitOppositeTickScore, 2));
   CsvAppend(line, DoubleToString(lastSingleEarlyExitOppositeScoreDiff, 2));
   CsvAppend(line, lastSingleEarlyExitPositionDirection);
   CsvAppend(line, IntegerToString(lastSingleEarlyExitHoldSeconds));
   CsvAppend(line, BoolText(lastSingleEarlyExitMaReverse));
   CsvAppend(line, BoolText(lastSingleEarlyExitTrendReverse));
   CsvAppend(line, BoolText(lastSingleEarlyExitTickReverse));
   bool postCooldownActive = (UseSingleEarlyExitPostCooldown && singleEarlyExitPostCooldownUntil > TimeCurrent());
   CsvAppend(line, BoolText(postCooldownActive));
   CsvAppend(line, lastSingleEarlyExitPostCooldownUntil > 0 ? TimeToString(lastSingleEarlyExitPostCooldownUntil, TIME_DATE | TIME_SECONDS) : "");
   CsvAppend(line, IntegerToString(singleEarlyExitPostCooldownBlockCount));
   CsvAppend(line, IntegerToString(sameDirectionReentryBlockedAfterSingleEarlyExitCount));
   CsvAppend(line, IntegerToString(maxSingleEarlyExitPerDayHitCount));
   CsvAppend(line, BoolText(lastSingleEarlyExitM5ConfirmationPassed));
   CsvAppend(line, IntegerToString(lastSingleEarlyExitM5ConfirmationBars));
   CsvAppend(line, IntegerToString(m5ConfirmationPassedCount));
   CsvAppend(line, IntegerToString(m5ConfirmationFailedCount));
   CsvAppend(line, BoolText(lastSingleEarlyExitVixCautionAdjustmentApplied));
   CsvAppend(line, DoubleToString(lastSingleEarlyExitEffectiveOppositeTickScoreThreshold, 2));
   CsvAppend(line, DoubleToString(lastSingleEarlyExitEffectiveSoftLossYen, 2));
   CsvAppend(line, DoubleToString(lastSingleEarlyExitEffectiveHardLossYen, 2));
   CsvAppend(line, IntegerToString(largeCandleEntryCautionCount));
   CsvAppend(line, IntegerToString(largeCandleEntryBlockedCount));
   CsvAppend(line, BoolText(currentLargeCandleEntryCaution));
   CsvAppend(line, BoolText(currentLargeCandleEntryBlock));
   CsvAppend(line, currentLargeCandleDirection);
   CsvAppend(line, currentLargeCandleEntryDirection);
   CsvAppend(line, DoubleToString(LargeCandleEntryScoreAddForSingle, 2));
   CsvAppend(line, BoolText(BlockEntryOnLargeCandleAgainstMaTrend));
   PerfFileWriteString(handle, line + "\r\n");
   FileClose(handle);
}

void LogStopEventsIfNeeded(bool dailyStop, bool consecutiveStop, double dailyPL, int consecutiveLosses)
{
   if(dailyStop)
   {
      datetime today = DayStart(TimeCurrent());
      if(lastDailyLossStopLogDay != today)
      {
         lastDailyLossStopLogDay = today;
         WriteTradeEventLog("DAILY_LOSS_STOP", 0, 0, "", "daily loss stop active", "", 0.0, 0.0, 0.0, 0.0, 0.0, dailyPL,
                            tradeEventContextReady ? tradeEventPosition.floatingProfit : 0.0);
      }
   }

   if(consecutiveStop && consecutiveLossStopUntil > 0 && lastConsecutiveLossStopLogUntil != consecutiveLossStopUntil)
   {
      lastConsecutiveLossStopLogUntil = consecutiveLossStopUntil;
      WriteTradeEventLog("CONSECUTIVE_LOSS_STOP", 0, 0, "", "consecutive loss stop active", "", 0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
                         tradeEventContextReady ? tradeEventPosition.floatingProfit : 0.0);
   }
}

double FileSizeKbSafe(string fileName)
{
   int handle = FileOpen(fileName, FILE_READ | FILE_BIN | FILE_ANSI | FILE_SHARE_READ | FILE_SHARE_WRITE);
   if(handle == INVALID_HANDLE)
      return 0.0;
   double sizeKb = (double)FileSize(handle) / 1024.0;
   FileClose(handle);
   return sizeKb;
}

void WritePerformanceStats()
{
   int handle = FileOpen(PerformanceStatsFileName, FILE_READ | FILE_WRITE | FILE_CSV | FILE_ANSI | FILE_SHARE_READ | FILE_SHARE_WRITE);
   if(handle == INVALID_HANDLE)
   {
      if(CountPerformanceStats)
         perfPrintCount++;
      Print(EA_NAME, ": performance stats open failed. error=", GetLastError());
      return;
   }

   if(FileSize(handle) == 0)
   {
      string header = "";
      CsvAppend(header, "Pattern");
      CsvAppend(header, "Time");
      CsvAppend(header, "ElapsedSeconds");
      CsvAppend(header, "ElapsedMinutes");
      CsvAppend(header, "UsePerformanceCache");
      CsvAppend(header, "DxyVixCacheSeconds");
      CsvAppend(header, "GoldLocationCacheSeconds");
      CsvAppend(header, "TechnicalDangerCacheSeconds");
      CsvAppend(header, "CopyBufferCallCount");
      CsvAppend(header, "CopyBufferRequestedCount");
      CsvAppend(header, "CopyBufferDuplicateSameTickCount");
      CsvAppend(header, "CopyBufferMemoHitCount");
      CsvAppend(header, "CopyBufferMemoMissCount");
      CsvAppend(header, "ICustomCallCount");
      CsvAppend(header, "DxyUpdateCount");
      CsvAppend(header, "VixUpdateCount");
      CsvAppend(header, "GoldLocationUpdateCount");
      CsvAppend(header, "TechnicalDangerUpdateCount");
      CsvAppend(header, "HigherTfUpdateCount");
      CsvAppend(header, "MaStructureUpdateCount");
      CsvAppend(header, "NewsCsvReadCount");
      CsvAppend(header, "PositionScanCount");
      CsvAppend(header, "PositionScanCacheHitCount");
      CsvAppend(header, "HistoryScanCount");
      CsvAppend(header, "DailyPlCacheUpdateCount");
      CsvAppend(header, "CsvWriteCount");
      CsvAppend(header, "PrintCount");
      CsvAppend(header, "FileFlushCount");
      CsvAppend(header, "CommentUpdateCount");
      CsvAppend(header, "TradeEventLogSizeKB");
      CsvAppend(header, "SegmentSummarySizeKB");
      CsvAppend(header, "BacktestCompleted");
      CsvAppend(header, "Comment");
      PerfFileWriteString(handle, header + "\r\n");
   }

   string pattern = BacktestPatternName;
   if(pattern == "")
      pattern = "UNKNOWN";
   int elapsed = (int)(TimeLocal() - perfInitWallTime);
   string line = "";
   CsvAppend(line, pattern);
   CsvAppend(line, TimeToString(TimeCurrent(), TIME_DATE | TIME_SECONDS));
   CsvAppend(line, IntegerToString(elapsed));
   CsvAppend(line, DoubleToString((double)elapsed / 60.0, 2));
   CsvAppend(line, BoolText(UsePerformanceCache));
   CsvAppend(line, IntegerToString(DxyVixCacheSeconds));
   CsvAppend(line, IntegerToString(GoldLocationCacheSeconds));
   CsvAppend(line, IntegerToString(TechnicalDangerCacheSeconds));
   CsvAppend(line, IntegerToString(perfCopyBufferCallCount));
   CsvAppend(line, IntegerToString(perfCopyBufferRequestedCount));
   CsvAppend(line, IntegerToString(perfCopyBufferDuplicateSameTickCount));
   CsvAppend(line, IntegerToString(perfCopyBufferMemoHitCount));
   CsvAppend(line, IntegerToString(perfCopyBufferMemoMissCount));
   CsvAppend(line, IntegerToString(perfICustomCallCount));
   CsvAppend(line, IntegerToString(perfDxyUpdateCount));
   CsvAppend(line, IntegerToString(perfVixUpdateCount));
   CsvAppend(line, IntegerToString(perfGoldLocationUpdateCount));
   CsvAppend(line, IntegerToString(perfTechnicalDangerUpdateCount));
   CsvAppend(line, IntegerToString(perfHigherTfUpdateCount));
   CsvAppend(line, IntegerToString(perfMaStructureUpdateCount));
   CsvAppend(line, IntegerToString(perfNewsCsvReadCount));
   CsvAppend(line, IntegerToString(perfPositionScanCount));
   CsvAppend(line, IntegerToString(perfPositionScanCacheHitCount));
   CsvAppend(line, IntegerToString(perfHistoryScanCount));
   CsvAppend(line, IntegerToString(perfDailyPlCacheUpdateCount));
   CsvAppend(line, IntegerToString(perfCsvWriteCount));
   CsvAppend(line, IntegerToString(perfPrintCount));
   CsvAppend(line, IntegerToString(perfFileFlushCount));
   CsvAppend(line, IntegerToString(perfCommentUpdateCount));
   CsvAppend(line, DoubleToString(FileSizeKbSafe(TradeEventLogFileName), 2));
   CsvAppend(line, DoubleToString(FileSizeKbSafe(EntryOpportunityAuditFileName), 2));
   CsvAppend(line, "true");
   CsvAppend(line, "EA performance counters");
   PerfFileWriteString(handle, line + "\r\n");
   FileClose(handle);
}

void WriteCopyBufferBreakdown()
{
   int handle = FileOpen(CopyBufferBreakdownFileName, FILE_READ | FILE_WRITE | FILE_CSV | FILE_ANSI | FILE_SHARE_READ | FILE_SHARE_WRITE);
   if(handle == INVALID_HANDLE)
   {
      if(CountPerformanceStats)
         perfPrintCount++;
      Print(EA_NAME, ": copybuffer breakdown open failed. error=", GetLastError());
      return;
   }

   if(FileSize(handle) == 0)
   {
      string header = "";
      CsvAppend(header, "Category");
      CsvAppend(header, "Symbol");
      CsvAppend(header, "Timeframe");
      CsvAppend(header, "IndicatorOrSeriesName");
      CsvAppend(header, "BufferIndex");
      CsvAppend(header, "Shift");
      CsvAppend(header, "Count");
      CsvAppend(header, "CallCount");
      CsvAppend(header, "UniqueTickCallCount");
      CsvAppend(header, "DuplicateSameTickCallCount");
      CsvAppend(header, "Comment");
      PerfFileWriteString(handle, header + "\r\n");
   }

   for(int i = 0; i < copyBufferBreakdownItems; i++)
   {
      string line = "";
      CsvAppend(line, copyBufferBreakdownCategory[i]);
      CsvAppend(line, copyBufferBreakdownSymbol[i]);
      CsvAppend(line, copyBufferBreakdownTimeframe[i]);
      CsvAppend(line, copyBufferBreakdownName[i]);
      CsvAppend(line, IntegerToString(copyBufferBreakdownBuffer[i]));
      CsvAppend(line, IntegerToString(copyBufferBreakdownShift[i]));
      CsvAppend(line, IntegerToString(copyBufferBreakdownCountParam[i]));
      CsvAppend(line, IntegerToString(copyBufferBreakdownCallCount[i]));
      CsvAppend(line, IntegerToString(copyBufferBreakdownUniqueTickCount[i]));
      CsvAppend(line, IntegerToString(copyBufferBreakdownDuplicateSameTickCount[i]));
      CsvAppend(line, "EA CopyBuffer wrapper breakdown");
      PerfFileWriteString(handle, line + "\r\n");
   }
   FileClose(handle);
}

void WriteCsvHeader()
{
   int handle = FileOpen(LogFileName, FILE_READ | FILE_WRITE | FILE_CSV | FILE_ANSI | FILE_SHARE_READ | FILE_SHARE_WRITE);
   if(handle == INVALID_HANDLE)
   {
      Print(EA_NAME, ": log header open failed. error=", GetLastError());
      return;
   }

   if(FileSize(handle) == 0)
   {
      string line = "";
      CsvAppend(line, "time"); CsvAppend(line, "symbol"); CsvAppend(line, "bid"); CsvAppend(line, "ask"); CsvAppend(line, "spread");
      CsvAppend(line, "LongScore"); CsvAppend(line, "ShortScore"); CsvAppend(line, "signal"); CsvAppend(line, "action"); CsvAppend(line, "reason");
      CsvAppend(line, "GoldLocationState"); CsvAppend(line, "GoldLocationBlockReason"); CsvAppend(line, "DxyValue"); CsvAppend(line, "DxyState"); CsvAppend(line, "DxyBlockReason");
      CsvAppend(line, "DxyVolatilityState"); CsvAppend(line, "VixValue"); CsvAppend(line, "VixState"); CsvAppend(line, "VixBlockReason"); CsvAppend(line, "news state"); CsvAppend(line, "news block reason");
      CsvAppend(line, "NewsCsvLoaded"); CsvAppend(line, "NewsCsvEventCount"); CsvAppend(line, "NewsCsvLoadError"); CsvAppend(line, "NewsBlockActive"); CsvAppend(line, "NewsBlockEventName");
      CsvAppend(line, "NewsBlockStartTimeServer"); CsvAppend(line, "NewsBlockEndTimeServer"); CsvAppend(line, "NewsBlockEventTimeJST"); CsvAppend(line, "NewsBlockEventTimeServer");
      CsvAppend(line, "TechnicalDangerBlockActive"); CsvAppend(line, "TechnicalDangerBlockReason");
      CsvAppend(line, "manual bias state"); CsvAppend(line, "higher timeframe state"); CsvAppend(line, "floating drawdown percent"); CsvAppend(line, "margin level");
      CsvAppend(line, "daily P/L"); CsvAppend(line, "consecutive losses"); CsvAppend(line, "total EA positions"); CsvAppend(line, "buy EA positions"); CsvAppend(line, "sell EA positions");
      CsvAppend(line, "net EA positions"); CsvAppend(line, "basket floating profit"); CsvAppend(line, "LastTradeActionTime"); CsvAppend(line, "LastAnyEaCloseTime");
      CsvAppend(line, "LastEntryDirection"); CsvAppend(line, "OppositeCooldownRemaining"); CsvAppend(line, "AfterCloseCooldownRemaining"); CsvAppend(line, "LastStopReason");
      CsvAppend(line, "TrendMainDirection"); CsvAppend(line, "MainDirectionPositions"); CsvAppend(line, "DefenseHedgePositions"); CsvAppend(line, "BasketNetProfitYen");
      CsvAppend(line, "BasketRecoveryCloseActive"); CsvAppend(line, "HardStopAfterMode"); CsvAppend(line, "HardStopCooldownRemaining");
      CsvAppend(line, "DefenseHedgeAllowed"); CsvAppend(line, "DefenseHedgeBlockReason"); CsvAppend(line, "AddPositionAllowed"); CsvAppend(line, "AddPositionBlockReason");
      CsvAppend(line, "PullbackMode"); CsvAppend(line, "PullbackDirection"); CsvAppend(line, "PullbackOkBuy"); CsvAppend(line, "PullbackOkSell");
      CsvAppend(line, "PullbackBlockReasonBuy"); CsvAppend(line, "PullbackBlockReasonSell"); CsvAppend(line, "PullbackRsiValue"); CsvAppend(line, "PullbackEma20");
      CsvAppend(line, "PullbackEma50"); CsvAppend(line, "RecentHigh"); CsvAppend(line, "RecentLow"); CsvAppend(line, "DistanceFromRecentHigh"); CsvAppend(line, "DistanceFromRecentLow");
      CsvAppend(line, "SpikeUpBlocked"); CsvAppend(line, "SpikeDownBlocked"); CsvAppend(line, "CounterTrendBlocked");
      CsvAppend(line, "MaStructureMode"); CsvAppend(line, "MaTrendDirection"); CsvAppend(line, "MaFastValue"); CsvAppend(line, "MaMiddleValue"); CsvAppend(line, "MaLongValue");
      CsvAppend(line, "MaFastAboveMiddle"); CsvAppend(line, "MaMiddleAboveLong"); CsvAppend(line, "DistanceToMaFast"); CsvAppend(line, "DistanceToMaMiddle");
      CsvAppend(line, "PriceTooFarFromMa"); CsvAppend(line, "PriceNearMaPullback"); CsvAppend(line, "MaFlatBlocked"); CsvAppend(line, "MaCrossState");
      CsvAppend(line, "MaCrossWaitBlocked"); CsvAppend(line, "MaStructureBlockReasonBuy"); CsvAppend(line, "MaStructureBlockReasonSell");
      CsvAppend(line, "MaFastSlope"); CsvAppend(line, "MaMiddleSlope"); CsvAppend(line, "MaLongSlope");
      CsvAppend(line, "MaFastSlopeState"); CsvAppend(line, "MaMiddleSlopeState"); CsvAppend(line, "MaLongSlopeState");
      CsvAppend(line, "MaSlopeBlockReasonBuy"); CsvAppend(line, "MaSlopeBlockReasonSell");
      CsvAppend(line, "BuyingIntoFallingMa"); CsvAppend(line, "SellingIntoRisingMa");
      CsvAppend(line, "AllowPureTickEntry"); CsvAppend(line, "UseStructureBeforeTickEntry"); CsvAppend(line, "StructurePermission"); CsvAppend(line, "CandlePatternPermission");
      CsvAppend(line, "TickTriggerPermission"); CsvAppend(line, "TickScoreBuy"); CsvAppend(line, "TickScoreSell"); CsvAppend(line, "TickScoreDifference"); CsvAppend(line, "TickScoreAtEntry");
      CsvAppend(line, "BlockedPureTickEntry"); CsvAppend(line, "BlockedPureTickEntryReason"); CsvAppend(line, "BlockedPureTickEntryCount");
      CsvAppend(line, "MacroFibDirection"); CsvAppend(line, "DayFibDirection"); CsvAppend(line, "EntryFibDirection");
      CsvAppend(line, "MacroFibStartPrice"); CsvAppend(line, "MacroFibEndPrice"); CsvAppend(line, "DayFibStartPrice"); CsvAppend(line, "DayFibEndPrice");
      CsvAppend(line, "EntryFibStartPrice"); CsvAppend(line, "EntryFibEndPrice"); CsvAppend(line, "CurrentFibZone"); CsvAppend(line, "IsPriceInFibZone");
      CsvAppend(line, "FibTrendAligned"); CsvAppend(line, "MacroDayFibAligned"); CsvAppend(line, "FibStructureBroken");
      CsvAppend(line, "StructureTrendState"); CsvAppend(line, "H1H4BreakoutState"); CsvAppend(line, "PreviousDayHighDistance"); CsvAppend(line, "PreviousDayLowDistance");
      CsvAppend(line, "PivotDistance"); CsvAppend(line, "NearestSupportResistance"); CsvAppend(line, "LargeCandleDetected"); CsvAppend(line, "ConsecutiveCandleDetected");
      CsvAppend(line, "CandlePatternDetected"); CsvAppend(line, "CandlePatternType"); CsvAppend(line, "CandlePatternDirection"); CsvAppend(line, "CandlePatternTimeframe");
      CsvAppend(line, "CandlePatternNearStructure"); CsvAppend(line, "CandlePatternConfirmed"); CsvAppend(line, "CandleDangerDetected"); CsvAppend(line, "CandleDangerReason");
      CsvAppend(line, "EarlyExitReason"); CsvAppend(line, "PlannedAddReason"); CsvAppend(line, "HedgedBasketLossCompressionReason");
      CsvAppend(line, "StructureBasedEarlyExitCount"); CsvAppend(line, "StructureBasedEarlyExitProfitTotal"); CsvAppend(line, "PlannedAddPositionCount"); CsvAppend(line, "PlannedAddPositionProfitTotal");
      CsvAppend(line, "HedgedBasketLossCompressionCount"); CsvAppend(line, "BlockedByGoldStructureCount"); CsvAppend(line, "BlockedByFibContextCount"); CsvAppend(line, "BlockedByMacroDayMismatchCount");
      CsvAppend(line, "BlockedByPreviousDayHighLowCount"); CsvAppend(line, "BlockedByPivotCount"); CsvAppend(line, "BlockedByH1H4BreakoutCount"); CsvAppend(line, "BlockedByLargeCandleCount");
      CsvAppend(line, "BlockedByConsecutiveCandleCount"); CsvAppend(line, "BlockedByCandlePatternCount"); CsvAppend(line, "CandlePatternConfirmationCount");
      CsvAppend(line, "BullishPinBarCount"); CsvAppend(line, "BearishPinBarCount"); CsvAppend(line, "EngulfingConfirmationCount"); CsvAppend(line, "SpikeReversalConfirmationCount"); CsvAppend(line, "DojiDangerBlockCount");
      CsvAppend(line, "UseHistoricalTimeRiskFilter"); CsvAppend(line, "HistoricalTimeOffsetHours"); CsvAppend(line, "HistoricalTimeSourceWeekday"); CsvAppend(line, "HistoricalTimeSourceHour");
      CsvAppend(line, "HistoricalTimeRiskState"); CsvAppend(line, "HistoricalTimeRiskReason"); CsvAppend(line, "HistoricalTimeScoreAdd");
      CsvAppend(line, "HistoricalTimeHighRisk"); CsvAppend(line, "HistoricalTimeCaution"); CsvAppend(line, "HistoricalTimeQuiet"); CsvAppend(line, "HistoricalWeekdayHourBlock");
      CsvAppend(line, "BlockedByHistoricalTimeRiskCount"); CsvAppend(line, "BlockedNewEntryByHistoricalTimeRiskCount"); CsvAppend(line, "BlockedAddByHistoricalTimeRiskCount");
      CsvAppend(line, "BlockedDefenseHedgeByHistoricalTimeRiskCount"); CsvAppend(line, "BlockedBreakoutChaseByHistoricalTimeRiskCount");
      PerfFileWriteString(handle, line + "\r\n");
   }

   FileClose(handle);
}

void WriteCsvLog(const MqlTick &tick,
                 const ScoreState &score,
                 string signal,
                 string action,
                 string reason,
                 bool goldBuyOk,
                 bool goldSellOk,
                 string goldBuyReason,
                 string goldSellReason,
                 const FilterState &dxy,
                 const FilterState &vix,
                 string newsState,
                 string newsReason,
                 string htfState,
                 const PullbackState &pullback,
                 const MaStructureState &ma,
                 const PositionState &ps,
                 double marginLevel,
                 double dailyPL,
                 int consecutiveLosses)
{
   int handle = FileOpen(LogFileName, FILE_READ | FILE_WRITE | FILE_CSV | FILE_ANSI | FILE_SHARE_READ | FILE_SHARE_WRITE);
   if(handle == INVALID_HANDLE)
   {
      Print(EA_NAME, ": log open failed. error=", GetLastError());
      return;
   }

   FileSeek(handle, 0, SEEK_END);

   string goldState = "SAFE";
   string goldReason = "";
   if(signal == "BUY")
   {
      goldState = goldBuyOk ? "SAFE" : "BLOCKED";
      goldReason = goldBuyReason;
   }
   else if(signal == "SELL")
   {
      goldState = goldSellOk ? "SAFE" : "BLOCKED";
      goldReason = goldSellReason;
   }
   else
   {
      if(!goldBuyOk || !goldSellOk)
         goldState = "BLOCKED";
      goldReason = "BUY:" + goldBuyReason + " SELL:" + goldSellReason;
   }

   bool counterBlocked = pullback.counterTrendBlockedBuy || pullback.counterTrendBlockedSell;
   bool priceTooFar = ma.priceTooFarFromMaBuy || ma.priceTooFarFromMaSell;
   bool maCrossWaitBlocked = ma.maCrossWaitBlockedBuy || ma.maCrossWaitBlockedSell;
   int mainDirectionPositions = MathMax(ps.buys, ps.sells);
   int hedgePositions = CountDefenseHedges();
   bool basketRecoveryActive = UseBasketRecoveryClose && hedgePositions > 0 && ps.total >= 2;
   bool defenseAllowed = lastDefenseHedgeAllowed;
   string defenseBlockReason = lastDefenseHedgeBlockReason;
   bool addAllowed = UseAddPosition && CountAddPositions(true) < MaxAddPositionsPerDirection && CountAddPositions(false) < MaxAddPositionsPerDirection;
   string addBlockReason = addAllowed ? "add position possible" : "ADD blocked: max add positions reached";
   bool logIsBuy = (signal == "BUY");
   bool directionStructurePermission = logIsBuy ? currentStructureGate.structurePermissionBuy : currentStructureGate.structurePermissionSell;
   bool directionCandlePermission = logIsBuy ? currentStructureGate.candlePermissionBuy : currentStructureGate.candlePermissionSell;
   bool directionTickPermission = logIsBuy ? currentStructureGate.tickTriggerPermissionBuy : currentStructureGate.tickTriggerPermissionSell;
   bool directionBlockedPureTick = logIsBuy ? currentStructureGate.blockedPureTickEntryBuy : currentStructureGate.blockedPureTickEntrySell;
   string directionBlockedPureTickReason = logIsBuy ? currentStructureGate.blockedPureTickReasonBuy : currentStructureGate.blockedPureTickReasonSell;

   string line = "";
   CsvAppend(line, TimeToString(TimeCurrent(), TIME_DATE | TIME_SECONDS));
   CsvAppend(line, _Symbol);
   CsvAppend(line, DoubleToString(tick.bid, _Digits));
   CsvAppend(line, DoubleToString(tick.ask, _Digits));
   CsvAppend(line, DoubleToString(tick.ask - tick.bid, 2));
   CsvAppend(line, DoubleToString(score.longScore, 2));
   CsvAppend(line, DoubleToString(score.shortScore, 2));
   CsvAppend(line, signal);
   CsvAppend(line, action);
   CsvAppend(line, reason);
   CsvAppend(line, goldState);
   CsvAppend(line, goldReason);
   CsvAppend(line, DoubleToString(dxy.value, 4));
   CsvAppend(line, dxy.state);
   CsvAppend(line, dxy.reason);
   CsvAppend(line, IntegerToString(DxyVolatilityState));
   CsvAppend(line, DoubleToString(vix.value, 4));
   CsvAppend(line, vix.state);
   CsvAppend(line, vix.reason);
   CsvAppend(line, newsState);
   CsvAppend(line, newsReason);
   CsvAppend(line, BoolText(newsCsvLoaded));
   CsvAppend(line, IntegerToString(newsCsvEventCount));
   CsvAppend(line, newsCsvLoadError);
   CsvAppend(line, BoolText(currentNewsBlockActive));
   CsvAppend(line, currentNewsBlockEventName);
   CsvAppend(line, currentNewsBlockStartServer > 0 ? TimeToString(currentNewsBlockStartServer, TIME_DATE | TIME_SECONDS) : "");
   CsvAppend(line, currentNewsBlockEndServer > 0 ? TimeToString(currentNewsBlockEndServer, TIME_DATE | TIME_SECONDS) : "");
   CsvAppend(line, currentNewsBlockEventTimeJst);
   CsvAppend(line, currentNewsBlockEventTimeServer > 0 ? TimeToString(currentNewsBlockEventTimeServer, TIME_DATE | TIME_SECONDS) : "");
   CsvAppend(line, BoolText(currentTechnicalDangerActive));
   CsvAppend(line, currentTechnicalDangerReason);
   CsvAppend(line, IntegerToString(ManualBiasMode));
   CsvAppend(line, htfState);
   CsvAppend(line, DoubleToString(ps.floatingLossPercent, 2));
   CsvAppend(line, DoubleToString(marginLevel, 2));
   CsvAppend(line, DoubleToString(dailyPL, 2));
   CsvAppend(line, IntegerToString(consecutiveLosses));
   CsvAppend(line, IntegerToString(ps.total));
   CsvAppend(line, IntegerToString(ps.buys));
   CsvAppend(line, IntegerToString(ps.sells));
   CsvAppend(line, IntegerToString(ps.net));
   CsvAppend(line, DoubleToString(ps.floatingProfit, 2));
   CsvAppend(line, TimeToString(lastTradeActionTime, TIME_DATE | TIME_SECONDS));
   CsvAppend(line, TimeToString(lastAnyEaCloseTime, TIME_DATE | TIME_SECONDS));
   CsvAppend(line, DirectionToString(lastEntryDirection));
   CsvAppend(line, IntegerToString(GetOppositeCooldownRemaining()));
   CsvAppend(line, IntegerToString(GetAfterCloseCooldownRemaining()));
   CsvAppend(line, lastStopReason);
   CsvAppend(line, ma.trendDirection);
   CsvAppend(line, IntegerToString(mainDirectionPositions));
   CsvAppend(line, IntegerToString(hedgePositions));
   CsvAppend(line, DoubleToString(ps.floatingProfit, 2));
   CsvAppend(line, basketRecoveryActive ? "true" : "false");
   CsvAppend(line, IntegerToString(HardStopAfterMode));
   CsvAppend(line, IntegerToString(GetHardStopCooldownRemaining()));
   CsvAppend(line, defenseAllowed ? "true" : "false");
   CsvAppend(line, defenseBlockReason);
   CsvAppend(line, addAllowed ? "true" : "false");
   CsvAppend(line, addBlockReason);
   CsvAppend(line, pullback.mode);
   CsvAppend(line, pullback.direction);
   CsvAppend(line, pullback.okBuy ? "true" : "false");
   CsvAppend(line, pullback.okSell ? "true" : "false");
   CsvAppend(line, pullback.reasonBuy);
   CsvAppend(line, pullback.reasonSell);
   CsvAppend(line, DoubleToString(pullback.rsi, 2));
   CsvAppend(line, DoubleToString(pullback.emaFast, _Digits));
   CsvAppend(line, DoubleToString(pullback.emaSlow, _Digits));
   CsvAppend(line, DoubleToString(pullback.recentHigh, _Digits));
   CsvAppend(line, DoubleToString(pullback.recentLow, _Digits));
   CsvAppend(line, DoubleToString(pullback.distanceFromRecentHigh, 2));
   CsvAppend(line, DoubleToString(pullback.distanceFromRecentLow, 2));
   CsvAppend(line, pullback.spikeUpBlocked ? "true" : "false");
   CsvAppend(line, pullback.spikeDownBlocked ? "true" : "false");
   CsvAppend(line, counterBlocked ? "true" : "false");
   CsvAppend(line, ma.mode);
   CsvAppend(line, ma.trendDirection);
   CsvAppend(line, DoubleToString(ma.fastValue, _Digits));
   CsvAppend(line, DoubleToString(ma.middleValue, _Digits));
   CsvAppend(line, DoubleToString(ma.longValue, _Digits));
   CsvAppend(line, ma.fastAboveMiddle ? "true" : "false");
   CsvAppend(line, ma.middleAboveLong ? "true" : "false");
   CsvAppend(line, DoubleToString(ma.distanceToFast, 2));
   CsvAppend(line, DoubleToString(ma.distanceToMiddle, 2));
   CsvAppend(line, priceTooFar ? "true" : "false");
   CsvAppend(line, ma.priceNearMaPullback ? "true" : "false");
   CsvAppend(line, ma.maFlatBlocked ? "true" : "false");
   CsvAppend(line, ma.crossState);
   CsvAppend(line, maCrossWaitBlocked ? "true" : "false");
   CsvAppend(line, ma.reasonBuy);
   CsvAppend(line, ma.reasonSell);
   CsvAppend(line, DoubleToString(ma.fastSlope, 2));
   CsvAppend(line, DoubleToString(ma.middleSlope, 2));
   CsvAppend(line, DoubleToString(ma.longSlope, 2));
   CsvAppend(line, ma.fastSlopeState);
   CsvAppend(line, ma.middleSlopeState);
   CsvAppend(line, ma.longSlopeState);
   CsvAppend(line, ma.slopeReasonBuy);
   CsvAppend(line, ma.slopeReasonSell);
   CsvAppend(line, ma.buyingIntoFallingMa ? "true" : "false");
   CsvAppend(line, ma.sellingIntoRisingMa ? "true" : "false");
   CsvAppend(line, BoolText(AllowPureTickEntry));
   CsvAppend(line, BoolText(UseStructureBeforeTickEntry));
   CsvAppend(line, BoolText(directionStructurePermission));
   CsvAppend(line, BoolText(directionCandlePermission));
   CsvAppend(line, BoolText(directionTickPermission));
   CsvAppend(line, DoubleToString(score.longScore, 2));
   CsvAppend(line, DoubleToString(score.shortScore, 2));
   CsvAppend(line, DoubleToString(MathAbs(score.longScore - score.shortScore), 2));
   CsvAppend(line, DoubleToString(logIsBuy ? score.longScore : score.shortScore, 2));
   CsvAppend(line, BoolText(directionBlockedPureTick));
   CsvAppend(line, directionBlockedPureTickReason);
   CsvAppend(line, IntegerToString(blockedPureTickEntryCount));
   CsvAppend(line, currentStructureGate.macroFib.direction);
   CsvAppend(line, currentStructureGate.dayFib.direction);
   CsvAppend(line, currentStructureGate.entryFib.direction);
   CsvAppend(line, DoubleToString(currentStructureGate.macroFib.startPrice, _Digits));
   CsvAppend(line, DoubleToString(currentStructureGate.macroFib.endPrice, _Digits));
   CsvAppend(line, DoubleToString(currentStructureGate.dayFib.startPrice, _Digits));
   CsvAppend(line, DoubleToString(currentStructureGate.dayFib.endPrice, _Digits));
   CsvAppend(line, DoubleToString(currentStructureGate.entryFib.startPrice, _Digits));
   CsvAppend(line, DoubleToString(currentStructureGate.entryFib.endPrice, _Digits));
   CsvAppend(line, currentStructureGate.dayFib.currentZone);
   CsvAppend(line, BoolText(currentStructureGate.dayFib.inZone || currentStructureGate.entryFib.inZone));
   CsvAppend(line, BoolText(currentStructureGate.dayFib.trendAligned));
   CsvAppend(line, BoolText(currentStructureGate.macroDayFibAligned));
   CsvAppend(line, BoolText(currentStructureGate.dayFib.structureBroken || currentStructureGate.entryFib.structureBroken));
   CsvAppend(line, currentStructureGate.structureTrendState);
   CsvAppend(line, currentStructureGate.h1h4BreakoutState);
   CsvAppend(line, DoubleToString(currentStructureGate.previousDayHighDistance, 2));
   CsvAppend(line, DoubleToString(currentStructureGate.previousDayLowDistance, 2));
   CsvAppend(line, DoubleToString(currentStructureGate.pivotDistance, 2));
   CsvAppend(line, DoubleToString(currentStructureGate.nearestSupportResistance, 2));
   CsvAppend(line, BoolText(currentStructureGate.largeCandleDetected));
   CsvAppend(line, BoolText(currentStructureGate.consecutiveCandleDetected));
   CsvAppend(line, BoolText(currentStructureGate.candle.detected));
   CsvAppend(line, currentStructureGate.candle.patternType);
   CsvAppend(line, currentStructureGate.candle.direction);
   CsvAppend(line, currentStructureGate.candle.timeframeText);
   CsvAppend(line, BoolText(currentStructureGate.candle.nearStructure));
   CsvAppend(line, BoolText(currentStructureGate.candle.confirmed));
   CsvAppend(line, BoolText(currentStructureGate.candle.dangerDetected));
   CsvAppend(line, currentStructureGate.candle.dangerReason);
   CsvAppend(line, currentStructureGate.earlyExitReason);
   CsvAppend(line, currentStructureGate.plannedAddReason);
   CsvAppend(line, currentStructureGate.hedgedBasketLossCompressionReason);
   CsvAppend(line, IntegerToString(structureBasedEarlyExitCount));
   CsvAppend(line, DoubleToString(structureBasedEarlyExitProfitTotal, 2));
   CsvAppend(line, IntegerToString(plannedAddPositionCount));
   CsvAppend(line, DoubleToString(plannedAddPositionProfitTotal, 2));
   CsvAppend(line, IntegerToString(hedgedBasketLossCompressionCount));
   CsvAppend(line, IntegerToString(blockedByGoldStructureCount));
   CsvAppend(line, IntegerToString(blockedByFibContextCount));
   CsvAppend(line, IntegerToString(blockedByMacroDayMismatchCount));
   CsvAppend(line, IntegerToString(blockedByPreviousDayHighLowCount));
   CsvAppend(line, IntegerToString(blockedByPivotCount));
   CsvAppend(line, IntegerToString(blockedByH1H4BreakoutCount));
   CsvAppend(line, IntegerToString(blockedByLargeCandleCount));
   CsvAppend(line, IntegerToString(blockedByConsecutiveCandleCount));
   CsvAppend(line, IntegerToString(blockedByCandlePatternCount));
   CsvAppend(line, IntegerToString(candlePatternConfirmationCount));
   CsvAppend(line, IntegerToString(bullishPinBarCount));
   CsvAppend(line, IntegerToString(bearishPinBarCount));
   CsvAppend(line, IntegerToString(engulfingConfirmationCount));
   CsvAppend(line, IntegerToString(spikeReversalConfirmationCount));
   CsvAppend(line, IntegerToString(dojiDangerBlockCount));
   CsvAppend(line, BoolText(UseHistoricalTimeRiskFilter));
   CsvAppend(line, IntegerToString(HistoricalTimeOffsetHours));
   CsvAppend(line, IntegerToString(currentHistoricalTimeSourceWeekday));
   CsvAppend(line, IntegerToString(currentHistoricalTimeSourceHour));
   CsvAppend(line, currentHistoricalTimeRiskState);
   CsvAppend(line, currentHistoricalTimeRiskReason);
   CsvAppend(line, DoubleToString(currentHistoricalTimeScoreAdd, 2));
   CsvAppend(line, BoolText(currentHistoricalTimeHighRisk));
   CsvAppend(line, BoolText(currentHistoricalTimeCaution));
   CsvAppend(line, BoolText(currentHistoricalTimeQuiet));
   CsvAppend(line, BoolText(currentHistoricalWeekdayHourBlock));
   CsvAppend(line, IntegerToString(blockedByHistoricalTimeRiskCount));
   CsvAppend(line, IntegerToString(blockedNewEntryByHistoricalTimeRiskCount));
   CsvAppend(line, IntegerToString(blockedAddByHistoricalTimeRiskCount));
   CsvAppend(line, IntegerToString(blockedDefenseHedgeByHistoricalTimeRiskCount));
   CsvAppend(line, IntegerToString(blockedBreakoutChaseByHistoricalTimeRiskCount));
   PerfFileWriteString(handle, line + "\r\n");

   FileClose(handle);
}

void DisplayStatus(const ScoreState &score,
                   string signal,
                   string action,
                   string reason,
                   const FilterState &dxy,
                   const FilterState &vix,
                   string newsState,
                   string newsReason,
                   string htfState,
                   string goldBuyReason,
                   string goldSellReason,
                   const PullbackState &pullback,
                   const MaStructureState &ma,
                   const PositionState &ps,
                   double marginLevel,
                   double dailyPL,
                   int consecutiveLosses)
{
   if(MinimizeCommentInBacktest && (IsFastCompareMode() || UseBacktestLightLogMode) && MQLInfoInteger(MQL_TESTER))
      return;

   string mode = "AUTO";
   if(SignalOnlyMode || ManualBiasMode == 4)
      mode = "SIGNAL ONLY";
   else if(ManualBiasMode == 3)
      mode = "STOP";
   else if(ManualBiasMode == 1)
      mode = "BUY ONLY";
   else if(ManualBiasMode == 2)
      mode = "SELL ONLY";

   string text =
      EA_NAME + "\n" +
      "LongScore: " + DoubleToString(score.longScore, 2) + "  ShortScore: " + DoubleToString(score.shortScore, 2) +
      "  Signal: " + signal + "\n" +
      "Mode: " + mode + "  Action: " + action + "\n" +
      "DXY: " + DoubleToString(dxy.value, 4) + "  " + dxy.state + "  " + dxy.reason + "\n" +
      "VIX: " + DoubleToString(vix.value, 4) + "  " + vix.state + "  " + vix.reason + "\n" +
      "News: " + newsState + "  " + newsReason + "\n" +
      "HTF: " + htfState + "\n" +
      "Pullback BUY: " + (pullback.okBuy ? "OK " : "NG ") + pullback.reasonBuy + "\n" +
      "Pullback SELL: " + (pullback.okSell ? "OK " : "NG ") + pullback.reasonSell + "\n" +
      "RSI: " + DoubleToString(pullback.rsi, 2) +
      "  EMA20: " + DoubleToString(pullback.emaFast, _Digits) +
      "  EMA50: " + DoubleToString(pullback.emaSlow, _Digits) + "\n" +
      "RecentHigh/Low: " + DoubleToString(pullback.recentHigh, _Digits) + " / " + DoubleToString(pullback.recentLow, _Digits) + "\n" +
      "MA: " + ma.trendDirection +
      "  F/M/L: " + DoubleToString(ma.fastValue, _Digits) + " / " + DoubleToString(ma.middleValue, _Digits) + " / " + DoubleToString(ma.longValue, _Digits) + "\n" +
      "MA Slope F/M/L: " + DoubleToString(ma.fastSlope, 2) + "(" + ma.fastSlopeState + ") / " +
      DoubleToString(ma.middleSlope, 2) + "(" + ma.middleSlopeState + ") / " +
      DoubleToString(ma.longSlope, 2) + "(" + ma.longSlopeState + ")\n" +
      "MA Slope BUY: " + ma.slopeReasonBuy + "\n" +
      "MA Slope SELL: " + ma.slopeReasonSell + "\n" +
      "MA BUY: " + (ma.okBuy ? "OK " : "NG ") + ma.reasonBuy + "\n" +
      "MA SELL: " + (ma.okSell ? "OK " : "NG ") + ma.reasonSell + "\n" +
      "GOLD BUY: " + goldBuyReason + "\n" +
      "GOLD SELL: " + goldSellReason + "\n" +
      "Spread: " + DoubleToString(SymbolInfoDouble(_Symbol, SYMBOL_ASK) - SymbolInfoDouble(_Symbol, SYMBOL_BID), 2) +
      "  Margin: " + DoubleToString(marginLevel, 2) +
      "  FloatDD%: " + DoubleToString(ps.floatingLossPercent, 2) + "\n" +
      "Daily P/L: " + DoubleToString(dailyPL, 2) +
      "  ConsecutiveLosses: " + IntegerToString(consecutiveLosses) + "\n" +
      "Positions T/B/S/Net: " + IntegerToString(ps.total) + "/" + IntegerToString(ps.buys) + "/" +
      IntegerToString(ps.sells) + "/" + IntegerToString(ps.net) + "\n" +
      "LastTradeActionTime: " + TimeToString(lastTradeActionTime, TIME_DATE | TIME_SECONDS) + "\n" +
      "LastAnyEaCloseTime: " + TimeToString(lastAnyEaCloseTime, TIME_DATE | TIME_SECONDS) + "\n" +
      "LastEntryDirection: " + DirectionToString(lastEntryDirection) +
      "  OppositeCooldownRemaining: " + IntegerToString(GetOppositeCooldownRemaining()) +
      "  AfterCloseCooldownRemaining: " + IntegerToString(GetAfterCloseCooldownRemaining()) + "\n" +
      "HardStopAfterMode: " + IntegerToString(HardStopAfterMode) +
      "  HardStopCooldownRemaining: " + IntegerToString(GetHardStopCooldownRemaining()) + "\n" +
      "LastStopReason: " + reason;

   if(CountPerformanceStats)
      perfCommentUpdateCount++;
   Comment(text);
}
