//+------------------------------------------------------------------+
//|                                       GoldSessionBreakout.mq5    |
//|  XAUUSD London-session breakout EA.                              |
//|                                                                  |
//|  Structural hypothesis: gold compresses during the Asian         |
//|  session and expands during London/NY. We trade the breakout of  |
//|  the Asian range, filtered by range quality (vs daily ATR),      |
//|  an H4 trend filter, spread/news guards, and strict              |
//|  fixed-fractional risk with daily-loss and drawdown lockouts.    |
//|                                                                  |
//|  Timeframe: attach to XAUUSD M15. Session hours are SERVER time  |
//|  - align them with your broker's timezone before use.            |
//|                                                                  |
//|  NO PROFIT IS GUARANTEED. Validate per README before any live    |
//|  deployment.                                                     |
//+------------------------------------------------------------------+
#property copyright   "MIT License"
#property version     "1.11"
#property description "Asian-range breakout at London open for XAUUSD with strict risk controls."

#include <Trade\Trade.mqh>
#include <Trade\PositionInfo.mqh>

//--- inputs -------------------------------------------------------
input group "=== General ==="
input long              InpMagic              = 20260715;   // Magic number
input string            InpTradeComment       = "GSB";      // Order comment

input group "=== Sessions (SERVER time, hours 0-23) ==="
input int               InpAsiaStartHour      = 1;          // Asian range: start hour
input int               InpAsiaEndHour        = 9;          // Asian range: end hour (~London open)
input int               InpLastEntryHour      = 15;         // No new entries at/after this hour
input int               InpFlatHour           = 22;         // Close all positions at this hour
input int               InpPreCloseBufferMin  = 15;         // Also flatten this many minutes before session close

input group "=== Range quality (multiples of daily ATR) ==="
input int               InpATRPeriodD1        = 14;         // Daily ATR period
input double            InpMinRangeATR        = 0.10;       // Min Asian range width
input double            InpMaxRangeATR        = 0.60;       // Max Asian range width
input double            InpBreakBufferATR     = 0.05;       // Breakout buffer beyond range edge
input double            InpMaxChaseATR        = 0.25;       // Skip entry if price ran further than this past the edge

input group "=== Direction / trend filter ==="
input bool              InpAllowLong          = true;       // Allow long breakouts
input bool              InpAllowShort         = true;       // Allow short breakouts
input bool              InpUseTrendFilter     = true;       // Trade only with higher-TF trend
input ENUM_TIMEFRAMES   InpTrendTF            = PERIOD_H4;  // Trend timeframe
input int               InpTrendMAPeriod      = 50;         // Trend EMA period

input group "=== Risk management ==="
input double            InpRiskPercent        = 0.5;        // Risk per trade, % of equity
input double            InpMaxSLATR           = 0.80;       // Cap SL distance, x daily ATR
input double            InpTPRR               = 1.6;        // Take profit, R multiple
input double            InpBreakevenR         = 1.0;        // Move SL to breakeven at this R
input double            InpTrailATRMult       = 2.5;        // Trail distance, x H1 ATR (after BE)
input int               InpTrailStepPoints    = 30;         // Min SL improvement (points) per trail update
input int               InpATRPeriodH1        = 14;         // H1 ATR period (trailing)
input double            InpDailyLossPct       = 2.0;        // Daily loss stop, % of day-start equity
input bool              InpFlattenOnDailyStop = true;       // Close open positions when daily stop hits
input double            InpMaxDrawdownPct     = 10.0;       // Hard lockout, % below equity high-water mark
input bool              InpFlattenOnDDLock    = true;       // Close open positions when lockout triggers
input int               InpMaxTradesPerSide   = 1;          // Max entries per direction per day
input bool              InpAllowMinLotFallback = false;     // Small accounts: trade min lot when risk target unreachable
input double            InpHardRiskCapPct     = 2.0;        // Max actual risk % allowed on a min-lot fallback entry

input group "=== Execution guards ==="
input int               InpMaxSpreadPoints    = 45;         // Max spread (points) to open trades
input int               InpSlippagePoints     = 50;         // Max deviation (points)
input bool              InpUseNewsFilter      = true;       // Block around high-impact USD news
input int               InpNewsBlockBeforeMin = 30;         // Minutes blocked before news
input int               InpNewsBlockAfterMin  = 30;         // Minutes blocked after news

