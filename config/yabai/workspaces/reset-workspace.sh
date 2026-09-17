#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib.sh
source "$SCRIPT_DIR/lib.sh"

confirm_reset() {
  osascript >/dev/null <<'APPLESCRIPT'
display dialog "Quit visible apps, close Finder windows, and remove extra Spaces?" buttons {"Cancel", "Reset"} default button "Reset" cancel button "Cancel" with icon caution
APPLESCRIPT
}

close_finder_windows() {
  osascript >/dev/null 2>&1 <<'APPLESCRIPT' || true
tell application "Finder"
  close every window
end tell
APPLESCRIPT
}

quit_app() {
  local app

  if [ "$1" = "WhatsApp" ]; then
    osascript -e 'tell application id "net.whatsapp.WhatsApp" to quit' >/dev/null 2>&1 || true
    return
  fi

  app="$(applescript_escape "$1")"
  osascript -e "tell application \"$app\" to quit" >/dev/null 2>&1 || true
}

is_resettable_app() {
  case "$1" in
    Dock|SystemUIServer|ControlCenter|NotificationCenter|loginwindow|WindowManager|Spotlight|ScreenSaverEngine)
      return 1
      ;;
  esac

  return 0
}

remaining_window_summary() {
  windows_json | jq -r '
    [ .[]
      | select(.app != null and .app != "")
      | (.app | gsub("\u200e"; "") | gsub("\u200f"; ""))
    ]
    | unique
    | join(", ")
  '
}

wait_for_windows_to_close() {
  local remaining

  for _ in {1..60}; do
    remaining="$(remaining_window_summary)"
    if [ -z "$remaining" ]; then
      return 0
    fi
    sleep 0.25
  done

  printf '%s\n' "$remaining"
  return 1
}

destroy_extra_spaces() {
  local indices index

  indices="$(spaces_json | jq -r '[ .[] | select(.index > 1) | .index ] | sort | reverse | .[]')"
  focus_space 1

  while IFS= read -r index; do
    [ -n "$index" ] || continue
    yabai -m space "$index" --destroy || true
    sleep 0.1
  done <<<"$indices"
}

confirm_reset || exit 0
close_finder_windows

while IFS= read -r app; do
  [ -n "$app" ] || continue
  is_resettable_app "$app" || continue
  quit_app "$app"
done < <(
  windows_json | jq -r '
    [ .[]
      | select(.app != null and .app != "" and .app != "Finder")
      | (.app | gsub("\u200e"; "") | gsub("\u200f"; ""))
    ]
    | unique
    | .[]
  '
)

if ! remaining="$(wait_for_windows_to_close)"; then
  notify_workspace "Reset stopped. Windows still open: $remaining"
  exit 1
fi

destroy_extra_spaces
focus_space 1
notify_workspace "Workspace reset complete"
