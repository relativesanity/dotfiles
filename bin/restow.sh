#!/usr/bin/env bash

set -euo pipefail # Exit on error, undefined vars, and pipeline failures
IFS=$'\n\t'       # Stricter word splitting

# Trap Ctrl-C (SIGINT) and exit gracefully
trap 'echo -e "\nInterrupted. Exiting..."; exit 130' INT

# Dotfiles stow script
# Supports:
#   - macOS (via Homebrew)
#
# Usage:
#   ./restow.sh [--plan] [--yes]
#
# Run with no arguments it prints the plan and asks before applying.
#
# Options:
#   --plan  Simulate stowing (stow -n) and report conflicts, then exit without
#           creating or changing any symlinks
#   --yes   Apply without printing the plan or asking
#
# Prerequisites:
#   - Homebrew must be available (or will be installed)
#   - dotfiles repository must be present

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "$SCRIPT_DIR/lib/common.sh"

restow() {
  local plan=false
  local yes=false
  for arg in "$@"; do
    [[ "$arg" == "--plan" ]] && plan=true
    [[ "$arg" == "--yes" ]] && yes=true
  done

  if [[ "$plan" == "true" ]]; then
    plan_restow
    return 0
  fi

  print_header restow

  if ! is_macos; then
    print_failure "Unsupported operating system"
    return 1
  fi

  if [[ "$yes" == "false" ]]; then
    plan_restow
    if ! confirm "Apply this plan?"; then
      print_status "Nothing applied"
      return 0
    fi
    echo
  fi

  ensure_stow || {
    print_failure "Stow could not be set up"
    return 1
  }
  setup_directories || {
    print_failure "Required directories could not be set up"
    return 1
  }
  stow_packages || {
    print_failure "Packages could not be stowed"
    return 1
  }
  print_status "Stow complete"

  echo
  print_block "restow summary" \
    "Packages: $((STOW_LINKED + STOW_SKIPPED)) total" \
    "Linked:   ${STOW_LINKED}" \
    "Skipped:  ${STOW_SKIPPED} (local overrides)"
}

# Pre-created before stowing so each app's main config dir is a real directory
# rather than a single folded symlink into the repo. Stow still folds anything
# nested below them (e.g. nvim/lua, btop/themes, .claude/skills), which is what
# we want; keeping the top dir real stops tools' own scratch/state files (locks,
# machine-specific overrides like git's config.local, lazy-lock.json) from
# leaking into the repo. Add an entry when a new package introduces an app dir.
readonly REQUIRED_DIRECTORIES=(
  "$HOME/.claude"
  "$HOME/.config"
  "$HOME/.config/aerospace"
  "$HOME/.config/borders"
  "$HOME/.config/btop"
  "$HOME/.config/ghostty"
  "$HOME/.config/git"
  "$HOME/.config/nvim"
  "$HOME/.config/ripgrep"
  "$HOME/.config/sketchybar"
  "$HOME/.config/tmux"
)

# ------------------------------------------------------------------------------------------------------
# Read-only preview: simulate restowing every package and report conflicts.
plan_restow() {
  local dir pkg out clean=true
  dir="${DOTFILES_PATH:-$HOME/.dotfiles}"

  echo "Plan — restow (dry run, no symlinks changed)"
  echo

  if ! command -v stow >/dev/null 2>&1; then
    echo "  stow not installed — run restow to install it"
    return 0
  fi

  while IFS= read -r pkg; do
    # stow -n always emits a benign "simulation mode" notice; drop it so only
    # real conflict lines remain.
    out="$(stow -n -d "$dir" -t "$HOME" --restow "$pkg" 2>&1 | grep -v 'simulation mode' || true)"
    if [[ -n "$out" ]]; then
      clean=false
      printf '  ⚠ %s\n' "$pkg"
      printf '%s\n' "$out" | sed 's/^/      /'
    else
      printf '  ✓ %s\n' "$pkg"
    fi
  done < <(stow_packages_list)

  echo
  if [[ "$clean" == "true" ]]; then
    echo "All packages link cleanly."
  else
    echo "Conflicts above are expected on machine-specific configs (restow skips them)."
  fi
}

# ------------------------------------------------------------------------------------------------------
ensure_stow() {
  print_status "Checking stow"
  if command -v stow >/dev/null 2>&1; then
    return 0
  fi

  print_status "Installing stow"
  ensure_homebrew && brew install stow || return 1
  print_status "Stow installed"
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
setup_directories() {
  print_status "Checking required directories"
  for dir in "${REQUIRED_DIRECTORIES[@]}"; do
    if [[ ! -e $dir ]]; then
      print_status "Creating $dir"
      mkdir -p "$dir" || return 1
    fi
  done
}

# ------------------------------------------------------------------------------------------------------
stow_packages() {
  print_status "Stowing…"
  local package
  STOW_LINKED=0
  STOW_SKIPPED=0
  while IFS= read -r package; do
    print_status "Stowing $package"
    if stow -d "${DOTFILES_PATH:-$HOME/.dotfiles}" -t "$HOME" --restow "$package" 2>&1; then
      STOW_LINKED=$((STOW_LINKED + 1))
    else
      STOW_SKIPPED=$((STOW_SKIPPED + 1))
      print_warning "$package has local overrides — skipping conflicting files (expected on machine-specific configs)"
    fi
  done < <(stow_packages_list)
}

# ------------------------------------------------------------------------------------------------------
if ! restow "$@"; then
  print_status "Stow failed"
  exit 1
fi
