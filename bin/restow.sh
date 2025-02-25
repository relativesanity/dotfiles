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
  ensure_stow || print_failure "Failed to ensure stow is available"
  setup_directories || print_failure "Failed to setup directories"
  stow_packages || print_failure "Failed to stow packages"
  print_status "Stow complete"
}

# ------------------------------------------------------------------------------------------------------

print_status() {
  echo "[stow] $1"
}

print_failure() {
  print_status "$1"
  return 1
}

has_homebrew() {
  [[ -e /opt/homebrew/bin/brew ]]
}

ensure_homebrew() {
  if [[ ! -e /opt/homebrew/bin/brew ]]; then
    print_failure "Homebrew installation not found"
  fi

  if ! command -v brew >/dev/null 2>&1; then
    print_status "Configuring Homebrew"
    if ! eval "$(/opt/homebrew/bin/brew shellenv)"; then
      print_failure "Failed to configure Homebrew"
    fi
  fi
}

has_yay() {
  command -v yay >/dev/null 2>&1
}

ensure_stow() {
  if ! command -v stow >/dev/null 2>&1; then
    print_status "Installing stow"
    if has_homebrew; then
      ensure_homebrew
      brew install stow
    elif has_yay; then
      yay -S --noconfirm stow
    else
      print_failure "No supported package manager found"
    fi
  fi
  print_status "stow is available"
}

setup_directories() {
  print_status "Creating required directories"
  if ! mkdir -p "$HOME"/.config/; then
    print_failure "Failed to create .config directory"
  fi
  if ! mkdir -p "$HOME"/.rbenv/; then
    print_failure "Failed to create .rbenv directory"
  fi
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
    if ! stow -d "$HOME"/.dotfiles/ --restow "$package"; then
      print_failure "Failed to stow $package"
    fi
  done
}

# Run restow and capture any errors
if ! restow; then
  print_status "Stow failed"
  exit 1
fi
