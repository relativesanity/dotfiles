#!/usr/bin/env bash

set -euo pipefail # Exit on error, undefined vars, and pipeline failures
IFS=$'\n\t'       # Stricter word splitting

# Trap Ctrl-C (SIGINT) and exit gracefully
trap 'echo -e "\nInterrupted. Exiting..."; exit 130' INT

# Ruby version installer
# Supports:
#   - macOS (via asdf)
#
# Usage:
#   ./reenv.sh
#
# Prerequisites:
#   - asdf must be installed (optional - skips if not present)

reenv() {
  echo -e "\033[1;36m== reenv ==\033[0m"

  # Check if asdf is installed
  if ! command -v asdf >/dev/null 2>&1; then
    print_status "asdf not installed, skipping Ruby setup"
    return 0
  fi

  # Check if .tool-versions file exists
  if [[ ! -e "$HOME/.tool-versions" ]]; then
    print_status "No .tool-versions configured, skipping Ruby setup"
    return 0
  fi

  # Extract Ruby version from .tool-versions
  local ruby_version
  ruby_version=$(grep '^ruby ' "$HOME/.tool-versions" | awk '{print $2}' || true)

  if [[ -z "$ruby_version" ]]; then
    print_status "No Ruby version in .tool-versions, skipping Ruby setup"
    return 0
  fi

  # Ensure ruby plugin is installed
  if ! asdf plugin list | grep -q '^ruby$'; then
    print_status "Adding asdf ruby plugin"
    asdf plugin add ruby
  fi

  print_status "Checking Ruby version: $ruby_version"
  asdf install ruby "$ruby_version"
  print_status "Ruby setup complete"
}

print_status() {
  echo "$1"
}

reenv
