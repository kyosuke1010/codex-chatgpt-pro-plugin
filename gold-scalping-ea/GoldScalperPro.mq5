//+------------------------------------------------------------------+
//| GoldScalperPro.mq5                                               |
//| XAUUSD M1 mean-reversion scalper with layered regime gating.     |
//|                                                                  |
//| Attach to an XAUUSD M1 chart. All signal decisions use the last  |
//| CLOSED bar; entries are market orders at the open of the next    |
//| bar. Every position carries a hard SL. No averaging, no grid.    |
//|                                                                  |
//| This EA is NOT guaranteed to be profitable. Run the validation   |
//| protocol in README.md (real ticks, real spread, walk-forward,    |
//| stress tests) before risking money.                              |
//+------------------------------------------------------------------+
#property copyright "MIT"
#property version   "1.10"
#property strict

#include <Trade/Trade.mqh>

//=== Inputs: identification ==========================================
input long   InpMagic            = 20260715;   // Magic number
input string InpComment          = "GSP";      // Order comment

//=== Inputs: risk =====================================================
input double InpRiskPct          = 0.30;       // Risk per trade (% of balance)
input double InpDailyLossLimitPct= 2.0;        // Stop trading after daily loss (%)
input int    InpMaxTradesPerDay  = 6;          // Max entries per day
input int    InpMaxConsecLosses  = 3;          // Losing streak before cooldown
input int    InpCooldownMinutes  = 90;         // Cooldown after losing streak (min)

//=== Inputs: signal ===================================================
input int    InpBbPeriod         = 20;         // Bollinger period (M1)
input double InpBbDev            = 2.0;        // Bollinger deviation
input int    InpRsiPeriod        = 3;          // RSI period (M1)
input double InpRsiOversold      = 15.0;       // RSI oversold (long)
input double InpRsiOverbought    = 85.0;       // RSI overbought (short)
input double InpMinStretchAtr    = 1.0;        // Min |close-midband| in ATR mult
enum ENUM_TREND_FILTER
  {
   TREND_FILTER_OFF   = 0,                     // No trend filter
   TREND_FILTER_WITH  = 1,                     // Trade only with M5 EMA200 trend
   TREND_FILTER_AGAINST = 2                    // Trade only against M5 EMA200 trend
  };
input ENUM_TREND_FILTER InpTrendFilter = TREND_FILTER_WITH; // Trend filter mode
enum ENUM_ENTRY_CONFIRM
  {
   CONFIRM_NONE         = 0,                   // Enter right after the extreme close
   CONFIRM_REENTRY      = 1,                   // Wait for a close back inside the band
   CONFIRM_REVERSAL_BAR = 2                    // Re-entry close + bar direction agrees
  };
input ENUM_ENTRY_CONFIRM InpEntryConfirm = CONFIRM_REENTRY; // Entry confirmation mode
input int    InpConfirmTimeoutBars = 5;        // Cancel setup after N bars w/o confirm

//=== Inputs: exits ====================================================
input double InpSlAtrMult        = 1.5;        // SL distance in ATR(14,M1) mult
input double InpTpRR             = 1.2;        // TP as multiple of SL distance
input double InpBeTriggerRR      = 0.7;        // Move SL to breakeven at +R
input double InpBeOffsetPoints   = 5;          // Breakeven offset (points)
input int    InpMaxHoldMinutes   = 20;         // Time stop (minutes, 0=off)

//=== Inputs: regime gate =============================================
input int    InpMaxSpreadPoints  = 35;         // Max spread (points)
input double InpMinAtrPoints     = 15;         // Min ATR(14,M1) in points
input double InpMaxAtrPoints     = 120;        // Max ATR(14,M1) in points
input string InpSession1         = "10:00-13:00"; // Session 1 (server time)
input string InpSession2         = "15:30-19:00"; // Session 2 (server time, empty=off)
input string InpBlackout         = "";         // Blackout "HH:MM-HH:MM,..." (news)
input int    InpFridayLastHour   = 18;         // No new trades from this hour on Friday
input bool   InpTradeMonday      = true;       // Allow Monday

