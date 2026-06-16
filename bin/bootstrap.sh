#!/usr/bin/env bash

set -euo pipefail # Exit on error, undefined vars, and pipeline failures
IFS=$'\n\t'       # Stricter word splitting

# Trap Ctrl-C (SIGINT) and exit gracefully
trap 'echo -e "\nInterrupted. Exiting..."; exit 130' INT

# Bootstrap script for new system setup
# Supports:
#   - macOS (via Homebrew)
#
# Usage:
#   ./bootstrap.sh
#   DOTFILES_BRANCH=branch-name ./bootstrap.sh
#   DOTFILES_PATH=/custom/path ./bootstrap.sh
#
# Prerequisites:
#   - None (script will install required package managers)

bootstrap() {
  echo -e "\033[1;36m== bootstrap ==\033[0m"

  if ! is_macos; then
    print_failure "Unsupported operating system"
    return 1
  fi

  ensure_homebrew || print_failure "Homebrew could not be set up"
  ensure_git || print_failure "Git could not be set up"
  ensure_zsh || print_failure "Zsh could not be set up"
  ensure_dotfiles || print_failure "Dotfiles could not be set up"
  print_status "Running initial dotfiles setup"
  "${DOTFILES_PATH:-$HOME/.dotfiles}/bin/redot.sh" || print_failure "Initial dotfiles setup failed"
  persist_dotfiles_path
  print_status "Bootstrap complete"
}

# ------------------------------------------------------------------------------------------------------
# A custom DOTFILES_PATH only lives for this run; persist it to ~/.zprofile.local so
# future shells (and the bin scripts) resolve the repo to the same place.
persist_dotfiles_path() {
  local dotfiles local_profile
  dotfiles="${DOTFILES_PATH:-$HOME/.dotfiles}"
  [[ "$dotfiles" == "$HOME/.dotfiles" ]] && return 0

  local_profile="$HOME/.zprofile.local"
  if [[ -f "$local_profile" ]] && grep -qF "DOTFILES_PATH" "$local_profile"; then
    print_warning "DOTFILES_PATH already present in $local_profile; leaving it untouched."
    return 0
  fi

  echo "export DOTFILES_PATH=\"$dotfiles\"" >>"$local_profile"
  print_status "Persisted DOTFILES_PATH to $local_profile for future shells."
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

# ------------------------------------------------------------------------------------------------------
ensure_git() {
  print_status "Checking git"
  if command -v git >/dev/null 2>&1; then
    return 0
  fi

  print_status "Installing git"
  brew install git || return 1
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
    brew install zsh || return 1
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
  local dotfiles="${DOTFILES_PATH:-$HOME/.dotfiles}"
  print_status "Checking dotfiles"
  if [[ -d $dotfiles ]]; then
    return 0
  fi

  local branch="${DOTFILES_BRANCH:-main}"

  print_status "Downloading dotfiles"
  cd "$HOME" &&
    git clone https://github.com/relativesanity/dotfiles "$dotfiles" &&
    cd "$dotfiles" &&
    git checkout "$branch" || return 1
  print_status "Dotfiles downloaded"
}

# ------------------------------------------------------------------------------------------------------
print_status() {
  echo "$1"
}

print_failure() {
  echo -e "\033[0;31m$1\033[0m"
  return 1
}

print_warning() {
  echo -e "\033[0;33m$1\033[0m"
}

# ------------------------------------------------------------------------------------------------------
is_macos() {
  [[ "$(uname)" == "Darwin" ]]
}

# ------------------------------------------------------------------------------------------------------
if ! bootstrap; then
  print_status "Bootstrap failed"
  exit 1
fi
