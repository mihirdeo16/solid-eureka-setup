#!/usr/bin/env bash
# terminal-theme.sh — switch Apple Terminal between the two Rose Pine profiles.
#
# Usage:
#   terminal-theme.sh            # auto: match the current macOS appearance
#   terminal-theme.sh auto       # same as above
#   terminal-theme.sh dark       # force Rose Pine (dark)
#   terminal-theme.sh light      # force Rose Pine Dawn (light)
#
# "auto" is what the launchd agent runs on a timer so Terminal follows
# macOS light/dark (including macOS's own sunrise/sunset "Auto" appearance).
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

# Never LAUNCH Terminal just to theme it — matters for the scheduled agent.
if ! pgrep -x Terminal >/dev/null 2>&1; then
  exit 0
fi

/usr/bin/osascript <<OSA
tell application "Terminal"
  set default settings to settings set "$profile"
  set startup settings to settings set "$profile"
  repeat with w in windows
    try
      repeat with t in tabs of w
        set current settings of t to settings set "$profile"
      end repeat
    end try
  end repeat
end tell
OSA

echo "Terminal theme → $profile ($mode)"
