# workspace_setup

My macOS workspace setup — a zsh config, two Apple Terminal profiles
(Rose Pine dark + Rose Pine Dawn light), Automic Vault for secrets, and my AI
agent instructions and skills — as copy-paste steps for a fresh machine.

## Step 1 — Zsh config

Starship prompt, autosuggestions + syntax highlighting, shared history, and my
aliases. The aliases live in [`terminal/aliases.zsh`](terminal/aliases.zsh) and
are sourced from `~/.zshrc`, so add new ones there. The path assumes this repo
is cloned to `~/Code/workspace_setup`.

**Requires:** Homebrew. Install the packages (and the Nerd Font used in
step 2) first:

```sh
brew install starship zsh-autosuggestions zsh-syntax-highlighting bat tree
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

# --- Aliases (tracked in the workspace_setup repo) ---
ALIASES_FILE="$HOME/Code/workspace_setup/terminal/aliases.zsh"
if [[ -f "$ALIASES_FILE" ]]; then
  source "$ALIASES_FILE"
else
  echo "zshrc: aliases file not found: $ALIASES_FILE" >&2
fi
unset ALIASES_FILE

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

Only needed if you skip step 5, which manages this for you.

```sh
defaults write com.apple.Terminal "Default Window Settings" "Rose Pine Dawn"
defaults write com.apple.Terminal "Startup Window Settings" "Rose Pine Dawn"
```

Note these two writes only stick while Terminal is **closed** — it rewrites its
prefs on quit, clobbering them. Use step 5 (or step 3's AppleScript form) to
change the profile of a running Terminal.

## Step 5 — Follow macOS light/dark automatically

Installs a LaunchAgent that switches Terminal to **Rose Pine Dawn** in light
appearance and **Rose Pine** in dark — open windows included:

```sh
./scripts/install.sh
```

It runs at login, whenever the system appearance changes (typically within a
few seconds), and every 5 minutes as a safety net. Logs to
`/tmp/terminal-theme.log`; remove it with `./scripts/install.sh uninstall`.

Pair it with **System Settings ▸ Appearance ▸ Auto** so macOS itself flips at
sunrise/sunset. To override by hand:

```sh
./scripts/terminal-theme.sh dark    # or: light, auto
```

## Step 6 — Herdr

[Herdr](https://herdr.dev) config — keybindings (prefix `alt+tab`) and theme.

```sh
brew install herdr
mkdir -p ~/.config/herdr
cp terminal/herdr-config.toml ~/.config/herdr/config.toml
```

If herdr is already running, apply it without restarting:

```sh
herdr config check           # validate first
herdr server reload-config
```

## Step 7 — Starship prompt config

Custom prompt: directory + git branch/status + language versions (Python/Node/Dart)
on the left, RAM/battery/time/shell on the right — no default noise from unused
language runtimes.

```sh
mkdir -p ~/.config
cp terminal/starship.toml ~/.config/starship.toml
```

Takes effect on your next prompt — no reload needed.

## Step 8 — Automic Vault (secrets & env vars)

[Automic Vault](https://www.automicvault.com/docs/) stores environment
variables and secrets in the Keychain and hands them to one command at a time —
it replaces `.env` files everywhere.

```sh
brew install --cask automic-vault/isotopes/automic-vault
open /Applications/Automic\ Vault.app   # finish the attended CLI install when prompted
av --version
```

**Store a variable** (the value is typed into a hidden prompt, never into shell
history):

```sh
av save MY_API_KEY                         # global
av save --project-directory=. MY_API_KEY   # scoped to the current project
av list                                    # names only, never values
```

**Use it** — the variable exists only for that one command:

```sh
av inject +MY_API_KEY -- uv run main.py
```

Moving an existing project off `.env`: `av save` each key, switch the run
commands to `av inject +KEY -- <command>`, then delete the `.env` file. Run
`av scan` to check nothing is left exposed.

## Step 9 — Agent instructions & skills

`AGENTS.md` is the single source of my instructions for AI coding agents, and
`skills/` holds the skills it points to (`tech-stack`, `automic-vault`).

Run everything in this step from the repo root.

**Global instructions** — link it as Claude Code's user-level file (back up any
existing one first):

```sh
[ -f ~/.claude/CLAUDE.md ] && [ ! -L ~/.claude/CLAUDE.md ] && mv ~/.claude/CLAUDE.md ~/.claude/CLAUDE.md.bak
ln -sfn "$PWD/AGENTS.md" ~/.claude/CLAUDE.md
```

**Skills** — link each one into `~/.agents/skills` (shared by agents) and
`~/.claude/skills`:

```sh
mkdir -p ~/.agents/skills ~/.claude/skills
for skill in skills/*/; do
  name="$(basename "$skill")"
  ln -sfn "$PWD/skills/$name" ~/.agents/skills/"$name"
  ln -sfn ../../.agents/skills/"$name" ~/.claude/skills/"$name"
done
```

Both are symlinks into this repo, so edits here apply everywhere immediately.

**New repo** — for agents that don't read the global file, copy it in. Claude
Code reads `AGENTS.md` natively (v2.1.277+) as long as the repo has no
`CLAUDE.md`:

```sh
cp AGENTS.md /path/to/new-repo/AGENTS.md
```

## Reference

- [Rosé Pine palette](https://rosepinetheme.com/palette/)
- [Refactoring Guru — design patterns catalog](https://refactoring.guru/design-patterns/catalog)
