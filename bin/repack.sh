#!/usr/bin/env bash

set -euo pipefail # Exit on error, undefined vars, and pipeline failures
IFS=$'\n\t'       # Stricter word splitting

# Dotfiles repack script
# Supports:
#   - macOS (via Homebrew)
#
# Usage:
#   ./repack.sh
#
# Prerequisites:
#   - Homebrew must be already installed for macOS
#   - dotfiles repository must be present

repack() {
  if ! is_macos; then
    print_failure "Unsupported operating system"
    return 1
  fi

  ensure_homebrew || print_failure "Homebrew could not be set up"
  update_homebrew || print_failure "Homebrew could not be updated"
  bundle_homebrew || print_failure "Homebrew could not be bundled"
  print_status "Repack complete"
}

#
#
#
#
# ------------------------------------------------------------------------------------------------------
detect_environment() {
  if [[ "$(whoami)" == "relativesanity" ]]; then
    echo "home"
  else
    echo "work"
  fi
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
  filepath="${DOTFILES_PATH:-$HOME/.dotfiles}"
  environment=$(detect_environment)

  print_status "Bundling Homebrew packages for environment: $environment"

  brewfiles=()
  brewfiles+=("$filepath/Brewfile")
  brewfiles+=("$filepath/Brewfile.$environment")

  if [[ -f "$filepath/Brewfile.local" ]]; then
    brewfiles+=("$filepath/Brewfile.local")
  fi

  cat "${brewfiles[@]}" | brew bundle --file=- --cleanup --zap
}

# ------------------------------------------------------------------------------------------------------
print_status() {
  local status=$1
  if is_macos; then
    echo "[macOS] $status"
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
  [[ "$(uname)" == "Darwin" ]]
}

# ------------------------------------------------------------------------------------------------------
if ! repack; then
  print_status "Repack failed"
  exit 1
fi
