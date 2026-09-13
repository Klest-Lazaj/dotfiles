#!/usr/bin/env bash
set -euo pipefail

current_space="$(yabai -m query --spaces --space)"
current_index="$(jq -r '.index' <<<"$current_space")"
current_display="$(jq -r '.display' <<<"$current_space")"

before_spaces="$(yabai -m query --spaces)"
before_ids="$(jq -r '.[].id' <<<"$before_spaces")"
next_index="$(
  jq -r --argjson display "$current_display" --argjson current "$current_index" '
    [ .[]
      | select(.display == $display and .index > $current)
      | .index
    ]
    | min // empty
  ' <<<"$before_spaces"
)"

yabai -m space --create

created_spaces=""
for _ in {1..20}; do
  spaces="$(yabai -m query --spaces)"
  created_spaces="$(
    jq --arg before "$before_ids" '
      ($before | split("\n")) as $before_ids |
      map(select((.id | tostring) as $id | $before_ids | index($id) | not))
    ' <<<"$spaces"
  )"

  if [ "$(jq 'length' <<<"$created_spaces")" -eq 1 ]; then
    break
  fi

  sleep 0.05
done

if [ "$(jq 'length' <<<"$created_spaces")" -ne 1 ]; then
  exit 1
fi

created_space="$(jq '.[0]' <<<"$created_spaces")"
created_index="$(jq -r '.index' <<<"$created_space")"
created_display="$(jq -r '.display' <<<"$created_space")"
label="created-$(date +%s)-$$"

if [ "$created_display" != "$current_display" ]; then
  exit 1
fi

yabai -m space "$created_index" --label "$label"

if [ -n "$next_index" ]; then
  yabai -m space "$label" --move "$next_index"
fi

yabai -m space --focus "$label"
yabai -m space "$label" --label
