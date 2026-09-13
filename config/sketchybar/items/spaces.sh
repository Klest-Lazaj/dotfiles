#!/bin/bash

# Destroy space on right click, focus space on left click.
# New space by left clicking separator (>)

sid=0
spaces=()
for sid in {1..12}
do
  space=(
    space=$sid
    width=54
    icon="$sid"
    icon.width=54
    icon.align=center
    icon.padding_left=0
    icon.padding_right=0
    padding_left=2
    padding_right=2
    label.drawing=off
    icon.highlight_color=$BLUE
    background.color=$BACKGROUND_1
    background.border_color=$BACKGROUND_2
    script="$PLUGIN_DIR/space.sh"
  )

  sketchybar --add space space.$sid left    \
             --set space.$sid "${space[@]}" \
             --subscribe space.$sid mouse.clicked
done

space_creator=(
  icon=􀆊
  icon.font="$FONT:Heavy:16.0"
  padding_left=10
  padding_right=8
  label.drawing=off
  display=active
  click_script="$HOME/.config/yabai/create-space-right.sh"
  icon.color=$WHITE
)

sketchybar --add item space_creator left               \
           --set space_creator "${space_creator[@]}"
