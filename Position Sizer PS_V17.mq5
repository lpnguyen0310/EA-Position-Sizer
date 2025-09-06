 //+------------------------------------------------------------------+
//|                                               Position Sizer.mq5 |
//|                                  Copyright © 2023, EarnForex.com |
//|                                       https://www.earnforex.com/ |
//+------------------------------------------------------------------+
#property copyright "EarnForex.com"
#property link      "https://www.earnforex.com/metatrader-expert-advisors/Position-Sizer/"
#property icon      "EF-Icon-64x64px.ico"
#property version   "3.06 modV17"
string    Version = "3.06 modV17";



#include "Translations\English.mqh"
//#include "Translations\Arabic.mqh"
//#include "Translations\Chinese.mqh"
//#include "Translations\Portuguese.mqh" // Contributed by Matheus Sevaroli.
//#include "Translations\Russian.mqh"
//#include "Translations\Spanish.mqh"
//#include "Translations\Ukrainian.mqh"

#property description "Calculates risk-based position size for your account."
#property description "Allows trade execution based the calculation results.\r\n"
#property description "WARNING: No warranty. This EA is offered \"as is\". Use at your own risk.\r\n"
#property description "Note: Pressing Shift+T will open a trade."

#include "Position Sizer.mqh";
#include "Position Sizer Trading.mqh";

// Default values for settings:
double EntryLevel = 0;
double StopLossLevel = 0;
double TakeProfitLevel = 0;
double StopPriceLevel = 0;
string PanelCaption = "";
string PanelCaptionBase = "";

input group "Compactness"
input bool ShowLineLabels = true; // ShowLineLabels: Show point distance for TP/SL near lines?
input bool ShowAdditionalSLLabel = false; // ShowAdditionalSLLabel: Show SL $/% label?
input bool ShowAdditionalTPLabel = false; // ShowAdditionalTPLabel: Show TP $/% + R/R label?
input bool DrawTextAsBackground = false; // DrawTextAsBackground: Draw label objects as background?
input bool HideAccSize = false; // HideAccSize: Hide account size?
input bool ShowPointValue = false; // ShowPointValue: Show point value?
input bool ShowMaxPSButton = false; // ShowMaxPSButton: Show Max Position Size button?
input bool StartPanelMinimized = false; // StartPanelMinimized: Start the panel minimized?
input bool ShowATROptions = false; // ShowATROptions: If true, SL and TP can be set via ATR.
input bool ShowMaxParametersOnTrading = true; // Show max parameters on Trading tab?
input bool ShowFusesOnTrading = true; // Show trading "fuses" on Trading tab?
input bool ShowCheckboxesOnTrading = true; // Show checkboxes on Trading tab?
input group "Fonts"
input color sl_label_font_color = clrLime; // SL Label Color
input color tp_label_font_color = clrYellow; // TP Label Color
input color sp_label_font_color = clrPurple; // Stop Price Label Color
input color entry_label_font_color = clrBlue; // Entry Label Font Color
input uint font_size = 13; // Labels Font Size
input string font_face = "Courier"; // Labels Font Face
input group "Lines"
input color entry_line_color = clrBlue; // Entry Line Color
input color stoploss_line_color = clrLime; // Stop-Loss Line Color
input color takeprofit_line_color = clrYellow; // Take-Profit Line Color
input color stopprice_line_color = clrPurple; // Stop Price Line Color
input color be_line_color = clrNONE; // BE Line Color
input ENUM_LINE_STYLE entry_line_style = STYLE_SOLID; // Entry Line Style
input ENUM_LINE_STYLE stoploss_line_style = STYLE_SOLID; // Stop-Loss Line Style
input ENUM_LINE_STYLE takeprofit_line_style = STYLE_SOLID; // Take-Profit Line Style
input ENUM_LINE_STYLE stopprice_line_style = STYLE_DOT; // Stop Price Line Style
input ENUM_LINE_STYLE be_line_style = STYLE_DOT; // BE Line Style
input uint entry_line_width = 1; // Entry Line Width
input uint stoploss_line_width = 1; // Stop-Loss Line Width
input uint takeprofit_line_width = 1; // Take-Profit Line Width
input uint stopprice_line_width = 1; // Stop Price Line Width
input uint be_line_width = 1; // BE Line Width
input group "Defaults"
input TRADE_DIRECTION DefaultTradeDirection = Long; // TradeDirection: Default trade direction.
input int DefaultSL = 0; // SL: Default stop-loss value, in points.
input int DefaultTP = 0; // TP: Default take-profit value, in points.
input int DefaultTakeProfitsNumber = 1; // TakeProfitsNumber: More than 1 target to split trades.
input ENTRY_TYPE DefaultEntryType = Instant; // EntryType: Instant, Pending, or StopLimit.
input bool DefaultShowLines = true; // ShowLines: Show the lines by default?
input bool DefaultLinesSelected = true; // LinesSelected: SL/TP (Entry in Pending) lines selected.
input int DefaultATRPeriod = 14; // ATRPeriod: Default ATR period.
input double DefaultATRMultiplierSL = 0; // ATRMultiplierSL: Default ATR multiplier for SL.
input double DefaultATRMultiplierTP = 0; // ATRMultiplierTP: Default ATR multiplier for TP.
input ENUM_TIMEFRAMES DefaultATRTimeframe = PERIOD_CURRENT; // ATRTimeframe: Default timeframe for ATR.
input bool DefaultSpreadAdjustmentSL = false; // SpreadAdjustmentSL: Adjust SL by Spread value in ATR mode.
input bool DefaultSpreadAdjustmentTP = false; // SpreadAdjustmentTP: Adjust TP by Spread value in ATR mode.
input double DefaultCommission = 0; // Commission: Default one-way commission per 1 lot.
input COMMISSION_TYPE DefaultCommissionType = COMMISSION_CURRENCY; // CommossionType: Default commission type.
input ACCOUNT_BUTTON DefaultAccountButton = Balance; // AccountButton: Balance/Equity/Balance-CPR
input double DefaultRisk = 1; // Risk: Initial risk tolerance in percentage points
input double DefaultMoneyRisk = 0; // MoneyRisk: If > 0, money risk tolerance in currency.
input double DefaultPositionSize = 0; // PositionSize: If > 0, position size in lots.
input bool DefaultCountPendingOrders = false; // CountPendingOrders: Count pending orders for portfolio risk.
input bool DefaultIgnoreOrdersWithoutSL = false; // IgnoreOrdersWithoutSL: Ignore orders w/o SL in portfolio risk.
input bool DefaultIgnoreOrdersWithoutTP = false; // IgnoreOrdersWithoutTP: Ignore orders w/o TP in portfolio risk.
input bool DefaultIgnoreOtherSymbols = false; // IgnoreOtherSymbols: Ignore other symbols' orders in portfolio risk.
input double DefaultCustomLeverage = 0; // CustomLeverage: Default custom leverage for Margin tab.
input int DefaultMagicNumber = 2022052714; // MagicNumber: Default magic number for Trading tab.
input string DefaultCommentary = ""; // Commentary: Default order comment for Trading tab.
input bool DefaultCommentAutoSuffix = false; // AutoSuffix: Automatic suffix for order commentary in Trading tab.
input bool DefaultDisableTradingWhenLinesAreHidden = false; // DisableTradingWhenLinesAreHidden: for Trading tab.
input int DefaultMaxSlippage = 0; // MaxSlippage: Maximum slippage for Trading tab.
input int DefaultMaxSpread = 0; // MaxSpread: Maximum spread for Trading tab.
input int DefaultMaxEntrySLDistance = 0; // MaxEntrySLDistance: Maximum entry/SL distance for Trading tab.
input int DefaultMinEntrySLDistance = 0; // MinEntrySLDistance: Minimum entry/SL distance for Trading tab.
input double DefaultMaxPositionSizeTotal = 0; // Maximum position size total for Trading tab.
input double DefaultMaxPositionSizePerSymbol = 0; // Maximum position size per symbol for Trading tab.
input bool DefaultSubtractOPV = false; // SubtractOPV: Subtract open positions volume (Trading tab).
input bool DefaultSubtractPOV = false; // SubtractPOV: Subtract pending orders volume (Trading tab).
input bool DefaultDoNotApplyStopLoss = false; // DoNotApplyStopLoss: Don't apply SL for Trading tab.
input bool DefaultDoNotApplyTakeProfit = false; // DoNotApplyTakeProfit: Don't apply TP for Trading tab.
input bool DefaultAskForConfirmation = true; // AskForConfirmation: Ask for confirmation for Trading tab.
input int DefaultPanelPositionX = 0; // PanelPositionX: Panel's X coordinate.
input int DefaultPanelPositionY = 15; // PanelPositionY: Panel's Y coordinate.
input ENUM_BASE_CORNER DefaultPanelPositionCorner = CORNER_LEFT_UPPER; // PanelPositionCorner: Panel's corner.
input bool DefaultTPLockedOnSL = false; // TPLockedOnSL: Lock TP to (multiplied) SL distance.
input int DefaultTrailingStop = 0; // TrailingStop: For the Trading tab.
input int DefaultBreakEven = 0; // BreakEven: For the Trading tab.
input int DefaultMaxNumberOfTradesTotal = 0; // MaxNumberOfTradesTotal: For the Trading tab. 0 - no limit.
input int DefaultMaxNumberOfTradesPerSymbol = 0; // MaxNumberOfTradesPerSymbol: For the Trading tab. 0 - no limit.
input double DefaultMaxRiskTotal = 0; // MaxRiskTotal: For the Trading tab. 0 - no limit.
input double DefaultMaxRiskPerSymbol = 0; // MaxRiskPerSymbol: For the Trading tab. 0 - no limit.
input group "Keyboard shortcuts"
input string ____ = "Case-insensitive hotkey. Supports Ctrl, Shift.";
input string TradeHotKey = "Shift+T"; // TradeHotKey: Execute a trade.
input string SwitchOrderTypeHotKey = "O"; // SwitchOrderTypeHotKey: Switch order type.
input string SwitchEntryDirectionHotKey = "TAB"; // SwitchEntryDirectionHotKey: Switch entry direction.
input string SwitchHideShowLinesHotKey = "H"; // SwitchHideShowLinesHotKey: Switch Hide/Show lines.
input string SetStopLossHotKey = "Shift + S"; // SetStopLossHotKey: Set SL to where mouse pointer is.
input string SetTakeProfitHotKey = "P"; // SetTakeProfitHotKey: Set TP to where mouse pointer is.
input string SetEntryHotKey = "E"; // SetEntryHotKey: Set Entry to where mouse pointer is.


input string SetBreakEvenHotKey = "A"; // SetBreakEvenHotKey: Đặt BE (dời SL về Entry)
input group "Miscellaneous"
input double TP_Multiplier = 1; // TP Multiplier for SL value, appears in Take-profit button.
input bool UseCommissionToSetTPDistance = false; // UseCommissionToSetTPDistance: For TP button.
input SHOW_SPREAD ShowSpread = No; // ShowSpread: Show current spread in points or as an SL ratio.
input double AdditionalFunds = 0; // AdditionalFunds: Added to account balance for risk calculation.
input double CustomBalance = 0; // CustomBalance: Overrides AdditionalFunds value.
input bool SLDistanceInPoints = false; // SLDistanceInPoints: SL distance in points instead of a level.
input bool TPDistanceInPoints = false; // TPDistanceInPoints: TP distance in points instead of a level.
input CANDLE_NUMBER ATRCandle = Current_Candle; // ATRCandle: Candle to get ATR value from.
input bool CalculateUnadjustedPositionSize = false; // CalculateUnadjustedPositionSize: Ignore broker's restrictions.
input bool SurpassBrokerMaxPositionSize = false; // Surpass Broker Max Position Size with multiple trades.
input bool RoundDown = true; // RoundDown: Position size and potential reward are rounded down.
input double QuickRisk1 = 0; // QuickRisk1: First quick risk button, in percentage points.
input double QuickRisk2 = 0; // QuickRisk2: Second quick risk button, in percentage points.
input string ObjectPrefix = "PS_"; // ObjectPrefix: To prevent confusion with other indicators/EAs.
input SYMBOL_CHART_CHANGE_REACTION SymbolChange = SYMBOL_CHART_CHANGE_EACH_OWN; // SymbolChange: What to do with the panel on chart symbol change?
input bool DisableStopLimit = false; // DisableStopLimit: If true, Stop Limit will be skipped.
input string TradeSymbol = ""; // TradeSymbol: If non-empty, this symbol will be traded.
input bool DisableTradingSounds = false; // DisableTradingSounds: If true, no sound for trading actions.
input bool IgnoreMarketExecutionMode = true; // IgnoreMarketExecutionMode: If true, ignore Market execution.
input bool MarketModeApplySLTPAfterAllTradesExecuted = false; // Market Mode - Apply SL/TP After All Trades Executed
input bool DarkMode = false; // DarkMode: Enable dark mode for a less bright panel.
input string SettingsFile = ""; // SettingsFile: Load custom panel settings from \Files\ folder.
input bool PrefillAdditionalTPsBasedOnMain = true; // Prefill additional TPs based on Main?
input double SpreadSLPoints = 0; // Spread cộng thêm vào SL cho lệnh Sell (đơn vị: points)
// Ghi chú phím tắt:
// S: Đặt SL SELL tại đỉnh nến vừa click + spread (ưu tiên input SpreadSLPoints nếu có)
// B: Đặt SL BUY tại đáy nến vừa click - BuySLBelowLowPoints points (có thể chỉnh trong input)
// Shift+S hoặc SetStopLossHotKey (có Shift): Đặt SL tại vị trí chuột (không phân biệt BUY/SELL)

