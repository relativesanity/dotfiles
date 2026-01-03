#!/usr/bin/env bash

set -euo pipefail # Exit on error, undefined vars, and pipeline failures
IFS=$'\n\t'       # Stricter word splitting

# Trap Ctrl-C (SIGINT) and exit gracefully
trap 'echo -e "\nInterrupted. Exiting..."; exit 130' INT

# Dotfiles stow script
# Supports:
#   - macOS (via Homebrew)
#
# Usage:
#   ./restow.sh
#
# Prerequisites:
#   - Homebrew must be available (or will be installed)
#   - dotfiles repository must be present

restow() {
  echo -e "\033[1;36m== restow ==\033[0m"

  if ! is_macos; then
    print_failure "Unsupported operating system"
    return 1
  fi

  ensure_stow || { print_failure "Stow could not be set up"; return 1; }
  setup_directories || { print_failure "Required directories could not be set up"; return 1; }
  stow_packages || { print_failure "Packages could not be stowed"; return 1; }
  print_status "Stow complete"
}

readonly REQUIRED_DIRECTORIES=(
  "$HOME/.claude"
  "$HOME/.config"
  "$HOME/.rbenv"
)

readonly STOW_PACKAGES=(
  "aerospace"
  "borders"
  "btop"
  "claude"
  "gh"
  "ghostty"
  "git"
  "hammerspoon"
  "hetzner"
  "leaderkey"
  "neovim"
  "rbenv"
  "sh"
  "sketchybar"
  "starship"
  "tmux"
)

#
#
#
#
# ------------------------------------------------------------------------------------------------------
ensure_stow() {
  print_status "Checking stow"
  if command -v stow >/dev/null 2>&1; then
    return 0
  fi

  if ! command -v stow >/dev/null 2>&1; then
    print_status "Installing stow"
    ensure_homebrew && brew install stow || return 1
  fi
  print_status "Stow installed"
}

# ------------------------------------------------------------------------------------------------------
ensure_homebrew() {
  print_status "Checking homebrew"
  if command -v brew >/dev/null 2>&1; then
    return 0
  fi

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

# ------------------------------------------------------------------------------------------------------
setup_directories() {
  print_status "Checking required directories"
  for dir in "${REQUIRED_DIRECTORIES[@]}"; do
    if [[ ! -e $dir ]]; then
      print_status "Creating $dir"
      mkdir -p "$dir" || return 1
    fi
  done
}

# ------------------------------------------------------------------------------------------------------
stow_packages() {
  print_status "Stowing…"
  for package in "${STOW_PACKAGES[@]}"; do
    print_status "Stowing $package"
    stow -d "$HOME/.dotfiles" -t "$HOME" --restow "$package" || return 1
  done
}

# ------------------------------------------------------------------------------------------------------
print_status() {
  echo "$1"
}

print_failure() {
  echo -e "\033[0;31m$1\033[0m"
  return 1
}

# ------------------------------------------------------------------------------------------------------
is_macos() {
  [[ "$(uname)" == "Darwin" ]]
}

# ------------------------------------------------------------------------------------------------------
if ! restow; then
  print_status "Stow failed"
  exit 1
fi
