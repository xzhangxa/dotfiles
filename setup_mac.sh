#!/bin/bash

set -euo pipefail

SRC_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

mkdir -p ~/.local/bin
mkdir -p ~/.config
mkdir -p /tmp/zx_setup
cd /tmp/zx_setup

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

echo "=== Copy config files ==="
cp "$SRC_DIR"/gitconfig ~/.gitconfig
cp "$SRC_DIR"/tmux.conf ~/.tmux.conf
cp "$SRC_DIR"/dgdb ~/.local/bin

echo "=== Setup GDB ==="
wget https://raw.githubusercontent.com/cyrus-and/gdb-dashboard/master/.gdbinit -O ~/.gdbinit
mkdir -p ~/.gdbinit.d
cp "$SRC_DIR"/gdb_dashboard ~/.gdbinit.d/dashboard

echo "=== Setup fzf ==="
if [ -d ~/.fzf ]; then
    rm -rf ~/.fzf
fi
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
~/.fzf/install --all --no-fish

echo "=== Setup zsh ==="
if [ -d ~/.zsh-plugins ]; then
    rm -rf ~/.zsh-plugins/
fi
mkdir -p ~/.zsh-plugins/omz
curl -sS https://starship.rs/install.sh | sh -s -- -y -b ~/.local/bin
git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.zsh-plugins/zsh-syntax-highlighting
wget -P ~/.zsh-plugins/omz/ https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/refs/heads/master/plugins/extract/extract.plugin.zsh
wget -P ~/.zsh-plugins/omz/ https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/refs/heads/master/plugins/command-not-found/command-not-found.plugin.zsh
wget -P ~/.zsh-plugins/omz/ https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/refs/heads/master/plugins/colored-man-pages/colored-man-pages.plugin.zsh
cp "$SRC_DIR"/zshrc ~/.zshrc
cp "$SRC_DIR"/starship.toml ~/.config/starship.toml

echo "=== Setup neovim and plugins ==="
brew install -y neovim
mkdir -p ~/.config/nvim
rsync -a "$SRC_DIR"/nvim/ ~/.config/nvim/

echo "=== Setup lazygit ==="
brew install -y lazygit
mkdir -p ~/.config/lazygit
cp "$SRC_DIR"/lazygit.yml ~/.config/lazygit/config.yml

echo "=== Setup uv ==="
curl -LsSf https://astral.sh/uv/install.sh | sh

echo "=== Setup rust and tools from cargo ==="
# if rustup is slow:
#   export RUSTUP_DIST_SERVER=https://mirrors.ustc.edu.cn/rust-static
#   export RUSTUP_UPDATE_ROOT=https://mirrors.ustc.edu.cn/rust-static/rustup
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --no-modify-path
source ~/.cargo/env
cargo install ripgrep bat eza fd-find tree-sitter-cli
rustup component add rust-analyzer

echo "remember to re-login."
echo "Bye Bye."
