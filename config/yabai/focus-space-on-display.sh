#!/usr/bin/env bash
set -euo pipefail

case "${1:-}" in
  prev|next) ;;
  *) printf 'Usage: %s prev|next\n' "$0" >&2; exit 2 ;;
esac

spaces="$(yabai -m query --spaces --display)"
target="$(
  jq -r --arg direction "$1" '
    (map(select(."has-focus"))[0].index // empty) as $current
    | [.[]
       | select(if $direction == "prev" then .index < $current else .index > $current end)
       | .index]
    | (if $direction == "prev" then max else min end) // empty
  ' <<< "$spaces"
)"

if [ -n "$target" ]; then
  yabai -m space --focus "$target"
fi
