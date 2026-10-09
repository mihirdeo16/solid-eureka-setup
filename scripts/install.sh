#!/usr/bin/env bash
# install.sh — install the terminal-theme LaunchAgent so Apple Terminal follows
# macOS light/dark automatically.
#
# What it does:
#   1. Substitutes {{SCRIPT}} and {{HOME}} in
#      launchd/com.md.terminal-theme.plist.template with real absolute paths.
#   2. Writes the result to ~/Library/LaunchAgents/com.md.terminal-theme.plist.
#   3. (Re)loads it with launchctl so it runs at login, on appearance changes,
#      and on a 5-minute safety-net timer.
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
esc_script=${SCRIPT//&/\\&}; esc_script=${esc_script//|/\\|}
esc_home=${HOME//&/\\&};     esc_home=${esc_home//|/\\|}
sed -e "s|{{SCRIPT}}|${esc_script}|g" -e "s|{{HOME}}|${esc_home}|g" \
  "$TEMPLATE" > "$PLIST"

# Reload cleanly: bootout any old instance, then bootstrap the new one.
launchctl bootout "$DOMAIN/$LABEL" 2>/dev/null || true
launchctl bootstrap "$DOMAIN" "$PLIST"
launchctl kickstart -k "$DOMAIN/$LABEL"

echo "Installed $LABEL → $PLIST"
echo "Runs terminal-theme.sh at login, on appearance change, and every 5 min."
