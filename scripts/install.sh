#!/usr/bin/env bash
# install.sh — install the terminal-theme LaunchAgent so Apple Terminal follows
# macOS light/dark automatically.
#
# What it does:
#   1. Substitutes {{SCRIPT}} in launchd/com.md.terminal-theme.plist.template with
#      the absolute path to scripts/terminal-theme.sh.
#   2. Writes the result to ~/Library/LaunchAgents/com.md.terminal-theme.plist.
#   3. (Re)loads it with launchctl so it runs at login and every 5 minutes.
#
# Usage:
#   ./scripts/install.sh          # install / reinstall
#   ./scripts/install.sh uninstall
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SCRIPT="$REPO/scripts/terminal-theme.sh"
TEMPLATE="$REPO/launchd/com.md.terminal-theme.plist.template"
LABEL="com.md.terminal-theme"
PLIST="$HOME/Library/LaunchAgents/$LABEL.plist"
DOMAIN="gui/$(id -u)"

uninstall() {
  launchctl bootout "$DOMAIN/$LABEL" 2>/dev/null || true
  rm -f "$PLIST"
  echo "Uninstalled $LABEL"
}

if [[ "${1:-}" == "uninstall" ]]; then
  uninstall
  exit 0
fi

[[ -f "$SCRIPT" ]]   || { echo "missing script: $SCRIPT" >&2; exit 1; }
[[ -f "$TEMPLATE" ]] || { echo "missing template: $TEMPLATE" >&2; exit 1; }

chmod +x "$SCRIPT"
mkdir -p "$HOME/Library/LaunchAgents"

# Render the template (escape & and | for sed's replacement).
esc=${SCRIPT//&/\\&}
sed "s|{{SCRIPT}}|${esc//|/\\|}|g" "$TEMPLATE" > "$PLIST"

# Reload cleanly: bootout any old instance, then bootstrap the new one.
launchctl bootout "$DOMAIN/$LABEL" 2>/dev/null || true
launchctl bootstrap "$DOMAIN" "$PLIST"
launchctl kickstart -k "$DOMAIN/$LABEL"

echo "Installed $LABEL → $PLIST"
echo "Runs terminal-theme.sh at login and every 5 minutes."
