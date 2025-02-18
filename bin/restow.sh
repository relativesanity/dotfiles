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

  if ! command -v stow >/dev/null 2>&1; then
    echo "Installing stow"
    brew install stow
  fi
fi

mkdir -p "$HOME"/.config/ # a noop if it exists
mkdir -p "$HOME"/.rbenv/  # a noop if it exists

echo "stowing ghostty" && stow -d "$HOME"/.dotfiles/ --restow ghostty
echo "stowing git" && stow -d "$HOME"/.dotfiles/ --restow git
echo "stowing neovim" && stow -d "$HOME"/.dotfiles/ --restow neovim
echo "stowing rbenv" && stow -d "$HOME"/.dotfiles/ --restow rbenv
echo "stowing sh" && stow -d "$HOME"/.dotfiles/ --restow sh