input int BuySLBelowLowPoints = 5; // Số point trừ khỏi đáy nến khi đặt SL cho BUY bằng phím B



input double RR1 = 2.0;      // Tỉ lệ R:R đầu tiên (vd: 2 cho 1:2)
input double RR2 = 3.0;      // Tỉ lệ R:R thứ hai (vd: 3 cho 1:3)
input color  RRTextColor = clrYellow; // Màu sắc cho toàn bộ dòng text thông tin TP

// Thêm các input này chung nhóm với các input khác ở đầu file
input int    RiskLabel_X_Offset = -60;      // Dịch trái/phải cho label risk (âm: trái, dương: phải)
input int    RiskLabel_Y_Offset = 10;       // Dịch lên/xuống cho label risk (âm: lên, dương: xuống)
input color  RiskLabel_Color    = clrRed;   // Màu sắc cho label risk
input int    RiskLabel_FontSize = 13;       // Kích thước font cho label risk
input string RiskLabel_Font     = "Arial";  // Font chữ cho label risk

CPositionSizeCalculator* ExtDialog;


// --- BỔ SUNG: Nút nổi BE trên chart (góc phải trên) và label profit tại line Entry --- //
#define BE_BUTTON_NAME    "PS_BE_BUTTON"
#define PROFIT_LABEL_NAME "PS_PROFIT_LABEL"
#define TAKEHALF_BUTTON_NAME "PS_TAKEHALF_BUTTON"
#define TAKETHREEQUATER_BUTTON_NAME "PS_TAKETHREEQUATER_BUTTON"
#define RISKUSD_EDIT_NAME "PS_RISKUSD_EDIT"
#define CLOSEALL_BUTTON_NAME "PS_CLOSEALL_BUTTON"
#define PARTIAL_TITLE_LABEL "PARTIAL_TITLE_LABEL"

#define PARTIAL_PANEL_BG   "PARTIAL_PANEL_BG"
#define PARTIAL_BTN_PREF   "PARTIAL_BTN_"
#define PARTIAL_OK         "PARTIAL_OK"
#define PARTIAL_ALL        "PARTIAL_ALL"
#define PARTIAL_CANCEL     "PARTIAL_CANCEL"
#define MAX_PARTIAL_POS    20

bool partial_selected[MAX_PARTIAL_POS];
ulong partial_ticket[MAX_PARTIAL_POS];
int partial_count = 0;
double partial_percent = 0.5;




// Global variables:
bool Dont_Move_the_Panel_to_Default_Corner_X_Y = true;
uint LastRecalculationTime = 0;
bool StopLossLineIsBeingMoved = false;
bool TakeProfitLineIsBeingMoved[]; // Separate for each TP.
uchar MainKey_TradeHotKey = 0, MainKey_SwitchOrderTypeHotKey = 0, MainKey_SwitchEntryDirectionHotKey = 0, MainKey_SwitchHideShowLinesHotKey = 0, MainKey_SetStopLossHotKey = 0, MainKey_SetTakeProfitHotKey = 0, MainKey_SetEntryHotKey = 0, MainKey_SetBreakEvenHotKey = 0;
bool CtrlRequired_TradeHotKey = false, CtrlRequired_SwitchOrderTypeHotKey = false, CtrlRequired_SwitchEntryDirectionHotKey = false, CtrlRequired_SwitchHideShowLinesHotKey = false, CtrlRequired_SetStopLossHotKey = false, CtrlRequired_SetTakeProfitHotKey = false, CtrlRequired_SetEntryHotKey = false, CtrlRequired_SetBreakEvenHotKey = false;
bool ShiftRequired_TradeHotKey = false, ShiftRequired_SwitchOrderTypeHotKey = false, ShiftRequired_SwitchEntryDirectionHotKey = false, ShiftRequired_SwitchHideShowLinesHotKey = false, ShiftRequired_SetStopLossHotKey = false, ShiftRequired_SetTakeProfitHotKey = false, ShiftRequired_SetEntryHotKey = false, ShiftRequired_SetBreakEvenHotKey = false;
bool AdditionalTPLineMoved = false;
int DeinitializationReason = -1;
string OldSymbol = "";
int OldTakeProfitsNumber = -1;
string SymbolForTrading;
int Mouse_Last_X = 0, Mouse_Last_Y = 0; // For SL/TP hotkeys.

