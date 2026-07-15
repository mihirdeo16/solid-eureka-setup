# workspace_setup

My macOS terminal environment, kept in one place so a fresh machine (or a single
piece of it) can be rebuilt with copy-paste commands.

It's **modular** — each section below is independent. Set up everything, or just
the one piece you want. Where a module depends on another, it says so up top.

```
workspace_setup/
├── Brewfile                         # module 1 — CLI tools & font (Homebrew)
├── zsh/                             # module 2 — shell config
│   ├── .zshrc
│   └── .zprofile
├── terminal/                        # module 3 — Apple Terminal profiles (colors + font)
│   ├── Rose Pine.terminal           #   dark
│   └── Rose Pine Dawn.terminal      #   light
├── scripts/
│   ├── terminal-theme.sh            # module 4 — switch profile to match macOS
│   └── install.sh                   #   installs the LaunchAgent below
└── launchd/
    └── com.md.terminal-theme.plist.template
```

| # | Module | What it gives you | Depends on |
|---|--------|-------------------|------------|
| 1 | [Homebrew packages](#module-1--homebrew-packages) | starship prompt, zsh plugins, `bat`, Nerd Font | — |
| 2 | [Zsh config](#module-2--zsh-config) | prompt, plugins, aliases, history | 1 (for plugins/`bat`) |
| 3 | [Terminal profiles](#module-3--terminal-profiles) | Rose Pine (dark) + Rose Pine Dawn (light), Nerd Font @ 18 pt | 1 (for the font glyphs) |
| 4 | [Auto theme switching](#module-4--auto-theme-switching) | Terminal follows macOS light/dark | 3 (needs the profiles) |

**Start here (once):**

```sh
cd ~/Code/workspace_setup
```

All commands below assume you're in this directory.

> The modules are independent, but the "natural" order is 1 → 2 → 3 → 4, since
> later modules use tools/profiles the earlier ones install.

---

## Module 1 — Homebrew packages

CLI tools and the Nerd Font used by everything else.

**Requires:** [Homebrew](https://brew.sh).

**Install:**

```sh
brew bundle --file=Brewfile
```

Installs: `starship`, `zsh-autosuggestions`, `zsh-syntax-highlighting`, `bat`,
and the `MesloLG Nerd Font` cask.

**Verify:**

```sh
brew bundle check --file=Brewfile   # "dependencies are satisfied" when done
```

---

## Module 2 — Zsh config

Starship prompt, autosuggestions + syntax highlighting, shared history, and
handy aliases (`cat` → `bat`, `theme` → the switcher in module 4).

**Requires:** module 1 (starship, the two plugins, and `bat` come from the
Brewfile). Skipped it? Install just these pieces:

```sh
brew install starship zsh-autosuggestions zsh-syntax-highlighting bat
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

> **Additional note — symlink the repo's full config instead** (keeps this repo
> the source of truth; edits here show up in your shell):
>
> ```sh
> ln -sf "$PWD/zsh/.zshrc"    ~/.zshrc
> ln -sf "$PWD/zsh/.zprofile" ~/.zprofile
> ```
>
> ⚠️ This replaces your existing `~/.zshrc` / `~/.zprofile`. Back them up first if
> you have ones you care about: `cp ~/.zshrc ~/.zshrc.bak`.

---

## Module 3 — Terminal profiles

Two Apple Terminal profiles: **Rose Pine** (dark) and **Rose Pine Dawn**
(light). Each profile carries the whole look — the color scheme **and** the
font: `MesloLGS Nerd Font Mono`, size **18**.

### Step 1 — Install the font

The profiles reference `MesloLGS Nerd Font Mono`; without it, prompt glyphs
render as boxes and Terminal falls back to a default font. If you did
module 1 the font is already installed (it's in the Brewfile) — skip ahead.
Otherwise install just the font:

```sh
brew install --cask font-meslo-lg-nerd-font
```

**Verify:**

```sh
ls ~/Library/Fonts | grep -i meslo    # should list MesloLG*NerdFont*.ttf files
```

### Step 2 — Import the profiles

Imports each profile into Terminal ▸ Settings ▸ Profiles:

```sh
open "terminal/Rose Pine.terminal"
open "terminal/Rose Pine Dawn.terminal"
```

Each `open` pops a new Terminal window using that profile — that's how macOS
imports it. You can close those extra windows afterward.

The imported profiles already set the font and size (18), so no manual font
step is needed. If the font or size looks wrong anyway — e.g. the font was
installed *after* the profiles were imported — set it by hand:
Terminal ▸ Settings ▸ Profiles ▸ select the profile ▸ **Text** tab ▸ Font
**Change…** → family `MesloLGS Nerd Font Mono`, size **18**. Repeat for the
other profile.

### Step 3 — Set one as the default (optional — module 4 will manage this for you)

```sh
defaults write com.apple.Terminal "Default Window Settings" "Rose Pine Dawn"
defaults write com.apple.Terminal "Startup Window Settings" "Rose Pine Dawn"
```

---

## Rebuild everything on a fresh Mac

```sh
cd ~/Code/workspace_setup
brew bundle --file=Brewfile                       # 1
ln -sf "$PWD/zsh/.zshrc" ~/.zshrc                  # 2
ln -sf "$PWD/zsh/.zprofile" ~/.zprofile           # 2
open "terminal/Rose Pine.terminal"                # 3
open "terminal/Rose Pine Dawn.terminal"           # 3
./scripts/install.sh                              # 4
source ~/.zshrc
```


## Reference
https://rosepinetheme.com/palette/
https://refactoring.guru/design-patterns/catalog