//=== Globals ==========================================================
CTrade   g_trade;
int      g_hBands = INVALID_HANDLE;
int      g_hRsi   = INVALID_HANDLE;
int      g_hAtr   = INVALID_HANDLE;
int      g_hEmaM5 = INVALID_HANDLE;

datetime g_lastBarTime      = 0;      // last processed M1 bar
datetime g_lastSignalBar    = 0;      // bar that already produced an entry
int      g_pendingDir       = 0;      // armed setup awaiting confirmation (0=none)
int      g_pendingBars      = 0;      // closed bars elapsed since the setup was armed
datetime g_dayAnchorDate    = 0;      // start of current trading day
double   g_dayStartEquity   = 0.0;
int      g_tradesToday      = 0;
bool     g_dayHalted        = false;
int      g_lossStreak       = 0;
datetime g_cooldownUntil    = 0;

struct TimeRange { int fromMin; int toMin; };
TimeRange g_sessions[2];
int       g_sessionCount = 0;
TimeRange g_blackouts[16];
int       g_blackoutCount = 0;

//+------------------------------------------------------------------+
//| Parse "HH:MM-HH:MM" into minutes-of-day range                    |
//+------------------------------------------------------------------+
bool ParseRange(const string text, TimeRange &r)
  {
   string parts[];
   if(StringSplit(text, '-', parts) != 2)
      return false;
   string a[], b[];
   if(StringSplit(parts[0], ':', a) != 2 || StringSplit(parts[1], ':', b) != 2)
      return false;
   r.fromMin = (int)StringToInteger(a[0]) * 60 + (int)StringToInteger(a[1]);
   r.toMin   = (int)StringToInteger(b[0]) * 60 + (int)StringToInteger(b[1]);
   return (r.fromMin >= 0 && r.toMin <= 24 * 60 && r.fromMin < r.toMin);
  }

//+------------------------------------------------------------------+
bool InRange(const TimeRange &r, const int minuteOfDay)
  {
   return (minuteOfDay >= r.fromMin && minuteOfDay < r.toMin);
  }

//+------------------------------------------------------------------+
int OnInit()
  {
   if(StringFind(_Symbol, "XAU") < 0 && StringFind(_Symbol, "GOLD") < 0)
      Print("WARNING: symbol ", _Symbol, " does not look like gold. Defaults are tuned for XAUUSD.");
   if(_Period != PERIOD_M1)
      Print("WARNING: designed for M1 charts; signals always use M1 data regardless.");

   g_trade.SetExpertMagicNumber(InpMagic);
   g_trade.SetDeviationInPoints(20);
   g_trade.SetTypeFillingBySymbol(_Symbol);

   g_hBands = iBands(_Symbol, PERIOD_M1, InpBbPeriod, 0, InpBbDev, PRICE_CLOSE);
   g_hRsi   = iRSI(_Symbol, PERIOD_M1, InpRsiPeriod, PRICE_CLOSE);
   g_hAtr   = iATR(_Symbol, PERIOD_M1, 14);
   g_hEmaM5 = iMA(_Symbol, PERIOD_M5, 200, 0, MODE_EMA, PRICE_CLOSE);
   if(g_hBands == INVALID_HANDLE || g_hRsi == INVALID_HANDLE ||
      g_hAtr == INVALID_HANDLE || g_hEmaM5 == INVALID_HANDLE)
     {
      Print("Failed to create indicator handles");
      return INIT_FAILED;
     }

   // Sessions
   g_sessionCount = 0;
   TimeRange r;
   if(InpSession1 != "" && ParseRange(InpSession1, r))
      g_sessions[g_sessionCount++] = r;
   if(InpSession2 != "" && ParseRange(InpSession2, r))
      g_sessions[g_sessionCount++] = r;
   if(g_sessionCount == 0)
     {
      Print("No valid trading session configured (Session1/Session2)");
      return INIT_PARAMETERS_INCORRECT;
     }

   // Blackout windows
   g_blackoutCount = 0;
   if(InpBlackout != "")
     {
      string chunks[];
      int n = StringSplit(InpBlackout, ',', chunks);
      for(int i = 0; i < n && g_blackoutCount < 16; i++)
        {
         string chunk = chunks[i];
         StringTrimLeft(chunk);
         StringTrimRight(chunk);
         if(chunk == "")
            continue;
         if(ParseRange(chunk, r))
            g_blackouts[g_blackoutCount++] = r;
         else
            Print("Ignoring malformed blackout window: ", chunk);
        }
     }

   if(InpRiskPct <= 0 || InpRiskPct > 2.0)
     {
      Print("RiskPct must be within (0, 2.0] — refusing oversized per-trade risk");
      return INIT_PARAMETERS_INCORRECT;
     }
   return INIT_SUCCEEDED;
  }