//--- globals ------------------------------------------------------
CTrade        g_trade;
CPositionInfo g_pos;

int      g_hATR_D1        = INVALID_HANDLE;
int      g_hATR_H1        = INVALID_HANDLE;
int      g_hTrendMA       = INVALID_HANDLE;

datetime g_curDay         = 0;      // start of current server day
double   g_dayStartEquity = 0.0;
bool     g_dailyStopHit   = false;
bool     g_rangeReady     = false;  // range build attempted today
bool     g_rangeValid     = false;  // range passed quality filters
double   g_rangeHigh      = 0.0;
double   g_rangeLow       = 0.0;
datetime g_lastM15Bar     = 0;
bool     g_ddLockLogged   = false;

string   g_hwmName;                 // GlobalVariable key for equity high-water mark

//+------------------------------------------------------------------+
int OnInit()
{
   if(InpAsiaStartHour >= InpAsiaEndHour ||
      InpAsiaEndHour   >  InpLastEntryHour ||
      InpLastEntryHour >  InpFlatHour)
   {
      Print("Invalid session hours: require AsiaStart < AsiaEnd <= LastEntry <= Flat");
      return INIT_PARAMETERS_INCORRECT;
   }

   g_trade.SetExpertMagicNumber(InpMagic);
   g_trade.SetDeviationInPoints(InpSlippagePoints);
   SetFillingMode();

   g_hATR_D1 = iATR(_Symbol, PERIOD_D1, InpATRPeriodD1);
   g_hATR_H1 = iATR(_Symbol, PERIOD_H1, InpATRPeriodH1);
   if(InpUseTrendFilter)
      g_hTrendMA = iMA(_Symbol, InpTrendTF, InpTrendMAPeriod, 0, MODE_EMA, PRICE_CLOSE);

   if(g_hATR_D1 == INVALID_HANDLE || g_hATR_H1 == INVALID_HANDLE ||
      (InpUseTrendFilter && g_hTrendMA == INVALID_HANDLE))
   {
      Print("Failed to create indicator handles");
      return INIT_FAILED;
   }

   // account login in the key: isolates state between accounts on one terminal
   g_hwmName = StringFormat("GSB_HWM_%I64d_%s_%I64d",
                            AccountInfoInteger(ACCOUNT_LOGIN), _Symbol, InpMagic);
   if(!GlobalVariableCheck(g_hwmName))
      GlobalVariableSet(g_hwmName, AccountInfoDouble(ACCOUNT_EQUITY));

   EventSetTimer(60);   // flat enforcement even when no ticks arrive

   return INIT_SUCCEEDED;
}

//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   EventKillTimer();
   if(g_hATR_D1  != INVALID_HANDLE) IndicatorRelease(g_hATR_D1);
   if(g_hATR_H1  != INVALID_HANDLE) IndicatorRelease(g_hATR_H1);
   if(g_hTrendMA != INVALID_HANDLE) IndicatorRelease(g_hTrendMA);
   Comment("");
}

//+------------------------------------------------------------------+
void OnTick()
{
   UpdateDay();
   UpdateHighWaterMark();

   MqlDateTime tm;
   TimeToStruct(TimeCurrent(), tm);

   // positions carried past midnight (early-close/holiday days): close at first opportunity
   CloseStalePositions();

   // end-of-day flat: rollover spread, overnight gaps, broker session close
   if(tm.hour >= InpFlatHour || SessionCloseSoon())
   {
      CloseAllPositions("flat window");
      UpdateChartComment(tm);
      return;
   }

   if(InpFlattenOnDDLock && DrawdownLocked())
      CloseAllPositions("dd lockout");

   ManageOpenPositions();
   CheckDailyStop();

   if(tm.hour >= InpAsiaEndHour && !g_rangeReady)
      BuildAsianRange();

   if(IsNewM15Bar() && CanOpenNewTrades(tm))
      CheckBreakoutEntry();

   UpdateChartComment(tm);
}

