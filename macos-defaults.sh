#!/usr/bin/env bash
set -euo pipefail

log() {
  printf "\033[1;34m==>\033[0m %s\n" "$1"
}

log "Reducing macOS window, Dock, Finder, and Launchpad animations"

# Global AppKit animation knobs.
defaults write -g NSAutomaticWindowAnimationsEnabled -bool false
defaults write -g NSWindowResizeTime -float 0.001
defaults write -g QLPanelAnimationDuration -float 0
defaults write -g NSDocumentRevisionsWindowTransformAnimation -bool false
defaults write -g NSToolbarFullScreenAnimationDuration -float 0
defaults write -g NSBrowserColumnAnimationSpeedMultiplier -float 0

# Disable scroll edge bounce, but keep native smooth scrolling untouched.
defaults write -g NSScrollViewRubberbanding -bool false

# Dock, Mission Control, and Launchpad animation timing.
defaults write com.apple.dock autohide-time-modifier -float 0
defaults write com.apple.dock autohide-delay -float 0
defaults write com.apple.dock expose-animation-duration -float 0
defaults write com.apple.dock springboard-show-duration -float 0
defaults write com.apple.dock springboard-hide-duration -float 0
defaults write com.apple.dock springboard-page-duration -float 0

# Finder UI animations.
defaults write com.apple.finder DisableAllAnimations -bool true

killall Dock 2>/dev/null || true
killall Finder 2>/dev/null || true

log "macOS animation defaults applied"
