#!/bin/bash

set -euo pipefail

# shellcheck source=lib_common.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib_common.sh"

ensure_xcode_command_line_tools() {
    if xcode-select -p >/dev/null 2>&1; then
        return
    fi

    cat >&2 <<'EOF'
Xcode Command Line Tools are required but are not installed.

Install them interactively with:
    xcode-select --install

Then re-run this script. The macOS installer for the command line tools is
GUI-based, so it cannot be automated reliably from this script.
EOF
    exit 1
}

ensure_homebrew() {
    if [ "${EUID:-$(id -u)}" -eq 0 ]; then
        echo "Do not run this script with sudo/root; Homebrew does not support it." >&2
        exit 1
    fi

    local brew_bin=""
    if command -v brew >/dev/null 2>&1; then
        brew_bin="$(command -v brew)"
    elif [ -x /opt/homebrew/bin/brew ]; then
        brew_bin=/opt/homebrew/bin/brew
    elif [ -x /usr/local/bin/brew ]; then
        brew_bin=/usr/local/bin/brew
    fi

    if [ -z "$brew_bin" ]; then
        echo "=== Homebrew not found; installing ==="
        # NONINTERACTIVE=1 suppresses the installer's own prompts. On a fresh
        # Mac the installer may still ask for sudo to create /opt/homebrew.
        local installer
        installer="$(mktemp /tmp/homebrew-install.XXXXXX)"
        if ! curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh -o "$installer"; then
            rm -f "$installer"
            echo "Failed to download the Homebrew installer." >&2
            exit 1
        fi
        if ! NONINTERACTIVE=1 /bin/bash "$installer"; then
            rm -f "$installer"
            echo "Homebrew installation failed." >&2
            exit 1
        fi
        rm -f "$installer"

        if [ -x /opt/homebrew/bin/brew ]; then
            brew_bin=/opt/homebrew/bin/brew
        elif [ -x /usr/local/bin/brew ]; then
            brew_bin=/usr/local/bin/brew
        fi
    fi

    if [ -z "$brew_bin" ]; then
        echo "Homebrew is unavailable: brew was not found in PATH, /opt/homebrew/bin, or /usr/local/bin." >&2
        exit 1
    fi

    eval "$("$brew_bin" shellenv)"

    if ! command -v brew >/dev/null 2>&1; then
        echo "Homebrew was found at $brew_bin but could not be added to PATH." >&2
        exit 1
    fi

    # Persist Homebrew in future login shells as well. The official installer
    # prints these instructions but does not edit the shell profile itself.
    local zprofile="$HOME/.zprofile"
    if ! grep -Fq "$brew_bin shellenv" "$zprofile" 2>/dev/null; then
        {
            echo
            echo '# Homebrew'
            echo "eval \"\$($brew_bin shellenv)\""
        } >> "$zprofile"
    fi
}

ensure_xcode_command_line_tools
ensure_homebrew

common_preamble

echo "=== Install necessary packages ==="
brew update
brew install -y \
        curl wget rsync unzip coreutils \
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