//+------------------------------------------------------------------+
//| Timer: enforce the flat rules even when no ticks arrive          |
//+------------------------------------------------------------------+
void OnTimer()
{
   UpdateDay();
   CloseStalePositions();

   MqlDateTime tm;
   TimeToStruct(TimeCurrent(), tm);
   if(tm.hour >= InpFlatHour || SessionCloseSoon())
      CloseAllPositions("flat window (timer)");
}

//+------------------------------------------------------------------+
//| Day rollover: reset daily state                                  |
//+------------------------------------------------------------------+
void UpdateDay()
{
   datetime t     = TimeCurrent();
   datetime today = t - (t % 86400);
   if(today != g_curDay)
   {
      g_curDay         = today;
      g_dayStartEquity = AccountInfoDouble(ACCOUNT_EQUITY);
      g_dailyStopHit   = false;
      g_rangeReady     = false;
      g_rangeValid     = false;
   }
}

//+------------------------------------------------------------------+
//| Asian range: built once per day after the session ends           |
//+------------------------------------------------------------------+
void BuildAsianRange()
{
   g_rangeReady = true;
   g_rangeValid = false;

   datetime from = g_curDay + InpAsiaStartHour * 3600;
   datetime to   = g_curDay + InpAsiaEndHour   * 3600 - 1;

   MqlRates rates[];
   int copied = CopyRates(_Symbol, PERIOD_M15, from, to, rates);
   if(copied < 4)
   {
      PrintFormat("Asian range: not enough M15 bars (%d) - no trading today", copied);
      return;
   }

   double hi = rates[0].high, lo = rates[0].low;
   for(int i = 1; i < copied; i++)
   {
      if(rates[i].high > hi) hi = rates[i].high;
      if(rates[i].low  < lo) lo = rates[i].low;
   }

   double atrD = DailyATR();
   if(atrD <= 0)
      return;

   double width = hi - lo;
   if(width < InpMinRangeATR * atrD || width > InpMaxRangeATR * atrD)
   {
      PrintFormat("Asian range rejected: width %.2f = %.2f x dailyATR (allowed %.2f-%.2f)",
                  width, width / atrD, InpMinRangeATR, InpMaxRangeATR);
      return;
   }

   g_rangeHigh  = hi;
   g_rangeLow   = lo;
   g_rangeValid = true;
   PrintFormat("Asian range accepted: %.2f .. %.2f (%.2f x dailyATR)", lo, hi, width / atrD);
}

//+------------------------------------------------------------------+
bool IsNewM15Bar()
{
   datetime t = iTime(_Symbol, PERIOD_M15, 0);
   if(t == g_lastM15Bar)
      return false;
   g_lastM15Bar = t;
   return true;
}

//+------------------------------------------------------------------+
bool CanOpenNewTrades(const MqlDateTime &tm)
{
   if(!g_rangeValid)                                        return false;
   if(tm.hour < InpAsiaEndHour || tm.hour >= InpLastEntryHour) return false;
   if(g_dailyStopHit)                                       return false;
   if(DrawdownLocked())                                     return false;
   if(SpreadPoints() > InpMaxSpreadPoints)                  return false;
   if(IsNewsBlackout())                                     return false;
   return true;
}

//+------------------------------------------------------------------+
//| Entry: close-confirmed breakout of the Asian range               |
//+------------------------------------------------------------------+
void CheckBreakoutEntry()
{
   double atrD = DailyATR();
   if(atrD <= 0)
      return;

   MqlTick tick;
   if(!SymbolInfoTick(_Symbol, tick))
      return;

   double buffer    = InpBreakBufferATR * atrD;
   double maxChase  = InpMaxChaseATR   * atrD;
   double closePrev = iClose(_Symbol, PERIOD_M15, 1);

   bool longSignal  = InpAllowLong  && closePrev > g_rangeHigh + buffer
                      && tick.ask <= g_rangeHigh + maxChase;
   bool shortSignal = InpAllowShort && closePrev < g_rangeLow - buffer
                      && tick.bid >= g_rangeLow - maxChase;

   if(longSignal && TrendAllows(true)
      && !HasOpenPosition(POSITION_TYPE_BUY)
      && EntriesToday(POSITION_TYPE_BUY) < InpMaxTradesPerSide)
      OpenTrade(ORDER_TYPE_BUY, atrD);

   if(shortSignal && TrendAllows(false)
      && !HasOpenPosition(POSITION_TYPE_SELL)
      && EntriesToday(POSITION_TYPE_SELL) < InpMaxTradesPerSide)
      OpenTrade(ORDER_TYPE_SELL, atrD);
}

