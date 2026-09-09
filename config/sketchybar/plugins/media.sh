#!/bin/bash

update_media() {
  STATE="$(echo "$INFO" | jq -r '.state')"

  if [ "$STATE" = "playing" ]; then
    MEDIA="$(echo "$INFO" | jq -r '.title + " - " + .artist')"
    sketchybar --set $NAME label="$MEDIA" drawing=on
  else
    sketchybar --set $NAME drawing=off
  fi
}

check_now_playing() {
  STATE="$(osascript -e 'tell application "System Events" to get (name of processes whose background only is false)' 2>/dev/null)"
  TITLE="$(osascript -e 'tell application "Music" to get name of current track' 2>/dev/null)"
  ARTIST="$(osascript -e 'tell application "Music" to get artist of current track' 2>/dev/null)"
  if [ -n "$TITLE" ]; then
    sketchybar --set $NAME label="$TITLE - $ARTIST" drawing=on
  else
    sketchybar --set $NAME drawing=off
  fi
}

case "$SENDER" in
  "media_change") update_media
  ;;
  "routine"|"forced") check_now_playing
  ;;
esac