int OnInit()
{
    if (DarkMode)
    {
        CONTROLS_EDIT_COLOR_ENABLE  = DARKMODE_EDIT_BG_COLOR;
        CONTROLS_EDIT_COLOR_DISABLE = 0x999999;
        CONTROLS_BUTTON_COLOR_ENABLE  = DARKMODE_BUTTON_BG_COLOR;
        CONTROLS_BUTTON_COLOR_DISABLE = 0x919999;
    }
    else
    {
        CONTROLS_EDIT_COLOR_ENABLE  = C'255,255,255';
        CONTROLS_EDIT_COLOR_DISABLE = C'221,221,211';
        CONTROLS_BUTTON_COLOR_ENABLE  = C'200,200,200';
        CONTROLS_BUTTON_COLOR_DISABLE = C'224,224,224';
    }

    TickSize = -1;

    if (DeinitializationReason != REASON_CHARTCHANGE) ExtDialog = new CPositionSizeCalculator; // Create the panel only if it is not a symbol/timeframe change.
    else OldTakeProfitsNumber = sets.TakeProfitsNumber; // Will be used to resize the panel if needed when switching symbols in some modes.

    MathSrand(GetTickCount() + 293029); // Used by CreateInstanceId() in Dialog.mqh (standard library). Keep the second number unique across other panel indicators/EAs.
    
    if (SettingsFile != "") // Load a custom settings file if given via input parameters.
    {
        ExtDialog.SetFileName(SettingsFile);
    }

    Dont_Move_the_Panel_to_Default_Corner_X_Y = true;
    
    PanelCaptionBase = "Position Sizer (ver. " + Version + ")";

    // Symbol changed.
    if ((DeinitializationReason == REASON_CHARTCHANGE) && (OldSymbol != _Symbol))
    {
        ObjectsDeleteAll(0, ObjectPrefix, -1, OBJ_HLINE); // All lines should be deleted, so that they could be recreated at new sets. values.
        if (SymbolChange == SYMBOL_CHART_CHANGE_EACH_OWN)
        {
            ExtDialog.SaveSettingsOnDisk(OldSymbol); // Save old symbol's settings.
        }
        ExtDialog.UpdateFileName(); // Update the filename.

        // Reset everything.
        OutputPointValue = ""; OutputSwapsType = TRANSLATION_LABEL_UNKNOWN; SwapsTripleDay = "?";
        OutputSwapsDailyLongLot = "?"; OutputSwapsDailyShortLot = "?"; OutputSwapsDailyLongPS = "?"; OutputSwapsDailyShortPS = "?";
        OutputSwapsYearlyLongLot = "?"; OutputSwapsYearlyShortLot = "?"; OutputSwapsYearlyLongPS = "?"; OutputSwapsYearlyShortPS = "?";
        OutputSwapsCurrencyDailyLot = ""; OutputSwapsCurrencyDailyPS = ""; OutputSwapsCurrencyYearlyLot = ""; OutputSwapsCurrencyYearlyPS = "";
        WarnedAboutZeroUnitCost = 0;

        if (SymbolChange == SYMBOL_CHART_CHANGE_HARD_RESET)
        {
            // Lines are treated as a part of the panel.
            if (DefaultLinesSelected) LinesSelectedStatus = 1; // Flip lines to selected.
            else LinesSelectedStatus = 2; // Flip lines to unselected.
        }
    }

    bool is_InitControlsValues_required = false;
    // Normal attempt to load settings fails (attempted in not chart change case and in chart case with 'each pair own settings' case
    if ((((DeinitializationReason != REASON_CHARTCHANGE) || ((DeinitializationReason == REASON_CHARTCHANGE) && (OldSymbol != _Symbol) && (SymbolChange == SYMBOL_CHART_CHANGE_EACH_OWN))) && (!ExtDialog.LoadSettingsFromDisk())) 
    // OR chart change with hard_reset configured and with symbol change.
      || ((DeinitializationReason == REASON_CHARTCHANGE) && (SymbolChange == SYMBOL_CHART_CHANGE_HARD_RESET) && (OldSymbol != _Symbol)))
    {
        sets.TradeDirection = DefaultTradeDirection;
        sets.EntryLevel = EntryLevel;
        sets.StopLossLevel = StopLossLevel;
        sets.TakeProfitLevel = TakeProfitLevel; // Optional
        sets.TakeProfitsNumber = DefaultTakeProfitsNumber;
        if (sets.TakeProfitsNumber < 1) sets.TakeProfitsNumber = 1; // At least one TP.
        ArrayResize(sets.TP, sets.TakeProfitsNumber);
        ArrayResize(sets.TPShare, sets.TakeProfitsNumber);
        ArrayResize(TakeProfitLineIsBeingMoved, sets.TakeProfitsNumber);
        ArrayInitialize(sets.TP, 0);
        ArrayInitialize(sets.TPShare, 100 / sets.TakeProfitsNumber);
        ArrayResize(sets.WasSelectedAdditionalTakeProfitLine, sets.TakeProfitsNumber - 1); // -1 because the flag for the main TP is saved elsewhere.
        sets.StopPriceLevel = StopPriceLevel; // Optional
        sets.ATRPeriod = DefaultATRPeriod;
        sets.ATRMultiplierSL = DefaultATRMultiplierSL;
        sets.ATRMultiplierTP = DefaultATRMultiplierTP;
        sets.ATRTimeframe = DefaultATRTimeframe;
        sets.EntryType = DefaultEntryType; // If Instant, Entry level will be updated to current Ask/Bid price automatically; if Pending, Entry level will remain intact and StopLevel warning will be issued if needed.
        sets.Risk = DefaultRisk; // Risk tolerance in percentage points
        sets.MoneyRisk = DefaultMoneyRisk; // Risk tolerance in account currency
        if (DefaultMoneyRisk > 0) sets.UseMoneyInsteadOfPercentage = true;
        else sets.UseMoneyInsteadOfPercentage = false;
        if (DefaultPositionSize > 0)
        {
            sets.RiskFromPositionSize = true;
            sets.PositionSize = DefaultPositionSize;
            OutputPositionSize = DefaultPositionSize;
        }
        else sets.RiskFromPositionSize = false;
        sets.CommissionPerLot = DefaultCommission; // Commission charged per lot (one side) in account currency or %.
        sets.CommissionType = DefaultCommissionType;
        sets.CustomBalance = CustomBalance;
        sets.RiskFromPositionSize = false;
        sets.AccountButton = DefaultAccountButton;
        sets.CountPendingOrders = DefaultCountPendingOrders; // If true, portfolio risk calculation will also involve pending orders.
        sets.IgnoreOrdersWithoutSL = DefaultIgnoreOrdersWithoutSL; // If true, portfolio risk calculation will skip orders without stop-loss.
        sets.IgnoreOrdersWithoutTP = DefaultIgnoreOrdersWithoutTP; // If true, portfolio risk calculation will skip orders without take-profit.
        sets.IgnoreOtherSymbols = DefaultIgnoreOtherSymbols; // If true, portfolio risk calculation will skip orders in other symbols.
        sets.HideAccSize = HideAccSize; // If true, account size line will not be shown.
        sets.ShowLines = DefaultShowLines;
        sets.SelectedTab = MainTab;
        sets.CustomLeverage = DefaultCustomLeverage;
        sets.MagicNumber = DefaultMagicNumber;
        sets.Commentary = DefaultCommentary;
        sets.CommentAutoSuffix = DefaultCommentAutoSuffix;
        sets.DisableTradingWhenLinesAreHidden = DefaultDisableTradingWhenLinesAreHidden;
        if (sets.TakeProfitsNumber > 1)
        {
            for (int i = 0; i < sets.TakeProfitsNumber; i++)
            {
                sets.TP[i] = TakeProfitLevel;
                sets.TPShare[i] = 100 / sets.TakeProfitsNumber;
            }
        }
        sets.MaxSlippage = DefaultMaxSlippage;
        sets.MaxSpread = DefaultMaxSpread;
        sets.MaxEntrySLDistance = DefaultMaxEntrySLDistance;
        sets.MinEntrySLDistance = DefaultMinEntrySLDistance;
        sets.MaxPositionSizeTotal = DefaultMaxPositionSizeTotal;
        sets.MaxPositionSizePerSymbol = DefaultMaxPositionSizePerSymbol;
        if ((sets.MaxPositionSizeTotal < sets.MaxPositionSizePerSymbol) && (sets.MaxPositionSizeTotal != 0)) sets.MaxPositionSizeTotal = sets.MaxPositionSizePerSymbol;
        sets.StopLoss = 0;
        sets.TakeProfit = 0;
        sets.SubtractPendingOrders = DefaultSubtractPOV;
        sets.SubtractPositions = DefaultSubtractOPV;
        sets.DoNotApplyStopLoss = DefaultDoNotApplyStopLoss;
        sets.DoNotApplyTakeProfit = DefaultDoNotApplyTakeProfit;
        sets.AskForConfirmation = DefaultAskForConfirmation;
        sets.WasSelectedEntryLine = false;
        sets.WasSelectedStopLossLine  = false;
        sets.WasSelectedTakeProfitLine = false;
        sets.WasSelectedStopPriceLine = false;
        sets.TPLockedOnSL = DefaultTPLockedOnSL;
        sets.TrailingStopPoints = DefaultTrailingStop;
        sets.BreakEvenPoints = DefaultBreakEven;
        sets.MaxNumberOfTradesTotal = DefaultMaxNumberOfTradesTotal;
        sets.MaxNumberOfTradesPerSymbol = DefaultMaxNumberOfTradesPerSymbol;
        if ((sets.MaxNumberOfTradesTotal < sets.MaxNumberOfTradesPerSymbol) && (sets.MaxNumberOfTradesTotal != 0)) sets.MaxNumberOfTradesTotal = sets.MaxNumberOfTradesPerSymbol;
        sets.MaxRiskTotal = DefaultMaxRiskTotal;
        sets.MaxRiskPerSymbol = DefaultMaxRiskPerSymbol;
        if ((sets.MaxRiskTotal < sets.MaxRiskPerSymbol) && (sets.MaxRiskTotal != 0)) sets.MaxRiskTotal = sets.MaxRiskPerSymbol;
        // Because it is the first load:
        Dont_Move_the_Panel_to_Default_Corner_X_Y = false;
        sets.ShareVolumeMode = Decreasing;
        if (DeinitializationReason == REASON_CHARTCHANGE) is_InitControlsValues_required = true;
    }
    if (sets.TakeProfitsNumber < 1) sets.TakeProfitsNumber = 1; // At least one TP.

    if (DeinitializationReason != REASON_CHARTCHANGE)
    {
        if (!ExtDialog.Create(0, "Position Sizer (ver. " + Version + ")", 0, DefaultPanelPositionX, DefaultPanelPositionY)) return INIT_FAILED;
        ExtDialog.Run();

        // No ini file - move the panel according to the inputs.
        if (!FileIsExist(ExtDialog.IniFileName() + ExtDialog.IniFileExt()))
        {
            Dont_Move_the_Panel_to_Default_Corner_X_Y = false;
        }
        ExtDialog.IniFileLoad();

        // If a hotkey is given, break up the string to check for hotkey presses in OnChartEvent().
        if (TradeHotKey != "") DissectHotKeyCombination(TradeHotKey, ShiftRequired_TradeHotKey, CtrlRequired_TradeHotKey, MainKey_TradeHotKey);
        if (SwitchEntryDirectionHotKey != "") DissectHotKeyCombination(SwitchEntryDirectionHotKey, ShiftRequired_SwitchEntryDirectionHotKey, CtrlRequired_SwitchEntryDirectionHotKey, MainKey_SwitchEntryDirectionHotKey);
        if (SwitchOrderTypeHotKey != "") DissectHotKeyCombination(SwitchOrderTypeHotKey, ShiftRequired_SwitchOrderTypeHotKey, CtrlRequired_SwitchOrderTypeHotKey, MainKey_SwitchOrderTypeHotKey);
        if (SwitchHideShowLinesHotKey != "") DissectHotKeyCombination(SwitchHideShowLinesHotKey, ShiftRequired_SwitchHideShowLinesHotKey, CtrlRequired_SwitchHideShowLinesHotKey, MainKey_SwitchHideShowLinesHotKey);
        if (SetStopLossHotKey != "") DissectHotKeyCombination(SetStopLossHotKey, ShiftRequired_SetStopLossHotKey, CtrlRequired_SetStopLossHotKey, MainKey_SetStopLossHotKey);
        if (SetTakeProfitHotKey != "") DissectHotKeyCombination(SetTakeProfitHotKey, ShiftRequired_SetTakeProfitHotKey, CtrlRequired_SetTakeProfitHotKey, MainKey_SetTakeProfitHotKey);
        if (SetEntryHotKey != "") DissectHotKeyCombination(SetEntryHotKey, ShiftRequired_SetEntryHotKey, CtrlRequired_SetEntryHotKey, MainKey_SetEntryHotKey);
		if (SetBreakEvenHotKey != "") DissectHotKeyCombination(SetBreakEvenHotKey, ShiftRequired_SetBreakEvenHotKey, CtrlRequired_SetBreakEvenHotKey, MainKey_SetBreakEvenHotKey);
    }
    else if (OldSymbol != _Symbol)
    {
        if (SymbolChange == SYMBOL_CHART_CHANGE_HARD_RESET) // Reset Entry, SL, and all TPs if it was a symbol change and a hard reset is required.
        {
            sets.EntryLevel = 0;
            sets.StopLossLevel = 0;
            sets.StopLoss = 0;
            sets.TakeProfitLevel = 0;
            sets.TakeProfit = 0;
            for (int i = 0; i < sets.TakeProfitsNumber; i++)
            {
                sets.TP[i] = 0;
            }
            sets.StopPriceLevel = 0;
            Dont_Move_the_Panel_to_Default_Corner_X_Y = false;
        }
/*        else if (SymbolChange == SYMBOL_CHART_CHANGE_EACH_OWN) // Load the INI file if it was a symbol change and a each symbol has its own settings.
        {
            ExtDialog.IniFileLoad();
        }
  */  }    

    // Avoid re-initialization on timeframe change and on symbol change with the 'keep panel' setting.
    if ((DeinitializationReason != REASON_CHARTCHANGE) || ((DeinitializationReason == REASON_CHARTCHANGE) && (OldSymbol != _Symbol) && ((SymbolChange == SYMBOL_CHART_CHANGE_HARD_RESET) || (SymbolChange == SYMBOL_CHART_CHANGE_EACH_OWN))))
    {
        Initialization();
        if (DeinitializationReason == REASON_CHARTCHANGE) // Do not run if it is not the symbol change because 'CPositionSizeCalculator::Create()' takes care of that in other cases.
        {
            // Remove extra empty space on the panel when going from a panel with more TPs to a panel with fewer TPs.
            if (sets.TakeProfitsNumber < OldTakeProfitsNumber)
            {
                int NewTakeProfitsNumber = sets.TakeProfitsNumber;
                sets.TakeProfitsNumber = OldTakeProfitsNumber; // Used and decremented inside OnClickBtnTakeProfitsNumberRemove().
                while (sets.TakeProfitsNumber > NewTakeProfitsNumber)
                {
                    ExtDialog.OnClickBtnTakeProfitsNumberRemove();
                }
            }
            else
            {
                // Create necessary panel elements if newly loaded symbol has more TPs.
                int NewTakeProfitsNumber = sets.TakeProfitsNumber;
                sets.TakeProfitsNumber = OldTakeProfitsNumber; // It will be increased inside OnClickBtnTakeProfitsNumberAdd().
                while (sets.TakeProfitsNumber < NewTakeProfitsNumber)
                {
                    ExtDialog.OnClickBtnTakeProfitsNumberAdd();
                }
            }
        }
    }

    // Moved this down to let the additional TP controls get created before actually trying to hide them.
    if ((DeinitializationReason == REASON_CHARTCHANGE) && (OldSymbol != _Symbol) && (SymbolChange == SYMBOL_CHART_CHANGE_EACH_OWN)) // Load the INI file if it was a symbol change and a each symbol has its own settings.
    {
        ExtDialog.IniFileLoad();
    }
    
    // Brings panel on top of other objects without actual maximization of the panel.
    ExtDialog.HideShowMaximize();
    if (!Dont_Move_the_Panel_to_Default_Corner_X_Y)
    {
        int new_x = DefaultPanelPositionX, new_y = DefaultPanelPositionY;
        int chart_width = (int)ChartGetInteger(0, CHART_WIDTH_IN_PIXELS);
        int chart_height = (int)ChartGetInteger(0, CHART_HEIGHT_IN_PIXELS);
        int panel_width = ExtDialog.Width();
        int panel_height = ExtDialog.Height();

        // Invert coordinate if necessary.
        if (DefaultPanelPositionCorner == CORNER_LEFT_LOWER)
        {
            new_y = chart_height - panel_height - new_y;
        }
        else if (DefaultPanelPositionCorner == CORNER_RIGHT_UPPER)
        {
            new_x = chart_width - panel_width - new_x;
        }
        else if (DefaultPanelPositionCorner == CORNER_RIGHT_LOWER)
        {
            new_x = chart_width - panel_width - new_x;
            new_y = chart_height - panel_height - new_y;
        }

        ExtDialog.remember_left = new_x;
        ExtDialog.remember_top = new_y;
        ExtDialog.Move(new_x, new_y);
        ExtDialog.FixatePanelPosition(); // Remember the panel's new position for the INI file.
    }

    if ((StartPanelMinimized) && (!ExtDialog.IsMinimized()) && (!Dont_Move_the_Panel_to_Default_Corner_X_Y)) // Minimize only if needs minimization. We check Dont_Move_the_Panel_to_Default_Corner_X_Y to make sure we didn't load an INI-file. An INI-file already contains a more preferred state for the panel.
    {
        // No access to the minmax button, no way to edit the chart height.
        // Dummy variables for passing as references.
        long lparam = 0;
        double dparam = 0;
        string sparam = "";
        // Increasing the height of the panel beyond that of the chart will trigger its minimization.
        ExtDialog.Height((int)ChartGetInteger(ChartID(), CHART_HEIGHT_IN_PIXELS) + 1);
        // Call the chart event processing function.
        ExtDialog.ChartEvent(CHARTEVENT_CHART_CHANGE, lparam, dparam, sparam);
    }

    if (!EventSetTimer(1)) Print(TRANSLATION_MESSAGE_ERROR_SETTING_TIMER + ": ", GetLastError());

    if (ShowATROptions) ExtDialog.InitATR();

    if (TradeSymbol != "") SymbolForTrading = TradeSymbol;
    else SymbolForTrading = _Symbol;

    if (DarkMode)
    {
        int total = ObjectsTotal(ChartID());
        for (int i = 0; i < total; i++)
        {
            string obj_name = ObjectName(ChartID(), i);
            if (StringSubstr(obj_name, 0, StringLen(ExtDialog.Name())) != ExtDialog.Name()) continue; // Skip non-panel objects.
            //if (ObjectType(obj_name) != OBJ_RECTANGLE_LABEL) continue;
            if (obj_name == ExtDialog.Name() + "Back")
            {
                
                ObjectSetInteger(ChartID(), obj_name, OBJPROP_BGCOLOR, DARKMODE_BG_DARK_COLOR);
            }
            if (obj_name == ExtDialog.Name() + "Caption")
            {
                ObjectSetInteger(ChartID(), obj_name, OBJPROP_BGCOLOR, DARKMODE_BG_DARK_COLOR);
                ObjectSetInteger(ChartID(), obj_name, OBJPROP_COLOR, DARKMODE_CONTROL_BRODER_COLOR);
                ObjectSetInteger(ChartID(), obj_name, OBJPROP_BORDER_COLOR, DARKMODE_BG_DARK_COLOR);
            }
            else if (obj_name == ExtDialog.Name() + "ClientBack")
            {
                ObjectSetInteger(ChartID(), obj_name, OBJPROP_COLOR, DARKMODE_MAIN_AREA_BORDER_COLOR);
                ObjectSetInteger(ChartID(), obj_name, OBJPROP_BGCOLOR, DARKMODE_MAIN_AREA_BG_COLOR);
            }
            else if (StringSubstr(obj_name, 0, StringLen(ExtDialog.Name() + "m_Edt")) == ExtDialog.Name() + "m_Edt")
            {
                ObjectSetInteger(ChartID(), obj_name, OBJPROP_BGCOLOR, DARKMODE_EDIT_BG_COLOR);
                ObjectSetInteger(ChartID(), obj_name, OBJPROP_BORDER_COLOR, DARKMODE_CONTROL_BRODER_COLOR);
            }
            else if (StringSubstr(obj_name, 0, StringLen(ExtDialog.Name() + "m_Btn")) == ExtDialog.Name() + "m_Btn")
            {
                ObjectSetInteger(ChartID(), obj_name, OBJPROP_BGCOLOR, DARKMODE_BUTTON_BG_COLOR);
                ObjectSetInteger(ChartID(), obj_name, OBJPROP_BORDER_COLOR, DARKMODE_CONTROL_BRODER_COLOR);
            }
            else if (StringSubstr(obj_name, 0, StringLen(ExtDialog.Name() + "m_Chk")) == ExtDialog.Name() + "m_Chk")
            {
                ObjectSetInteger(ChartID(), obj_name, OBJPROP_COLOR, DARKMODE_TEXT_COLOR);
                ObjectSetInteger(ChartID(), obj_name, OBJPROP_BGCOLOR, DARKMODE_MAIN_AREA_BG_COLOR);
                ObjectSetInteger(ChartID(), obj_name, OBJPROP_BORDER_COLOR, DARKMODE_MAIN_AREA_BG_COLOR);
            }
            else
            {
                if (obj_name == ExtDialog.Name() + "m_LblURL") ObjectSetInteger(ChartID(), obj_name, OBJPROP_COLOR, 0x224400);
                else ObjectSetInteger(ChartID(), obj_name, OBJPROP_COLOR, DARKMODE_TEXT_COLOR);
            }
        }
    }

    // If symbol change with a reset was enacted.
    if (is_InitControlsValues_required) ExtDialog.InitControlsValues();
	
	
	 CreateOrUpdateBEButton();
    CreateOrUpdateProfitLabel();
    CreateOrUpdateTakeHalfButton();
    CreateOrUpdateTakeThreeQuaterButton();
    CreateOrUpdateRiskUSDEdit();
    CreateOrUpdateCloseAllButton();

    return INIT_SUCCEEDED;
}



