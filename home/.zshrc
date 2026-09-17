# --- PATH ---
export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH
export PATH="/Users/klestlazaj/mongodb-macos-aarch64-8.0.0/bin:$PATH"
PATH=~/.console-ninja/.bin:$PATH

# --- ZINIT ---
source "$HOME/.local/share/zinit/zinit.git/zinit.zsh"
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit

# Plugins (loaded in parallel, fast)
zinit light zsh-users/zsh-autosuggestions
zinit light zsh-users/zsh-syntax-highlighting

# Zoxide (smarter z)
eval "$(zoxide init zsh)"

# OMZ completion lib
zinit snippet OMZ::lib/completion.zsh

# FZF
export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git . $HOME'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git . $HOME'
export FZF_DEFAULT_OPTS="
  --height 50% --layout reverse --border rounded --multi
  --preview 'bat --color=always --style=numbers --line-range=:80 {} 2>/dev/null || ls -la {}'
  --preview-window 'right:50%:wrap'
  --bind 'ctrl-/:toggle-preview'
  --bind 'ctrl-a:select-all'
  --bind 'ctrl-y:execute-silent(echo {+} | pbcopy)'
"

# control + f keybind to cd into a dir fast
bindkey '^F' fzf-cd-widget

source <(fzf --zsh)

# --- COMPLETION ---
fpath=(~/.zsh/completions $fpath)
autoload -Uz compinit && compinit

# --- STARSHIP ---
eval "$(starship init zsh)"

# --- ALIASES ---

# Git
alias gs="git status"
alias gca="git commit -a -m"
alias gcm="git commit -m"
alias gpu="git push"
alias gf="git fetch && git pull"
alias gb="git checkout -b"
alias glog="git log --oneline --graph --all --decorate"
alias gdiff="git diff --color | diff-so-fancy"

# General
alias c="clear && printf '\e[3J'"
alias la='ls -lAh'
alias ll='ls -l'
alias l='ls -lah'
alias lsa='ls -lah'
alias ls='ls -a -1 --color=auto'
alias md='mkdir -p'
alias _='sudo '

# Navigation
alias 1='cd -1'
alias 2='cd -2'
alias 3='cd -3'
alias 4='cd -4'
alias 5='cd -5'
alias 6='cd -6'
alias 7='cd -7'
alias 8='cd -8'
alias 9='cd -9'
alias ...='../..'
alias ....='../../..'
alias .....='../../../..'
alias ......='../../../../..'

# Grep
alias egrep='grep -E'
alias fgrep='grep -F'

# Git shorthand
alias g=git

# Docker
alias dcu="docker compose up"
alias dcd="docker compose down"
alias dcb="docker compose build"
alias dcl="docker compose logs"
alias dps="docker ps"
alias dpa="docker ps -a"
alias drm="docker rm"
alias drmi="docker rmi"

# NNN file manager
export NNN_TRASH="trash"
export NNN_COLORS="2136"
# export NNN_OPENER=nuke

n () {
  [ "${NNNLVL:-0}" -eq 0 ] || { echo "nnn is already running"; return; }
  export NNN_TMPFILE="${XDG_CONFIG_HOME:-$HOME/.config}/nnn/.lastd"
  export NNN_FIFO=/tmp/nnn.fifo
  export NNN_PLUG='d:fzcd;'
  export NNN_BMS="h:$HOME;d:$HOME/Downloads;D:$HOME/Documents;"
  command nnn -xR "$@"
  [ ! -f "$NNN_TMPFILE" ] || { . "$NNN_TMPFILE"; rm -f "$NNN_TMPFILE" > /dev/null; }
}

# --- PNPM ---
export PNPM_HOME="/Users/klestlazaj/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac

# --- NIX ---
if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then
  . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
fi

# --- BUN ---
[ -s "/Users/klestlazaj/.bun/_bun" ] && source "/Users/klestlazaj/.bun/_bun"
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# --- NVM (lazy) ---
export NVM_DIR="$HOME/.nvm"
_load_nvm() {
  unset -f nvm node npm npx yarn pnpm
  [ -s "$NVM_DIR/nvm.sh" ] && source "$NVM_DIR/nvm.sh"
  [ -s "$NVM_DIR/bash_completion" ] && source "$NVM_DIR/bash_completion"
}
nvm()  { _load_nvm; nvm "$@" }
node() { _load_nvm; node "$@" }
npm()  { _load_nvm; npm "$@" }
npx()  { _load_nvm; npx "$@" }
yarn() { _load_nvm; yarn "$@" }
pnpm() { _load_nvm; pnpm "$@" }

# --- DIRENV ---
eval "$(direnv hook zsh)"

# --- SDKMAN (lazy, must be last) ---
export SDKMAN_DIR="$HOME/.sdkman"
sdk() {
  unset -f sdk
  [[ -s "$SDKMAN_DIR/bin/sdkman-init.sh" ]] && source "$SDKMAN_DIR/bin/sdkman-init.sh"
  sdk "$@"
}
