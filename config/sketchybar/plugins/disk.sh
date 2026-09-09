#!/bin/bash

source "$CONFIG_DIR/colors.sh"

# Get disk usage percent for /
PERCENT=$(df / | awk 'NR==2 {gsub(/%/,"",$5); print $5}')

# Get free space for the top label
FREE=$(df -H / | awk 'NR==2 {print $4}')

if   [ "$PERCENT" -ge 90 ]; then COLOR=$RED;    BG=$CARD_RED
elif [ "$PERCENT" -ge 75 ]; then COLOR=$ORANGE; BG=$CARD_ORANGE
elif [ "$PERCENT" -ge 60 ]; then COLOR=$YELLOW; BG=$CARD_YELLOW
else                              COLOR=$GREEN;  BG=$CARD_GREEN
fi

sketchybar --set $NAME \
             label="${PERCENT}%" \
             label.color=$COLOR
