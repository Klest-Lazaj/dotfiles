#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"

backup_and_link() {
  local source_path="$1"
  local target_path="$2"

  mkdir -p "$(dirname "$target_path")"

  if [ -L "$target_path" ] && [ "$(readlink "$target_path")" = "$source_path" ]; then
    return
  fi

  if [ -e "$target_path" ] || [ -L "$target_path" ]; then
    mkdir -p "$BACKUP_DIR$(dirname "$target_path")"
    mv "$target_path" "$BACKUP_DIR$target_path"
  fi

  ln -s "$source_path" "$target_path"
}

backup_and_link "$DOTFILES_DIR/home/.zshrc" "$HOME/.zshrc"
backup_and_link "$DOTFILES_DIR/home/.zprofile" "$HOME/.zprofile"
backup_and_link "$DOTFILES_DIR/home/.skhdrc" "$HOME/.skhdrc"
backup_and_link "$DOTFILES_DIR/home/.zsh/completions" "$HOME/.zsh/completions"

backup_and_link "$DOTFILES_DIR/config/yabai" "$HOME/.config/yabai"
backup_and_link "$DOTFILES_DIR/config/sketchybar" "$HOME/.config/sketchybar"
backup_and_link "$DOTFILES_DIR/config/borders" "$HOME/.config/borders"
backup_and_link "$DOTFILES_DIR/config/ghostty" "$HOME/.config/ghostty"
backup_and_link "$DOTFILES_DIR/config/btop" "$HOME/.config/btop"
backup_and_link "$DOTFILES_DIR/config/neofetch" "$HOME/.config/neofetch"
backup_and_link "$DOTFILES_DIR/config/starship.toml" "$HOME/.config/starship.toml"

printf "Linked dotfiles. Backups are in %s\n" "$BACKUP_DIR"
