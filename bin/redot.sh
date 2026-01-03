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
#   ./redot.sh
#
# Prerequisites:
#   - dotfiles repository must be present

redot() {
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

  ./bin/repack.sh
  echo
  ./bin/restow.sh
  echo
  ./bin/reenv.sh
}

redot
