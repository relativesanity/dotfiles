#!/usr/bin/env bash

set -euo pipefail # Exit on error, undefined vars, and pipeline failures
IFS=$'\n\t'       # Stricter word splitting

# Trap Ctrl-C (SIGINT) and exit gracefully
trap 'echo -e "\nInterrupted. Exiting..."; exit 130' INT

# Language runtime installer
# Installs the Ruby pinned in ~/.ruby-version, the CLI tools listed in
# ~/.default-gems (each as an isolated `rv tool`), and the global npm packages
# listed in ~/.default-npm (language servers with no Homebrew formula).
# Supports:
#   - macOS (via rv and npm)
#
# Usage:
#   ./reenv.sh                                 (--help for detail)
#
# Prints a plan and asks before applying. Takes no options.
#
# Prerequisites:
#   - rv must be installed (optional - skips if not present)
#   - npm must be installed (optional - skips if not present)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source-path=SCRIPTDIR source=lib/common.sh
source "$SCRIPT_DIR/lib/common.sh"

RUBY_VERSION_FILE="$HOME/.ruby-version"
DEFAULT_GEMS_FILE="$HOME/.default-gems"
DEFAULT_NPM_FILE="$HOME/.default-npm"

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

# Echo the declared global npm packages, one per line.
default_npm() {
  [[ -e "$DEFAULT_NPM_FILE" ]] || return 0
  while IFS= read -r line || [[ -n "$line" ]]; do
    line="${line#"${line%%[![:space:]]*}"}"
    line="${line%"${line##*[![:space:]]}"}"
    [[ -z "$line" || "$line" =~ ^# ]] && continue
    echo "$line"
  done < "$DEFAULT_NPM_FILE"
}

usage() {
  cat <<'EOF'
reenv — install the language runtimes and global tools

Usage: reenv.sh

Takes no options. It prints a plan and asks before applying — answer no to
preview only.

Installs the Ruby pinned in ~/.ruby-version, the CLI tools in ~/.default-gems
(each as an isolated rv tool), and the global npm packages in ~/.default-npm.
EOF
}

reenv() {
  if [[ "${1:-}" == "--help" || "${1:-}" == "-h" ]]; then
    usage
    return 0
  fi
  if [[ $# -gt 0 ]]; then
    print_failure "Unknown option: $1"
    print_status "Try 'reenv.sh --help'."
    return 1
  fi

  print_header reenv

  require_terminal || return 1

  plan_reenv
  if ! confirm "Apply this plan?"; then
    print_status "Nothing applied"
    return 0
  fi
  echo

  local version="" installed_now=0 already=0 tools=0

  # rv is optional and gated separately from npm, so a machine missing one still
  # gets everything the other manages.
  if ! command -v rv >/dev/null 2>&1; then
    print_status "rv not installed, skipping Ruby"
  else
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
    while IFS= read -r gem; do
      [[ -z "$gem" ]] && continue
      tools=$((tools + 1))
      print_status "Installing tool: $gem"
      rv tool install "$gem"
    done < <(default_gems)

    print_status "rv setup complete"
  fi

  # Global npm packages: language servers Homebrew has no formula for. Unlike
  # `rv tool install`, `npm i -g` refetches even when current, so check first.
  local pkgs=0 pkgs_installed=0
  if ! command -v npm >/dev/null 2>&1; then
    print_status "npm not installed, skipping global packages"
  else
    while IFS= read -r pkg; do
      [[ -z "$pkg" ]] && continue
      pkgs=$((pkgs + 1))
      if npm ls -g --depth=0 "$pkg" >/dev/null 2>&1; then
        print_status "npm package already installed: $pkg"
      else
        print_status "Installing npm package: $pkg"
        npm install -g "$pkg"
        pkgs_installed=$((pkgs_installed + 1))
      fi
    done < <(default_npm)
  fi

  echo
  print_block "reenv summary" \
    "Ruby: ${version:-none} (installed this run: ${installed_now}, already: ${already})" \
    "Tools: ${tools} declared" \
    "npm: ${pkgs} declared (installed this run: ${pkgs_installed})"
}

# ------------------------------------------------------------------------------------------------------
# Read-only preview: compare ~/.ruby-version, ~/.default-gems and ~/.default-npm
# against what rv and npm already have installed. No side effects.
plan_reenv() {
  echo "Plan — reenv (dry run, nothing installed)"
  echo

  if ! command -v rv >/dev/null 2>&1; then
    echo "  rv not installed — skipped"
  else
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
  fi

  if ! command -v npm >/dev/null 2>&1; then
    echo "  npm not installed — skipped"
  else
    while IFS= read -r pkg; do
      [[ -z "$pkg" ]] && continue
      if npm ls -g --depth=0 "$pkg" >/dev/null 2>&1; then
        printf '  ✓ npm %s\n' "$pkg"
      else
        printf '  + npm %s   (not installed)\n' "$pkg"
      fi
    done < <(default_npm)
  fi
}

# ------------------------------------------------------------------------------------------------------
reenv "$@"
