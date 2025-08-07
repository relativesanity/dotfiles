[[ -f /opt/homebrew/bin/brew ]] && eval $(/opt/homebrew/bin/brew shellenv)
[[ -f $HOME/.zprofile.local ]] && source $HOME/.zprofile.local

export PATH="$HOME/.local/bin:$PATH"
