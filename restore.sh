#!/bin/bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIGS_DIR="$REPO_DIR/configs"

RSYNC_EXCLUDES=(
    --exclude='.git/' --exclude='node_modules/' --exclude='__pycache__/'
    --exclude='.cache/' --exclude='cache/' --exclude='Cache/' --exclude='Crashpad/' --exclude='CachedData/'
    --exclude='CachedConfigurations/' --exclude='CachedExtensionVSIXs/' --exclude='CachedProfilesData/'
    --exclude='Code Cache/' --exclude='GPUCache/' --exclude='DawnGraphiteCache/' --exclude='DawnWebGPUCache/'
    --exclude='blob_storage/' --exclude='logs/' --exclude='log/' --exclude='history/' --exclude='sessions/' --exclude='History/'
    --exclude='workspaceStorage/' --exclude='globalStorage/' --exclude='Local Storage/' --exclude='Session Storage/'
    --exclude='IndexedDB/' --exclude='Cookies*' --exclude='cookie' --exclude='*.cookie' --exclude='Singleton*'
    --exclude='Trust Tokens*' --exclude='Shared Dictionary/' --exclude='SharedStorage*' --exclude='DIPS*' --exclude='WebStorage/'
    --exclude='auth.json' --exclude='credentials*'
    --exclude='*credential*' --exclude='*token*' --exclude='*oauth*' --exclude='*secret*' --exclude='*api_key*' --exclude='*apikey*'
    --exclude='*.pem' --exclude='*.key' --exclude='*.p12' --exclude='*.kdbx' --exclude='*.sqlite*'
    --exclude='*.db*' --exclude='*.log' --exclude='*.tmp' --exclude='*.jsonl' --exclude='.tmp/' --exclude='tmp/'
    --exclude='1Password/' --exclude='Bitwarden/' --exclude='Signal/' --exclude='BraveSoftware/'
    --exclude='chromium/' --exclude='chromium-headless/' --exclude='google-chrome*/'
    --exclude='microsoft-edge*/' --exclude='vivaldi*/' --exclude='zen/' --exclude='Cursor/'
    --exclude='VSCodium/' --exclude='Codex/' --exclude='gh/' --exclude='gcloud/' --exclude='doctl/'
    --exclude='configstore/' --exclude='antigravity*/' --exclude='backups/' --exclude='backup/' --exclude='file-history/'
    --exclude='.android/avd/'
    --exclude='paste-cache/' --exclude='plans/' --exclude='projects/' --exclude='shell-snapshots/' --exclude='shell_snapshots/'
    --exclude='tasks/' --exclude='packages/' --exclude='generated_images/' --exclude='models_cache.json'
    --exclude='tools/' --exclude='*.asar' --exclude='*.lock' --exclude='*.pid' --exclude='*.dmp'
    --exclude='DevToolsActivePort' --exclude='Network Persistent State' --exclude='TransportSecurity'
    --exclude='Dictionaries/' --exclude='event-log-metadata/' --exclude='draftsRecover/'
    --exclude='workspace/' --exclude='app_storage.json' --exclude='machineid' --exclude='id'
    --exclude='installation_id' --exclude='google_accounts.json' --exclude='projects.json'
    --exclude='trust.json' --exclude='session.json' --exclude='.codex-global-state.json'
    --exclude='.codex-global-state.json.bak'
    --exclude='Preferences' --exclude='ambient-suggestions/'
    --exclude='tui-thread-reference-capabilities/' --exclude='state.json'
    --exclude='trustedFolders.json' --exclude='obsidian/[0-9a-f]*.json'
    --exclude='.android/studio/agent/conversations/'
    --exclude='Google/AndroidStudio*/options/recentProjects.xml'
    --exclude='*.sock' --exclude='*.sock.*' --exclude='*.keystore'
    --exclude='*.bak' --exclude='*.bak.*' --exclude='*.log.previous'
)

