# config-backup

Portable Arch Linux, Omarchy, desktop, and AI-tool configuration snapshots. Clone this repo on a new machine to restore reusable settings without copying credentials or machine-specific runtime state.

## Backup (current machine)

```bash
./backup.sh
git add -A
git commit -m "chore: backup $(date +%Y-%m-%d)"
git push
```

Before committing, review the diff. The backup script excludes credentials, browser profiles, caches, sessions, databases, logs, and generated dependencies. Restore does not delete destination-only files, so existing authentication and app state are retained.

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

### 4. Re-authenticate services

Sign in again to Git, AI providers, cloud CLIs, browsers, and password managers. Their credentials are intentionally not stored in this repository.

## What's backed up

- All portable settings in `~/.config/`, including desktop, terminal, editor, and application configuration.
- AI-tool configuration in `~/.agents/`, `~/.antigravitycli/`, `~/.claude/`, `~/.codex/`, `~/.gemini/`, and `~/.pi/`.
- Shell configuration: `~/.bashrc`, `~/.profile`, `~/.zshrc`, and `~/.XCompose` when present.
- System udev rules in `/etc/udev/rules.d/`.

## What's excluded

- Credentials, tokens, API keys, certificates, and authentication databases.
- `~/.bash_profile`, because it contains a DigitalOcean personal-access token on this machine.
- Browser and password-manager profiles.
- Caches, logs, sessions, history, workspace state, databases, and generated dependencies.
- `~/.ssh/` and all other non-configuration home directories.