//+------------------------------------------------------------------+
//| Trend filter: fail closed if indicator data is unavailable       |
//+------------------------------------------------------------------+
bool TrendAllows(const bool isLong)
{
   if(!InpUseTrendFilter)
      return true;
   double ma[1];
   if(CopyBuffer(g_hTrendMA, 0, 1, 1, ma) != 1)
      return false;
   double c = iClose(_Symbol, InpTrendTF, 1);
   return isLong ? (c > ma[0]) : (c < ma[0]);
}

//+------------------------------------------------------------------+
void OpenTrade(const ENUM_ORDER_TYPE type, const double atrD)
{
   MqlTick tick;
   if(!SymbolInfoTick(_Symbol, tick))
      return;

   bool   isLong = (type == ORDER_TYPE_BUY);
   double entry  = isLong ? tick.ask : tick.bid;

   // SL at the far side of the range, capped at InpMaxSLATR x daily ATR
   double rawSL   = isLong ? g_rangeLow : g_rangeHigh;
   double dist    = MathAbs(entry - rawSL);
   double maxDist = InpMaxSLATR * atrD;
   if(dist > maxDist)
      dist = maxDist;

   double minDist = (SymbolInfoInteger(_Symbol, SYMBOL_TRADE_STOPS_LEVEL) + 1) * _Point;
   if(dist < minDist)
      dist = minDist;

   double sl = NormalizeDouble(isLong ? entry - dist : entry + dist, _Digits);
   double tp = NormalizeDouble(isLong ? entry + InpTPRR * dist : entry - InpTPRR * dist, _Digits);

   double lots = CalcLots(dist);
   if(lots <= 0)
   {
      Print("Lot sizing failed or below minimum - trade skipped");
      return;
   }

   bool ok = isLong
             ? g_trade.Buy(lots, _Symbol, 0.0, sl, tp, InpTradeComment)
             : g_trade.Sell(lots, _Symbol, 0.0, sl, tp, InpTradeComment);
   if(!ok)
      PrintFormat("Order failed: %u %s", g_trade.ResultRetcode(), g_trade.ResultRetcodeDescription());
}

//+------------------------------------------------------------------+
//| Fixed-fractional sizing; skips the trade rather than oversizing  |
//+------------------------------------------------------------------+
double CalcLots(const double slDistance)
{
   double tickSize  = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE);
   double tickValue = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE);
   if(tickSize <= 0 || tickValue <= 0 || slDistance <= 0)
      return 0.0;

   double riskMoney  = AccountInfoDouble(ACCOUNT_EQUITY) * InpRiskPercent / 100.0;
   double lossPerLot = slDistance / tickSize * tickValue;
   if(lossPerLot <= 0)
      return 0.0;

   double step = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);
   double vmin = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
   double vmax = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX);
   if(step <= 0)
      return 0.0;

   double lots = MathFloor(riskMoney / lossPerLot / step) * step;
   if(lots < vmin)
   {
      // min lot would exceed the risk target: skip, unless the explicit
      // small-account fallback is enabled AND actual risk stays under the hard cap
      if(!InpAllowMinLotFallback)
         return 0.0;
      double equity = AccountInfoDouble(ACCOUNT_EQUITY);
      if(equity <= 0)
         return 0.0;
      double minLotRiskPct = vmin * lossPerLot / equity * 100.0;
      if(minLotRiskPct > InpHardRiskCapPct)
      {
         PrintFormat("Min-lot fallback refused: risk %.2f%% exceeds hard cap %.2f%%",
                     minLotRiskPct, InpHardRiskCapPct);
         return 0.0;
      }
      PrintFormat("Min-lot fallback: trading %.2f lots at %.2f%% actual risk (target %.2f%%)",
                  vmin, minLotRiskPct, InpRiskPercent);
      lots = vmin;
   }
   if(lots > vmax)
      lots = vmax;

   // reduce until margin fits
   double margin = 0.0;
   double price  = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   while(lots >= vmin)
   {
      if(!OrderCalcMargin(ORDER_TYPE_BUY, _Symbol, lots, price, margin))
         break;
      if(margin <= AccountInfoDouble(ACCOUNT_MARGIN_FREE) * 0.9)
         break;
      lots -= step;
   }
   if(lots < vmin)
      return 0.0;

   return NormalizeDouble(lots, 2);
}

