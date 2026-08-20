#!/usr/bin/env bash

set -euo pipefail # Exit on error, undefined vars, and pipeline failures
IFS=$'\n\t'       # Stricter word splitting

# Trap Ctrl-C (SIGINT) and exit gracefully
trap 'echo -e "\nInterrupted. Exiting..."; exit 130' INT

# Language runtime installer
# Installs everything declared in mise's global config
# (~/.config/mise/config.toml): the pinned Ruby and Node versions, and the
# CLI tools/language servers listed there via mise's gem: and npm: backends.
# Supports:
#   - macOS (via mise)
#
# Usage:
#   ./reenv.sh                                 (--help for detail)
#
# Prints a plan and asks before applying. Takes no options.
#
# Prerequisites:
#   - mise must be installed (optional - skips if not present)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source-path=SCRIPTDIR source=lib/common.sh
source "$SCRIPT_DIR/lib/common.sh"

usage() {
  cat <<'EOF'
reenv — install the language runtimes and global tools

Usage: reenv.sh

Takes no options. It prints a plan and asks before applying — answer no to
preview only.

Installs everything declared in mise's global config: the pinned Ruby and
Node versions, and the CLI tools/language servers listed there via mise's
gem: and npm: backends.
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

  if ! command -v mise >/dev/null 2>&1; then
    print_status "mise not installed, skipping"
    return 0
  fi

  plan_reenv
  if ! confirm "Apply this plan?"; then
    print_status "Nothing applied"
    return 0
  fi
  echo

  mise install
  print_status "reenv complete"
}

# ------------------------------------------------------------------------------------------------------
# Read-only preview: mise's own dry run diffs the declared config (Ruby, Node,
# gem:/npm: tools) against what's already installed. No side effects. Only
# called after reenv() has already confirmed mise is installed.
plan_reenv() {
  echo "Plan — reenv (dry run, nothing installed)"
  echo

  local out
  out="$(mise install --dry-run 2>&1)"
  if [[ -z "$out" ]]; then
    echo "  Nothing to install — everything declared is already installed"
  else
    echo "$out" | sed 's/^/  /'
  fi
}

# ------------------------------------------------------------------------------------------------------
reenv "$@"
