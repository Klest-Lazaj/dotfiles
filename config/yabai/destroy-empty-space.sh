#!/usr/bin/env bash
# Destroy the current Space only when it contains no windows.
set -euo pipefail

current_space="$(yabai -m query --spaces --space)"
current_index="$(jq -r '.index' <<<"$current_space")"
window_count="$(yabai -m query --windows | jq --argjson space "$current_index" '[.[] | select(.space == $space)] | length')"

if (( window_count > 0 )); then
  osascript -e 'display notification "Move or close its windows before removing this Space." with title "Space is not empty"'
  exit 0
fi

target_index=$((current_index > 1 ? current_index - 1 : 1))
yabai -m space --destroy
yabai -m space --focus "$target_index"
