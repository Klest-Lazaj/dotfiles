#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"

log() {
  printf "\033[1;34m==>\033[0m %s\n" "$1"
}

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

install_homebrew() {
  if command -v brew >/dev/null 2>&1; then
    return
  fi

  log "Installing Homebrew"
  NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
}

setup_homebrew_shellenv() {
  if [ -x /opt/homebrew/bin/brew ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [ -x /usr/local/bin/brew ]; then
    eval "$(/usr/local/bin/brew shellenv)"
  fi
}

install_zinit() {
  local zinit_dir="$HOME/.local/share/zinit/zinit.git"

  if [ -d "$zinit_dir" ]; then
    return
  fi

  log "Installing zinit"
  git clone https://github.com/zdharma-continuum/zinit.git "$zinit_dir"
}

install_nvm() {
  if [ -s "$HOME/.nvm/nvm.sh" ]; then
    return
  fi

  log "Installing nvm"
  mkdir -p "$HOME/.nvm"
  PROFILE=/dev/null bash -c "$(curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh)"
}

install_sdkman() {
  if [ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]; then
    return
  fi

  log "Installing SDKMAN"
  curl -s "https://get.sdkman.io" | bash
}

install_tooling() {
  log "Installing Homebrew packages"
  brew bundle --file "$DOTFILES_DIR/Brewfile"

  log "Installing shell plugin managers"
  install_zinit
  install_nvm
  install_sdkman

  log "Installing latest Node via nvm"
  # shellcheck source=/dev/null
  source "$HOME/.nvm/nvm.sh"
  nvm install --lts
  nvm alias default 'lts/*'

  log "Preparing Java"
  if [ -d /opt/homebrew/opt/openjdk ]; then
    sudo ln -sfn /opt/homebrew/opt/openjdk/libexec/openjdk.jdk /Library/Java/JavaVirtualMachines/openjdk.jdk
  fi
}

link_dotfiles() {
  log "Linking dotfiles"

  backup_and_link "$DOTFILES_DIR/home/.zshrc" "$HOME/.zshrc"
  backup_and_link "$DOTFILES_DIR/home/.zprofile" "$HOME/.zprofile"
  backup_and_link "$DOTFILES_DIR/home/.skhdrc" "$HOME/.skhdrc"
  backup_and_link "$DOTFILES_DIR/home/.zsh/completions" "$HOME/.zsh/completions"

  backup_and_link "$DOTFILES_DIR/config/yabai" "$HOME/.config/yabai"
  backup_and_link "$DOTFILES_DIR/config/sketchybar" "$HOME/.config/sketchybar"
  backup_and_link "$DOTFILES_DIR/config/borders" "$HOME/.config/borders"
  backup_and_link "$DOTFILES_DIR/config/ghostty" "$HOME/.config/ghostty"
  backup_and_link "$DOTFILES_DIR/config/btop" "$HOME/.config/btop"
  backup_and_link "$DOTFILES_DIR/config/starship.toml" "$HOME/.config/starship.toml"
}

configure_macos() {
  log "Applying macOS defaults"
  "$DOTFILES_DIR/macos-defaults.sh"
}

start_services() {
  log "Starting services"
  yabai --start-service || true
  skhd --start-service || true
  brew services start sketchybar || true
  brew services start borders || true
}

main() {
  install_homebrew
  setup_homebrew_shellenv
  install_tooling
  link_dotfiles
  configure_macos
  start_services

  log "Done. Existing files, if any, were moved to $BACKUP_DIR"
}

main "$@"
