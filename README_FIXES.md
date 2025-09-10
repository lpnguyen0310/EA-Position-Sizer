# EA Position Sizer - Take Profit Button Fix

## Overview
This fix addresses the issue where the take profit 1/2 and 3/4 buttons always showed a selection panel, even when only one position was open.

## Changes Made

### 1. Smart Take Profit Logic
- **Before**: Always shows selection panel when clicking 1/2 or 3/4 buttons
- **After**: 
  - If 0 positions: Shows warning message
  - If 1 position: Directly executes take profit without showing panel
  - If 2+ positions: Shows selection panel as before

### 2. Helper Functions Added
- `CountPositionsForSymbol()`: Counts open positions for current symbol
- `GetFirstPositionTicket()`: Gets the ticket of the first position for current symbol

### 3. Fixed Hotkey Issues
- Corrected `TerminalInfoInteger()` logic for modifier keys (Shift/Ctrl)
- Fixed inconsistent keyboard state checking throughout the code
- Now properly detects when Shift or Ctrl keys are pressed/released

### 4. Added Missing Files
- `Position Sizer Trading.mqh`: Contains Trade() and DoTrailingStop() functions
- `Translations/English.mqh`: Contains all required translation constants

## Implementation Details

### Take Profit Button Logic
```mql5
if(id == CHARTEVENT_OBJECT_CLICK && sparam == TAKEHALF_BUTTON_NAME)
{
    int position_count = CountPositionsForSymbol();
    if(position_count == 0)
    {
        MessageBox("Không có lệnh nào đang mở để chốt lời!", "Thông báo", MB_ICONWARNING);
    }
    else if(position_count == 1)
    {
        // Direct execution for single position
        ulong ticket = GetFirstPositionTicket();
        if(TakeProfitByTicket(ticket, 0.5))
        {
            MessageBox("Đã chốt lời 1/2 số lot cho lệnh duy nhất!", "Thông báo", MB_ICONINFORMATION);
        }
    }
    else
    {
        // Show selection panel for multiple positions
        ShowPartialClosePanel(0.5);
    }
}
```

### Hotkey Fix Example
```mql5
// Before (incorrect)
if (TerminalInfoInteger(TERMINAL_KEYSTATE_SHIFT) == 0)

// After (correct)
if (TerminalInfoInteger(TERMINAL_KEYSTATE_SHIFT) >= 0)  // Not pressed
if (TerminalInfoInteger(TERMINAL_KEYSTATE_SHIFT) < 0)   // Pressed
```

## Testing Instructions
1. Compile the EA in MetaTrader 5
2. Attach to a chart
3. Open 1 position
4. Click "1/2" or "3/4" button - should execute immediately
5. Open multiple positions
6. Click "1/2" or "3/4" button - should show selection panel

## Files Modified
- `Position Sizer PS_V19.mq5`: Main EA file with button logic fixes
- `Position Sizer Trading.mqh`: Created with trading functions
- `Translations/English.mqh`: Created with translation constants

The EA should now compile without errors and provide the requested smart take profit functionality.