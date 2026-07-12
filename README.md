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
├── terminal/                        # module 3 — Apple Terminal color profiles
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
| 3 | [Terminal profiles](#module-3--terminal-profiles) | Rose Pine (dark) + Rose Pine Dawn (light) | 1 (for the font glyphs) |
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

**Requires:** module 1 (the `.zshrc` sources starship + the two plugins and
aliases `cat` to `bat`). Without it the shell still loads but those lines error.

**Install** (symlinks keep this repo the source of truth):

```sh
ln -sf "$PWD/zsh/.zshrc"    ~/.zshrc
ln -sf "$PWD/zsh/.zprofile" ~/.zprofile
```

> ⚠️ This replaces your existing `~/.zshrc` / `~/.zprofile`. Back them up first if
> you have ones you care about: `cp ~/.zshrc ~/.zshrc.bak`.

**Apply without reopening the terminal:**

```sh
source ~/.zshrc
```

Prefer to copy instead of symlink (edit your `~/.zshrc` freely, repo won't
track it)? Use `cp` instead of `ln -sf`.

---

## Module 3 — Terminal profiles

Two Apple Terminal color schemes: **Rose Pine** (dark) and **Rose Pine Dawn**
(light).

**Requires:** module 1 for the `MesloLG Nerd Font` (prompt glyphs render as
boxes without it). The colors themselves work regardless.

**Install** (imports each profile into Terminal ▸ Settings ▸ Profiles):

```sh
open "terminal/Rose Pine.terminal"
open "terminal/Rose Pine Dawn.terminal"
```

Each `open` pops a new Terminal window using that profile — that's how macOS
imports it. You can close those extra windows afterward.

**Set one as the default** (optional — module 4 will manage this for you):

```sh
defaults write com.apple.Terminal "Default Window Settings" "Rose Pine Dawn"
defaults write com.apple.Terminal "Startup Window Settings" "Rose Pine Dawn"
```

---

## Module 4 — Auto theme switching

Keeps Apple Terminal's profile matching the macOS appearance: **Rose Pine** in
dark mode, **Rose Pine Dawn** in light mode — including macOS's own sunrise/sunset
"Auto" appearance.

**Requires:** module 3 (the switcher sets Terminal to the "Rose Pine" /
"Rose Pine Dawn" profiles by name, so they must be imported first).

### One-off / manual

```sh
./scripts/terminal-theme.sh auto     # match the current macOS appearance
./scripts/terminal-theme.sh dark     # force Rose Pine
./scripts/terminal-theme.sh light    # force Rose Pine Dawn
```

With module 2 installed you also get the `theme` alias: `theme auto|dark|light`.

### Automatic (LaunchAgent)

Installs a LaunchAgent that runs the script **at login and every 5 minutes**, so
Terminal follows macOS within a few minutes with no manual step.

```sh
./scripts/install.sh              # install / reinstall + load it now
```

**Verify:**

```sh
launchctl list | grep terminal-theme     # shows the agent + last exit status
cat /tmp/terminal-theme.log               # e.g. "Terminal theme → Rose Pine Dawn (light)"
```

**Uninstall:**

```sh
./scripts/install.sh uninstall    # unloads the agent and removes the plist
```

**Notes**
- The script never *launches* Terminal — if Terminal isn't running it exits
  quietly, so the scheduled agent won't pop it open.
- On macOS "Auto" appearance, the switch follows the system's sunrise/sunset
  flip with up to a 5-minute lag (the agent's poll interval).

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
