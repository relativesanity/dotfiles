#!/usr/bin/env bash

set -euo pipefail # Exit on error, undefined vars, and pipeline failures
IFS=$'\n\t'       # Stricter word splitting

# Restow script for managing dotfile symlinks
# Supports: macOS (via Homebrew), Arch Linux (via yay/pacman)
#
# Usage:
#   ./restow.sh
#
# Prerequisites:
#   - macOS: none (will install homebrew and stow if needed)
#   - Arch: sudo access required if stow needs installing
#
# Security:
#   - Script should be run from a trusted dotfiles repository
#   - Verify symlink destinations before running

# Configuration
readonly REQUIRED_DIRS=(
  "$HOME/.config"
  "$HOME/.rbenv"
)

readonly STOW_CONFIGS=(
  "ghostty"
  "gh"
  "git"
  "neovim"
  "rbenv"
  "sh"
  "starship"
  "tmux"
)

# Main restow function to manage dotfile symlinks
restow() {
  ensure_stow || return 1

  # Create required directories
  print_status "Creating required directories"
  for dir in "${REQUIRED_DIRS[@]}"; do
    mkdir -p "$dir"
  done

  # Stow all configurations
  print_status "Stowing configurations"
  local dotfiles_dir="$HOME/.dotfiles"

  for config in "${STOW_CONFIGS[@]}"; do
    echo "stowing $config"
    stow -d "$dotfiles_dir" --restow "$config" || {
      print_status "Failed to stow $config"
      return 1
    }
  done

  print_status "All configurations stowed successfully"
}

# Print platform-specific status message
print_status() {
  local status=$1
  if is_macos; then
    echo "[macOS] $status"
  elif is_arch; then
    echo "[Arch] $status"
  else
    echo "[ERROR] $status"
  fi
}

# Platform detection
is_macos() {
  command -v defaults >/dev/null 2>&1
}

is_arch() {
  command -v pacman >/dev/null 2>&1
}

# Ensure stow is available on the system
ensure_stow() {
  if is_macos; then
    # Do we have homebrew installed already?
    if [[ ! -e /opt/homebrew/bin/brew ]]; then
      print_status "Installing homebrew"
      /usr/bin/env bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi
    print_status "Homebrew installed"

    # We now have homebrew installed, so if it's not an available command,
    # we must configure it for the current session
    if ! command -v brew >/dev/null 2>&1; then
      print_status "Enabling homebrew"
      eval "$(/opt/homebrew/bin/brew shellenv)"
    fi
    print_status "Homebrew enabled"

    if ! command -v stow >/dev/null 2>&1; then
      print_status "Installing stow"
      brew install stow
    fi
  elif is_arch; then
    if ! command -v yay >/dev/null 2>&1; then
      print_status "yay not found. This script prefers using yay on Arch Linux."
      echo "Options:"
      echo "  1) Exit (recommended: install yay yourself)"
      echo "  2) Continue using pacman instead"
      echo
      read -r -p "Please choose an option (1-2): " choice

      case $choice in
      1)
        print_status "Exiting. Please install yay before running this script again."
        return 1
        ;;
      2)
        print_status "Continuing with pacman"
        if ! command -v stow >/dev/null 2>&1; then
          print_status "Installing stow using pacman"
          sudo pacman -S --noconfirm stow
        fi
        ;;
      *)
        print_status "Invalid option"
        return 1
        ;;
      esac
    else
      # yay is available, use it
      if ! command -v stow >/dev/null 2>&1; then
        print_status "Installing stow using yay"
        yay -S --noconfirm stow
      fi
    fi
  else
    print_status "Unsupported operating system"
    return 1
  fi

  print_status "stow installed"
  return 0
}

# Run restow and capture any errors
if ! restow; then
  print_status "Restow failed"
  exit 1
fi
