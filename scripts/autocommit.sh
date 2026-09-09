#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
LOCK_DIR="/tmp/klest-dotfiles-autocommit.lock"

if ! mkdir "$LOCK_DIR" 2>/dev/null; then
  exit 0
fi

cleanup() {
  rmdir "$LOCK_DIR" 2>/dev/null || true
}
trap cleanup EXIT

# Coalesce editor writes and service reloads into one commit.
sleep 2

cd "$REPO_DIR"

if ! git diff --quiet || [ -n "$(git status --short)" ]; then
  git add home config Brewfile README.md install.sh link.sh scripts .gitignore

  if git diff --cached --quiet; then
    exit 0
  fi

  git commit -m "Auto-update dotfiles $(date '+%Y-%m-%d %H:%M:%S')"
fi
