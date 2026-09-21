#!/bin/bash

disk=(
  icon="DSK"
  icon.font="$FONT:Bold:10.0"
  icon.color=$WHITE
  label.font="$FONT:Heavy:11.0"
  label="–%"
  padding_left=8
  padding_right=8
  update_freq=60
  script="$PLUGIN_DIR/disk.sh"
  click_script="open -na Ghostty --args -e btop; sleep 0.2 && yabai -m window --focus \"\$(yabai -m query --windows | jq '[.[] | select(.app==\"Ghostty\")] | sort_by(.id) | last | .id')\" && \"$HOME/.config/yabai/toggle-zoom-fullscreen.sh\""
)

sketchybar --add item disk right \
           --set disk "${disk[@]}"
