#!/bin/bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIGS_DIR="$REPO_DIR/configs"
CONFIG_SRC="$HOME/.config"

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

mkdir -p "$CONFIGS_DIR/.config"

echo "Backing up configs to $CONFIGS_DIR"
echo "---"

for dir in "${CONFIG_DIRS[@]}"; do
    src="$CONFIG_SRC/$dir"
    dest="$CONFIGS_DIR/.config/$dir"
    if [ -d "$src" ]; then
        mkdir -p "$dest"
        rsync -a --delete --copy-links "$src/" "$dest/"
        echo "  synced  .config/$dir"
    else
        echo "  skipped .config/$dir (not found)"
    fi
done

for file in "${CONFIG_FILES[@]}"; do
    src="$CONFIG_SRC/$file"
    dest="$CONFIGS_DIR/.config/$file"
    if [ -e "$src" ]; then
        cp --dereference "$src" "$dest"
        echo "  synced  .config/$file"
    else
        echo "  skipped .config/$file (not found)"
    fi
done

for rc in .zshrc .bashrc; do
    if [ -f "$HOME/$rc" ]; then
        cp "$HOME/$rc" "$CONFIGS_DIR/$rc"
        echo "  synced  $rc"
    fi
done

echo "---"
echo "Done. Review git diff before committing:"
echo "  cd $REPO_DIR && git diff --stat"
echo ""
echo "Note: ~/.config/git/ may contain credential helpers — review before committing."