//+------------------------------------------------------------------+
//| Breakeven at +1R, then ATR trailing                              |
//+------------------------------------------------------------------+
void ManageOpenPositions()
{
   MqlTick tick;
   if(!SymbolInfoTick(_Symbol, tick))
      return;

   double atrH1   = H1ATR();
   double minStop = (SymbolInfoInteger(_Symbol, SYMBOL_TRADE_STOPS_LEVEL) + 1) * _Point;
   double beOff   = (tick.ask - tick.bid) + 2 * _Point;   // cover spread at breakeven

   for(int i = PositionsTotal() - 1; i >= 0; i--)
   {
      if(!g_pos.SelectByIndex(i)) continue;
      if(g_pos.Magic() != InpMagic || g_pos.Symbol() != _Symbol) continue;

      double entry = g_pos.PriceOpen();
      double sl    = g_pos.StopLoss();
      double tp    = g_pos.TakeProfit();
      bool  isLong = (g_pos.PositionType() == POSITION_TYPE_BUY);

      if(isLong)
      {
         double risk = entry - sl;
         if(sl < entry && risk > 0 && tick.bid - entry >= InpBreakevenR * risk)
         {
            double newSL = NormalizeDouble(entry + beOff, _Digits);
            if(newSL <= tick.bid - minStop)
               g_trade.PositionModify(g_pos.Ticket(), newSL, tp);
         }
         else if(sl >= entry && atrH1 > 0)
         {
            double newSL = NormalizeDouble(tick.bid - InpTrailATRMult * atrH1, _Digits);
            if(newSL >= sl + InpTrailStepPoints * _Point && newSL <= tick.bid - minStop)
               g_trade.PositionModify(g_pos.Ticket(), newSL, tp);
         }
      }
      else
      {
         double risk = sl - entry;
         if(sl > entry && risk > 0 && entry - tick.ask >= InpBreakevenR * risk)
         {
            double newSL = NormalizeDouble(entry - beOff, _Digits);
            if(newSL >= tick.ask + minStop)
               g_trade.PositionModify(g_pos.Ticket(), newSL, tp);
         }
         else if(sl <= entry && sl > 0 && atrH1 > 0)
         {
            double newSL = NormalizeDouble(tick.ask + InpTrailATRMult * atrH1, _Digits);
            if(newSL <= sl - InpTrailStepPoints * _Point && newSL >= tick.ask + minStop)
               g_trade.PositionModify(g_pos.Ticket(), newSL, tp);
         }
      }
   }
}

//+------------------------------------------------------------------+
void CheckDailyStop()
{
   if(g_dailyStopHit || g_dayStartEquity <= 0)
      return;
   double eq = AccountInfoDouble(ACCOUNT_EQUITY);
   if(eq <= g_dayStartEquity * (1.0 - InpDailyLossPct / 100.0))
   {
      g_dailyStopHit = true;
      PrintFormat("DAILY LOSS STOP: equity %.2f vs day start %.2f - no more entries today", eq, g_dayStartEquity);
      if(InpFlattenOnDailyStop)
         CloseAllPositions("daily stop");
   }
}

//+------------------------------------------------------------------+
void UpdateHighWaterMark()
{
   double eq  = AccountInfoDouble(ACCOUNT_EQUITY);
   double hwm = GlobalVariableGet(g_hwmName);
   if(eq > hwm)
      GlobalVariableSet(g_hwmName, eq);
}