//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   if(g_hBands != INVALID_HANDLE) IndicatorRelease(g_hBands);
   if(g_hRsi   != INVALID_HANDLE) IndicatorRelease(g_hRsi);
   if(g_hAtr   != INVALID_HANDLE) IndicatorRelease(g_hAtr);
   if(g_hEmaM5 != INVALID_HANDLE) IndicatorRelease(g_hEmaM5);
  }

//+------------------------------------------------------------------+
//| Daily anchor: reset counters at server-day rollover               |
//+------------------------------------------------------------------+
void UpdateDailyAnchor()
  {
   MqlDateTime dt;
   TimeToStruct(TimeCurrent(), dt);
   dt.hour = 0; dt.min = 0; dt.sec = 0;
   datetime today = StructToTime(dt);
   if(today != g_dayAnchorDate)
     {
      g_dayAnchorDate  = today;
      g_dayStartEquity = AccountInfoDouble(ACCOUNT_EQUITY);
      g_tradesToday    = 0;
      g_dayHalted      = false;
     }
  }

//+------------------------------------------------------------------+
//| Position helpers                                                 |
//+------------------------------------------------------------------+
bool HasOpenPosition()
  {
   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      ulong ticket = PositionGetTicket(i);
      if(ticket == 0)
         continue;
      if(PositionGetString(POSITION_SYMBOL) == _Symbol &&
         PositionGetInteger(POSITION_MAGIC) == InpMagic)
         return true;
     }
   return false;
  }

//+------------------------------------------------------------------+
//| Exit management: breakeven + time stop (every tick)              |
//+------------------------------------------------------------------+
void ManageOpenPosition()
  {
   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      ulong ticket = PositionGetTicket(i);
      if(ticket == 0)
         continue;
      if(PositionGetString(POSITION_SYMBOL) != _Symbol ||
         PositionGetInteger(POSITION_MAGIC) != InpMagic)
         continue;

      long   type    = PositionGetInteger(POSITION_TYPE);
      double entry   = PositionGetDouble(POSITION_PRICE_OPEN);
      double sl      = PositionGetDouble(POSITION_SL);
      double tp      = PositionGetDouble(POSITION_TP);
      datetime opened= (datetime)PositionGetInteger(POSITION_TIME);

      // Time stop: a reversion scalp that has not worked is a losing trade in disguise
      if(InpMaxHoldMinutes > 0 && TimeCurrent() - opened >= InpMaxHoldMinutes * 60)
        {
         if(!g_trade.PositionClose(ticket))
            Print("Time-stop close failed: ", g_trade.ResultRetcodeDescription());
         continue;
        }

      // Breakeven move
      double riskDist = MathAbs(entry - sl);
      if(riskDist <= 0)
         continue;
      double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
      double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
      double beOffset = InpBeOffsetPoints * _Point;

      if(type == POSITION_TYPE_BUY)
        {
         double newSl = NormalizePrice(entry + beOffset);
         if(bid - entry >= InpBeTriggerRR * riskDist && sl < newSl)
            g_trade.PositionModify(ticket, newSl, tp);
        }
      else
        {
         double newSl = NormalizePrice(entry - beOffset);
         if(entry - ask >= InpBeTriggerRR * riskDist && (sl > newSl || sl == 0))
            g_trade.PositionModify(ticket, newSl, tp);
        }
     }
  }

