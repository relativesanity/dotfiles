#!/usr/bin/env bash

set -euo pipefail # Exit on error, undefined vars, and pipeline failures
IFS=$'\n\t'       # Stricter word splitting

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
  cd "${DOTFILES_PATH:-$HOME/.dotfiles}" &&
    echo "Current branch: $(git branch --show-current)" &&
    git pull &&
    ./bin/repack.sh &&
    ./bin/restow.sh &&
    ./bin/reenv.sh
}

redot
