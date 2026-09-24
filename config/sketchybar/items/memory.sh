#!/bin/bash

mem=(
  icon="RAM"
  icon.font="$FONT:Bold:10.0"
  icon.color=$WHITE
  label.font="$FONT:Heavy:11.0"
  label="–%"
  padding_left=8
  padding_right=8
  update_freq=10
  script="$PLUGIN_DIR/memory.sh"
  click_script="open -na Ghostty --args -e btop; sleep 0.2 && yabai -m window --focus \"\$(yabai -m query --windows | jq '[.[] | select(.app==\"Ghostty\")] | sort_by(.id) | last | .id')\" && yabai -m window --toggle zoom-fullscreen"
)

sketchybar --add item mem right \
           --set mem "${mem[@]}"
