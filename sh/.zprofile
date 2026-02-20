# Homebrew initialization
# Must be in .zprofile (not .zshenv) to run after macOS's /etc/zprofile
# which runs path_helper and reorders PATH
[[ -f /opt/homebrew/bin/brew ]] && eval "$(/opt/homebrew/bin/brew shellenv)"

# Local overrides
[[ -f $HOME/.zprofile.local ]] && source $HOME/.zprofile.local

# Add ~/.local/bin to PATH, avoiding duplicates
[[ ":$PATH:" != *":$HOME/.local/bin:"* ]] && export PATH="$HOME/.local/bin:$PATH"

# Added by OrbStack: command-line tools and integration
# This won't be added again if you remove it.
source ~/.orbstack/shell/init.zsh 2>/dev/null || :

# Added by Obsidian
export PATH="$PATH:/Applications/Obsidian.app/Contents/MacOS"
