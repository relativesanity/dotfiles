#!/usr/bin/env bash

set -euo pipefail # Exit on error, undefined vars, and pipeline failures
IFS=$'\n\t'       # Stricter word splitting

# Dotfiles sync and update script
#
# Since this is purely a script to run other scripts, it delegates all
# error handling and exiting to them

redot() {
  cd ${DOTFILES_PATH:-$HOME/.dotfiles} &&
    echo "Current branch: $(git branch --show-current)" &&
    git pull &&
    ./bin/repack.sh &&
    ./bin/restow.sh
}

redot
