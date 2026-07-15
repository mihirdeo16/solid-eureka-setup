# workspace_setup

My macOS terminal setup — a zsh config and two Apple Terminal profiles
(Rose Pine dark + Rose Pine Dawn light) — as copy-paste steps for a fresh
machine.

## Step 1 — Zsh config

Starship prompt, autosuggestions + syntax highlighting, shared history, and a
`cat` → `bat` alias.

**Requires:** Homebrew. Install the packages (and the Nerd Font used in
step 2) first:

```sh
brew install starship zsh-autosuggestions zsh-syntax-highlighting bat
brew install --cask font-meslo-lg-nerd-font
```

**Install** (appends the config to your existing `~/.zshrc` — nothing is
replaced):

```sh
cat >> ~/.zshrc <<'EOF'

# --- History (shared across sessions, no dupes) ---
HISTFILE="$HOME/.zsh_history"
HISTSIZE=10000
SAVEHIST=10000
setopt SHARE_HISTORY HIST_IGNORE_ALL_DUPS HIST_IGNORE_SPACE

# --- Aliases ---
alias cat='bat --style=plain --paging=never'

# --- Prompt: starship ---
eval "$(starship init zsh)"

# --- Plugins (syntax-highlighting must be sourced LAST) ---
source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
EOF
```

**Apply without reopening the terminal:**

```sh
source ~/.zshrc
```

## Step 2 — Import the Terminal profiles

From the repo root, import each profile into Terminal ▸ Settings ▸ Profiles:

```sh
open "terminal/Rose Pine.terminal"
open "terminal/Rose Pine Dawn.terminal"
```

Each `open` pops up a new Terminal window using that profile — that's how
macOS imports it. You can close those extra windows afterward.

The imported profiles already set the font and size (MesloLGS Nerd Font Mono,
18 pt), so no manual font step is needed. To change either, see step 3.

## Step 3 — Font & size (optional)

Set the two variables and run — this updates both imported profiles in place
(open windows change immediately, and Terminal persists it):

```sh
FONT="MesloLGSNFM-Regular"
SIZE=10

for profile in "Rose Pine" "Rose Pine Dawn"; do
  osascript -e "tell application \"Terminal\" to set font name of settings set \"$profile\" to \"$FONT\"" \
            -e "tell application \"Terminal\" to set font size of settings set \"$profile\" to $SIZE"
done
```

Also run this if the font looks wrong after import — e.g. because the Nerd
Font was installed *after* the profiles were imported.

## Step 4 — Set the default profile (optional)

```sh
defaults write com.apple.Terminal "Default Window Settings" "Rose Pine Dawn"
defaults write com.apple.Terminal "Startup Window Settings" "Rose Pine Dawn"
```

## Reference

- [Rosé Pine palette](https://rosepinetheme.com/palette/)
- [Refactoring Guru — design patterns catalog](https://refactoring.guru/design-patterns/catalog)
