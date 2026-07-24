#!/bin/bash

# Shared setup steps used by both setup_debian.sh and setup_mac.sh.
# This is a library: it is meant to be *sourced*, not executed directly
# (hence the lib_ prefix rather than the setup_ prefix of the entrypoints).
# It resolves
# SRC_DIR to this repo and defines functions the OS-specific scripts call in
# order, interleaving their own package-manager and tool-install steps.

# Resolve the repo dir regardless of the caller's cwd. When sourced,
# BASH_SOURCE[0] points at this file, which lives at the repo root.
SRC_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

common_preamble() {
    mkdir -p ~/.local/bin
    mkdir -p ~/.config
    mkdir -p /tmp/zx_setup
    cd /tmp/zx_setup
}

copy_config_files() {
    echo "=== Copy config files ==="
    cp "$SRC_DIR"/gitconfig ~/.gitconfig
    cp "$SRC_DIR"/tmux.conf ~/.tmux.conf
    cp "$SRC_DIR"/dgdb ~/.local/bin
}

setup_gdb() {
    echo "=== Setup GDB ==="
    wget https://raw.githubusercontent.com/cyrus-and/gdb-dashboard/master/.gdbinit -O ~/.gdbinit
    mkdir -p ~/.gdbinit.d
    cp "$SRC_DIR"/gdb_dashboard ~/.gdbinit.d/dashboard
}

setup_fzf() {
    echo "=== Setup fzf ==="
    if [ -d ~/.fzf ]; then
        rm -rf ~/.fzf
    fi
    git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
    ~/.fzf/install --all --no-fish
}

setup_zsh() {
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
}

install_nvim_config() {
    mkdir -p ~/.config/nvim
    rsync -a "$SRC_DIR"/nvim/ ~/.config/nvim/
}

install_lazygit_config() {
    mkdir -p ~/.config/lazygit
    cp "$SRC_DIR"/lazygit.yml ~/.config/lazygit/config.yml
}

setup_uv() {
    echo "=== Setup uv ==="
    curl -LsSf https://astral.sh/uv/install.sh | sh
}

setup_rust() {
    echo "=== Setup rust and tools from cargo ==="
    # if rustup is slow:
    #   export RUSTUP_DIST_SERVER=https://mirrors.ustc.edu.cn/rust-static
    #   export RUSTUP_UPDATE_ROOT=https://mirrors.ustc.edu.cn/rust-static/rustup
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --no-modify-path
    source ~/.cargo/env
    cargo install ripgrep bat eza fd-find tree-sitter-cli
    rustup component add rust-analyzer
}

goodbye() {
    echo "remember to re-login."
    echo "Bye Bye."
}
