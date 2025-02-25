#!/usr/bin/env bash

set -euo pipefail # Exit on error, undefined vars, and pipeline failures
IFS=$'\n\t'       # Stricter word splitting

# Dotfiles stow script
# Supports:
#   - macOS (via Homebrew)
#   - Arch Linux (via yay)
#
# Usage:
#   ./restow.sh
#
# Prerequisites:
#   - Homebrew or yay must be available
#   - dotfiles repository must be present

restow() {
  ensure_stow || {
    print_status "Failed to ensure stow is available"
    return 1
  }

  setup_directories || {
    print_status "Failed to setup directories"
    return 1
  }

  stow_packages || {
    print_status "Failed to stow packages"
    return 1
  }

  print_status "Stow complete"
}

# ------------------------------------------------------------------------------------------------------

print_status() {
  echo "[stow] $1"
}

has_homebrew() {
  command -v brew >/dev/null 2>&1
}

has_yay() {
  command -v yay >/dev/null 2>&1
}

ensure_stow() {
  if ! command -v stow >/dev/null 2>&1; then
    print_status "Installing stow"
    if has_homebrew; then
      brew install stow
    elif has_yay; then
      yay -S --noconfirm stow
    else
      print_status "No supported package manager found"
      return 1
    fi
  fi
  print_status "stow is available"
}

setup_directories() {
  print_status "Creating required directories"
  mkdir -p "$HOME"/.config/
  mkdir -p "$HOME"/.rbenv/
}

stow_packages() {
  local packages=(
    "ghostty"
    "gh"
    "git"
    "neovim"
    "rbenv"
    "sh"
    "starship"
    "tmux"
  )

  for package in "${packages[@]}"; do
    print_status "stowing $package"
    stow -d "$HOME"/.dotfiles/ --restow "$package"
  done
}

# Run restow and capture any errors
if ! restow; then
  print_status "Stow failed"
  exit 1
fi
