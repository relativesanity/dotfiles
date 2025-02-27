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
    ensure_homebrew || print_failure "Homebrew could not be set up"
    ensure_git || print_failure "Git could not be set up"
  elif is_arch; then
    ensure_git || print_failure "Git could not be set up"
    ensure_yay || print_failure "Yay could not be set up"
  else
    print_failure "Unsupported operating system"
  fi

  ensure_zsh || print_failure "Zsh could not be set up"
  ensure_dotfiles || print_failure "Dotfiles could not be set up"
  print_status "Bootstrap complete"
}

#
#
#
#
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
ensure_git() {
  print_status "Checking git"
  if ! command -v git >/dev/null 2>&1; then
    return 0
  fi

  if ! command -v git >/dev/null 2>&1; then
    print_status "Installing git"
    if is_macos; then
      brew install git || return 1
    elif is_arch; then
      sudo pacman -S --noconfirm git || return 1
    else
      return 1
    fi
  fi
  print_status "Git installed"
}

# ------------------------------------------------------------------------------------------------------
ensure_zsh() {
  print_status "Checking zsh"
  if command -v zsh >/dev/null 2>&1 && [[ "$SHELL" == "$(command -v zsh)" ]]; then
    return 0
  fi

  # Check if zsh is already installed
  if ! command -v zsh >/dev/null 2>&1; then
    print_status "Installing zsh"
    if is_macos; then
      brew install zsh || return 1
    elif is_arch; then
      sudo pacman -S --noconfirm zsh || return 1
    else
      return 1
    fi
  fi
  print_status "Zsh installed"

  # Check if zsh is in /etc/shells
  if ! grep -q "$(command -v zsh)" /etc/shells; then
    print_status "Adding zsh to /etc/shells"
    echo "$(command -v zsh)" | sudo tee -a /etc/shells >/dev/null || return 1
  fi

  # Check if zsh is already the default shell
  if [[ "$SHELL" != "$(command -v zsh)" ]]; then
    print_status "Setting zsh as default shell"
    chsh -s "$(command -v zsh)" || return 1
  fi

  print_status "Zsh configured as default shell"
}

# ------------------------------------------------------------------------------------------------------
ensure_dotfiles() {
  print_status "Checking dotfiles"
  if [[ ! -d $HOME/.dotfiles ]]; then
    return 0
  fi

  if [[ ! -d $HOME/.dotfiles ]]; then
    print_status "Downloading dotfiles"
    cd "$HOME" &&
      git clone https://github.com/relativesanity/dotfiles "$HOME"/.dotfiles &&
      cd "$HOME"/.dotfiles &&
      git checkout v2-dev || return 1
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
is_macos() {
  command -v defaults >/dev/null 2>&1
}

is_arch() {
  command -v pacman >/dev/null 2>&1
}

# ------------------------------------------------------------------------------------------------------
if ! bootstrap; then
  print_status "Bootstrap failed"
  exit 1
fi
