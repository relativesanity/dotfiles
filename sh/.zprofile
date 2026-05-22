# Homebrew initialization
# Must be in .zprofile (not .zshenv) to run after macOS's /etc/zprofile
# which runs path_helper and reorders PATH
[[ -f /opt/homebrew/bin/brew ]] && eval "$(/opt/homebrew/bin/brew shellenv)"

# Add ~/.local/bin to PATH, avoiding duplicates
[[ ":$PATH:" != *":$HOME/.local/bin:"* ]] && export PATH="$HOME/.local/bin:$PATH"

# OrbStack (re-added by installer on each new machine)
[[ -f ~/.orbstack/shell/init.zsh ]] && source ~/.orbstack/shell/init.zsh

# Local overrides (machine-specific PATH additions, etc.)
[[ -f $HOME/.zprofile.local ]] && source $HOME/.zprofile.local
