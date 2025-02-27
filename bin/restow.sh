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
  ensure_stow || print_failure "Stow could not be set up"
  setup_directories || print_failure "Required directories could not be set up"
  stow_packages || print_failure "Packages could not be stowed"
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
  print_status "Checking stow"
  if command -v stow >/dev/null 2>&1; then
    return 0
  fi

  if ! command -v stow >/dev/null 2>&1; then
    print_status "Installing stow"
    if is_macos; then
      ensure_homebrew &&
        brew install stow || return 1
    elif is_arch; then
      ensure_yay &&
        yay -S --noconfirm stow || return 1
    else
      return 1
    fi
  fi
  print_status "Stow intalled"
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

ensure_yay() {
  print_status "Checking yay"
  if command -v yay >/dev/null 2>&1; then
    return 0
  fi

  if ! command -v yay >/dev/null 2>&1; then
    print_status "Installing base-devel"
    sudo pacman -S --noconfirm base-devel

    print_status "Installing yay"
    local tmp_dir
    tmp_dir=$(mktemp -d) &&
      git clone https://aur.archlinux.org/yay.git "$tmp_dir" &&
      cd "$tmp_dir" &&
      makepkg -si --noconfirm &&
      cd - &&
      rm -rf "$tmp_dir" || return 1
  fi
  print_status "Yay installed"
}

# ------------------------------------------------------------------------------------------------------
setup_directories() {
  print_status "Checking required directories"
  for dir in "${REQUIRED_DIRECTORIES[@]}"; do
    print_status "Creating $dir"
    mkdir -p "$dir" || return 1
  done
}

# ------------------------------------------------------------------------------------------------------
stow_packages() {
  print_status "Stowing packages"
  for package in "${STOW_PACKAGES[@]}"; do
    print_status "Stowing $package"
    stow -d "$HOME"/.dotfiles/ --restow "$package" || return 1
  done
}

# ------------------------------------------------------------------------------------------------------
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

print_failure() {
  print_status "$1"
  return 1
}

# ------------------------------------------------------------------------------------------------------
is_macos() {
  command -v defaults >/dev/null 2>&1
}

is_arch() {
  command -v pacman >/dev/null 2>&1
}

# ------------------------------------------------------------------------------------------------------
if ! restow; then
  print_status "Stow failed"
  exit 1
fi
