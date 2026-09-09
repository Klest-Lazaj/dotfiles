# Klest's Dotfiles

Personal macOS dotfiles for zsh, skhd, yabai, sketchybar, borders, Ghostty, Starship, btop, and AeroSpace.

## New Mac Setup

Clone the repo, then run:

```sh
./install.sh
```

The installer:

- installs Homebrew if missing
- installs packages from `Brewfile`
- installs zinit, nvm, SDKMAN, latest Node LTS, and Homebrew OpenJDK
- symlinks configs into `$HOME`
- backs up existing files to `~/.dotfiles-backup/<timestamp>`
- starts yabai, skhd, sketchybar, and borders

For linking only, without installing packages:

```sh
./link.sh
```

## Included

- `home/.zshrc`
- `home/.zprofile`
- `home/.skhdrc`
- `home/.zsh/completions`
- `config/yabai`
- `config/sketchybar`
- `config/borders`
- `config/ghostty`
- `config/starship.toml`
- `config/btop`
- `config/aerospace`
- `legacy/sketchybar_backup`

## Notes

- The current sketchybar helper binary is intentionally excluded. It is rebuilt from source by the sketchybar config.
- Credentials, app caches, and generated machine state are intentionally excluded.
- Some macOS permissions still need to be granted manually on a fresh machine, especially Accessibility permissions for yabai/skhd/sketchybar.
