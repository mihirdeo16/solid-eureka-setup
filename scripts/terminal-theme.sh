#!/usr/bin/env bash
# terminal-theme.sh — switch Apple Terminal between the two Rose Pine profiles.
#
# Usage:
#   terminal-theme.sh            # auto: match the current macOS appearance
#   terminal-theme.sh auto       # same as above
#   terminal-theme.sh dark       # force Rose Pine (dark)
#   terminal-theme.sh light      # force Rose Pine Dawn (light)
#
# "auto" is what the launchd agent runs so Terminal follows macOS light/dark
# (including macOS's own sunrise/sunset "Auto" appearance).
set -euo pipefail

DARK_PROFILE="Rose Pine"
LIGHT_PROFILE="Rose Pine Dawn"

mode="${1:-auto}"

if [[ "$mode" == "auto" ]]; then
  # `defaults read -g AppleInterfaceStyle` prints "Dark" in dark mode and
  # errors (key absent) in light mode.
  if defaults read -g AppleInterfaceStyle >/dev/null 2>&1; then
    mode="dark"
  else
    mode="light"
  fi
fi

case "$mode" in
  dark)  profile="$DARK_PROFILE"  ;;
  light) profile="$LIGHT_PROFILE" ;;
  *) echo "usage: $(basename "$0") [auto|dark|light]" >&2; exit 2 ;;
esac

# The agent fires on a timer as well as on appearance changes, so most runs have
# nothing to do. Bail out early rather than waking Terminal every time. An
# explicit `dark`/`light` always applies, which is also the manual override.
STATE_FILE="${XDG_STATE_HOME:-$HOME/.local/state}/terminal-theme.mode"
mkdir -p "$(dirname "$STATE_FILE")"
if [[ "${1:-auto}" == "auto" && -r "$STATE_FILE" && "$(cat "$STATE_FILE")" == "$mode" ]]; then
  exit 0
fi

# Terminal rewrites its prefs on quit, so while it's running the profile has to
# be set through AppleScript; only when it's closed is `defaults` authoritative.
# Note: `pgrep -x Terminal` does NOT work here — the process's comm is the full
# executable path, so the exact-match never fires and every run wrongly took the
# `defaults` branch. AppleScript's `is running` is authoritative and, unlike most
# commands sent to an app, does not launch it.
if [[ "$(/usr/bin/osascript -e 'application "Terminal" is running' 2>/dev/null)" == "true" ]]; then
  # Window bounds are saved and restored around the switch: assigning a tab's
  # settings otherwise resizes the window to the profile's row/column count.
  /usr/bin/osascript <<OSA
tell application "Terminal"
  set targetSettings to settings set "$profile"
  set default settings to targetSettings
  set startup settings to targetSettings
  repeat with w in windows
    try
      set savedBounds to bounds of w
      repeat with t in tabs of w
        set current settings of t to targetSettings
      end repeat
      set bounds of w to savedBounds
    end try
  end repeat
end tell
OSA
else
  # Never LAUNCH Terminal just to theme it — matters for the scheduled agent.
  # Writing the prefs directly is enough for the next launch to come up right.
  defaults write com.apple.Terminal "Default Window Settings" -string "$profile"
  defaults write com.apple.Terminal "Startup Window Settings" -string "$profile"
fi

printf '%s\n' "$mode" > "$STATE_FILE"
echo "$(date '+%Y-%m-%d %H:%M:%S') Terminal theme → $profile ($mode)"
