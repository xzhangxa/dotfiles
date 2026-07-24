#!/bin/bash

set -euo pipefail

# shellcheck source=lib_common.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib_common.sh"

common_preamble

echo "=== Install necessary packages ==="
sudo -E apt-get update
sudo -E apt-get install -y \
            aptitude apt-file openssh-server curl wget rsync trash-cli unzip \
            git tmux zsh htop btop clang-format cloc bear \
            build-essential gdb cmake cmake-curses-gui meson pkgconf \
            fuse3 command-not-found ranger

sudo -E apt-file update

copy_config_files

setup_gdb

setup_fzf

setup_zsh

echo "=== Setup neovim and plugins ==="
wget https://github.com/neovim/neovim/releases/download/stable/nvim-linux-x86_64.appimage -O ~/.local/bin/nvim
chmod +x ~/.local/bin/nvim
install_nvim_config

echo "=== Setup lazygit ==="
LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/download/v${LAZYGIT_VERSION}/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
tar xf lazygit.tar.gz lazygit
mv lazygit ~/.local/bin
install_lazygit_config

setup_uv

setup_rust

goodbye
