#!/usr/bin/env bash

set -euo pipefail # Exit on error, undefined vars, and pipeline failures
IFS=$'\n\t'       # Stricter word splitting

# Trap Ctrl-C (SIGINT) and exit gracefully
trap 'echo -e "\nInterrupted. Exiting..."; exit 130' INT

# Dotfiles sync and update script
# Supports:
#   - macOS (via Homebrew)
#
# Usage:
#   ./redot.sh [--update-only] [--skip-cache] [--clear-cache]
#
# Options:
#   --update-only  Run brew bundle without --zap and --force-cleanup
#   --skip-cache   Skip refreshing Brewfile.cache; honour the existing cache but
#                  zap anything not in the Brewfiles or that cache
#   --clear-cache  Delete Brewfile.cache then run with --skip-cache, zapping
#                  every untracked app. Lists the cache and confirms first
#
# Prerequisites:
#   - dotfiles repository must be present

redot() {
  local update_only=false
  local skip_cache=false
  local clear_cache=false
  for arg in "$@"; do
    [[ "$arg" == "--update-only" ]] && update_only=true
    [[ "$arg" == "--skip-cache" ]] && skip_cache=true
    [[ "$arg" == "--clear-cache" ]] && clear_cache=true
  done

  cd "${DOTFILES_PATH:-$HOME/.dotfiles}"

  local current_branch
  current_branch="$(git branch --show-current)"
  echo "Current branch: $current_branch"

  # Check if current branch has upstream tracking
  if git rev-parse --abbrev-ref @{upstream} >/dev/null 2>&1; then
    echo "Pulling from upstream..."
    git pull || {
      echo "Error: Failed to pull from upstream"
      return 1
    }
  else
    echo "No upstream configured, skipping pull"
  fi

  local repack_args=()
  [[ "$update_only" == "true" ]] && repack_args+=(--update-only)
  [[ "$skip_cache" == "true" ]] && repack_args+=(--skip-cache)
  [[ "$clear_cache" == "true" ]] && repack_args+=(--clear-cache)
  ./bin/repack.sh ${repack_args[@]+"${repack_args[@]}"}
  echo
  ./bin/restow.sh
  echo
  ./bin/reenv.sh
}

redot "$@"
