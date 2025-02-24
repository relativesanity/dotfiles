#!/usr/bin/env bash

set -euo pipefail # Exit on error, undefined vars, and pipeline failures
IFS=$'\n\t'       # Stricter word splitting

# Bootstrap script for setting up a new system
# Supports: macOS (via Homebrew), Arch Linux (via yay)
#
# Usage:
#   /usr/bin/env bash -c "$(curl -fsSL https://raw.githubusercontent.com/relativesanity/dotfiles/refs/heads/v2-dev/bin/bootstrap.sh)"
#
# Prerequisites:
#   - macOS: none
#   - Arch: sudo access required
#
# Security:
#   - Verify this script's contents before running
#   - Source: https://raw.githubusercontent.com/relativesanity/dotfiles/refs/heads/v2-dev/bin/bootstrap.sh

bootstrap() {
  check_prerequisites || return 1

  if is_macos; then
    setup_homebrew
    install_git_macos
  elif is_arch; then
    install_git_arch
    setup_yay
    setup_zsh_arch
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

# ------------------------------------------------------------------------------------------------------

# Ensure we're not being piped into sh
if [ -z "${BASH_VERSION:-}" ]; then
  echo "This script requires bash" >&2
  exit 1
fi

# Check for required permissions and connectivity
check_prerequisites() {
  if is_arch && ! sudo -v; then
    print_status "Sudo access required for Arch Linux installation"
    return 1
  fi

  if ! curl --silent --head https://github.com >/dev/null; then
    print_status "No network connectivity"
    return 1
  fi
}

# Cleanup handler
cleanup() {
  local exit_code=$?
  if [ -n "${TMP_DIR:-}" ] && [ -d "$TMP_DIR" ]; then
    rm -rf "$TMP_DIR"
  fi
  exit $exit_code
}

trap cleanup EXIT
trap 'trap - EXIT; cleanup' INT TERM

# Create secure temporary directory
TMP_DIR=$(mktemp -d)
chmod 700 "$TMP_DIR"

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

setup_yay() {
  if ! command -v yay >/dev/null 2>&1; then
    print_status "Installing base-devel"
    sudo pacman -S --noconfirm base-devel

    print_status "Installing yay"
    local yay_dir="$TMP_DIR/yay"
    git clone https://aur.archlinux.org/yay.git "$yay_dir"
    cd "$yay_dir" || exit
    # Verify PKGBUILD
    if ! grep -q 'pkgname=yay' PKGBUILD; then
      print_status "Invalid yay PKGBUILD"
      return 1
    fi
    makepkg -si --noconfirm
    cd - || exit
  fi
  print_status "yay installed"
}

# Git installation
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

# Zsh setup for Arch
setup_zsh_arch() {
  if ! command -v zsh >/dev/null 2>&1; then
    print_status "Installing zsh"
    yay -S --noconfirm zsh
  fi
  print_status "zsh installed"

  # Get the path to zsh
  local zsh_path
  zsh_path=$(command -v zsh)

  # Check if zsh is already the default shell
  if [[ "$SHELL" != "$zsh_path" ]]; then
    print_status "Setting zsh as default shell"

    # Verify zsh is in /etc/shells
    if ! grep -q "^${zsh_path}$" /etc/shells; then
      print_status "Adding zsh to /etc/shells"
      echo "$zsh_path" | sudo tee -a /etc/shells >/dev/null
    fi

    # Change default shell
    chsh -s "$zsh_path" "$USER" || {
      print_status "Failed to set zsh as default shell"
      return 1
    }
  fi
  print_status "zsh configured as default shell"
}

# Dotfiles setup
setup_dotfiles() {
  local dotfiles_dir="$HOME/.dotfiles"
  local dotfiles_repo="https://github.com/relativesanity/dotfiles"
  local dotfiles_branch="v2-dev"

  if [[ ! -d $dotfiles_dir ]]; then
    print_status "Downloading dotfiles"

    # Clone with minimal history for speed
    git clone --depth 1 --branch "$dotfiles_branch" "$dotfiles_repo" "$dotfiles_dir" || {
      print_status "Failed to clone dotfiles repository"
      return 1
    }

    cd "$dotfiles_dir" || exit

    # Verify we're on the expected branch
    local current_branch
    current_branch=$(git symbolic-ref --short HEAD)
    if [[ "$current_branch" != "$dotfiles_branch" ]]; then
      print_status "Unexpected branch: $current_branch (expected: $dotfiles_branch)"
      return 1
    fi

    # Verify remote URL
    local remote_url
    remote_url=$(git config --get remote.origin.url)
    if [[ "$remote_url" != "$dotfiles_repo" ]]; then
      print_status "Unexpected remote URL: $remote_url"
      return 1
    fi
  fi
  print_status "Dotfiles downloaded and verified"
}

# Run bootstrap and capture any errors
if ! bootstrap; then
  print_status "Bootstrap failed"
  exit 1
fi