void CreateOrUpdateCloseAllButton()
{
    int x = 180; // Cùng x với ô nhập USD
    int y = 20; // Dưới ô nhập USD, điều chỉnh 32 px hoặc theo ý muốn
    int width = 80;
    int height = 26;
    if (ObjectFind(0, CLOSEALL_BUTTON_NAME) < 0)
        ObjectCreate(0, CLOSEALL_BUTTON_NAME, OBJ_BUTTON, 0, 0, 0);
    ObjectSetInteger(0, CLOSEALL_BUTTON_NAME, OBJPROP_CORNER, CORNER_RIGHT_UPPER);
    ObjectSetInteger(0, CLOSEALL_BUTTON_NAME, OBJPROP_XDISTANCE, x);
    ObjectSetInteger(0, CLOSEALL_BUTTON_NAME, OBJPROP_YDISTANCE, y);
    ObjectSetInteger(0, CLOSEALL_BUTTON_NAME, OBJPROP_XSIZE, width);
    ObjectSetInteger(0, CLOSEALL_BUTTON_NAME, OBJPROP_YSIZE, height);
    ObjectSetInteger(0, CLOSEALL_BUTTON_NAME, OBJPROP_BGCOLOR, clrRed);
    ObjectSetInteger(0, CLOSEALL_BUTTON_NAME, OBJPROP_COLOR, clrWhite);
    ObjectSetInteger(0, CLOSEALL_BUTTON_NAME, OBJPROP_FONTSIZE, 13);
    ObjectSetString(0, CLOSEALL_BUTTON_NAME, OBJPROP_TEXT, "Close All");
    ObjectSetInteger(0, CLOSEALL_BUTTON_NAME, OBJPROP_HIDDEN, false);
    ObjectSetString(0, CLOSEALL_BUTTON_NAME, OBJPROP_TOOLTIP, "Đóng tất cả lệnh đang chạy");
}




void CreateOrUpdateRiskUSDEdit()
{
    int x = 180;                    // Cùng X với các nút trên
    int y = 55;          // Dưới nút "Chốt lời 1/2" 35px
    int width = 65;
    int height = 27;
    if (ObjectFind(0, RISKUSD_EDIT_NAME) < 0)
        ObjectCreate(0, RISKUSD_EDIT_NAME, OBJ_EDIT, 0, 0, 0);
    ObjectSetInteger(0, RISKUSD_EDIT_NAME, OBJPROP_CORNER, CORNER_RIGHT_UPPER);
    ObjectSetInteger(0, RISKUSD_EDIT_NAME, OBJPROP_XDISTANCE, x+10);
    ObjectSetInteger(0, RISKUSD_EDIT_NAME, OBJPROP_YDISTANCE, y);
    ObjectSetInteger(0, RISKUSD_EDIT_NAME, OBJPROP_XSIZE, width);
    ObjectSetInteger(0, RISKUSD_EDIT_NAME, OBJPROP_YSIZE, height);
    ObjectSetInteger(0, RISKUSD_EDIT_NAME, OBJPROP_BGCOLOR, clrWhite);
    ObjectSetInteger(0, RISKUSD_EDIT_NAME, OBJPROP_COLOR, clrBlack);
    ObjectSetInteger(0, RISKUSD_EDIT_NAME, OBJPROP_FONTSIZE, 13);
    ObjectSetString(0, RISKUSD_EDIT_NAME, OBJPROP_TEXT, DoubleToString(sets.MoneyRisk, 2));
    ObjectSetInteger(0, RISKUSD_EDIT_NAME, OBJPROP_HIDDEN, false);
    ObjectSetString(0, RISKUSD_EDIT_NAME, OBJPROP_TOOLTIP, "Nhập số USD rủi ro muốn đặt");
}





void CreateOrUpdateTakeHalfButton()
{
    int x = 60;                // Cùng X với nút BE
    int y = 55;           // Bên dưới nút BE 35px
    int width = 55;
    int height = 26;
    if(ObjectFind(0, TAKEHALF_BUTTON_NAME) < 0)
        ObjectCreate(0, TAKEHALF_BUTTON_NAME, OBJ_BUTTON, 0, 0, 0);
    ObjectSetInteger(0, TAKEHALF_BUTTON_NAME, OBJPROP_CORNER, CORNER_RIGHT_UPPER);
    ObjectSetInteger(0, TAKEHALF_BUTTON_NAME, OBJPROP_XDISTANCE, x);
    ObjectSetInteger(0, TAKEHALF_BUTTON_NAME, OBJPROP_YDISTANCE, y);
    ObjectSetInteger(0, TAKEHALF_BUTTON_NAME, OBJPROP_BGCOLOR, clrLimeGreen);
    ObjectSetInteger(0, TAKEHALF_BUTTON_NAME, OBJPROP_COLOR, clrBlack);
    ObjectSetInteger(0, TAKEHALF_BUTTON_NAME, OBJPROP_FONTSIZE, 14);
    ObjectSetString(0, TAKEHALF_BUTTON_NAME, OBJPROP_TEXT, "1/2");
    ObjectSetInteger(0, TAKEHALF_BUTTON_NAME, OBJPROP_XSIZE, width);
    ObjectSetInteger(0, TAKEHALF_BUTTON_NAME, OBJPROP_YSIZE, height);
    ObjectSetInteger(0, TAKEHALF_BUTTON_NAME, OBJPROP_HIDDEN, false);
}


void CreateOrUpdateTakeThreeQuaterButton()
{
    int x = 115;                // Cùng X với nút BE
    int y = 55;           // Bên dưới nút BE 35px
    int width = 55;
    int height = 26;
    if(ObjectFind(0, TAKETHREEQUATER_BUTTON_NAME) < 0)
        ObjectCreate(0, TAKETHREEQUATER_BUTTON_NAME, OBJ_BUTTON, 0, 0, 0);
    ObjectSetInteger(0, TAKETHREEQUATER_BUTTON_NAME, OBJPROP_CORNER, CORNER_RIGHT_UPPER);
    ObjectSetInteger(0, TAKETHREEQUATER_BUTTON_NAME, OBJPROP_XDISTANCE, x+5);
    ObjectSetInteger(0, TAKETHREEQUATER_BUTTON_NAME, OBJPROP_YDISTANCE, y);
    ObjectSetInteger(0, TAKETHREEQUATER_BUTTON_NAME, OBJPROP_BGCOLOR, clrLime);
    ObjectSetInteger(0, TAKETHREEQUATER_BUTTON_NAME, OBJPROP_COLOR, clrBlack);
    ObjectSetInteger(0, TAKETHREEQUATER_BUTTON_NAME, OBJPROP_FONTSIZE, 14);
    ObjectSetString(0, TAKETHREEQUATER_BUTTON_NAME, OBJPROP_TEXT, "3/4");
    ObjectSetInteger(0, TAKETHREEQUATER_BUTTON_NAME, OBJPROP_XSIZE, width);
    ObjectSetInteger(0, TAKETHREEQUATER_BUTTON_NAME, OBJPROP_YSIZE, height);
    ObjectSetInteger(0, TAKETHREEQUATER_BUTTON_NAME, OBJPROP_HIDDEN, false);
}


void CreateOrUpdateBEButton()
{
    int x = 90, y = 20, width = 75, height = 26;
    if(ObjectFind(0, BE_BUTTON_NAME) < 0)
    {
        ObjectCreate(0, BE_BUTTON_NAME, OBJ_BUTTON, 0, 0, 0);
    }
    ObjectSetInteger(0, BE_BUTTON_NAME, OBJPROP_CORNER, CORNER_RIGHT_UPPER);
    ObjectSetInteger(0, BE_BUTTON_NAME, OBJPROP_XDISTANCE, x);
    ObjectSetInteger(0, BE_BUTTON_NAME, OBJPROP_YDISTANCE, y);
    ObjectSetInteger(0, BE_BUTTON_NAME, OBJPROP_BGCOLOR, clrYellow);
    ObjectSetInteger(0, BE_BUTTON_NAME, OBJPROP_COLOR, clrBlack);
    ObjectSetInteger(0, BE_BUTTON_NAME, OBJPROP_FONTSIZE, 12);
    ObjectSetString(0, BE_BUTTON_NAME, OBJPROP_TEXT, " BE Lệnh ");
    ObjectSetInteger(0, BE_BUTTON_NAME, OBJPROP_XSIZE, width);   // Sửa lại
    ObjectSetInteger(0, BE_BUTTON_NAME, OBJPROP_YSIZE, height);  // Sửa lại
    ObjectSetInteger(0, BE_BUTTON_NAME, OBJPROP_HIDDEN, false);
}

