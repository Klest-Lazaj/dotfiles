#!/bin/bash

source "$CONFIG_DIR/icons.sh"
source "$CONFIG_DIR/colors.sh"

BATTERY_INFO="$(pmset -g batt)"
TIME_RAW=$(echo "$BATTERY_INFO" | grep -Eo '[0-9]+:[0-9]+')

# Format time remaining
if [ -n "$TIME_RAW" ]; then
  HOURS=$(echo "$TIME_RAW" | cut -d: -f1 | sed 's/^0//')
  MINS=$(echo "$TIME_RAW" | cut -d: -f2)
  if [ -n "$HOURS" ] && [ "$HOURS" != "0" ]; then
    TIME_LABEL="${HOURS}h ${MINS}m"
  else
    TIME_LABEL="${MINS}m"
  fi
else
  TIME_LABEL=""
fi

ICON="⚡"
COLOR=$WHITE
LABEL="$TIME_LABEL"

sketchybar --set $NAME drawing=on icon="$ICON" icon.color=$COLOR label="$LABEL" label.color=$COLOR
