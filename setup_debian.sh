#!/bin/bash

set -e

SRC_DIR=$(cd $(dirname "${BASH_SOURCE[0]}") && pwd)

echo "=== Install necessary packages ==="
sudo -E apt-get update
sudo -E apt-get install -y \
            aptitude apt-file \
            curl wget rsync socat ranger trash-cli \
            openssh-server git tmux zsh htop unzip \
            build-essential gdb cmake cmake-curses-gui clang-format cloc \
            fuse3 libfuse2 command-not-found lsb-release

# Install this only on desktop with wayland
# sudo -E apt-get install -y wl-clipboard

sudo -E apt-file update

mkdir -p /tmp/zx_setup
cd /tmp/zx_setup

echo "=== Setup GDB ==="
wget https://raw.githubusercontent.com/cyrus-and/gdb-dashboard/master/.gdbinit -O ~/.gdbinit
mkdir -p ~/.gdbinit.d
cp "$SRC_DIR"/gdb_dashboard ~/.gdbinit.d/dashboard

echo "=== Setup oh-my-zsh ==="
if [ -d ~/.oh-my-zsh ]; then
    rm -rf ~/.oh-my-zsh
fi
sh -c "CHSH=no RUNZSH=no $(wget https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh -O -)"
if [ ! -d ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting ]; then
    git clone https://github.com/zsh-users/zsh-syntax-highlighting ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
fi
if [ ! -d ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/themes/powerlevel10k ]; then
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
fi

echo "=== Copy config files ==="
mkdir -p ~/.config/nvim
mkdir -p ~/.config/lazygit
cp "$SRC_DIR"/init.lua ~/.config/nvim/init.lua
cp "$SRC_DIR"/lazygit.yml ~/.config/lazygit/config.yml
cp "$SRC_DIR"/zshrc ~/.zshrc
cp "$SRC_DIR"/p10k.zsh ~/.p10k.zsh
cp "$SRC_DIR"/tmux.conf ~/.tmux.conf
cp "$SRC_DIR"/gitconfig ~/.gitconfig
mkdir -p ~/.local/bin
cp "$SRC_DIR"/dgdb ~/.local/bin
cp "$SRC_DIR"/git-proxy ~/.local/bin

echo "=== Setup fzf ==="
if [ -d ~/.fzf ]; then
    rm -rf ~/.fzf
fi
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
~/.fzf/install --all

echo "=== Setup neovim, vim-plug and plugins ==="
wget https://github.com/neovim/neovim/releases/download/stable/nvim-linux-x86_64.appimage -O ~/.local/bin/nvim
chmod +x ~/.local/bin/nvim

echo "=== Setup lazygit ==="
LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/download/v${LAZYGIT_VERSION}/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
tar xf lazygit.tar.gz lazygit
mv lazygit ~/.local/bin

echo "=== Setup rust and tools from cargo ==="
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs > sh.rustup.rs
sh ./sh.rustup.rs -y --no-modify-path
source ~/.cargo/env
cargo install ripgrep bat eza fd-find

echo "remember to re-login."
echo "Bye Bye."
