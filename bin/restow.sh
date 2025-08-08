#!/usr/bin/env bash

set -euo pipefail # Exit on error, undefined vars, and pipeline failures
IFS=$'\n\t'       # Stricter word splitting

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
  ensure_stow || { print_failure "Stow could not be set up"; return 1; }
  setup_directories || { print_failure "Required directories could not be set up"; return 1; }
  stow_packages || { print_failure "Packages could not be stowed"; return 1; }
  print_status "Stow complete"
}

readonly REQUIRED_DIRECTORIES=(
  "$HOME/.config"
  "$HOME/.rbenv"
)

readonly STOW_PACKAGES=(
  "btop"
  "gh"
  "ghostty"
  "git"
  "hammerspoon"
  "hetzner"
  "neovim"
  "rbenv"
  "sh"
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
    if is_macos; then
      ensure_homebrew &&
        brew install stow || return 1
    else
      return 1
    fi
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
  local status=$1
  if is_macos; then
    echo "[macOS] $status"
  else
    echo "[ERROR] $status"
  fi
}

print_failure() {
  print_status "$1"
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
