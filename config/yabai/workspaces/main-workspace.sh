#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib.sh
source "$SCRIPT_DIR/lib.sh"

ensure_space_count 4

# Space 1
code_id="$(ensure_app_window_in_space Code 1 launch_app "Visual Studio Code")" || workspace_die "Code window not found on space 1"
ensure_ghostty_windows_in_space 1 2 || workspace_die "Ghostty windows not found on space 1"
ghostty_1="$(window_ids_for_app_in_space Ghostty 1 | sed -n '1p')"
ghostty_2="$(window_ids_for_app_in_space Ghostty 1 | sed -n '2p')"
place_tiled_window "$code_id" 1
place_tiled_window "$ghostty_1" 1
place_tiled_window "$ghostty_2" 1
set_window_split_ratio "$code_id" "0.70"

# Space 2
arc_id="$(ensure_app_window_in_space Arc 2 launch_app "Arc")" || workspace_die "Arc window not found on space 2"
place_tiled_window "$arc_id" 2

# Space 3
whatsapp_id="$(ensure_app_window_in_space WhatsApp 3 launch_app "WhatsApp")" || workspace_die "WhatsApp window not found on space 3"
telegram_id="$(ensure_app_window_in_space Telegram 3 launch_app "Telegram")" || workspace_die "Telegram window not found on space 3"
place_tiled_window "$whatsapp_id" 3
place_tiled_window "$telegram_id" 3
set_window_split_ratio "$whatsapp_id" "0.70"

# Space 4
finder_id="$(ensure_app_window_in_space Finder 4 open_finder_downloads)" || workspace_die "Finder window not found on space 4"
ensure_ghostty_windows_in_space 4 2 || workspace_die "Ghostty windows not found on space 4"
ghostty_3="$(window_ids_for_app_in_space Ghostty 4 | sed -n '1p')"
ghostty_4="$(window_ids_for_app_in_space Ghostty 4 | sed -n '2p')"
place_tiled_window "$finder_id" 4
yabai -m window "$finder_id" --focus
open_finder_downloads
place_tiled_window "$ghostty_3" 4
place_tiled_window "$ghostty_4" 4

focus_space 1
notify_workspace "Main workspace ready"
