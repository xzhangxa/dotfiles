#!/bin/bash

set -euo pipefail

SRC_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

curl -fsSL https://opencode.ai/install | bash

mkdir -p ~/.config/opencode
cp -r opencode/* ~/.config/opencode/
touch ~/.config/nvim/.opencode-enabled

~/.opencode/bin/opencode completion >> ~/.zshrc