void CreateOrUpdateProfitLabel()
{
    double profit = 0;
    bool has_position = false;
    // Duyệt qua tất cả vị thế đang mở
    for(int i=0; i<PositionsTotal(); i++)
    {
        ulong ticket = PositionGetTicket(i);
        if(PositionGetSymbol(i) == _Symbol)
        {
            profit = PositionGetDouble(POSITION_PROFIT);
            has_position = true;
            break;
        }
    }
    if(has_position)
    {
        string profit_text = StringFormat("%s%.2f USD", (profit>=0?"+":""), profit);
        if(ObjectFind(0, PROFIT_LABEL_NAME) < 0)
            ObjectCreate(0, PROFIT_LABEL_NAME, OBJ_LABEL, 0, 0, 0);
        ObjectSetString(0, PROFIT_LABEL_NAME, OBJPROP_TEXT, profit_text);
        ObjectSetInteger(0, PROFIT_LABEL_NAME, OBJPROP_COLOR, clrYellow);
        ObjectSetInteger(0, PROFIT_LABEL_NAME, OBJPROP_FONTSIZE, 10);
        ObjectSetInteger(0, PROFIT_LABEL_NAME, OBJPROP_XDISTANCE, 250); // Sát phải
        ObjectSetInteger(0, PROFIT_LABEL_NAME, OBJPROP_YDISTANCE, 25);
        ObjectSetInteger(0, PROFIT_LABEL_NAME, OBJPROP_CORNER, CORNER_RIGHT_UPPER);
    }
    else
    {
        ObjectDelete(0, PROFIT_LABEL_NAME);
    }
}






void OnDeinit(const int reason)
{
    DeinitializationReason = reason; // Remember reason to avoid recreating the panel in the OnInit() if it is not deleted here.
    
    EventKillTimer();

    if (reason == REASON_TEMPLATE) sets.TemplateChanged = true; // Will be used to select lines according to the DefaultLinesSelected input parameter.

    if ((reason == REASON_CLOSE) || (reason == REASON_REMOVE) || (reason == REASON_CHARTCLOSE) || (reason == REASON_PROGRAM))
    {
        ObjectsDeleteAll(0, ObjectPrefix); // Delete all lines if platform was closed.
        if ((reason == REASON_REMOVE) || (reason == REASON_PROGRAM))
        {
            if (SettingsFile == "") ExtDialog.DeleteSettingsFile();
            if (!FileDelete(ExtDialog.IniFileName() + ExtDialog.IniFileExt())) Print(TRANSLATION_MESSAGE_FAILED_DELETE_INI + ": ", GetLastError());
        }
    }
    
    // It is deinitialization due to input parameters change - save current parameters values (that are also changed via panel) to global variables.
    if (reason == REASON_PARAMETERS) GlobalVariableSet("PS-" + IntegerToString(ChartID()) + "-Parameters", 1);

    if ((reason != REASON_CHARTCHANGE) && (reason != REASON_REMOVE) && (reason != REASON_PROGRAM))
    {
        ExtDialog.SaveSettingsOnDisk();
        ExtDialog.IniFileSave();
    } 

    if (reason == REASON_CHARTCHANGE)
    {
        OldSymbol = _Symbol;
    }
    else
    {
        ObjectDelete(0, ObjectPrefix + "StopLossLabel");
        ObjectsDeleteAll(0, ObjectPrefix + "TakeProfitLabel", -1, OBJ_LABEL);
        ObjectDelete(0, ObjectPrefix + "StopPriceLabel");
        ObjectsDeleteAll(0, ObjectPrefix + "TPAdditionalLabel", -1, OBJ_LABEL);
        ObjectDelete(0, ObjectPrefix + "SLAdditionalLabel");
        ExtDialog.Destroy();
        delete ExtDialog;
    }
    
    ObjectsDeleteAll(0, ObjectPrefix + "BE"); // Delete all BE lines and labels.
    
	
	ObjectDelete(0, BE_BUTTON_NAME);
	ObjectDelete(0, PROFIT_LABEL_NAME);
	ObjectDelete(0, RISKUSD_EDIT_NAME);
	ObjectDelete(0, TAKEHALF_BUTTON_NAME);
	ObjectDelete(0, TAKETHREEQUATER_BUTTON_NAME);
	ObjectDelete(0, CLOSEALL_BUTTON_NAME);
	
    ChartRedraw();
}

void OnTick()
{
    ExtDialog.RefreshValues();

    if (sets.TrailingStopPoints > 0) DoTrailingStop();
	 CreateOrUpdateBEButton();
    CreateOrUpdateProfitLabel();
    CreateOrUpdateTakeHalfButton();
    CreateOrUpdateTakeThreeQuaterButton();
    CreateOrUpdateRiskUSDEdit();
    CreateOrUpdateCloseAllButton();
    ShowProfitOnSLTPLine();

	
}

void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
                  
