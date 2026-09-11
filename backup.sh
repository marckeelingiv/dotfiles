#!/bin/bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIGS_DIR="$REPO_DIR/configs"

# These paths contain authentication, caches, conversation history, databases,
# and generated dependencies rather than portable configuration.
RSYNC_EXCLUDES=(
    --exclude='.git/'
    --exclude='node_modules/'
    --exclude='__pycache__/'
    --exclude='.cache/'
    --exclude='cache/'
    --exclude='Cache/'
    --exclude='Crashpad/'
    --exclude='CachedData/'
    --exclude='CachedConfigurations/'
    --exclude='CachedExtensionVSIXs/'
    --exclude='CachedProfilesData/'
    --exclude='Code Cache/'
    --exclude='GPUCache/'
    --exclude='DawnGraphiteCache/'
    --exclude='DawnWebGPUCache/'
    --exclude='blob_storage/'
    --exclude='logs/'
    --exclude='log/'
    --exclude='history/'
    --exclude='sessions/'
    --exclude='History/'
    --exclude='workspaceStorage/'
    --exclude='globalStorage/'
    --exclude='Local Storage/'
    --exclude='Session Storage/'
    --exclude='IndexedDB/'
    --exclude='Cookies*'
    --exclude='cookie'
    --exclude='*.cookie'
    --exclude='Singleton*'
    --exclude='Trust Tokens*'
    --exclude='Shared Dictionary/'
    --exclude='SharedStorage*'
    --exclude='DIPS*'
    --exclude='WebStorage/'
    --exclude='auth.json'
    --exclude='credentials*'
    --exclude='*credential*'
    --exclude='*token*'
    --exclude='*oauth*'
    --exclude='*secret*'
    --exclude='*api_key*'
    --exclude='*apikey*'
    --exclude='*.pem'
    --exclude='*.key'
    --exclude='*.p12'
    --exclude='*.kdbx'
    --exclude='*.sqlite*'
    --exclude='*.db*'
    --exclude='*.log'
    --exclude='*.tmp'
    --exclude='*.jsonl'
    --exclude='.tmp/'
    --exclude='tmp/'
    --exclude='1Password/'
    --exclude='Bitwarden/'
    --exclude='Signal/'
    --exclude='BraveSoftware/'
    --exclude='chromium/'
    --exclude='chromium-headless/'
    --exclude='google-chrome*/'
    --exclude='microsoft-edge*/'
    --exclude='vivaldi*/'
    --exclude='zen/'
    --exclude='Cursor/'
    --exclude='VSCodium/'
    --exclude='Codex/'
    --exclude='gh/'
    --exclude='gcloud/'
    --exclude='doctl/'
    --exclude='configstore/'
    --exclude='.android/avd/'
    --exclude='antigravity*/'
    --exclude='backups/'
    --exclude='backup/'
    --exclude='file-history/'
    --exclude='paste-cache/'
    --exclude='plans/'
    --exclude='projects/'
    --exclude='shell-snapshots/'
    --exclude='shell_snapshots/'
    --exclude='tasks/'
    --exclude='packages/'
    --exclude='generated_images/'
    --exclude='models_cache.json'
    --exclude='tools/'
    --exclude='*.asar'
    --exclude='*.lock'
    --exclude='*.pid'
    --exclude='*.dmp'
    --exclude='DevToolsActivePort'
    --exclude='Network Persistent State'
    --exclude='TransportSecurity'
    --exclude='Dictionaries/'
    --exclude='event-log-metadata/'
    --exclude='draftsRecover/'
    --exclude='workspace/'
    --exclude='app_storage.json'
    --exclude='machineid'
    --exclude='id'
    --exclude='installation_id'
    --exclude='google_accounts.json'
    --exclude='projects.json'
    --exclude='trust.json'
    --exclude='session.json'
    --exclude='.codex-global-state.json'
    --exclude='.codex-global-state.json.bak'
    --exclude='Preferences'
    --exclude='ambient-suggestions/'
    --exclude='tui-thread-reference-capabilities/'
    --exclude='state.json'
    --exclude='trustedFolders.json'
    --exclude='obsidian/[0-9a-f]*.json'
    --exclude='.android/studio/agent/conversations/'
    --exclude='Google/AndroidStudio*/options/recentProjects.xml'
)

HOME_CONFIG_DIRS=(
    .agents
    .claude
    .codex
    .gemini
    .pi
)

sync_snapshot() {
    local src="$1"
    local dest="$2"
    local extra_excludes=()

    case "$src" in
        "$HOME/.claude"|"$HOME/.codex") extra_excludes+=(--exclude='plugins/') ;;
        "$HOME/.config") extra_excludes+=(
            --exclude='lightdash/'
            --exclude='Google/AndroidStudio*/options/other.xml'
            --exclude='Google/AndroidStudio*/options/trusted-paths.xml'
        ) ;;
        "$HOME/.gemini") extra_excludes+=(--exclude='config/config.json') ;;
    esac

    mkdir -p "$dest"
    rsync -a --delete --delete-excluded "${RSYNC_EXCLUDES[@]}" "${extra_excludes[@]}" "$src/" "$dest/"
}

echo "Backing up portable configuration to $CONFIGS_DIR"
echo "---"

sync_snapshot "$HOME/.config" "$CONFIGS_DIR/.config"
echo "  synced  .config"

for dir in "${HOME_CONFIG_DIRS[@]}"; do
    src="$HOME/$dir"
    dest="$CONFIGS_DIR/home/$dir"
    if [ -d "$src" ]; then
        sync_snapshot "$src" "$dest"
        echo "  synced  $dir"
    else
        echo "  skipped $dir (not found)"
    fi
done

for rc in .zshrc .bashrc .profile .XCompose; do
    if [ -f "$HOME/$rc" ]; then
        cp --dereference "$HOME/$rc" "$CONFIGS_DIR/home/$rc"
        echo "  synced  $rc"
    fi
done

SYSTEM_UDEV_SRC="/etc/udev/rules.d"
SYSTEM_UDEV_DEST="$CONFIGS_DIR/system/udev/rules.d"

if [ -d "$SYSTEM_UDEV_SRC" ]; then
    mkdir -p "$SYSTEM_UDEV_DEST"
    rsync -a --delete --copy-links "$SYSTEM_UDEV_SRC/" "$SYSTEM_UDEV_DEST/"
    echo "  synced  system/udev/rules.d"
else
    echo "  skipped system/udev/rules.d (not found)"
fi

echo "---"
echo "Done. Review git diff before committing:"
echo "  cd $REPO_DIR && git diff --stat"
