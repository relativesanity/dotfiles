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
  if [[ -f "$HOME"/.dotfiles/Brewfile.local ]]; then
    # concat the files and pipe to the command to ensure the whole brewfile is considered when cleaning up
    cat "$HOME"/.dotfiles/Brewfile "$HOME"/.dotfiles/Brewfile.local | brew bundle --file=- --cleanup --zap
  else
    brew bundle --file "$HOME"/.dotfiles/Brewfile --cleanup --zap
  fi
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