//+------------------------------------------------------------------+
double NormalizePrice(double price)
  {
   double tick = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE);
   if(tick <= 0)
      tick = _Point;
   return NormalizeDouble(MathRound(price / tick) * tick, _Digits);
  }

//+------------------------------------------------------------------+
//| Regime gate: every condition must pass to allow a NEW entry      |
//+------------------------------------------------------------------+
bool RegimeAllowsEntry(const double atr)
  {
   MqlDateTime dt;
   TimeToStruct(TimeCurrent(), dt);
   int minuteOfDay = dt.hour * 60 + dt.min;

   // Weekday gates
   if(dt.day_of_week == 5 && dt.hour >= InpFridayLastHour) return false;
   if(dt.day_of_week == 1 && !InpTradeMonday)              return false;
   if(dt.day_of_week == 0 || dt.day_of_week == 6)          return false;

   // Session windows
   bool inSession = false;
   for(int i = 0; i < g_sessionCount; i++)
      if(InRange(g_sessions[i], minuteOfDay)) { inSession = true; break; }
   if(!inSession)
      return false;

   // News blackout
   for(int i = 0; i < g_blackoutCount; i++)
      if(InRange(g_blackouts[i], minuteOfDay))
         return false;

   // Spread
   long spread = SymbolInfoInteger(_Symbol, SYMBOL_SPREAD);
   if(spread > InpMaxSpreadPoints)
      return false;

   // Volatility regime: dead markets fake out, broken markets run through stops
   double atrPoints = atr / _Point;
   if(atrPoints < InpMinAtrPoints || atrPoints > InpMaxAtrPoints)
      return false;

   // Daily loss guard
   if(g_dayHalted)
      return false;
   if(g_dayStartEquity > 0)
     {
      double dd = (g_dayStartEquity - AccountInfoDouble(ACCOUNT_EQUITY)) / g_dayStartEquity * 100.0;
      if(dd >= InpDailyLossLimitPct)
        {
         g_dayHalted = true;
         Print("Daily loss limit hit (", DoubleToString(dd, 2), "%). Halting for the day.");
         return false;
        }
     }

   // Trade count / streak cooldown
   if(g_tradesToday >= InpMaxTradesPerDay) return false;
   if(TimeCurrent() < g_cooldownUntil)     return false;

   return true;
  }

//+------------------------------------------------------------------+
//| Signal: -1 short, +1 long, 0 none. Uses closed bar (shift 1).    |
//+------------------------------------------------------------------+
int GetSignal(const double atr)
  {
   double mid[1], upper[1], lower[1], rsi[1], emaM5[1];
   if(CopyBuffer(g_hBands, BASE_LINE,  1, 1, mid)   != 1) return 0;
   if(CopyBuffer(g_hBands, UPPER_BAND, 1, 1, upper) != 1) return 0;
   if(CopyBuffer(g_hBands, LOWER_BAND, 1, 1, lower) != 1) return 0;
   if(CopyBuffer(g_hRsi, 0, 1, 1, rsi)              != 1) return 0;
   if(CopyBuffer(g_hEmaM5, 0, 1, 1, emaM5)          != 1) return 0;

   double close = iClose(_Symbol, PERIOD_M1, 1);
   if(close <= 0 || atr <= 0)
      return 0;

   double stretch = MathAbs(close - mid[0]);
   if(stretch < InpMinStretchAtr * atr)
      return 0;

   bool longSetup  = (close < lower[0] && rsi[0] < InpRsiOversold);
   bool shortSetup = (close > upper[0] && rsi[0] > InpRsiOverbought);

   if(InpTrendFilter == TREND_FILTER_WITH)
     {
      if(longSetup  && close < emaM5[0]) longSetup  = false;
      if(shortSetup && close > emaM5[0]) shortSetup = false;
     }
   else if(InpTrendFilter == TREND_FILTER_AGAINST)
     {
      if(longSetup  && close > emaM5[0]) longSetup  = false;
      if(shortSetup && close < emaM5[0]) shortSetup = false;
     }

   if(longSetup)  return  1;
   if(shortSetup) return -1;
   return 0;
  }

