#!/usr/bin/env bash

set -euo pipefail # Exit on error, undefined vars, and pipeline failures
IFS=$'\n\t'       # Stricter word splitting

# Trap Ctrl-C (SIGINT) and exit gracefully
trap 'echo -e "\nInterrupted. Exiting..."; exit 130' INT

# Dotfiles sync - pull, then packages, symlinks and language runtimes
# Runs repack, restow and reenv in that order (reenv needs rv, which repack
# installs). Each of those prints its own plan and asks before applying, so
# this script only orchestrates — it asks nothing of its own.
# Supports:
#   - macOS (via Homebrew)
#
# Usage:
#   ./redot.sh [--plan] [--yes] [repack flags…]
#
# Options:
#   --plan  Print each script's dry-run plan in turn, then exit without
#           applying anything
#   --yes   Pass --yes to each script, applying without prompts
#
# Any other flags pass through to repack, e.g:
#   --update-only   bundle without removing anything
#   --skip-cache    zap apps not in the Brewfiles or the cache
#   --clear-cache   delete the cache and zap every untracked app
#   --select-cache  pick which untracked apps to prune; keep the rest cached
#
# Prerequisites:
#   - dotfiles repository must be present

DOT_DIR="${DOTFILES_PATH:-$HOME/.dotfiles}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "$SCRIPT_DIR/lib/common.sh"

redot() {
  local plan=false
  local yes=false
  local repack_args=()
  local arg
  for arg in "$@"; do
    case "$arg" in
      --plan) plan=true ;;
      --yes) yes=true ;;
      *) repack_args+=("$arg") ;;
    esac
  done

  if [[ "$plan" == "true" ]]; then
    plan_redot ${repack_args[@]+"${repack_args[@]}"}
    return 0
  fi

  print_header redot

  pull_dotfiles || return 1

  # --yes is the only flag the other two understand; the rest are repack's.
  local pass=()
  if [[ "$yes" == "true" ]]; then
    pass+=(--yes)
    repack_args+=(--yes)
  fi

  "$SCRIPT_DIR/repack.sh" ${repack_args[@]+"${repack_args[@]}"} || return 1
  echo
  "$SCRIPT_DIR/restow.sh" ${pass[@]+"${pass[@]}"} || return 1
  echo
  "$SCRIPT_DIR/reenv.sh" ${pass[@]+"${pass[@]}"} || return 1
}

# ------------------------------------------------------------------------------------------------------
# Fast-forward the repo before applying it. A checkout with no upstream (a local
# branch, a fresh bootstrap onto a detached branch) is not an error.
pull_dotfiles() {
  cd "$DOT_DIR" || {
    print_failure "No dotfiles repository at $DOT_DIR"
    return 1
  }

  if ! git rev-parse --abbrev-ref '@{upstream}' >/dev/null 2>&1; then
    print_status "No upstream configured, skipping pull"
    return 0
  fi

  print_status "Pulling $(git branch --show-current) from upstream"
  git pull || {
    print_failure "Failed to pull from upstream"
    return 1
  }
}

# ------------------------------------------------------------------------------------------------------
# Read-only preview: each script's own plan, in the order they would run.
plan_redot() {
  local script
  for script in repack restow reenv; do
    "$SCRIPT_DIR/$script.sh" --plan "$@"
    echo
  done
}

# ------------------------------------------------------------------------------------------------------
if ! redot "$@"; then
  print_status "Sync failed"
  exit 1
fi
