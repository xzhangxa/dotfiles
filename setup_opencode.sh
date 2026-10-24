#!/bin/bash

set -euo pipefail

SRC_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
ZSHRC="${ZDOTDIR:-$HOME}/.zshrc"

# Make curl-installed binaries available to this script and future shells.
export PATH="$HOME/.opencode/bin:$PATH"

if command -v opencode >/dev/null 2>&1; then
    opencode upgrade
else
    curl -fsSL https://opencode.ai/v2/install | bash -s -- --no-modify-path
fi

# Refresh managed settings without removing credentials or other local files.
mkdir -p "$CONFIG_HOME/opencode"
cp -R "$SRC_DIR/opencode/." "$CONFIG_HOME/opencode/"

mkdir -p ~/.config/nvim
touch ~/.config/nvim/.opencode-enabled

if ! grep -q "opencode --completions" "$ZSHRC" 2>/dev/null; then
    cat >> "$ZSHRC" <<'EOF'

# opencode
if [[ ! "$PATH" == *$HOME/.opencode/bin* ]]; then
  PATH="$HOME/.opencode/bin:$PATH"
fi
source <(opencode --completions zsh)
EOF
fi
