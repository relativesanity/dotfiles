# Homebrew initialization
# Must be in .zprofile (not .zshenv) to run after macOS's /etc/zprofile
# which runs path_helper and reorders PATH
[[ -f /opt/homebrew/bin/brew ]] && eval "$(/opt/homebrew/bin/brew shellenv)"

# Local overrides
[[ -f $HOME/.zprofile.local ]] && source $HOME/.zprofile.local

# Add ~/.local/bin to PATH, avoiding duplicates
[[ ":$PATH:" != *":$HOME/.local/bin:"* ]] && export PATH="$HOME/.local/bin:$PATH"
