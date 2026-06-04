#!/bin/bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIGS_DIR="$REPO_DIR/configs"
CONFIG_DEST="$HOME/.config"

CONFIG_DIRS=(
    hypr
    waybar
    walker
    omarchy
    swayosd
    autostart
    environment.d
    ghostty
    alacritty
    nvim
    tmux
    lazygit
    lazydocker
    git
    btop
    fastfetch
    mise
)

CONFIG_FILES=(
    starship.toml
    mimeapps.list
)

if [ ! -d "$CONFIGS_DIR" ]; then
    echo "Error: $CONFIGS_DIR not found. Are you running from the repo root?"
    exit 1
fi

echo "Restoring configs from $CONFIGS_DIR"
echo "---"

mkdir -p "$CONFIG_DEST"

for dir in "${CONFIG_DIRS[@]}"; do
    src="$CONFIGS_DIR/.config/$dir"
    dest="$CONFIG_DEST/$dir"
    if [ -d "$src" ]; then
        mkdir -p "$dest"
        rsync -a --delete "$src/" "$dest/"
        echo "  restored .config/$dir"
    else
        echo "  skipped  .config/$dir (not in backup)"
    fi
done

for file in "${CONFIG_FILES[@]}"; do
    src="$CONFIGS_DIR/.config/$file"
    dest="$CONFIG_DEST/$file"
    if [ -f "$src" ]; then
        cp "$src" "$dest"
        echo "  restored .config/$file"
    else
        echo "  skipped  .config/$file (not in backup)"
    fi
done

for rc in .zshrc .bashrc; do
    if [ -f "$CONFIGS_DIR/$rc" ]; then
        cp "$CONFIGS_DIR/$rc" "$HOME/$rc"
        echo "  restored $rc"
    fi
done

# System Configurations (udev rules, etc.)
SYSTEM_UDEV_SRC="$CONFIGS_DIR/system/udev/rules.d"
SYSTEM_UDEV_DEST="/etc/udev/rules.d"

if [ -d "$SYSTEM_UDEV_SRC" ] && [ "$(ls -A "$SYSTEM_UDEV_SRC")" ]; then
    echo "Restoring system udev rules to $SYSTEM_UDEV_DEST (requires sudo)..."
    sudo mkdir -p "$SYSTEM_UDEV_DEST"
    sudo rsync -a --delete "$SYSTEM_UDEV_SRC/" "$SYSTEM_UDEV_DEST/"
    echo "Reloading udev rules..."
    sudo udevadm control --reload-rules
    sudo udevadm trigger
    echo "  restored system/udev/rules.d"
fi

echo "---"
echo "Done."
echo ""
echo "Next steps on a new machine:"
echo "  1. Install omarchy: https://github.com/basecamp/omarchy"
echo "  2. Run omarchy setup to restore mako/waybar theming (managed by omarchy, not this backup)"
echo "  3. Re-authenticate any credential helpers in ~/.config/git/config"
