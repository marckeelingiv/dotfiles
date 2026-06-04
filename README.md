# config-backup

Snapshots of my Arch Linux + Omarchy desktop configs. Clone this repo on a new machine to restore the full setup.

## Backup (current machine)

```bash
./backup.sh
git add -A
git commit -m "chore: backup $(date +%Y-%m-%d)"
git push
```

> Before committing, check `~/.config/git/config` for any inline credentials — those should not be committed.

Managed config directories are restored as exact snapshots, so files removed from the backup will also be removed on restore.

## Restore (new machine)

### 1. Install Omarchy first

```bash
curl -s https://omarchy.com/install | bash
```

Omarchy sets up the base Hyprland environment and its own theme system (waybar colors, mako, etc.).

### 2. Clone this repo

```bash
git clone <your-repo-url> ~/dev/config-backup
```

### 3. Run restore

```bash
cd ~/dev/config-backup
./restore.sh
```

### 4. Re-authenticate git

Re-enable your preferred Git credential helper on the new machine. This backup tracks the helper configuration, but you still need to log back in locally.

## What's backed up

| Config | Path |
|--------|------|
| Hyprland | `~/.config/hypr/` |
| Waybar | `~/.config/waybar/` |
| Walker | `~/.config/walker/` |
| Omarchy user config | `~/.config/omarchy/` |
| Swayosd | `~/.config/swayosd/` |
| Autostart | `~/.config/autostart/` |
| Environment | `~/.config/environment.d/` |
| Ghostty | `~/.config/ghostty/` |
| Alacritty | `~/.config/alacritty/` |
| Neovim | `~/.config/nvim/` |
| Tmux | `~/.config/tmux/` |
| Lazygit | `~/.config/lazygit/` |
| Lazydocker | `~/.config/lazydocker/` |
| Git | `~/.config/git/` |
| Btop | `~/.config/btop/` |
| Fastfetch | `~/.config/fastfetch/` |
| Mise | `~/.config/mise/` |
| Starship | `~/.config/starship.toml` |
| Mimeapps | `~/.config/mimeapps.list` |
| Shell rc files | `~/.bashrc`, `~/.zshrc` (when present) |
| System udev rules | `/etc/udev/rules.d/` (requires `sudo` for restore) |

## What's NOT backed up

- `~/.config/mako/` — managed by omarchy's theme system; restored automatically by omarchy
- `~/.ssh/` — private keys (back up separately and securely)
- Browser profiles — too large and app-managed
