# Dotfiles

Personal shell config files for Debian/Ubuntu and macOS. See setup scripts for details.

## Setup

- `setup_debian.sh` — Debian/Ubuntu (supports `--desktop` for laptop/WM key remaps)
- `setup_mac.sh` — macOS
- `setup_kernel_dev.sh` — kernel dev extras
- `setup_oneapi.sh` — Intel oneAPI

## Configs

- **neovim** (`init.lua`, `vscode-neovim.lua`) — v0.12 native autocomplete, auto-session, gitsigns
- **zsh** (`zshrc`) — case-insensitive completion, auto title, syntax highlighting (no oh-my-zsh)
- **tmux** (`tmux.conf`)
- **git + lazygit** (`gitconfig`, `lazygit.yml`, `git-proxy`)
- **gdb** (`dgdb`, `gdb_dashboard`)
- **starship** (`starship.toml`) — prompt with git tag support
- **keyd** (`keyd-default.conf`, `local-overrides.quirks`) — desktop key remaps

## Tools Installed

- fzf, uv (Python), ripgrep, bat, eza, fd-find
