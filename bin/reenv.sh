#!/usr/bin/env bash

set -euo pipefail # Exit on error, undefined vars, and pipeline failures
IFS=$'\n\t'       # Stricter word splitting

# Trap Ctrl-C (SIGINT) and exit gracefully
trap 'echo -e "\nInterrupted. Exiting..."; exit 130' INT

# asdf version installer
# Installs plugins and versions from .tool-versions
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
    print_status "asdf not installed, skipping"
    return 0
  fi

  # Check if .tool-versions file exists
  if [[ ! -e "$HOME/.tool-versions" ]]; then
    print_status "No .tool-versions configured, skipping"
    return 0
  fi

  # Get list of installed plugins
  local installed_plugins
  installed_plugins=$(asdf plugin list 2>/dev/null || true)

  # Parse .tool-versions and install each plugin and version
  while IFS=' ' read -r plugin version; do
    # Skip empty lines and comments
    [[ -z "$plugin" || "$plugin" =~ ^# ]] && continue

    # Install plugin if not already installed
    if ! echo "$installed_plugins" | grep -q "^${plugin}$"; then
      print_status "Adding asdf plugin: $plugin"
      asdf plugin add "$plugin"
    fi

    print_status "Installing $plugin $version"
    asdf install "$plugin" "$version"
  done < "$HOME/.tool-versions"

  print_status "asdf setup complete"
}

print_status() {
  echo "$1"
}

reenv
