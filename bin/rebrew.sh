#!/usr/bin/env bash

# Check if we're using homebrew
if command -c brew >/dev/null 2>&1; then
  echo "Updating homebrew"
  brew update
  echo "Bundling homebrew"
  brew bundle --file "$HOME"/.dotfiles/Brewfile --cleanup --zap
fi
echo "Rebrew complete"
