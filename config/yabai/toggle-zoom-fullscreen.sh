#!/usr/bin/env bash
# Keep yabai's in-place zoom-fullscreen while hiding windows that would show
# through transparent application backgrounds. Opacity is restored on unzoom.
set -euo pipefail

# A zero opacity resets to yabai's configured default, so use a near-zero value.
# Keep the transition effectively instantaneous rather than visually prominent.
fade_steps=2
fade_delay=0.01
hidden_opacity=0.01
hidden_inactive_border='inactive_color=0x00000000'
normal_inactive_border='inactive_color=gradient(top_left=0xff4a3a8a,bottom_right=0xff2a6aaa)'
# A fixed path lets yabai signals access state created by skhd or SketchyBar.
state_dir="/tmp/yabai-zoom-fullscreen-opacity-$UID"

restore_hidden_windows() {
  local file id original_opacity

  for file in "$state_dir"/*.json; do
    [[ -f "$file" ]] || continue

    while IFS=$'\t' read -r id original_opacity; do
      [[ -n "$id" ]] || continue
      yabai -m window "$id" --opacity "$original_opacity" 2>/dev/null || true
    done < <(jq -r '.[] | "\(.id)\t\(.opacity)"' "$file")

    rm -f "$file"
  done

  borders "$normal_inactive_border"
}

# A fullscreen window can be closed before it is unzoomed. In that case, only
# restore the hidden windows once no other fullscreen zoom remains.
if [[ "${1:-}" == "--restore-hidden-windows" ]]; then
  if yabai -m query --windows | jq -e '[.[] | select(.["has-fullscreen-zoom"])] | length == 0' >/dev/null; then
    restore_hidden_windows
  fi
  exit 0
fi

focused_window="$(yabai -m query --windows --window)"
window_id="$(jq -r '.id' <<<"$focused_window")"
space_id="$(jq -r '.space' <<<"$focused_window")"
state_file="$state_dir/$space_id.json"
zoomed="$(jq -r '."has-fullscreen-zoom"' <<<"$focused_window")"


fade_windows() {
  local direction="$1"
  local step opacity

  for ((step = 1; step <= fade_steps; step++)); do
    while IFS=$'\t' read -r id original_opacity; do
      [[ -n "$id" ]] || continue

      if [[ "$direction" == "out" ]]; then
        opacity="$(awk -v original="$original_opacity" -v step="$step" -v total="$fade_steps" -v hidden="$hidden_opacity" 'BEGIN { value = original * (total - step) / total; if (value < hidden) value = hidden; printf "%.4f", value }')"
      else
        opacity="$(awk -v original="$original_opacity" -v step="$step" -v total="$fade_steps" 'BEGIN { printf "%.4f", original * step / total }')"
      fi

      yabai -m window "$id" --opacity "$opacity" 2>/dev/null || true
    done < <(jq -r '.[] | "\(.id)\t\(.opacity)"' "$state_file")
    sleep "$fade_delay"
  done
}

if [[ "$zoomed" == "true" ]]; then
  if [[ -f "$state_file" ]]; then
    yabai -m window --toggle zoom-fullscreen
    borders "$normal_inactive_border"
    fade_windows in
    rm -f "$state_file"
  else
    yabai -m window --toggle zoom-fullscreen
  fi
  exit 0
fi

mkdir -p "$state_dir"
yabai -m query --windows |
  jq --argjson space "$space_id" --argjson focused "$window_id" \
    '[.[] | select(.space == $space and .id != $focused) | {id, opacity}]' >"$state_file"

borders "$hidden_inactive_border"
fade_windows out
yabai -m window --toggle zoom-fullscreen
