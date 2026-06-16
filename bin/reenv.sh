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
#   ./reenv.sh [--plan]
#
# Options:
#   --plan  Show which plugins/versions are installed vs missing, then exit
#           without adding plugins or installing versions
#
# Prerequisites:
#   - asdf must be installed (optional - skips if not present)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/ui.sh
source "$SCRIPT_DIR/lib/ui.sh"

reenv() {
  local plan=false
  for arg in "$@"; do
    [[ "$arg" == "--plan" ]] && plan=true
  done

  if [[ "$plan" == "true" ]]; then
    plan_reenv
    return 0
  fi

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

    print_status "Updating $plugin versions"
    asdf plugin update "$plugin"

    # 'system' is a pseudo-version meaning "defer to the OS install"; the
    # plugin must still exist so project .tool-versions pins resolve, but
    # there is nothing to install for it.
    if [[ "$version" == "system" ]]; then
      print_status "Using system $plugin, skipping install"
      continue
    fi

    print_status "Installing $plugin $version"
    asdf install "$plugin" "$version"
  done < "$HOME/.tool-versions"

  print_status "asdf setup complete"
}

# ------------------------------------------------------------------------------------------------------
# Read-only preview: compare .tool-versions against what asdf already has.
plan_reenv() {
  local plugin version installed_plugins

  echo "Plan — reenv (dry run, nothing installed)"
  echo

  if ! command -v asdf >/dev/null 2>&1; then
    echo "  asdf not installed — skipped"
    return 0
  fi
  if [[ ! -e "$HOME/.tool-versions" ]]; then
    echo "  No ~/.tool-versions configured — skipped"
    return 0
  fi

  installed_plugins=$(asdf plugin list 2>/dev/null || true)

  while IFS=' ' read -r plugin version; do
    [[ -z "$plugin" || "$plugin" =~ ^# ]] && continue

    if ! echo "$installed_plugins" | grep -q "^${plugin}$"; then
      printf '  + %s %s   (plugin not added)\n' "$plugin" "$version"
    elif [[ "$version" == "system" ]]; then
      printf '  ✓ %s %s   (system)\n' "$plugin" "$version"
    elif asdf where "$plugin" "$version" >/dev/null 2>&1; then
      printf '  ✓ %s %s\n' "$plugin" "$version"
    else
      printf '  + %s %s   (version not installed)\n' "$plugin" "$version"
    fi
  done < "$HOME/.tool-versions"
}

# ------------------------------------------------------------------------------------------------------
reenv "$@"
