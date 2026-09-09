#!/bin/bash

if [ "$SENDER" != "space_windows_change" ]; then
  exit 0
fi

spaces="$(yabai -m query --spaces)" || exit 0
windows="$(yabai -m query --windows)" || windows="[]"
tab="$(printf '\t')"

printf '%s\n' "$spaces" | jq -r --argjson windows "$windows" '
  range(1; 13) as $index |
  (map(select(.index == $index)) | .[0]) as $space |
  if $space == null then
    "\($index)\t"
  else
    ($space.windows[0] // null) as $window_id |
    ([$windows[]? | select(.id == $window_id) | .app][0] // "") as $app |
    "\($index)\t\($app)"
  end
' | while IFS="$tab" read -r space app; do
  icon_strip=" —"

  if [ "$app" != "" ]; then
    icon_strip=" $($CONFIG_DIR/plugins/icon_map.sh "$app")"
  fi

  sketchybar --animate sin 10 --set "space.$space" \
             label="$icon_strip"
done