//+------------------------------------------------------------------+
//| Hard lockout below the equity high-water mark. Manual reset:     |
//| delete the GSB_HWM_* global variable in the terminal.            |
//+------------------------------------------------------------------+
bool DrawdownLocked()
{
   double hwm = GlobalVariableGet(g_hwmName);
   if(hwm <= 0)
      return false;
   bool locked = AccountInfoDouble(ACCOUNT_EQUITY) <= hwm * (1.0 - InpMaxDrawdownPct / 100.0);
   if(locked && !g_ddLockLogged)
   {
      g_ddLockLogged = true;
      PrintFormat("DRAWDOWN LOCKOUT: equity below %.1f%% of HWM %.2f. Review before resetting.",
                  100.0 - InpMaxDrawdownPct, hwm);
   }
   return locked;
}

//+------------------------------------------------------------------+
int EntriesToday(const ENUM_POSITION_TYPE side)
{
   if(!HistorySelect(g_curDay, TimeCurrent() + 60))
      return 99999;                    // fail closed
   int count = 0;
   int total = HistoryDealsTotal();
   for(int i = 0; i < total; i++)
   {
      ulong ticket = HistoryDealGetTicket(i);
      if(ticket == 0) continue;
      if(HistoryDealGetInteger(ticket, DEAL_MAGIC) != InpMagic) continue;
      if(HistoryDealGetString(ticket, DEAL_SYMBOL) != _Symbol) continue;
      if((ENUM_DEAL_ENTRY)HistoryDealGetInteger(ticket, DEAL_ENTRY) != DEAL_ENTRY_IN) continue;
      ENUM_DEAL_TYPE dt = (ENUM_DEAL_TYPE)HistoryDealGetInteger(ticket, DEAL_TYPE);
      if(side == POSITION_TYPE_BUY  && dt == DEAL_TYPE_BUY)  count++;
      if(side == POSITION_TYPE_SELL && dt == DEAL_TYPE_SELL) count++;
   }
   return count;
}

//+------------------------------------------------------------------+
bool HasOpenPosition(const ENUM_POSITION_TYPE side)
{
   for(int i = PositionsTotal() - 1; i >= 0; i--)
   {
      if(!g_pos.SelectByIndex(i)) continue;
      if(g_pos.Magic() != InpMagic || g_pos.Symbol() != _Symbol) continue;
      if(g_pos.PositionType() == side) return true;
   }
   return false;
}

//+------------------------------------------------------------------+
void CloseAllPositions(const string reason)
{
   for(int i = PositionsTotal() - 1; i >= 0; i--)
   {
      if(!g_pos.SelectByIndex(i)) continue;
      if(g_pos.Magic() != InpMagic || g_pos.Symbol() != _Symbol) continue;
      if(!g_trade.PositionClose(g_pos.Ticket()))
         PrintFormat("Close failed (%s): %s", reason, g_trade.ResultRetcodeDescription());
   }
}

//+------------------------------------------------------------------+
//| Close positions opened on a previous day. On early-close days    |
//| the flat hour may never fire; this bounds the carry to the next  |
//| available tick instead of the next day's flat hour.              |
//+------------------------------------------------------------------+
void CloseStalePositions()
{
   for(int i = PositionsTotal() - 1; i >= 0; i--)
   {
      if(!g_pos.SelectByIndex(i)) continue;
      if(g_pos.Magic() != InpMagic || g_pos.Symbol() != _Symbol) continue;
      if(g_pos.Time() >= g_curDay) continue;
      if(g_trade.PositionClose(g_pos.Ticket()))
         Print("Stale position from a previous day closed");
      else
         PrintFormat("Stale-position close failed: %s", g_trade.ResultRetcodeDescription());
   }
}

//+------------------------------------------------------------------+
//| True when today's scheduled trade session ends within the        |
//| pre-close buffer. Catches short Fridays from the symbol's        |
//| session schedule; ad-hoc holiday early closes may not appear     |
//| there - CloseStalePositions() is the fallback for those.         |
//+------------------------------------------------------------------+
bool SessionCloseSoon()
{
   MqlDateTime tm;
   TimeToStruct(TimeCurrent(), tm);

   datetime from = 0, to = 0, lastEnd = 0;
   for(uint s = 0; SymbolInfoSessionTrade(_Symbol, (ENUM_DAY_OF_WEEK)tm.day_of_week, s, from, to); s++)
      lastEnd = to;
   if(lastEnd <= 0)
      return false;

   long secOfDay = (long)TimeCurrent() % 86400;
   return secOfDay >= (long)lastEnd - (long)InpPreCloseBufferMin * 60;
}

