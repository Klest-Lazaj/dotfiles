# Klest's Dotfiles

Personal macOS dotfiles for zsh, skhd, yabai, sketchybar, borders, Ghostty, Starship, btop.

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
- applies low-animation macOS defaults
- backs up existing files to `~/.dotfiles-backup/<timestamp>`
- starts yabai, skhd, sketchybar, and borders

For linking only, without installing packages:

```sh
./link.sh
```

To apply only the macOS animation defaults on an existing machine:

```sh
./macos-defaults.sh
```

## Included

- `home/.zshrc`
- `home/.zprofile`
- `home/.skhdrc`
- `home/.zsh/completions`
- `macos-defaults.sh`
- `config/yabai`
- `config/sketchybar`
- `config/borders`
- `config/ghostty`
- `config/starship.toml`
- `config/btop`

## Notes

- The current sketchybar helper binary is intentionally excluded. It is rebuilt from source by the sketchybar config.
- Credentials, app caches, and generated machine state are intentionally excluded.
- Some macOS permissions still need to be granted manually on a fresh machine, especially Accessibility permissions for yabai/skhd/sketchybar.
