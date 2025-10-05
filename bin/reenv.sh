#!/usr/bin/env bash

set -euo pipefail # Exit on error, undefined vars, and pipeline failures
IFS=$'\n\t'       # Stricter word splitting

# Ruby version installer
# Supports:
#   - macOS (via rbenv)
#
# Usage:
#   ./reenv.sh
#
# Prerequisites:
#   - rbenv must be installed

reenv() {
  [[ -e "$HOME/.rbenv/version" ]] && \
    rbenv install -s "$(cat "$HOME/.rbenv/version")"
}

reenv
