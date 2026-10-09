# aliases.zsh — every shell alias and small command I've defined, in one place.
# Sourced from ~/.zshrc (see README step 1). Add new ones here, not in ~/.zshrc.

# --- General ---
# Note: this shadows the system C compiler `cc`; use `command cc` if you ever need it.
alias cc='claude'
# bat as a colorized cat (plain style, no pager — behaves like cat interactively).
# Remove this line if you'd rather keep the stock `cat`.
alias cat='bat --style=plain --paging=never'
# Switch Terminal color theme: `theme dark|light|auto` (auto = match macOS appearance).
alias theme="$HOME/Code/workspace_setup/scripts/terminal-theme.sh"

# Long listing, including dotfiles.
alias ll='ls -al'

# Tree view: current dir + each subfolder's contents, 2 levels deep.
alias la='tree -L 2 -C'

# Free disk space on the main (Data) volume, e.g. "70Gi free of 228Gi (63% used)".
alias space="df -h /System/Volumes/Data | awk 'NR==2 {print \$4 \" free of \" \$2 \" (\" \$5 \" used)\"}'"

# --- Git ---
# git checkout: switch branches (gco), or create-and-switch (gcb <new-branch>).
alias gco='git checkout'
alias gcb='git checkout -b'
alias gcm='git checkout main'
alias gcmp='git checkout main && git pull'
alias gss='git status'

# git worktree: bare passthrough (gwt list|remove|prune),
# attach an existing branch (gwta <path> <branch>),
# or create a new branch in a new worktree (gwtc <new-branch> <path>).
alias gwt='git worktree'
alias gwta='git worktree add'
alias gwtc='git worktree add -b'

# --- Tools ---
# Herdr
alias hdr=herdr
