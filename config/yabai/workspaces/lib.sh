#!/usr/bin/env bash

workspace_die() {
  printf 'workspace: %s\n' "$*" >&2
  if declare -F notify_workspace >/dev/null 2>&1; then
    notify_workspace "$*"
  fi
  exit 1
}

spaces_json() {
  yabai -m query --spaces
}

windows_json() {
  yabai -m query --windows
}

window_json() {
  yabai -m query --windows --window "$1"
}

space_count() {
  spaces_json | jq 'length'
}

ensure_space_count() {
  local wanted="$1"
  local count

  count="$(space_count)"
  while [ "$count" -lt "$wanted" ]; do
    yabai -m space --create
    wait_for_space_count $((count + 1))
    count="$(space_count)"
  done
}

wait_for_space_count() {
  local wanted="$1"
  local count

  for _ in {1..80}; do
    count="$(space_count)"
    if [ "$count" -ge "$wanted" ]; then
      return 0
    fi
    sleep 0.1
  done

  return 1
}

launch_app() {
  open -a "$1" >/dev/null 2>&1 || true
}

open_ghostty_window() {
  osascript -e 'tell application "Ghostty" to «event GhstNWin»' >/dev/null 2>&1 \
    || open -na Ghostty >/dev/null 2>&1 \
    || open -a Ghostty >/dev/null 2>&1
}

open_finder_downloads() {
  local downloads_path="$HOME/Downloads"

  osascript >/dev/null 2>&1 <<APPLESCRIPT || open "$downloads_path" >/dev/null 2>&1
tell application "Finder"
  activate
  if (count of windows) = 0 then
    make new Finder window
  end if
  set target of front window to (POSIX file "$downloads_path")
end tell
APPLESCRIPT
}

window_ids_for_app_in_space() {
  local app="$1"
  local space="$2"
  windows_json | jq -r --arg app "$app" --argjson space "$space" '
    [ .[]
      | select(
          (.app | gsub("\u200e"; "") | gsub("\u200f"; "")) == $app
          and .space == $space
        )
      | .id
    ]
    | sort
    | .[]
  '
}

first_window_id_for_app() {
  local app="$1"
  windows_json | jq -r --arg app "$app" '
    [ .[]
      | select((.app | gsub("\u200e"; "") | gsub("\u200f"; "")) == $app)
      | .id
    ]
    | sort
    | first // empty
  '
}

first_window_id_for_app_in_space() {
  local app="$1"
  local space="$2"
  window_ids_for_app_in_space "$app" "$space" | sed -n '1p'
}

app_window_count_in_space() {
  local app="$1"
  local space="$2"
  windows_json | jq --arg app "$app" --argjson space "$space" '
    [ .[]
      | select(
          (.app | gsub("\u200e"; "") | gsub("\u200f"; "")) == $app
          and .space == $space
        )
    ]
    | length
  '
}

wait_for_app_windows_in_space() {
  local app="$1"
  local space="$2"
  local wanted="$3"
  local count

  for _ in {1..120}; do
    count="$(app_window_count_in_space "$app" "$space")"
    if [ "$count" -ge "$wanted" ]; then
      return 0
    fi
    sleep 0.25
  done

  return 1
}

ensure_app_window_in_space() {
  local app="$1"
  local space="$2"
  local window_id
  shift 2

  window_id="$(first_window_id_for_app_in_space "$app" "$space")"
  if [ -n "$window_id" ]; then
    printf '%s\n' "$window_id"
    return 0
  fi

  window_id="$(first_window_id_for_app "$app")"
  if [ -n "$window_id" ]; then
    printf '%s\n' "$window_id"
    return 0
  fi

  focus_space "$space"
  "$@"
  wait_for_app_windows_in_space "$app" "$space" 1 || return 1
  first_window_id_for_app_in_space "$app" "$space"
}

ensure_ghostty_windows_in_space() {
  local space="$1"
  local wanted="$2"
  local count

  count="$(app_window_count_in_space Ghostty "$space")"
  while [ "$count" -lt "$wanted" ]; do
    focus_space "$space"
    open_ghostty_window
    wait_for_app_windows_in_space Ghostty "$space" $((count + 1)) || return 1
    count="$(app_window_count_in_space Ghostty "$space")"
  done
}

window_space() {
  window_json "$1" | jq -r '.space // empty'
}

window_is_floating() {
  window_json "$1" | jq -r '."is-floating" // false'
}

ensure_window_tiled() {
  local window_id="$1"

  if [ "$(window_is_floating "$window_id")" = "true" ]; then
    yabai -m window "$window_id" --toggle float
  fi
}

wait_for_window_space() {
  local window_id="$1"
  local space="$2"
  local current

  for _ in {1..60}; do
    current="$(window_json "$window_id" | jq -r '.space // empty')"
    if [ "$current" = "$space" ]; then
      return 0
    fi
    sleep 0.1
  done

  return 1
}

place_tiled_window() {
  local window_id="$1"
  local space="$2"

  [ -n "$window_id" ] || workspace_die "missing window id for space $space"

  if [ "$(window_space "$window_id")" != "$space" ]; then
    yabai -m window "$window_id" --space "$space"
    wait_for_window_space "$window_id" "$space" || workspace_die "window $window_id did not move to space $space"
  fi

  focus_space "$space"
  ensure_window_tiled "$window_id"
}

set_window_split_ratio() {
  local window_id="$1"
  local ratio="$2"

  yabai -m window "$window_id" --focus
  yabai -m window --ratio "abs:$ratio"
}

focus_space() {
  yabai -m space --focus "$1" >/dev/null 2>&1 || true
}

applescript_escape() {
  printf '%s' "$1" | sed 's/\\/\\\\/g; s/"/\\"/g'
}

notify_workspace() {
  local message
  message="$(applescript_escape "$1")"
  osascript -e "display notification \"$message\" with title \"Workspace\"" >/dev/null 2>&1 || true
}
