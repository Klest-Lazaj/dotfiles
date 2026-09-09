#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PLIST_DIR="$HOME/Library/LaunchAgents"
PLIST_PATH="$PLIST_DIR/com.klest.dotfiles.autocommit.plist"
LABEL="com.klest.dotfiles.autocommit"

mkdir -p "$PLIST_DIR"
mkdir -p "$DOTFILES_DIR/logs"

cat > "$PLIST_PATH" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key>
  <string>$LABEL</string>
  <key>ProgramArguments</key>
  <array>
    <string>$DOTFILES_DIR/scripts/autocommit.sh</string>
  </array>
  <key>WatchPaths</key>
  <array>
    <string>$DOTFILES_DIR/home</string>
    <string>$DOTFILES_DIR/config</string>
    <string>$DOTFILES_DIR/Brewfile</string>
    <string>$DOTFILES_DIR/install.sh</string>
    <string>$DOTFILES_DIR/link.sh</string>
    <string>$DOTFILES_DIR/README.md</string>
    <string>$DOTFILES_DIR/.gitignore</string>
    <string>$DOTFILES_DIR/scripts</string>
  </array>
  <key>StandardOutPath</key>
  <string>$DOTFILES_DIR/logs/autocommit.out.log</string>
  <key>StandardErrorPath</key>
  <string>$DOTFILES_DIR/logs/autocommit.err.log</string>
  <key>RunAtLoad</key>
  <false/>
</dict>
</plist>
PLIST

chmod +x "$DOTFILES_DIR/scripts/autocommit.sh"

launchctl bootout "gui/$(id -u)" "$PLIST_PATH" >/dev/null 2>&1 || true
launchctl bootstrap "gui/$(id -u)" "$PLIST_PATH"
launchctl kickstart -k "gui/$(id -u)/$LABEL"

printf "Installed %s\n" "$PLIST_PATH"
