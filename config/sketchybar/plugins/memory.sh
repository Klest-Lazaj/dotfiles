#!/bin/bash

source "$CONFIG_DIR/colors.sh"

TOTAL_BYTES=$(sysctl -n hw.memsize)
TOTAL_GB=$(echo "$TOTAL_BYTES" | awk '{printf "%.0f", $1/1024/1024/1024}')

# vm_stat pages are 4096 bytes on macOS
PAGE_SIZE=4096
VM=$(vm_stat)
ACTIVE=$(echo "$VM"   | awk '/Pages active/{gsub(/\./,"",$3); print $3}')
WIRED=$(echo "$VM"    | awk '/Pages wired down/{gsub(/\./,"",$4); print $4}')
COMPRESSED=$(echo "$VM" | awk '/Pages occupied by compressor/{gsub(/\./,"",$5); print $5}')

USED_GB=$(echo "$ACTIVE $WIRED $COMPRESSED $PAGE_SIZE $TOTAL_GB" | awk '{
  used = ($1 + $2 + $3) * $4 / 1024 / 1024 / 1024
  printf "%.1f", used
}')

PERCENT=$(echo "$USED_GB $TOTAL_GB" | awk '{printf "%.0f", ($1/$2)*100}')

if   [ "$PERCENT" -ge 85 ]; then COLOR=$RED;    BG=$CARD_RED
elif [ "$PERCENT" -ge 70 ]; then COLOR=$ORANGE; BG=$CARD_ORANGE
elif [ "$PERCENT" -ge 50 ]; then COLOR=$YELLOW; BG=$CARD_YELLOW
else                              COLOR=$GREEN;  BG=$CARD_GREEN
fi

sketchybar --set $NAME \
             label="${PERCENT}%" \
             label.color=$COLOR
