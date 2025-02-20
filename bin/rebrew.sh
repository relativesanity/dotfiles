#!/usr/bin/env bash

# Check if we're dealing with macOS
if command -v defaults >/dev/null 2>&1; then
  # Do we have homebrew installed already?
  if [[ ! -e /opt/homebrew/bin/brew ]]; then
    echo "Installing homebrew"
    /usr/bin/env bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  fi
  echo "Homebrew installed"

  # We now have homebrew installed, so if it's not an available command,
  # we must configure it for the current session
  if ! command -v brew >/dev/null 2>&1; then
    echo "Enabling homebrew"
    eval "$(/opt/homebrew/bin/brew shellenv)"
  fi
  echo "Homebrew enabled"

  echo "Updating homebrew"
  brew update

  echo "Bundling local homebrew"
  if [[ -f "$HOME"/.dotfiles/Brewfile.local ]]; then
    # concat the files and pipe to the command to ensure the whole brewfile is considered when cleaning up
    cat "$HOME"/.dotfiles/Brewfile "$HOME"/.dotfiles/Brewfile.local | brew bundle --file=- --cleanup --zap
  else
    brew bundle --file "$HOME"/.dotfiles/Brewfile --cleanup --zap
  fi
fi

# Check if we have tmux available
if command -v tmux >/dev/null 2>&1; then
  # and then check if we have tpm installed
  if [[ ! -d $HOME/.tmux/plugins/tpm ]]; then
    echo "Installing TMUX plugin manager"
    mkdir -p $HOME/.tmux/plugins
    git clone https://github.com/tmux-plugins/tpm $HOME/.tmux/plugins/tpm
  fi
fi

echo "Rebrew complete"
