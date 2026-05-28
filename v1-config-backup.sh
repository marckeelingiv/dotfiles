#!/bin/bash
# Superseded by backup.sh (rsync/copy approach) and restore.sh
# This script used GNU Stow (move + symlink) which has been replaced.
# Use:  ./backup.sh   to snapshot configs into configs/
#       ./restore.sh  to restore on a new machine
exit 0

# ==========================================
# Comprehensive Arch + Omarchy Backup Script
# ==========================================

# Your GitHub Repository URL (Change this!)
REPO_URL="git@github.com:yourusername/omarchy-dotfiles.git"
DOTFILES_DIR="$HOME/.dotfiles"

echo "🚀 Starting Comprehensive Dotfiles Backup..."

# 1. Ensure dependencies are installed
if ! command -v stow &> /dev/null; then
    echo "📦 Stow not found. Installing GNU Stow..."
    sudo pacman -S --noconfirm stow
fi

if ! command -v git &> /dev/null; then
    echo "📦 Git not found. Installing Git..."
    sudo pacman -S --noconfirm git
fi

# 2. Define the exact configurations to track based on your system
# Core Desktop & Window Manager
DESKTOP_DIRS=("hypr" "waybar" "walker" "mako" "swayosd" "omarchy" "autostart" "environment.d")

# Terminal Emulators & System Monitoring
TERMINAL_DIRS=("alacritty" "foot" "ghostty" "kitty" "btop" "fastfetch")

# Development & Infrastructure
DEV_DIRS=("lazydocker" "lazygit" "nvim" "tmux" "mise")

# Standalone configuration files inside ~/.config
CONFIG_FILES=("starship.toml" "mimeapps.list")

# 3. Create the organized directory structures
echo "📁 Creating organized dotfiles directories..."
mkdir -p "$DOTFILES_DIR/desktop/.config"
mkdir -p "$DOTFILES_DIR/terminal/.config"
mkdir -p "$DOTFILES_DIR/dev/.config"
mkdir -p "$DOTFILES_DIR/shell/.config"

# 4. Helper function to safely move directories
move_config_dir() {
    local dir_name=$1
    local target_pkg=$2
    local source_path="$HOME/.config/$dir_name"
    local dest_path="$DOTFILES_DIR/$target_pkg/.config/"

    if [ -d "$source_path" ] && [ ! -L "$source_path" ]; then
        mv "$source_path" "$dest_path"
        echo "  -> Moved $dir_name to $target_pkg/"
    fi
}

# Helper function to safely move individual files
move_config_file() {
    local file_name=$1
    local target_pkg=$2
    local source_path="$HOME/.config/$file_name"
    local dest_path="$DOTFILES_DIR/$target_pkg/.config/"

    if [ -f "$source_path" ] && [ ! -L "$source_path" ]; then
        mv "$source_path" "$dest_path"
        echo "  -> Moved $file_name to $target_pkg/"
    fi
}

# 5. Execute the moves
echo "🚚 Migrating configurations..."

for dir in "${DESKTOP_DIRS[@]}"; do move_config_dir "$dir" "desktop"; done
for dir in "${TERMINAL_DIRS[@]}"; do move_config_dir "$dir" "terminal"; done
for dir in "${DEV_DIRS[@]}"; do move_config_dir "$dir" "dev"; done
for file in "${CONFIG_FILES[@]}"; do move_config_file "$file" "shell"; done

# Handle the root .bashrc separately
if [ -f "$HOME/.bashrc" ] && [ ! -L "$HOME/.bashrc" ]; then
    mv "$HOME/.bashrc" "$DOTFILES_DIR/shell/"
    echo "  -> Moved ~/.bashrc to shell/"
fi

# 6. Execute GNU Stow to recreate the symlinks
echo "🔗 Creating symlinks with Stow..."
cd "$DOTFILES_DIR" || exit

# Stow maps everything from these package folders back to ~
stow desktop
stow terminal
stow dev
stow shell

# 7. Initialize Git and Push to GitHub
echo "🐙 Initializing Git repository..."
if [ ! -d ".git" ]; then
    git init
    git branch -M main
    git remote add origin "$REPO_URL"
fi

echo "📝 Committing changes..."
git add .
git commit -m "chore: comprehensive backup of desktop, dev, and terminal configs"

echo "☁️ Pushing to GitHub..."
git push -u origin main

echo "✅ Backup complete! Your development environment and Omarchy setup are now securely tracked."