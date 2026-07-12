# ~/.zshrc — interactive zsh setup (rebuilt 2026-07-12)
# Prompt: starship | Plugins: autosuggestions + syntax-highlighting | bat as cat

# --- Homebrew (idempotent; also set in .zprofile for login shells) ---
eval "$(/opt/homebrew/bin/brew shellenv)"

# --- PATH additions ---
export PATH="$HOME/.local/bin:$PATH"                               # uv & local bins

# --- uv environment ---
[ -f "$HOME/.local/bin/env" ] && . "$HOME/.local/bin/env"

# --- History ---
HISTFILE="$HOME/.zsh_history"
HISTSIZE=10000
SAVEHIST=10000
setopt SHARE_HISTORY HIST_IGNORE_ALL_DUPS HIST_IGNORE_SPACE

# --- Completion ---
autoload -Uz compinit && compinit

# --- Aliases ---
# bat as a colorized cat (plain style, no pager — behaves like cat interactively).
# Remove this line if you'd rather keep the stock `cat`.
alias cat='bat --style=plain --paging=never'
# Switch Terminal color theme: `theme dark|light|auto` (auto = match macOS appearance).
alias theme="$HOME/workspace_setup/scripts/terminal-theme.sh"

# --- Prompt: starship ---
eval "$(starship init zsh)"

# --- Plugins (syntax-highlighting must be sourced LAST) ---
source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