HOME_CONFIG_DIRS=(.agents .claude .codex .gemini .pi)

restore_snapshot() {
    local src="$1"
    local dest="$2"
    local extra_excludes=()

    case "$dest" in
        "$HOME/.claude") extra_excludes+=(--exclude='plugins/') ;;
        "$HOME/.codex") extra_excludes+=(
            --exclude='plugins/'
            --exclude='app-server-control/'
            --exclude='app-server-daemon/'
            --exclude='dictation-history/'
            --exclude='ipc/'
            --exclude='node_repl/'
            --exclude='project-chatgpt-pairing/'
            --exclude='project-chatgpt-provisioning/'
            --exclude='project-metadata-locks/'
            --exclude='rollout-migrations/'
            --exclude='sqlite/'
            --exclude='thread-writer-locks/'
            --exclude='vendor_imports/'
            --exclude='visualizations/'
            --exclude='realtime-voice-continuity.json'
        ) ;;
        "$HOME/.config") extra_excludes+=(
            --exclude='lightdash/'
            --exclude='Google/AndroidStudio*/options/other.xml'
            --exclude='Google/AndroidStudio*/options/trusted-paths.xml'
            --exclude='Google/AndroidStudio*/ssl/'
            --exclude='Antigravity/Local State'
            --exclude='Antigravity/bin/'
            --exclude='browser-harness/runtime/'
            --exclude='browser-harness/version-cache.json'
            --exclude='herdr/session-snapshots/'
            --exclude='herdr/release-notes.json'
            --exclude='fcitx/dbus/'
            --exclude='ibus/bus/'
            --exclude='opencode/service.json'
            --exclude='opencode/skill-backups/'
            --exclude='stripe/'
        ) ;;
        "$HOME/.gemini") extra_excludes+=(--exclude='config/config.json') ;;
        "$HOME/.pi") extra_excludes+=(--exclude='agent/pi-subagents/last-seen-version.json') ;;
    esac

    mkdir -p "$dest"
    # Do not delete destination-only files, including credentials and app state.
    rsync -a "${RSYNC_EXCLUDES[@]}" "${extra_excludes[@]}" "$src/" "$dest/"
}

if [ ! -d "$CONFIGS_DIR" ]; then
    echo "Error: $CONFIGS_DIR not found. Are you running from the repo root?"
    exit 1
fi

echo "Restoring portable configuration from $CONFIGS_DIR"
echo "---"

if [ -d "$CONFIGS_DIR/.config" ]; then
    restore_snapshot "$CONFIGS_DIR/.config" "$HOME/.config"
    echo "  restored .config"
fi

for dir in "${HOME_CONFIG_DIRS[@]}"; do
    src="$CONFIGS_DIR/home/$dir"
    if [ -d "$src" ]; then
        restore_snapshot "$src" "$HOME/$dir"
        echo "  restored $dir"
    fi
done

for rc in .zshrc .bashrc .profile .XCompose; do
    src="$CONFIGS_DIR/home/$rc"
    if [ -f "$src" ]; then
        cp "$src" "$HOME/$rc"
        echo "  restored $rc"
    fi
done

SYSTEM_UDEV_SRC="$CONFIGS_DIR/system/udev/rules.d"
SYSTEM_UDEV_DEST="/etc/udev/rules.d"

if [ -d "$SYSTEM_UDEV_SRC" ] && [ "$(ls -A "$SYSTEM_UDEV_SRC")" ]; then
    echo "Restoring system udev rules to $SYSTEM_UDEV_DEST (requires sudo)..."
    sudo mkdir -p "$SYSTEM_UDEV_DEST"
    sudo rsync -a --delete "$SYSTEM_UDEV_SRC/" "$SYSTEM_UDEV_DEST/"
    sudo udevadm control --reload-rules
    sudo udevadm trigger
    echo "  restored system/udev/rules.d"
fi

echo "---"
echo "Done. Re-authenticate services whose credentials were intentionally excluded."