//+------------------------------------------------------------------+
//| Confirmation: has price actually started turning back?           |
//| Long: closed bar back INSIDE the band (close > lower band);      |
//| REVERSAL_BAR additionally requires the bar itself to be bullish. |
//+------------------------------------------------------------------+
bool SetupConfirmed(const int dir)
  {
   double upper[1], lower[1];
   if(CopyBuffer(g_hBands, UPPER_BAND, 1, 1, upper) != 1) return false;
   if(CopyBuffer(g_hBands, LOWER_BAND, 1, 1, lower) != 1) return false;

   double close = iClose(_Symbol, PERIOD_M1, 1);
   double open  = iOpen(_Symbol, PERIOD_M1, 1);
   if(close <= 0 || open <= 0)
      return false;

   if(dir > 0)
     {
      if(close <= lower[0])
         return false;                      // still outside — knife is still falling
      if(InpEntryConfirm == CONFIRM_REVERSAL_BAR && close <= open)
         return false;                      // re-entered but the bar is not bullish
      return true;
     }
   else
     {
      if(close >= upper[0])
         return false;
      if(InpEntryConfirm == CONFIRM_REVERSAL_BAR && close >= open)
         return false;
      return true;
     }
  }

//+------------------------------------------------------------------+
//| Position sizing: fixed fractional risk against SL distance       |
//+------------------------------------------------------------------+
double CalcLots(const double slDistance)
  {
   if(slDistance <= 0)
      return 0.0;
   double balance   = AccountInfoDouble(ACCOUNT_BALANCE);
   double riskMoney = balance * InpRiskPct / 100.0;

   double tickValue = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE);
   double tickSize  = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE);
   if(tickValue <= 0 || tickSize <= 0)
      return 0.0;

   double lossPerLot = slDistance / tickSize * tickValue;
   if(lossPerLot <= 0)
      return 0.0;

   double lots = riskMoney / lossPerLot;

   double minLot  = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
   double maxLot  = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX);
   double lotStep = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);
   if(lotStep > 0)
      lots = MathFloor(lots / lotStep) * lotStep;
   if(lots < minLot)
      return 0.0; // account too small to respect the risk cap — do not trade
   return MathMin(lots, maxLot);
  }

//+------------------------------------------------------------------+
//| Entry execution                                                  |
//+------------------------------------------------------------------+
void TryEnter(const int dir, const double atr)
  {
   double slDist = InpSlAtrMult * atr;
   long stopsLevel = SymbolInfoInteger(_Symbol, SYMBOL_TRADE_STOPS_LEVEL);
   double minDist = (stopsLevel + 2) * _Point;
   if(slDist < minDist)
      slDist = minDist;

   double lots = CalcLots(slDist);
   if(lots <= 0)
     {
      Print("Sizing produced no valid lot (balance too small for risk cap?) — skipping");
      return;
     }

   bool ok = false;
   if(dir > 0)
     {
      double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
      double sl  = NormalizePrice(ask - slDist);
      double tp  = NormalizePrice(ask + InpTpRR * slDist);
      ok = g_trade.Buy(lots, _Symbol, 0.0, sl, tp, InpComment);
     }
   else
     {
      double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
      double sl  = NormalizePrice(bid + slDist);
      double tp  = NormalizePrice(bid - InpTpRR * slDist);
      ok = g_trade.Sell(lots, _Symbol, 0.0, sl, tp, InpComment);
     }

   if(ok)
     {
      g_tradesToday++;
      g_lastSignalBar = g_lastBarTime;
     }
   else
      Print("Entry failed: ", g_trade.ResultRetcodeDescription());
  }

