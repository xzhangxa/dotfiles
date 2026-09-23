#!/bin/bash

set -euo pipefail

SRC_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

curl -fsSL https://opencode.ai/v2/install | bash

mkdir -p ~/.config/opencode
cp -r "$SRC_DIR"/opencode/* ~/.config/opencode/
mkdir -p ~/.config/nvim
touch ~/.config/nvim/.opencode-enabled

if ! grep -q "opencode --completions" ~/.zshrc; then
    cat >> ~/.zshrc <<'EOF'

# opencode
export PATH="$HOME/.opencode/bin:$PATH"
source <(opencode --completions zsh)
EOF
fi
