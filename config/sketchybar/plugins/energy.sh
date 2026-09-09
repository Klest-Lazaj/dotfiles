#!/bin/bash

source "$CONFIG_DIR/colors.sh"

# Read voltage (mV) and amperage (mA) from AppleSmartBattery
VOLTAGE=$(ioreg -rn AppleSmartBattery | awk '/"Voltage" =/{print $NF; exit}')
AMPERAGE=$(ioreg -rn AppleSmartBattery | awk '/"InstantAmperage" =/{print $NF; exit}')

if [ -z "$VOLTAGE" ] || [ -z "$AMPERAGE" ]; then
  sketchybar --set $NAME label="–W"
  exit 0
fi

# Use python3 for exact 64-bit two's complement (Apple Silicon reports
# negative amperage as a large unsigned 64-bit int; awk loses precision)
WATTS=$(python3 -c "
v = int('$VOLTAGE')
a = int('$AMPERAGE')
if a > 2**63:
    a -= 2**64
w = abs(v * a) / 1_000_000
print(f'{w:.1f}')
" 2>/dev/null)

if [ -z "$WATTS" ]; then
  sketchybar --set $NAME label="–W"
  exit 0
fi

WATTS_INT=$(echo "$WATTS" | awk '{printf "%d", $1}')

if   [ "$WATTS_INT" -ge 25 ]; then COLOR=$RED;    BG=$CARD_RED
elif [ "$WATTS_INT" -ge 15 ]; then COLOR=$ORANGE; BG=$CARD_ORANGE
elif [ "$WATTS_INT" -ge 5  ]; then COLOR=$YELLOW; BG=$CARD_YELLOW
else                               COLOR=$GREEN;  BG=$CARD_GREEN
fi

sketchybar --set $NAME \
             label="${WATTS}W" \
             label.color=$COLOR
