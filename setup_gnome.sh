#!/bin/bash

set -euo pipefail

SRC_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

# Get current GNOME Shell major version (e.g., "49" from "49.5")
GNOME_VERSION=""
if command -v gnome-shell &>/dev/null; then
    GNOME_VERSION=$(gnome-shell --version 2>/dev/null | sed 's/[^0-9]*\([0-9]*\).*/\1/' || true)
fi

array=( dash-to-panel@jderose9.github.com kimpanel@kde.org tilingshell@ferrarodomenico.com )

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

dconf load /org/gnome/shell/extensions/ < "$SRC_DIR"/gnome_shell_extensions_backup.dconf
