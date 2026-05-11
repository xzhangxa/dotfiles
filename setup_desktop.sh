#!/bin/bash

set -euo pipefail

SRC_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

mkdir -p /tmp/zx_setup
cd /tmp/zx_setup

sudo -E apt-get install -y keyd
sudo mkdir -p /etc/libinput /etc/keyd
sudo cp "$SRC_DIR"/desktop/keyd-default.conf /etc/keyd/
sudo cp "$SRC_DIR"/desktop/local-overrides.quirks /etc/libinput/

sudo -E apt-get install -y wl-clipboard

sudo -E apt-get install -y fcitx5-pinyin
rsync -a "$SRC_DIR"/desktop/fcitx5/ ~/.config/fcitx5/

wget https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/Terminus.zip
unzip -d Terminus Terminus.zip
mkdir -p ~/.local/share/fonts/
cp Terminus/TerminessNerdFontMono-*.ttf ~/.local/share/fonts/
fc-cache -f

OS_ID=""
if [ -f /etc/os-release ]; then
    OS_ID=$(awk -F= '/^ID=/{gsub(/"/, "", $2); print tolower($2)}' /etc/os-release)
fi

if [ "$OS_ID" = "ubuntu" ]; then
    sudo snap install --classic ghostty
else
    curl -sS https://debian.griffo.io/EA0F721D231FDD3A0A17B9AC7808B4DD62C41256.asc | sudo gpg --dearmor --yes -o /etc/apt/trusted.gpg.d/debian.griffo.io.gpg
    echo "deb https://debian.griffo.io/apt $(lsb_release -sc 2>/dev/null) main" | sudo tee /etc/apt/sources.list.d/debian.griffo.io.list
    sudo -E apt-get update
    sudo -E apt-get install ghostty
fi
mkdir -p ~/.config/ghostty
cp "$SRC_DIR"/desktop/config.ghostty ~/.config/ghostty/

dconf load /org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/ < "$SRC_DIR"/desktop/gnome_custom_shortcuts.dconf

# Get current GNOME Shell major version (e.g., "49" from "49.5")
GNOME_VERSION=""
if command -v gnome-shell &>/dev/null; then
    GNOME_VERSION=$(gnome-shell --version 2>/dev/null | sed 's/[^0-9]*\([0-9]*\).*/\1/' || true)
fi

array=(
    dash-to-panel@jderose9.github.com
    kimpanel@kde.org
    tilingshell@ferrarodomenico.com
    appindicatorsupport@rgcjonas.gmail.com
)

for ext in "${array[@]}"; do
    echo "Installing: $ext"

    ext_info=$(curl -Lfs "https://extensions.gnome.org/extension-info/?uuid=${ext}" 2>/dev/null || true)

    if [ -z "$ext_info" ] || [ "$ext_info" = "Not Found" ]; then
        echo "Extension not found: $ext"
        continue
    fi

    # Try to get version for current GNOME Shell version, fallback to latest
    version=""
    if [ -n "$GNOME_VERSION" ]; then
        version=$(echo "$ext_info" | jq -r --arg v "$GNOME_VERSION" '.shell_version_map[$v].version // empty')
    fi

    if [ -z "$version" ]; then
        version=$(echo "$ext_info" | jq -r '[.shell_version_map[] | .version] | max')
    fi

    if [ -z "$version" ] || [ "$version" = "null" ]; then
        echo "No version found for: $ext"
        continue
    fi

    # Construct direct download URL (remove @ from UUID)
    download_url="https://extensions.gnome.org/extension-data/${ext//@/}.v${version}.shell-extension.zip"

    if ! wget -q -O "${ext}.zip" "$download_url"; then
        echo "Failed to download: $ext"
        continue
    fi

    gnome-extensions install --force "${ext}.zip"
    gnome-extensions enable "${ext}" 2>/dev/null || echo "Note: Enable ${ext} after restarting GNOME Shell (Alt+F2, type 'r')"
    rm -f "${ext}.zip"
done

dconf load /org/gnome/shell/extensions/ < "$SRC_DIR"/desktop/gnome_shell_extensions_backup.dconf
