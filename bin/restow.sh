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
#   ./restow.sh                                 (--help for detail)
#
# Prints a plan and asks before applying. Takes no options.
#
# Prerequisites:
#   - Homebrew must be available (or will be installed)
#   - dotfiles repository must be present

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "$SCRIPT_DIR/lib/common.sh"

usage() {
  cat <<'EOF'
restow — symlink the configs into place with GNU Stow

Usage: restow.sh

Takes no options. It prints a plan and asks before applying — answer no to
preview only.

Skips any package whose target already exists as a real file, so local
overrides are never clobbered.
EOF
}

restow() {
  if [[ "${1:-}" == "--help" || "${1:-}" == "-h" ]]; then
    usage
    return 0
  fi
  if [[ $# -gt 0 ]]; then
    print_failure "Unknown option: $1"
    print_status "Try 'restow.sh --help'."
    return 1
  fi

  print_header restow

  if ! is_macos; then
    print_failure "Unsupported operating system"
    return 1
  fi

  plan_restow
  if ! confirm "Apply this plan?"; then
    print_status "Nothing applied"
    return 0
  fi
  echo

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
  local summary=(
    "Packages: $((STOW_LINKED + STOW_SKIPPED)) total"
    "Linked:   ${STOW_LINKED}"
  )
  if ((STOW_SKIPPED > 0)); then
    summary+=("NOT stowed: ${STOW_SKIPPED} — resolve the conflicting files and re-run:")
    summary+=("${STOW_SKIPPED_NAMES[@]/#/  }")
  fi
  print_block "restow summary" "${summary[@]}"
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
  STOW_SKIPPED_NAMES=()
  while IFS= read -r package; do
    print_status "Stowing $package"
    if stow -d "${DOTFILES_PATH:-$HOME/.dotfiles}" -t "$HOME" --restow "$package" 2>&1; then
      STOW_LINKED=$((STOW_LINKED + 1))
    else
      STOW_SKIPPED=$((STOW_SKIPPED + 1))
      STOW_SKIPPED_NAMES+=("$package")
      # Not "some files were skipped": stow aborts the whole package on the
      # first conflict, so NONE of it is linked. Say so — a silently unstowed
      # sh package leaves a new machine with no shell config at all.
      print_warning "$package NOT stowed — a conflicting file above blocks the whole package"
    fi
  done < <(stow_packages_list)
}

# ------------------------------------------------------------------------------------------------------
if ! restow "$@"; then
  print_status "Stow failed"
  exit 1
fi