{
ShowProfitOnSLTPLine();


   if(id == CHARTEVENT_OBJECT_CLICK && sparam == CLOSEALL_BUTTON_NAME)
   {
       CloseAllPositions();
       return;
   }
  if(id == CHARTEVENT_OBJECT_ENDEDIT && sparam == RISKUSD_EDIT_NAME)
{
    string text = ObjectGetString(0, RISKUSD_EDIT_NAME, OBJPROP_TEXT);
    double riskusd = StringToDouble(text);
    if(riskusd > 0)
    {
        sets.MoneyRisk = riskusd;
        sets.UseMoneyInsteadOfPercentage = true;
        // Cập nhật panel hoặc risk tính toán lại
        ExtDialog.RefreshValues();
    }
    else
    {
        MessageBox("Vui lòng nhập số USD hợp lệ!", "Thông báo", MB_ICONWARNING);
    }
    return;
}


// Xử lý sự kiện panel partial close
if(id == CHARTEVENT_OBJECT_CLICK && sparam == PARTIAL_CANCEL)
{
    DeletePartialClosePanel();
    return;
}
if(id == CHARTEVENT_OBJECT_CLICK && sparam == PARTIAL_OK)
{
    // Duyệt qua các lệnh đã chọn (tức là partial_selected[i] == true)
    int closed = 0;
    for(int i=0;i<partial_count;i++)
    {
        if(partial_selected[i])
        {
            if(TakeProfitByTicket(partial_ticket[i], partial_percent))
                closed++;
        }
    }
    MessageBox(StringFormat("Đã chốt lời %d lệnh theo tỷ lệ %.2f%%!", closed, partial_percent*100.0), "Thông báo", MB_ICONINFORMATION);
    DeletePartialClosePanel();
    return;
}
if(id == CHARTEVENT_OBJECT_CLICK && sparam == PARTIAL_ALL)
{
    // Chọn tất cả, đổi trạng thái partial_selected
    for(int i=0;i<partial_count;i++)
        partial_selected[i] = true;
    // Tùy chọn: có thể đổi màu nút để hiển thị đã chọn
    return;
}

// Xử lý click từng nút chọn lệnh (dòng lệnh)
for(int i=0;i<partial_count;i++)
{
    string btn = PARTIAL_BTN_PREF + IntegerToString(i+1);
    if(id == CHARTEVENT_OBJECT_CLICK && sparam == btn)
    {
        partial_selected[i] = !partial_selected[i];
        // Đổi màu nút để biết trạng thái đã chọn chưa
        ObjectSetInteger(0, btn, OBJPROP_BGCOLOR, partial_selected[i]?clrLime:clrWhite);
        return;
    }
}






  if(id == CHARTEVENT_OBJECT_CLICK && sparam == TAKEHALF_BUTTON_NAME)
{
    ShowPartialClosePanel(0.5); // Panel chọn lệnh chốt 1/2
    return;
}
if(id == CHARTEVENT_OBJECT_CLICK && sparam == TAKETHREEQUATER_BUTTON_NAME)
{
    ShowPartialClosePanel(0.75); // Panel chọn lệnh chốt 3/4
    return;
}

	if(id == CHARTEVENT_OBJECT_CLICK && sparam == BE_BUTTON_NAME)
		{
			SetBreakEven();
			MessageBox("Đã dời SL về giá Entry (BE) cho tất cả lệnh!", "Thông báo", MB_ICONINFORMATION);
			return;
		}
		
		
    if (id == CHARTEVENT_MOUSE_MOVE)
    {
        Mouse_Last_X = (int)lparam;
        Mouse_Last_Y = (int)dparam;
        if (((uint)sparam & 1) == 1)
        {
            if ((SLDistanceInPoints) || ((ShowATROptions) && (sets.ATRMultiplierSL > 0)))
            {
                double current_line_price = NormalizeDouble(ObjectGetDouble(ChartID(), ObjectPrefix + "StopLossLine", OBJPROP_PRICE, 0), _Digits);
                if (MathAbs(current_line_price - tStopLossLevel) > _Point / 2.0)
                    StopLossLineIsBeingMoved = true;
                else
                    StopLossLineIsBeingMoved = false;
            }
            if ((TPDistanceInPoints) || ((ShowATROptions) && (sets.ATRMultiplierTP > 0)))
            {
                ArrayInitialize(TakeProfitLineIsBeingMoved, false);
                double current_line_price = NormalizeDouble(ObjectGetDouble(ChartID(), ObjectPrefix + "TakeProfitLine", OBJPROP_PRICE, 0), _Digits);
                if (MathAbs(current_line_price - tTakeProfitLevel) > _Point / 2.0)
                    TakeProfitLineIsBeingMoved[0] = true;
                else
                {
                    for (int i = 1; i < sets.TakeProfitsNumber; i++)
                    {
                        if (sets.TP[i] != 0)
                        {
                            current_line_price = NormalizeDouble(ObjectGetDouble(ChartID(), ObjectPrefix + "TakeProfitLine" + IntegerToString(i), OBJPROP_PRICE, 0), _Digits);
                            if (MathAbs(current_line_price - sets.TP[i]) > _Point / 2.0)
                            {
                                TakeProfitLineIsBeingMoved[i] = true;
                                break;
                            }
                        }
                    }
                }
            }
        }
    }

    if (id == CHARTEVENT_CLICK)
    {
        StopLossLineIsBeingMoved = false;
        ArrayInitialize(TakeProfitLineIsBeingMoved, false);
    }

    if ((id == CHARTEVENT_CUSTOM + ON_DRAG_END) && (lparam == -1))
    {
        ExtDialog.remember_top = ExtDialog.Top();
        ExtDialog.remember_left = ExtDialog.Left();
    }

    if (sets.TakeProfitsNumber > 1)
    {
        if (id == CHARTEVENT_OBJECT_ENDEDIT)
        {
            if (StringSubstr(sparam, 0, StringLen(ExtDialog.Name() + "m_EdtAdditionalTPEdits")) == ExtDialog.Name() + "m_EdtAdditionalTPEdits")
            {
                int i = (int)StringToInteger(StringSubstr(sparam, StringLen(ExtDialog.Name() + "m_EdtAdditionalTPEdits"))) - 1;
                ExtDialog.UpdateAdditionalTPEdit(i);
            }
            else if (StringSubstr(sparam, 0, StringLen(ExtDialog.Name() + "m_EdtTradingTPEdit")) == ExtDialog.Name() + "m_EdtTradingTPEdit")
            {
                int i = (int)StringToInteger(StringSubstr(sparam, StringLen(ExtDialog.Name() + "m_EdtTradingTPEdit"))) - 1;
                ExtDialog.UpdateTradingTPEdit(i);
            }
            else if (StringSubstr(sparam, 0, StringLen(ExtDialog.Name() + "m_EdtTradingTPShareEdit")) == ExtDialog.Name() + "m_EdtTradingTPShareEdit")
            {
                int i = (int)StringToInteger(StringSubstr(sparam, StringLen(ExtDialog.Name() + "m_EdtTradingTPShareEdit"))) - 1;
                ExtDialog.UpdateTradingTPShareEdit(i);
            }
        }
        else if (id == CHARTEVENT_CUSTOM + ON_CLICK)
        {
            if (StringSubstr(sparam, 0, StringLen(ExtDialog.Name() + "m_BtnAdditionalTPButtonsIncrease")) == ExtDialog.Name() + "m_BtnAdditionalTPButtonsIncrease")
            {
                int i = (int)StringToInteger(StringSubstr(sparam, StringLen(ExtDialog.Name() + "m_BtnAdditionalTPButtonsIncrease"))) - 1;
                ExtDialog.ProcessAdditionalTPButtonsIncrease(i);
            }
            else if (StringSubstr(sparam, 0, StringLen(ExtDialog.Name() + "m_BtnAdditionalTPButtonsDecrease")) == ExtDialog.Name() + "m_BtnAdditionalTPButtonsDecrease")
            {
                int i = (int)StringToInteger(StringSubstr(sparam, StringLen(ExtDialog.Name() + "m_BtnAdditionalTPButtonsDecrease"))) - 1;
                ExtDialog.ProcessAdditionalTPButtonsDecrease(i);
            }
            else if (sparam == ExtDialog.Name() + "m_BtnTakeProfitsNumberRemove")
            {
                ExtDialog.OnClickBtnTakeProfitsNumberRemove();
            }
            else if (sparam == ExtDialog.Name() + "m_BtnTPsInward")
            {
                ExtDialog.OnClickBtnTPsInward();
            }
            else if (sparam == ExtDialog.Name() + "m_BtnTPsOutward")
            {
                ExtDialog.OnClickBtnTPsOutward();
            }
            else if (sparam == ExtDialog.Name() + "m_BtnTradingTPShare")
            {
                ExtDialog.OnClickBtnTradingTPShare();
            }
        }
    }

    if (id == CHARTEVENT_KEYDOWN)
    {
        // ==== ĐỔI CHIỀU LỆNH ====
        if ((MainKey_SwitchEntryDirectionHotKey != 0) && (lparam == MainKey_SwitchEntryDirectionHotKey))
        {
            if (((!ShiftRequired_SwitchEntryDirectionHotKey) || (TerminalInfoInteger(TERMINAL_KEYSTATE_SHIFT) == 0))
                && ((!CtrlRequired_SwitchEntryDirectionHotKey) || (TerminalInfoInteger(TERMINAL_KEYSTATE_CONTROL) == 0)))
            {
                if (sets.TradeDirection == Long)
                    sets.TradeDirection = Short;
                else
                    sets.TradeDirection = Long;
                ObjectSetDouble(ChartID(), ObjectPrefix + "StopLossLine", OBJPROP_PRICE, 0);
            }
        }
        else if ((MainKey_SwitchOrderTypeHotKey != 0) && (lparam == MainKey_SwitchOrderTypeHotKey))
        {
            if (((!ShiftRequired_SwitchOrderTypeHotKey) || (TerminalInfoInteger(TERMINAL_KEYSTATE_SHIFT) == 0))
                && ((!CtrlRequired_SwitchOrderTypeHotKey) || (TerminalInfoInteger(TERMINAL_KEYSTATE_CONTROL) == 0)))
            {
                ExtDialog.OnClickBtnOrderType();
                ChartRedraw();
            }
        }
        else if ((MainKey_SwitchHideShowLinesHotKey != 0) && (lparam == MainKey_SwitchHideShowLinesHotKey))
        {
            if (((!ShiftRequired_SwitchHideShowLinesHotKey) || (TerminalInfoInteger(TERMINAL_KEYSTATE_SHIFT) == 0))
                && ((!CtrlRequired_SwitchHideShowLinesHotKey) || (TerminalInfoInteger(TERMINAL_KEYSTATE_CONTROL) == 0)))
            {
                ExtDialog.OnClickBtnLines();
            }
        }
        else if ((MainKey_TradeHotKey != 0) && (lparam == MainKey_TradeHotKey))
        {
            if (((!ShiftRequired_TradeHotKey) || (TerminalInfoInteger(TERMINAL_KEYSTATE_SHIFT) == 0))
                && ((!CtrlRequired_TradeHotKey) || (TerminalInfoInteger(TERMINAL_KEYSTATE_CONTROL) == 0)))
            {
                Trade();
            }
        }
		else if ((MainKey_SetBreakEvenHotKey != 0) && (lparam == MainKey_SetBreakEvenHotKey))
		{
			if (((!ShiftRequired_SetBreakEvenHotKey) || (TerminalInfoInteger(TERMINAL_KEYSTATE_SHIFT) != 0))
				&& ((!CtrlRequired_SetBreakEvenHotKey) || (TerminalInfoInteger(TERMINAL_KEYSTATE_CONTROL) != 0)))
			{
				SetBreakEven();
			}
		}

        // ==== PHÍM B: Đặt SL cho BUY, lấy giá thấp nhất nến vừa click - BuySLBelowLowPoints ====
        else if (lparam == 'B' || lparam == 'b')
        {
            int subwindow;
            double price;
            datetime time;
            ChartXYToTimePrice(ChartID(), Mouse_Last_X, Mouse_Last_Y, subwindow, time, price);
            if (subwindow == 0 && price > 0)
            {
                int bar = iBarShift(_Symbol, PERIOD_CURRENT, time, true);
                if (bar >= 0)
                {
                    double low = iLow(_Symbol, PERIOD_CURRENT, bar);
                    double SL_price = low - BuySLBelowLowPoints * _Point;
                    ObjectSetDouble(ChartID(), ObjectPrefix + "StopLossLine", OBJPROP_PRICE, SL_price);
                    if ((SLDistanceInPoints) || (ShowATROptions)) ExtDialog.UpdateFixedSL();
                    ExtDialog.RefreshValues();
                }
            }
        }
        // ==== PHÍM S: Đặt SL cho SELL, lấy giá cao nhất nến vừa click + spread ====
        else if ((lparam == 'S' || lparam == 's') && (TerminalInfoInteger(TERMINAL_KEYSTATE_SHIFT) == 0))
        {
            int subwindow;
            double price;
            datetime time;
            ChartXYToTimePrice(ChartID(), Mouse_Last_X, Mouse_Last_Y, subwindow, time, price);
            if (subwindow == 0 && price > 0)
            {
                int bar = iBarShift(_Symbol, PERIOD_CURRENT, time, true);
                if (bar >= 0)
                {
                    double high = iHigh(_Symbol, PERIOD_CURRENT, bar);
                    int spread_points = (SpreadSLPoints > 0) ? (int)SpreadSLPoints : (int)SymbolInfoInteger(_Symbol, SYMBOL_SPREAD);
                    double spread_price = spread_points * _Point;
                    double SL_price = high + spread_price;
                    ObjectSetDouble(ChartID(), ObjectPrefix + "StopLossLine", OBJPROP_PRICE, SL_price);
                    if ((SLDistanceInPoints) || (ShowATROptions)) ExtDialog.UpdateFixedSL();
                    ExtDialog.RefreshValues();
                }
            }
        }
        // ==== PHÍM SHIFT+S hoặc dùng input SetStopLossHotKey: đặt SL theo vị trí chuột (logic cũ, không phân biệt BUY/SELL) ====
        else if (
            ((MainKey_SetStopLossHotKey != 0) && (lparam == MainKey_SetStopLossHotKey) && (TerminalInfoInteger(TERMINAL_KEYSTATE_SHIFT) != 0)) // Shift+S (input)
            ||
            ((lparam == 'S' || lparam == 's') && (TerminalInfoInteger(TERMINAL_KEYSTATE_SHIFT) != 0)) // Shift+S (hardcode)
        )
        {
            int subwindow;
            double price;
            datetime time;
            ChartXYToTimePrice(ChartID(), Mouse_Last_X, Mouse_Last_Y, subwindow, time, price);
            if (subwindow == 0 && price > 0)
            {
                if (TickSize > 0) price = NormalizeDouble(MathRound(price / TickSize) * TickSize, _Digits);

                int spread_points = (SpreadSLPoints > 0) ? (int)SpreadSLPoints : (int)SymbolInfoInteger(_Symbol, SYMBOL_SPREAD);
                double spread_price = spread_points * _Point;

                if (sets.TradeDirection == Short)
                    price += spread_price;

                ObjectSetDouble(ChartID(), ObjectPrefix + "StopLossLine", OBJPROP_PRICE, price);

                if ((SLDistanceInPoints) || (ShowATROptions)) ExtDialog.UpdateFixedSL();
                ExtDialog.RefreshValues();
            }
        }
     
    }

    if (id != CHARTEVENT_CHART_CHANGE)
    {
        ExtDialog.OnEvent(id, lparam, dparam, sparam);
        if (id >= CHARTEVENT_CUSTOM) ChartRedraw();
    }

    if ((id == CHARTEVENT_CLICK) || (id == CHARTEVENT_CHART_CHANGE) ||
        ((id == CHARTEVENT_OBJECT_DRAG) && ((sparam == ObjectPrefix + "EntryLine") || (sparam == ObjectPrefix + "StopLossLine") || (StringFind(sparam, ObjectPrefix + "TakeProfitLine") != -1) || (sparam == ObjectPrefix + "StopPriceLine"))))
    {
        if (id == CHARTEVENT_OBJECT_DRAG)
        {
            if (sparam == ObjectPrefix + "EntryLine")
            {
                double entry_price = ObjectGetDouble(ChartID(), sparam, OBJPROP_PRICE, 0);
                double current_bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);

                if (entry_price > current_bid)
                    sets.TradeDirection = Short;
                else
                    sets.TradeDirection = Long;

                ObjectSetDouble(ChartID(), ObjectPrefix + "StopLossLine", OBJPROP_PRICE, 0);
            }

            if ((SLDistanceInPoints) || (TPDistanceInPoints) || (ShowATROptions))
            {
                if (sparam == ObjectPrefix + "StopLossLine")
                {
                    ExtDialog.UpdateFixedSL();
                    int subwindow;
                    double price;
                    datetime time;
                    ChartXYToTimePrice(ChartID(), Mouse_Last_X, Mouse_Last_Y, subwindow, time, price);
                    if ((subwindow == 0) && (price > 0))
                    {
                        if (TickSize > 0) price = NormalizeDouble(MathRound(price / TickSize) * TickSize, _Digits);
                        int spread_points = (SpreadSLPoints > 0) ? (int)SpreadSLPoints : (int)SymbolInfoInteger(_Symbol, SYMBOL_SPREAD);
                        double spread_price = spread_points * _Point;
                        if (sets.TradeDirection == Short)
                            price += spread_price;
                        ObjectSetDouble(ChartID(), ObjectPrefix + "StopLossLine", OBJPROP_PRICE, price);
                    }
                }
                else if (sparam == ObjectPrefix + "TakeProfitLine")
                {
                    ExtDialog.UpdateFixedTP();
                }
                else if ((sets.TakeProfitsNumber > 1) && (StringFind(sparam, ObjectPrefix + "TakeProfitLine") != -1))
                {
                    int len = StringLen(ObjectPrefix + "TakeProfitLine");
                    int i = (int)StringToInteger(StringSubstr(sparam, len));
                    ExtDialog.UpdateAdditionalFixedTP(i);
                }
            }
            if ((!TPDistanceInPoints) && (sets.TakeProfitsNumber > 1) && (StringFind(sparam, ObjectPrefix + "TakeProfitLine") != -1))
            {
                int len = StringLen(ObjectPrefix + "TakeProfitLine");
                int i = (int)StringToInteger(StringSubstr(sparam, len));
                AdditionalTPLineMoved = true;
            }
        }

        if (sparam == ObjectPrefix + "StopLossLine") StopLossLineIsBeingMoved = false;
        if (StringFind(sparam, ObjectPrefix + "TakeProfitLine") != -1) ArrayInitialize(TakeProfitLineIsBeingMoved, false);

        if (id != CHARTEVENT_CHART_CHANGE) ExtDialog.RefreshValues();

        static bool prev_chart_on_top = false;
        if (ChartGetInteger(ChartID(), CHART_BRING_TO_TOP))
        {
            if (ExtDialog.Top() < 0) ExtDialog.Move(ExtDialog.Left(), 0);
            int chart_height = (int)ChartGetInteger(0, CHART_HEIGHT_IN_PIXELS);
            if (ExtDialog.Top() > chart_height) ExtDialog.Move(ExtDialog.Left(), chart_height - ExtDialog.Height());
            int chart_width = (int)ChartGetInteger(0, CHART_WIDTH_IN_PIXELS);
            if (ExtDialog.Left() > chart_width) ExtDialog.Move(chart_width - ExtDialog.Width(), ExtDialog.Top());
            if ((prev_chart_on_top == false) && (ShowLineLabels)) ExtDialog.RefreshValues();
        }
        prev_chart_on_top = ChartGetInteger(ChartID(), CHART_BRING_TO_TOP);
        ChartRedraw();
    }
}




















