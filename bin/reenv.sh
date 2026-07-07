#!/usr/bin/env bash

set -euo pipefail # Exit on error, undefined vars, and pipeline failures
IFS=$'\n\t'       # Stricter word splitting

# Trap Ctrl-C (SIGINT) and exit gracefully
trap 'echo -e "\nInterrupted. Exiting..."; exit 130' INT

# rv runtime installer
# Installs the Ruby pinned in ~/.ruby-version and the CLI tools listed in
# ~/.default-gems (each as an isolated `rv tool`).
# Supports:
#   - macOS (via rv)
#
# Usage:
#   ./reenv.sh [--plan]
#
# Options:
#   --plan  Show whether the pinned Ruby and default tools are installed vs
#           missing, then exit without installing anything
#
# Prerequisites:
#   - rv must be installed (optional - skips if not present)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/ui.sh
source "$SCRIPT_DIR/lib/ui.sh"

RUBY_VERSION_FILE="$HOME/.ruby-version"
DEFAULT_GEMS_FILE="$HOME/.default-gems"

# Echo the pinned Ruby version (first non-blank, non-comment line, trimmed),
# or nothing if the file is absent/empty.
pinned_ruby() {
  [[ -e "$RUBY_VERSION_FILE" ]] || return 0
  while IFS= read -r line || [[ -n "$line" ]]; do
    line="${line#"${line%%[![:space:]]*}"}" # ltrim
    line="${line%"${line##*[![:space:]]}"}" # rtrim
    [[ -z "$line" || "$line" =~ ^# ]] && continue
    echo "$line"
    return 0
  done < "$RUBY_VERSION_FILE"
}

# Echo the declared default tools (gems installed as CLI tools), one per line.
default_gems() {
  [[ -e "$DEFAULT_GEMS_FILE" ]] || return 0
  while IFS= read -r line || [[ -n "$line" ]]; do
    line="${line#"${line%%[![:space:]]*}"}"
    line="${line%"${line##*[![:space:]]}"}"
    [[ -z "$line" || "$line" =~ ^# ]] && continue
    echo "$line"
  done < "$DEFAULT_GEMS_FILE"
}

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

  if ! command -v rv >/dev/null 2>&1; then
    print_status "rv not installed, skipping"
    return 0
  fi

  local version installed_now=0 already=0
  version="$(pinned_ruby)"

  if [[ -z "$version" ]]; then
    print_status "No ~/.ruby-version configured, skipping Ruby install"
  elif rv ruby find "$version" >/dev/null 2>&1; then
    print_status "Ruby $version already installed"
    already=1
  else
    print_status "Installing Ruby $version"
    rv ruby install "$version"
    installed_now=1
  fi

  # Default tools: `rv tool install` is idempotent (skips when already present),
  # so we can call it unconditionally for each declared gem.
  local tools=0
  while IFS= read -r gem; do
    [[ -z "$gem" ]] && continue
    tools=$((tools + 1))
    print_status "Installing tool: $gem"
    rv tool install "$gem"
  done < <(default_gems)

  print_status "rv setup complete"

  echo
  ui_box "reenv summary" "" \
    "Ruby: ${version:-none} (installed this run: ${installed_now}, already: ${already})" \
    "Tools: ${tools} declared"
}

# ------------------------------------------------------------------------------------------------------
# Read-only preview: compare ~/.ruby-version and ~/.default-gems against what
# rv already has installed. No side effects.
plan_reenv() {
  echo "Plan — reenv (dry run, nothing installed)"
  echo

  if ! command -v rv >/dev/null 2>&1; then
    echo "  rv not installed — skipped"
    return 0
  fi

  local version tools_installed
  version="$(pinned_ruby)"

  if [[ -z "$version" ]]; then
    echo "  No ~/.ruby-version configured — skipped"
  elif rv ruby find "$version" >/dev/null 2>&1; then
    printf '  ✓ ruby %s\n' "$version"
  else
    printf '  + ruby %s   (not installed)\n' "$version"
  fi

  tools_installed="$(rv tool list 2>/dev/null || true)"
  while IFS= read -r gem; do
    [[ -z "$gem" ]] && continue
    if grep -qiw "$gem" <<<"$tools_installed"; then
      printf '  ✓ tool %s\n' "$gem"
    else
      printf '  + tool %s   (not installed)\n' "$gem"
    fi
  done < <(default_gems)
}

# ------------------------------------------------------------------------------------------------------
reenv "$@"
