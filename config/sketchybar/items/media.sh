media=(
  drawing=off
  icon=􀑪
  icon.color=$WHITE
  script="$PLUGIN_DIR/media.sh"
  label.max_chars=20
  scroll_texts=on
  updates=on
)

sketchybar --add item media center \
           --set media "${media[@]}" \
           --subscribe media media_change
