#!/usr/bin/env bash

set -euo pipefail # Exit on error, undefined vars, and pipeline failures
IFS=$'\n\t'       # Stricter word splitting

# Bootstrap script for setting up a new macOS system
# Installs Homebrew, git, and downloads dotfiles repository

# Main bootstrap logic
bootstrap() {
  if is_macos; then
    setup_homebrew
    install_git_macos
  else
    print_status "Unsupported operating system"
    return 1
  fi

  setup_dotfiles || {
    print_status "Bootstrap failed during dotfiles setup"
    return 1
  }

  print_status "Bootstrap complete"
}

# Print platform-specific status message
print_status() {
  local status=$1
  if is_macos; then
    echo "[macOS] $status"
  else
    echo "[ERROR] $status"
  fi
}

# Platform detection
is_macos() {
  command -v defaults >/dev/null 2>&1
}

# Package manager setup
setup_homebrew() {
  if [[ ! -e /opt/homebrew/bin/brew ]]; then
    print_status "Installing homebrew"
    /usr/bin/env bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  fi
  print_status "Homebrew installed"

  if ! command -v brew >/dev/null 2>&1; then
    print_status "Enabling homebrew"
    eval "$(/opt/homebrew/bin/brew shellenv)"
  fi
  print_status "Homebrew enabled"
}

# Git installation
install_git_macos() {
  if ! command -v git >/dev/null 2>&1; then
    print_status "Installing git"
    brew install git
  fi
  print_status "git installed"
}

# Dotfiles setup
setup_dotfiles() {
  if [[ ! -d $HOME/.dotfiles ]]; then
    print_status "Downloading dotfiles"
    cd "$HOME" || exit
    git clone https://github.com/relativesanity/dotfiles "$HOME"/.dotfiles || {
      print_status "Failed to clone dotfiles repository"
      return 1
    }
    cd "$HOME"/.dotfiles || exit
    git checkout v2-dev || {
      print_status "Failed to checkout v2-dev branch"
      return 1
    }
  fi
  print_status "Dotfiles downloaded"
}

# Run bootstrap and capture any errors
if ! bootstrap; then
  print_status "Bootstrap failed"
  exit 1
fi