//+------------------------------------------------------------------+
void OnTick()
  {
   UpdateDailyAnchor();
   ManageOpenPosition();

   // Signal logic only on a fresh M1 bar
   datetime barTime = iTime(_Symbol, PERIOD_M1, 0);
   if(barTime == g_lastBarTime)
      return;
   g_lastBarTime = barTime;

   if(HasOpenPosition())
     {
      g_pendingDir = 0;                     // never stack setups behind an open trade
      return;
     }
   if(g_lastSignalBar == barTime)
      return;

   double atrBuf[1];
   if(CopyBuffer(g_hAtr, 0, 1, 1, atrBuf) != 1)
      return;
   double atr = atrBuf[0];

   int sig = GetSignal(atr);

   // --- Pending setup: waiting for the market to prove the turn ---
   if(g_pendingDir != 0)
     {
      g_pendingBars++;
      if(sig == g_pendingDir)
         g_pendingBars = 0;                 // extreme repeated — setup refreshed
      else if(sig == -g_pendingDir)
        {
         g_pendingDir  = sig;               // opposite extreme — flip the setup
         g_pendingBars = 0;
        }
      else if(SetupConfirmed(g_pendingDir))
        {
         int dir = g_pendingDir;
         g_pendingDir = 0;
         // Regime is re-checked at confirmation time; if conditions have
         // deteriorated (spread spike, session end), drop the setup entirely.
         if(RegimeAllowsEntry(atr))
            TryEnter(dir, atr);
         return;
        }
      if(g_pendingDir != 0 && g_pendingBars >= InpConfirmTimeoutBars)
         g_pendingDir = 0;                  // no confirmation in time — stand down
      return;
     }

   // --- No pending setup: look for a fresh extreme ---
   if(sig == 0)
      return;
   if(!RegimeAllowsEntry(atr))
      return;

   if(InpEntryConfirm == CONFIRM_NONE)
      TryEnter(sig, atr);
   else
     {
      g_pendingDir  = sig;
      g_pendingBars = 0;
     }
  }

//+------------------------------------------------------------------+
//| Track closed deals: losing-streak cooldown                       |
//+------------------------------------------------------------------+
void OnTradeTransaction(const MqlTradeTransaction &trans,
                        const MqlTradeRequest &request,
                        const MqlTradeResult &result)
  {
   if(trans.type != TRADE_TRANSACTION_DEAL_ADD)
      return;
   if(!HistoryDealSelect(trans.deal))
      return;
   if(HistoryDealGetInteger(trans.deal, DEAL_MAGIC) != InpMagic)
      return;
   if(HistoryDealGetString(trans.deal, DEAL_SYMBOL) != _Symbol)
      return;
   if(HistoryDealGetInteger(trans.deal, DEAL_ENTRY) != DEAL_ENTRY_OUT)
      return;

   double pnl = HistoryDealGetDouble(trans.deal, DEAL_PROFIT)
              + HistoryDealGetDouble(trans.deal, DEAL_COMMISSION)
              + HistoryDealGetDouble(trans.deal, DEAL_SWAP);

   if(pnl < 0)
     {
      g_lossStreak++;
      if(g_lossStreak >= InpMaxConsecLosses)
        {
         g_cooldownUntil = TimeCurrent() + (datetime)(InpCooldownMinutes * 60);
         g_lossStreak = 0;
         Print("Losing streak reached ", InpMaxConsecLosses,
               " — cooling down for ", InpCooldownMinutes, " minutes.");
        }
     }
   else
      g_lossStreak = 0;
  }
//+------------------------------------------------------------------+
