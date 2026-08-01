#!/usr/bin/env bash

set -euo pipefail # Exit on error, undefined vars, and pipeline failures
IFS=$'\n\t'       # Stricter word splitting

# Trap Ctrl-C (SIGINT) and exit gracefully
trap 'echo -e "\nInterrupted. Exiting..."; exit 130' INT

# Bootstrap script for new system setup
# Installs the prerequisites and clones the repo, then asks before handing over
# to redot for the full install (packages + symlinks + runtimes); answering no
# leaves the machine untouched beyond the clone.
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

  # Each guard returns explicitly instead of leaning on `set -e`: bootstrap is
  # called from an `if !` condition, which disables errexit for everything it
  # calls, so a bare `|| print_failure` prints in red and then carries on.
  ensure_homebrew || {
    print_failure "Homebrew could not be set up"
    return 1
  }
  ensure_git || {
    print_failure "Git could not be set up"
    return 1
  }
  ensure_zsh || {
    print_failure "Zsh could not be set up"
    return 1
  }
  ensure_dotfiles || {
    print_failure "Dotfiles could not be set up"
    return 1
  }
  persist_dotfiles_path

  local dotfiles="${DOTFILES_PATH:-$HOME/.dotfiles}"
  if ! confirm_full_install; then
    print_status "Stopping after bootstrap. Run '$dotfiles/bin/redot.sh' to install packages and symlinks."
    print_status "(the shorter 'redot' command appears once the shell configs are stowed)"
    return 0
  fi

  print_status "Running initial dotfiles setup"
  if ! "$dotfiles/bin/redot.sh"; then
    print_failure "Initial dotfiles setup failed"
    return 1
  fi
  print_status "Bootstrap complete"
  print_status "Run 'redot' to sync, or repack/restow/reenv for one part."
}

# ------------------------------------------------------------------------------------------------------
# Bootstrap only prepares the machine; redot is what changes it — it installs
# every package and, through `brew bundle --zap`, uninstalls anything undeclared.
# Ask before crossing that line, defaulting to no: on a fresh machine one extra
# keystroke costs nothing, and on a machine that already has the repo a mistyped
# answer would zap real apps.
#
# Ask on the controlling terminal rather than on stdin. Under the documented
# `bash -c "$(curl …)"` stdin is the TTY, but a genuinely piped run has stdin
# consumed by the script itself — and `read -p` writes its prompt to stderr,
# which disappears under `bootstrap.sh 2>log`, leaving what looks like a hang.
#
# Writing the prompt is the probe for a terminal: /dev/tty exists and even tests
# readable when there is no controlling terminal, so only the write reveals the
# truth. If it fails there is nobody to ask and the run continues, staying
# one-shot as it was before this prompt existed. A failed READ is different —
# that is EOF from a person (Ctrl-D), so it stops.
confirm_full_install() {
  local prompt="Continue to full installation? [y/N] " reply=""

  printf '%s' "$prompt" >/dev/tty 2>/dev/null || {
    # Say so rather than continue silently: the visible default is no, and an
    # unattended log should record that this run took the other branch.
    print_status "No terminal to prompt on; continuing to full installation."
    return 0
  }
  read -r reply </dev/tty 2>/dev/null || {
    printf '\n' >/dev/tty 2>/dev/null || true
    return 1
  }

  # Strict IFS ($'\n\t') means read leaves surrounding spaces on, so " y" would
  # miss the match below. Trim them rather than let a stray space decide this.
  reply="${reply#"${reply%%[![:space:]]*}"}"
  reply="${reply%"${reply##*[![:space:]]}"}"

  [[ "$reply" =~ ^[Yy]([Ee][Ss])?$ ]]
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
# repack.sh has an ensure_homebrew too, and lib/common.sh has a confirm() much
# like confirm_full_install. The duplication is deliberate: bootstrap runs from
# `curl` before the repo exists, so it cannot source bin/lib. Don't merge them.
ensure_homebrew() {
  print_status "Checking homebrew"
  if command -v brew >/dev/null 2>&1; then
    return 0
  fi

  if [[ ! -e /opt/homebrew/bin/brew ]]; then
    print_status "Installing homebrew"
    /usr/bin/env bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" || return 1
  fi
  print_status "Homebrew installed"

  if ! command -v brew >/dev/null 2>&1; then
    print_status "Enabling homebrew"
    eval "$(/opt/homebrew/bin/brew shellenv)"
  fi

  # Confirm rather than assume: the installer and shellenv can both fail, and the
  # caller's guard sees nothing but this function's status.
  command -v brew >/dev/null 2>&1 || return 1
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