//+------------------------------------------------------------------+
//| High-impact USD news blackout via the MQL5 economic calendar.    |
//| Fails open when the calendar is unavailable (e.g. old-build      |
//| strategy tester) - a message is printed once in that case.       |
//+------------------------------------------------------------------+
bool IsNewsBlackout()
{
   if(!InpUseNewsFilter)
      return false;

   static datetime lastCheck    = 0;
   static bool     lastResult   = false;
   static bool     unavailLogged = false;

   datetime now = TimeCurrent();
   if(now - lastCheck < 60)
      return lastResult;
   lastCheck  = now;
   lastResult = false;

   MqlCalendarValue values[];
   datetime from = now - InpNewsBlockAfterMin  * 60;
   datetime to   = now + InpNewsBlockBeforeMin * 60;
   if(!CalendarValueHistory(values, from, to, NULL, "USD"))
   {
      if(!unavailLogged)
      {
         unavailLogged = true;
         Print("Economic calendar unavailable - news filter inactive in this environment");
      }
      return false;
   }

   for(int i = 0; i < ArraySize(values); i++)
   {
      MqlCalendarEvent ev;
      if(!CalendarEventById(values[i].event_id, ev)) continue;
      if(ev.importance == CALENDAR_IMPORTANCE_HIGH)
      {
         lastResult = true;
         break;
      }
   }
   return lastResult;
}

//+------------------------------------------------------------------+
long SpreadPoints()
{
   MqlTick tick;
   if(!SymbolInfoTick(_Symbol, tick))
      return 1000000;                  // fail closed
   return (long)MathRound((tick.ask - tick.bid) / _Point);
}

//+------------------------------------------------------------------+
double DailyATR()
{
   double buf[1];
   if(CopyBuffer(g_hATR_D1, 0, 1, 1, buf) != 1)
      return 0.0;
   return buf[0];
}

//+------------------------------------------------------------------+
double H1ATR()
{
   double buf[1];
   if(CopyBuffer(g_hATR_H1, 0, 1, 1, buf) != 1)
      return 0.0;
   return buf[0];
}

//+------------------------------------------------------------------+
void SetFillingMode()
{
   long filling = SymbolInfoInteger(_Symbol, SYMBOL_FILLING_MODE);
   if((filling & SYMBOL_FILLING_IOC) != 0)
      g_trade.SetTypeFilling(ORDER_FILLING_IOC);
   else if((filling & SYMBOL_FILLING_FOK) != 0)
      g_trade.SetTypeFilling(ORDER_FILLING_FOK);
   else
      g_trade.SetTypeFilling(ORDER_FILLING_RETURN);
}

//+------------------------------------------------------------------+
void UpdateChartComment(const MqlDateTime &tm)
{
   string range = g_rangeReady
                  ? (g_rangeValid
                     ? StringFormat("%.2f .. %.2f", g_rangeLow, g_rangeHigh)
                     : "rejected (quality filter)")
                  : "building...";
   string state;
   if(DrawdownLocked())            state = "DD LOCKOUT";
   else if(g_dailyStopHit)         state = "daily stop hit";
   else if(tm.hour >= InpFlatHour) state = "flat window";
   else if(tm.hour >= InpLastEntryHour) state = "managing only";
   else                            state = "active";

   Comment(StringFormat(
      "GoldSessionBreakout | %s\n"
      "State: %s\n"
      "Asian range: %s\n"
      "Spread: %d pts (max %d)\n"
      "Equity: %.2f | Day start: %.2f | HWM: %.2f",
      _Symbol, state, range,
      (int)SpreadPoints(), InpMaxSpreadPoints,
      AccountInfoDouble(ACCOUNT_EQUITY), g_dayStartEquity, GlobalVariableGet(g_hwmName)));
}
//+------------------------------------------------------------------+
