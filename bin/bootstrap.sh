#!/usr/bin/env bash

set -euo pipefail # Exit on error, undefined vars, and pipeline failures
IFS=$'\n\t'       # Stricter word splitting

# Bootstrap script for new system setup
# Supports:
#   - macOS (via Homebrew)
#   - Arch Linux (via yay)
#
# Usage:
#   ./bootstrap.sh
#
# Prerequisites:
#   - None (script will install required package managers)

bootstrap() {
  if is_macos; then
    setup_homebrew || print_failure "Failed to setup Homebrew"
    install_git_macos || print_failure "Failed to install Git on macOS"
  elif is_arch; then
    install_git_arch || print_failure "Failed to install Git on Arch"
    setup_yay || print_failure "Failed to setup yay"
  else
    print_failure "Unsupported operating system"
  fi

  setup_dotfiles || print_failure "Failed to setup dotfiles"
  print_status "Bootstrap complete"
}

#
#
#
#
# ------------------------------------------------------------------------------------------------------
is_macos() {
  command -v defaults >/dev/null 2>&1
}

is_arch() {
  command -v pacman >/dev/null 2>&1
}

# ------------------------------------------------------------------------------------------------------
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

setup_yay() {
  if ! command -v yay >/dev/null 2>&1; then
    print_status "Installing base-devel"
    sudo pacman -S --noconfirm base-devel

    print_status "Installing yay"
    local tmp_dir
    tmp_dir=$(mktemp -d)
    git clone https://aur.archlinux.org/yay.git "$tmp_dir"
    cd "$tmp_dir" || exit
    makepkg -si --noconfirm
    cd - || exit
    rm -rf "$tmp_dir"
  fi
  print_status "yay installed"
}

# ------------------------------------------------------------------------------------------------------
install_git_macos() {
  if ! command -v git >/dev/null 2>&1; then
    print_status "Installing git"
    brew install git
  fi
  print_status "git installed"
}

install_git_arch() {
  if ! command -v git >/dev/null 2>&1; then
    print_status "Installing git"
    sudo pacman -S --noconfirm git
  fi
  print_status "git installed"
}

# ------------------------------------------------------------------------------------------------------
setup_dotfiles() {
  if [[ ! -d $HOME/.dotfiles ]]; then
    print_status "Downloading dotfiles"
    cd "$HOME" || exit
    git clone https://github.com/relativesanity/dotfiles "$HOME"/.dotfiles || {
      print_failure "Failed to clone dotfiles repository"
    }
    cd "$HOME"/.dotfiles || exit
    git checkout v2-dev || {
      print_failure "Failed to checkout v2-dev branch"
    }
  fi
  print_status "Dotfiles downloaded"
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
if ! bootstrap; then
  print_status "Bootstrap failed"
  exit 1
fi
