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

  # brew should now be available for use. Let's make sure git is available
  brew install git

  # Check for .dotfiles, and download them if not in place
  if [[ ! -d $HOME/.dotfiles ]]; then
    cd "$HOME" || exit
    echo "Downloading dotfiles"
    git clone https://github.com/relativesanity/dotfiles "$HOME"/.dotfiles
    cd "$HOME"/.dotfiles || exit
    git checkout v2-dev # switch to latest build
  else
    cd "$HOME"/.dotfiles || exit
    # Assume if .dotfiles is already in place, current branch is correct
    # git checkout v2-dev
  fi
  echo "Dotfiles downloaded"
fi
echo "Bootstrap complete"

# We are now in the dotfiles directory with git and a package manager
# available. Run the installation script

./bin/install.sh
