#!/usr/bin/env bash

set -euo pipefail # Exit on error, undefined vars, and pipeline failures
IFS=$'\n\t'       # Stricter word splitting

# Dotfiles repack script
# Supports:
#   - macOS (via Homebrew)
#   - Arch Linux (via yay)
#
# Usage:
#   ./repack.sh
#
# Prerequisites:
#   - Homebrew must be already installed for macOS
#   - dotfiles repository must be present

repack() {
  if is_macos; then
    ensure_homebrew || print_failure "Failed to ensure Homebrew is available"
    update_homebrew || print_failure "Failed to update Homebrew"
    bundle_homebrew || print_failure "Failed to bundle Homebrew packages"
  elif is_arch; then
    ensure_yay || print_failure "Failed to ensure yay is available"
    update_yay || print_failure "Failed to update yay"
    bundle_yay || print_failure "Failed to install Arch packages"
  else
    print_failure "Unsupported operating system"
  fi

  setup_tmux_plugins || print_failure "Failed to setup TMUX plugins"
  print_status "Repack complete"
}

#
#
#
#
# ------------------------------------------------------------------------------------------------------
is_macos() {
  command -v defaults >/dev/null 2>&1
}

# ------------------------------------------------------------------------------------------------------
is_arch() {
  command -v pacman >/dev/null 2>&1
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
  print_status "Homebrew is available"
}

# ------------------------------------------------------------------------------------------------------
update_homebrew() {
  print_status "Updating Homebrew"
  brew update
}

# ------------------------------------------------------------------------------------------------------
bundle_homebrew() {
  print_status "Bundling Homebrew packages"
  if [[ -f "${DOTFILES_PATH:-$HOME/.dotfiles}/Brewfile.local" ]]; then
    # concat the files and pipe to the command to ensure the whole brewfile is considered when cleaning up
    cat "${DOTFILES_PATH:-$HOME/.dotfiles}/Brewfile" "${DOTFILES_PATH:-$HOME/.dotfiles}/Brewfile.local" | brew bundle --file=- --cleanup --zap
  else
    brew bundle --file "${DOTFILES_PATH:-$HOME/.dotfiles}/Brewfile" --cleanup --zap
  fi
}

# ------------------------------------------------------------------------------------------------------
ensure_yay() {
  if ! command -v yay >/dev/null 2>&1; then
    print_failure "yay not found. Please install yay first."
    return 1
  fi
  print_status "yay is available"
  return 0
}

# ------------------------------------------------------------------------------------------------------
update_yay() {
  print_status "Updating yay database"
  yay -Sy || return 1
}

# ------------------------------------------------------------------------------------------------------
bundle_yay() {
  print_status "Installing Arch packages"
  local pkgfile="${DOTFILES_PATH:-$HOME/.dotfiles}/Yayfile"
  local pkgfile_local="${DOTFILES_PATH:-$HOME/.dotfiles}/Yayfile.local"

  if [[ ! -f "$pkgfile" ]]; then
    print_failure "Yayfile not found at $pkgfile"
    return 1
  fi

  # Install packages from Yayfile
  while IFS= read -r line || [[ -n "$line" ]]; do
    # Skip comments and empty lines
    [[ -z "$line" || "$line" =~ ^[[:space:]]*# ]] && continue

    print_status "Installing $line"
    yay -S --needed --noconfirm "$line" || print_status "Failed to install $line"
  done <"$pkgfile"

  # Install packages from Yayfile.local if it exists
  if [[ -f "$pkgfile_local" ]]; then
    print_status "Installing local packages"
    while IFS= read -r line || [[ -n "$line" ]]; do
      # Skip comments and empty lines
      [[ -z "$line" || "$line" =~ ^[[:space:]]*# ]] && continue

      print_status "Installing $line"
      yay -S --needed --noconfirm "$line" || print_status "Failed to install $line"
    done <"$pkgfile_local"
  fi

  return 0
}

# ------------------------------------------------------------------------------------------------------
setup_tmux_plugins() {
  if command -v tmux >/dev/null 2>&1; then
    if [[ ! -d $HOME/.tmux/plugins/tpm ]]; then
      print_status "Installing TMUX plugin manager"
      mkdir -p $HOME/.tmux/plugins
      git clone https://github.com/tmux-plugins/tpm $HOME/.tmux/plugins/tpm
    fi
  fi
  print_status "TMUX plugins are set up"
}

# ------------------------------------------------------------------------------------------------------
print_status() {
  echo "[repack] $1"
}

print_failure() {
  print_status "$1"
  return 1
}

# ------------------------------------------------------------------------------------------------------
if ! repack; then
  print_status "Repack failed"
  exit 1
fi