//+------------------------------------------------------------------+
//| Trade event handler                                              |
//+------------------------------------------------------------------+
void OnTrade()
{
    ExtDialog.RefreshValues();
    ChartRedraw();
    ShowProfitOnSLTPLine();
}

//+------------------------------------------------------------------+
//| Timer event handler                                              |
//+------------------------------------------------------------------+
void OnTimer()
{
    ExtDialog.CheckAndRestoreLines();
    if (GetTickCount() - LastRecalculationTime < 1000) return;
    ExtDialog.RefreshValues();
    ChartRedraw();
    ShowProfitOnSLTPLine();

}
//+------------------------------------------------------------------+

// ==== HÀM NÀY KHÔNG GỌI Ở ĐỔI CHIỀU LỆNH NỮA ====
// Nếu muốn reset SL line thủ công thì gọi hàm này, bình thường chỉ dùng phím S thôi
void ResetStopLossLineAfterSwitch()
{
    int subwindow;
    double price;
    datetime time;
    ChartXYToTimePrice(ChartID(), Mouse_Last_X, Mouse_Last_Y, subwindow, time, price);

    if ((subwindow == 0) && (price > 0))
    {
        if (TickSize > 0) price = NormalizeDouble(MathRound(price / TickSize) * TickSize, _Digits);

        int spread_points = (SpreadSLPoints > 0) ? (int)SpreadSLPoints : (int)SymbolInfoInteger(_Symbol, SYMBOL_SPREAD);
        double spread_price = spread_points * _Point;

        if (sets.TradeDirection == Short)
            price += spread_price;

        ObjectSetDouble(ChartID(), ObjectPrefix + "StopLossLine", OBJPROP_PRICE, price);

        if ((SLDistanceInPoints) || (ShowATROptions)) ExtDialog.UpdateFixedSL();
        ExtDialog.RefreshValues();
    }
}










void SetBreakEven()
{
    int total = PositionsTotal();
    if(total == 0)
    {
        MessageBox("Chưa có lệnh nào đang mở trên tài khoản để đặt Break Even!\nVui lòng mở lệnh trước.", "Thông báo", MB_ICONWARNING);
        return;
    }
    bool has_be = false;
    for(int i = 0; i < total; i++)
    {
        if(PositionGetSymbol(i) == _Symbol)
        {
            ulong ticket = PositionGetInteger(POSITION_TICKET);
            double entry  = PositionGetDouble(POSITION_PRICE_OPEN);
            double tp     = PositionGetDouble(POSITION_TP);
            int    magic  = (int)PositionGetInteger(POSITION_MAGIC);

            // Chỉ dời SL nếu chưa ở BE
            double sl = PositionGetDouble(POSITION_SL);
            if(MathAbs(sl - entry) > _Point)
            {
                MqlTradeRequest request = {};
                MqlTradeResult  result  = {0};
                request.action   = TRADE_ACTION_SLTP;
                request.position = ticket;
                request.symbol   = _Symbol;
                request.sl       = entry;
                request.tp       = tp;
                request.magic    = magic;
                request.deviation= 10;
                if(OrderSend(request, result) && result.retcode == TRADE_RETCODE_DONE)
                    has_be = true;
                else
                    PrintFormat("BE lỗi với ticket %I64u: %s", ticket, result.comment);
            }
        }
    }
    if(has_be)
        MessageBox("Đã dời Stop Loss tất cả các lệnh về giá Entry (BE)!", "Thông báo", MB_ICONINFORMATION);
    else
        MessageBox("Không có lệnh nào cần dời về BE hoặc tất cả đã ở BE!", "Thông báo", MB_ICONINFORMATION);
}

void TakeProfitHalf()
{
    bool has_closed = false;
    for(int i=0; i<PositionsTotal(); i++)
    {
        if(PositionGetSymbol(i)==_Symbol)
        {
            ulong ticket = PositionGetInteger(POSITION_TICKET);
            double volume = PositionGetDouble(POSITION_VOLUME);
            long type = PositionGetInteger(POSITION_TYPE);
            if(volume>=0.02) // Đảm bảo tối thiểu volume/2 > 0.01 lot
            {
                double close_vol = NormalizeDouble(volume/2.0, 2);
                MqlTradeRequest req = {};
                MqlTradeResult  res = {};
                req.action   = TRADE_ACTION_DEAL;
                req.symbol   = _Symbol;
                req.position = ticket;
                req.volume   = close_vol;
                req.price    = (type==POSITION_TYPE_BUY) ? SymbolInfoDouble(_Symbol, SYMBOL_BID) : SymbolInfoDouble(_Symbol, SYMBOL_ASK);
                req.type     = (type==POSITION_TYPE_BUY) ? ORDER_TYPE_SELL : ORDER_TYPE_BUY;
                req.deviation= 10;
                if(OrderSend(req, res) && res.retcode == TRADE_RETCODE_DONE)
                    has_closed = true;
            }
        }
    }
    if(has_closed)
        MessageBox("Đã chốt lời 1/2 số lot!", "Thông báo", MB_ICONINFORMATION);
    else
        MessageBox("Không có lệnh nào để chốt lời 1/2!", "Thông báo", MB_ICONWARNING);
}

void TakeProfitThreeQuater()
{
    bool has_closed = false;
    for(int i=0; i<PositionsTotal(); i++)
    {
        if(PositionGetSymbol(i)==_Symbol)
        {
            ulong ticket = PositionGetInteger(POSITION_TICKET);
            double volume = PositionGetDouble(POSITION_VOLUME);
            long type = PositionGetInteger(POSITION_TYPE);
            if(volume>=0.02) // Đảm bảo tối thiểu volume/2 > 0.01 lot
            {
                double close_vol = NormalizeDouble(volume*3/4.0, 2);
                MqlTradeRequest req = {};
                MqlTradeResult  res = {};
                req.action   = TRADE_ACTION_DEAL;
                req.symbol   = _Symbol;
                req.position = ticket;
                req.volume   = close_vol;
                req.price    = (type==POSITION_TYPE_BUY) ? SymbolInfoDouble(_Symbol, SYMBOL_BID) : SymbolInfoDouble(_Symbol, SYMBOL_ASK);
                req.type     = (type==POSITION_TYPE_BUY) ? ORDER_TYPE_SELL : ORDER_TYPE_BUY;
                req.deviation= 10;
                if(OrderSend(req, res) && res.retcode == TRADE_RETCODE_DONE)
                    has_closed = true;
            }
        }
    }
    if(has_closed)
        MessageBox("Đã chốt lời 3/4 số lot!", "Thông báo", MB_ICONINFORMATION);
    else
        MessageBox("Không có lệnh nào để chốt lời 3/4!", "Thông báo", MB_ICONWARNING);
}



void CloseAllPositions()
{
    bool has_closed = false;
    for(int i=PositionsTotal()-1; i>=0; i--)
    {
        if(PositionGetSymbol(i)==_Symbol)
        {
            ulong ticket = PositionGetInteger(POSITION_TICKET);
            double volume = PositionGetDouble(POSITION_VOLUME);
            long type = PositionGetInteger(POSITION_TYPE);
            MqlTradeRequest req = {};
            MqlTradeResult  res = {};
            req.action   = TRADE_ACTION_DEAL;
            req.symbol   = _Symbol;
            req.position = ticket;
            req.volume   = volume;
            req.price    = (type==POSITION_TYPE_BUY) ? SymbolInfoDouble(_Symbol, SYMBOL_BID) : SymbolInfoDouble(_Symbol, SYMBOL_ASK);
            req.type     = (type==POSITION_TYPE_BUY) ? ORDER_TYPE_SELL : ORDER_TYPE_BUY;
            req.deviation= 10;
            if(OrderSend(req, res) && res.retcode == TRADE_RETCODE_DONE)
                has_closed = true;
        }
    }
    if(has_closed)
        MessageBox("Đã đóng tất cả lệnh trên symbol này!", "Thông báo", MB_ICONINFORMATION);
    else
        MessageBox("Không có lệnh nào để đóng!", "Thông báo", MB_ICONWARNING);
        
     ObjectSetInteger(0, CLOSEALL_BUTTON_NAME, OBJPROP_STATE, false);
}






















































#define MAX_LABELS 20

color PAIR_COLORS[MAX_LABELS] = {
    clrOrange, clrViolet, clrYellow, clrAqua, clrPink, clrChartreuse, clrCyan, clrMagenta, clrTurquoise, clrGold, clrWhite, clrGreen, clrBlue, clrChocolate, clrDeepPink
};

bool PriceToY(double price, int &y)
{
    int x_dummy;
    return ChartTimePriceToXY(0, 0, 0, price, x_dummy, y);
}

// Tính khoảng cách X phù hợp theo độ dài text
int CalcXDistance(string txt, int base, int step)
{
    int len = StringLen(txt);
    return base + len * step;
}

void ShowProfitOnSLTPLine()
{
    bool used_sl[MAX_LABELS];
    bool used_tp[MAX_LABELS];
    ArrayInitialize(used_sl, false);
    ArrayInitialize(used_tp, false);

    double tick_value = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE);
    double tick_size  = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE);

    int label_count = 0;

    for(int i=0; i<PositionsTotal(); i++)
    {
        if(PositionGetSymbol(i) == _Symbol)
        {
            double open_price = PositionGetDouble(POSITION_PRICE_OPEN);
            double sl_price   = PositionGetDouble(POSITION_SL);
            double tp_price   = PositionGetDouble(POSITION_TP);
            double volume     = PositionGetDouble(POSITION_VOLUME);
            long type         = PositionGetInteger(POSITION_TYPE);
            double profit_now = PositionGetDouble(POSITION_PROFIT);

            double profit_at_sl = 0, profit_at_tp = 0;
            int y_sl = 0, y_tp = 0;

            // Tính profit dự kiến tại SL/TP so với entry
            if(type == POSITION_TYPE_BUY)
            {
                profit_at_sl = ((sl_price - open_price) / tick_size) * tick_value * volume;
                profit_at_tp = ((tp_price - open_price) / tick_size) * tick_value * volume;
            }
            else // SELL
            {
                profit_at_sl = ((open_price - sl_price) / tick_size) * tick_value * volume;
                profit_at_tp = ((open_price - tp_price) / tick_size) * tick_value * volume;
            }

            color sl_color, tp_color;
            if(label_count == 0) {
                sl_color = clrRed;
                tp_color = clrLime;
            } else {
                sl_color = PAIR_COLORS[(label_count-1) % MAX_LABELS];
                tp_color = sl_color;
            }

            // SL: chỉ số thứ tự và profit_at_sl
            string sl_text = StringFormat("#%d |  %.2f U", label_count+1, profit_at_sl);

            // TP: USD lời hiện tại, số thứ tự, profit_at_tp
            string tp_text = StringFormat("%.2f #%d | %.2f U", profit_now, label_count+1, profit_at_tp);

            // Tính khoảng cách X phù hợp
            int sl_x_dist = CalcXDistance(sl_text, 55, 1);
            int tp_x_dist = CalcXDistance(tp_text, 87, 1);

            // Label SL cho từng lệnh
            if(sl_price > 0 && PriceToY(sl_price, y_sl))
            {
                string sl_label = StringFormat("SL_USD_LABEL_%d", label_count);
                used_sl[label_count] = true;
                if(ObjectFind(0, sl_label) < 0)
                {
                    ObjectCreate(0, sl_label, OBJ_LABEL, 0, 0, 0);
                }
                ObjectSetString(0, sl_label, OBJPROP_TEXT, sl_text);
                ObjectSetInteger(0, sl_label, OBJPROP_COLOR, sl_color);
                ObjectSetInteger(0, sl_label, OBJPROP_FONTSIZE, 9);
                ObjectSetInteger(0, sl_label, OBJPROP_CORNER, CORNER_RIGHT_UPPER);
                ObjectSetInteger(0, sl_label, OBJPROP_XDISTANCE, sl_x_dist);
                ObjectSetInteger(0, sl_label, OBJPROP_YDISTANCE, y_sl + 2);
            }

            // Label TP cho từng lệnh
            if(tp_price > 0 && PriceToY(tp_price, y_tp))
            {
                string tp_label = StringFormat("TP_USD_LABEL_%d", label_count);
                used_tp[label_count] = true;
                if(ObjectFind(0, tp_label) < 0)
                {
                    ObjectCreate(0, tp_label, OBJ_LABEL, 0, 0, 0);
                }
                ObjectSetString(0, tp_label, OBJPROP_TEXT, tp_text);
                ObjectSetInteger(0, tp_label, OBJPROP_COLOR, tp_color);
                ObjectSetInteger(0, tp_label, OBJPROP_FONTSIZE, 9);
                ObjectSetInteger(0, tp_label, OBJPROP_CORNER, CORNER_RIGHT_UPPER);
                ObjectSetInteger(0, tp_label, OBJPROP_XDISTANCE, tp_x_dist);
                ObjectSetInteger(0, tp_label, OBJPROP_YDISTANCE, y_tp - 18);
            }

            label_count++;
        }
    }

    // Xóa label SL/TP không còn sử dụng (khi số lệnh giảm đi)
    for(int i=label_count; i<MAX_LABELS; i++)
    {
        if(!used_sl[i])
            ObjectDelete(0, StringFormat("SL_USD_LABEL_%d", i));
        if(!used_tp[i])
            ObjectDelete(0, StringFormat("TP_USD_LABEL_%d", i));
    }

    ChartRedraw();
}


