#!/bin/bash

set -euo pipefail

# shellcheck source=lib_common.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib_common.sh"

common_preamble

echo "=== Install necessary packages ==="
# /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
brew update
brew install -y \
        curl wget rsync trash-cli unzip coreutils \
        git tmux zsh htop btop clang-format cloc bear \
        gdb cmake meson pkg-config ranger

brew install --cask mos
brew install --cask font-terminess-ttf-nerd-font
brew install --cask ghostty
brew install --cask karabiner-elements

mkdir -p ~/.config/ghostty
mkdir -p ~/.config/karabiner
cp "$SRC_DIR"/desktop/config.ghostty ~/.config/ghostty/
cp "$SRC_DIR"/desktop/karabiner.json ~/.config/karabiner/

copy_config_files

setup_gdb

setup_fzf

setup_zsh

echo "=== Setup neovim and plugins ==="
brew install -y neovim
install_nvim_config

echo "=== Setup lazygit ==="
brew install -y lazygit
install_lazygit_config

setup_uv

setup_rust

goodbye
