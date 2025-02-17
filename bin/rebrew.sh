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

  echo "Bundling homebrew"
  brew bundle --file "$HOME"/.dotfiles/Brewfile --cleanup --zap
fi

echo "Rebrew complete"
