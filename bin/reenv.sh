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
#   - rbenv must be installed (optional - skips if not present)

reenv() {
  # Check if rbenv is installed
  if ! command -v rbenv >/dev/null 2>&1; then
    print_status "rbenv not installed, skipping Ruby setup"
    return 0
  fi

  # Check if version file exists
  if [[ ! -e "$HOME/.rbenv/version" ]]; then
    print_status "No rbenv version configured, skipping Ruby setup"
    return 0
  fi

  print_status "Installing Ruby version: $(cat "$HOME/.rbenv/version")"
  rbenv install -s "$(cat "$HOME/.rbenv/version")"
  print_status "Ruby setup complete"
}

print_status() {
  echo "[reenv] $1"
}

reenv