void ShowPartialClosePanel(double percent)
{
    DeletePartialClosePanel();
    partial_percent = percent;
    partial_count = 0;
    int panel_x = 25, panel_y = 20;
    int panel_width = 350, panel_height = 36+27*MAX_PARTIAL_POS;
    int font_size = 16;

    // Tạo panel nền
    ObjectCreate(0, PARTIAL_PANEL_BG, OBJ_RECTANGLE_LABEL, 0, 0, 0);
    ObjectSetInteger(0, PARTIAL_PANEL_BG, OBJPROP_CORNER, CORNER_LEFT_UPPER);
    ObjectSetInteger(0, PARTIAL_PANEL_BG, OBJPROP_XDISTANCE, panel_x);
    ObjectSetInteger(0, PARTIAL_PANEL_BG, OBJPROP_YDISTANCE, panel_y);
    ObjectSetInteger(0, PARTIAL_PANEL_BG, OBJPROP_XSIZE, panel_width);
    ObjectSetInteger(0, PARTIAL_PANEL_BG, OBJPROP_YSIZE, panel_height);
    ObjectSetInteger(0, PARTIAL_PANEL_BG, OBJPROP_BGCOLOR, clrAliceBlue);
    ObjectSetInteger(0, PARTIAL_PANEL_BG, OBJPROP_COLOR, clrBlue);

    // Tạo tiêu đề căn giữa
    string title = StringFormat("Chốt lời %.0f%%", percent*100.0);
    int title_len = StringLen(title);
    int est_char_width = font_size * 0.6;
    int title_width = (int)(title_len * est_char_width);
    int title_x = panel_x + (panel_width - title_width) / 2;
    int title_y = panel_y + 12;

    ObjectCreate(0, PARTIAL_TITLE_LABEL, OBJ_LABEL, 0, 0, 0);
    ObjectSetInteger(0, PARTIAL_TITLE_LABEL, OBJPROP_CORNER, CORNER_LEFT_UPPER);
    ObjectSetInteger(0, PARTIAL_TITLE_LABEL, OBJPROP_XDISTANCE, title_x);
    ObjectSetInteger(0, PARTIAL_TITLE_LABEL, OBJPROP_YDISTANCE, title_y);
    ObjectSetInteger(0, PARTIAL_TITLE_LABEL, OBJPROP_FONTSIZE, font_size);
    ObjectSetInteger(0, PARTIAL_TITLE_LABEL, OBJPROP_COLOR, clrBlue);
    ObjectSetString(0, PARTIAL_TITLE_LABEL, OBJPROP_TEXT, title);

    int y = panel_y + 40;

    // Panel chính
    ObjectCreate(0, PARTIAL_PANEL_BG, OBJ_RECTANGLE_LABEL, 0, 0, 0);
    ObjectSetInteger(0, PARTIAL_PANEL_BG, OBJPROP_CORNER, CORNER_LEFT_UPPER);
    ObjectSetInteger(0, PARTIAL_PANEL_BG, OBJPROP_XDISTANCE, 25);
    ObjectSetInteger(0, PARTIAL_PANEL_BG, OBJPROP_YDISTANCE, 20);
    ObjectSetInteger(0, PARTIAL_PANEL_BG, OBJPROP_XSIZE, 350);
    ObjectSetInteger(0, PARTIAL_PANEL_BG, OBJPROP_YSIZE, 36+27*MAX_PARTIAL_POS);
    ObjectSetInteger(0, PARTIAL_PANEL_BG, OBJPROP_BGCOLOR, clrAliceBlue);
    ObjectSetInteger(0, PARTIAL_PANEL_BG, OBJPROP_COLOR, clrBlue);

    int idx = 0;
    for(int i=0;i<PositionsTotal();i++)
    {
        if(PositionGetSymbol(i)==_Symbol && idx<MAX_PARTIAL_POS)
        {
            ulong ticket = PositionGetInteger(POSITION_TICKET);
            double vol = PositionGetDouble(POSITION_VOLUME);
            double price = PositionGetDouble(POSITION_PRICE_OPEN);
            string btnName = PARTIAL_BTN_PREF + IntegerToString(idx+1);

            partial_selected[idx] = false;
            partial_ticket[idx] = ticket;

            ObjectCreate(0, btnName, OBJ_BUTTON, 0, 0, 0);
            ObjectSetInteger(0, btnName, OBJPROP_CORNER, CORNER_LEFT_UPPER);
            ObjectSetInteger(0, btnName, OBJPROP_XDISTANCE, 35);
            ObjectSetInteger(0, btnName, OBJPROP_YDISTANCE, y);
            ObjectSetInteger(0, btnName, OBJPROP_XSIZE, 320);
            ObjectSetInteger(0, btnName, OBJPROP_YSIZE, 24);
            ObjectSetInteger(0, btnName, OBJPROP_BGCOLOR, clrWhite);
            ObjectSetInteger(0, btnName, OBJPROP_COLOR, clrBlack);
            ObjectSetInteger(0, btnName, OBJPROP_FONTSIZE, 10);
            ObjectSetString(0, btnName, OBJPROP_TEXT, 
                StringFormat("#%d | Ticket: %llu | Lot: %.2f | Giá: %.5f", idx+1, ticket, vol, price));
            ObjectSetInteger(0, btnName, OBJPROP_HIDDEN, false);
            ObjectSetString(0, btnName, OBJPROP_TOOLTIP, "Click chọn/bỏ chọn lệnh này");

            y += 27;
            idx++;
        }
    }
    partial_count = idx;

    ObjectCreate(0, PARTIAL_ALL, OBJ_BUTTON, 0, 0, 0);
    ObjectSetInteger(0, PARTIAL_ALL, OBJPROP_CORNER, CORNER_LEFT_UPPER);
    ObjectSetInteger(0, PARTIAL_ALL, OBJPROP_XDISTANCE, 50);
    ObjectSetInteger(0, PARTIAL_ALL, OBJPROP_YDISTANCE, y+8);
    ObjectSetInteger(0, PARTIAL_ALL, OBJPROP_XSIZE, 85);
    ObjectSetInteger(0, PARTIAL_ALL, OBJPROP_YSIZE, 23);
    ObjectSetInteger(0, PARTIAL_ALL, OBJPROP_BGCOLOR, clrYellow);
    ObjectSetString(0, PARTIAL_ALL, OBJPROP_TEXT, "Chọn tất cả");

    ObjectCreate(0, PARTIAL_OK, OBJ_BUTTON, 0, 0, 0);
    ObjectSetInteger(0, PARTIAL_OK, OBJPROP_CORNER, CORNER_LEFT_UPPER);
    ObjectSetInteger(0, PARTIAL_OK, OBJPROP_XDISTANCE, 160);
    ObjectSetInteger(0, PARTIAL_OK, OBJPROP_YDISTANCE, y+8);
    ObjectSetInteger(0, PARTIAL_OK, OBJPROP_XSIZE, 80);
    ObjectSetInteger(0, PARTIAL_OK, OBJPROP_YSIZE, 23);
    ObjectSetInteger(0, PARTIAL_OK, OBJPROP_BGCOLOR, clrLimeGreen);
    ObjectSetString(0, PARTIAL_OK, OBJPROP_TEXT, "Chốt lời");

    ObjectCreate(0, PARTIAL_CANCEL, OBJ_BUTTON, 0, 0, 0);
    ObjectSetInteger(0, PARTIAL_CANCEL, OBJPROP_CORNER, CORNER_LEFT_UPPER);
    ObjectSetInteger(0, PARTIAL_CANCEL, OBJPROP_XDISTANCE, 260);
    ObjectSetInteger(0, PARTIAL_CANCEL, OBJPROP_YDISTANCE, y+8);
    ObjectSetInteger(0, PARTIAL_CANCEL, OBJPROP_XSIZE, 65);
    ObjectSetInteger(0, PARTIAL_CANCEL, OBJPROP_YSIZE, 23);
    ObjectSetInteger(0, PARTIAL_CANCEL, OBJPROP_BGCOLOR, clrRed);
    ObjectSetString(0, PARTIAL_CANCEL, OBJPROP_TEXT, "Hủy");
}

void DeletePartialClosePanel()
{
    ObjectDelete(0, PARTIAL_TITLE_LABEL); // Xóa tiêu đề
    ObjectDelete(0, PARTIAL_PANEL_BG);
    for(int i=0;i<MAX_PARTIAL_POS;i++)
        ObjectDelete(0, PARTIAL_BTN_PREF + IntegerToString(i+1));
    ObjectDelete(0, PARTIAL_OK);
    ObjectDelete(0, PARTIAL_ALL);
    ObjectDelete(0, PARTIAL_CANCEL);
}

bool TakeProfitByTicket(ulong ticket, double percent)
{
    for(int i=0; i<PositionsTotal(); i++)
    {
        if(PositionGetSymbol(i)==_Symbol && PositionGetInteger(POSITION_TICKET)==ticket)
        {
            double volume = PositionGetDouble(POSITION_VOLUME);
            long type = PositionGetInteger(POSITION_TYPE);
            double close_vol = NormalizeDouble(volume*percent, 2);
            double minlot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
            double lotstep = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);
            close_vol = MathMax(close_vol, minlot);
            close_vol = MathFloor(close_vol/lotstep)*lotstep;
            if(close_vol < minlot + 1e-8)
                return false;
            MqlTradeRequest req = {};
            MqlTradeResult  res = {};
            req.action   = TRADE_ACTION_DEAL;
            req.symbol   = _Symbol;
            req.position = ticket;
            req.volume   = close_vol;
            req.price    = (type==POSITION_TYPE_BUY) ? SymbolInfoDouble(_Symbol, SYMBOL_BID) : SymbolInfoDouble(_Symbol, SYMBOL_ASK);
            req.type     = (type==POSITION_TYPE_BUY) ? ORDER_TYPE_SELL : ORDER_TYPE_BUY;
            req.deviation= 10;
            if(OrderSend(req, res) && res.retcode == TRADE_RETCODE_DONE)
                return true;
        }
    }
    return false;
}

