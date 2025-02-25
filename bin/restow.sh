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

readonly REQUIRED_DIRECTORIES=(
  "$HOME/.config"
  "$HOME/.rbenv"
)

readonly STOW_PACKAGES=(
  "ghostty"
  "gh"
  "git"
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
  if ! command -v stow >/dev/null 2>&1; then
    print_status "Installing stow"
    if is_macos; then
      ensure_homebrew || print_failure "Failed to ensure Homebrew is available"
      brew install stow
    elif is_arch; then
      ensure_yay || print_failure "Failed to ensure yay is available"
      yay -S --noconfirm stow
    else
      print_failure "Unsupported operating system"
    fi
  fi
  print_status "stow is available"
}

# ------------------------------------------------------------------------------------------------------
is_macos() {
  command -v defaults >/dev/null 2>&1
}

# ------------------------------------------------------------------------------------------------------
is_arch() {
  [[ -f /etc/arch-release ]]
}

# ------------------------------------------------------------------------------------------------------
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

# ------------------------------------------------------------------------------------------------------
ensure_yay() {
  if ! command -v yay >/dev/null 2>&1; then
    print_failure "yay not found"
  fi
}

# ------------------------------------------------------------------------------------------------------
setup_directories() {
  print_status "Creating required directories"
  for dir in "${REQUIRED_DIRECTORIES[@]}"; do
    if ! mkdir -p "$dir"; then
      print_failure "Failed to create directory: $dir"
    fi
  done
}

# ------------------------------------------------------------------------------------------------------
stow_packages() {
  for package in "${STOW_PACKAGES[@]}"; do
    print_status "stowing $package"
    if ! stow -d "$HOME"/.dotfiles/ --restow "$package"; then
      print_failure "Failed to stow $package"
    fi
  done
}

# ------------------------------------------------------------------------------------------------------
print_status() {
  echo "[stow] $1"
}

print_failure() {
  print_status "$1"
  return 1
}

# ------------------------------------------------------------------------------------------------------
if ! restow; then
  print_status "Stow failed"
  exit 1
fi
