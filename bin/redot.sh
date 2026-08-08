#!/usr/bin/env bash

set -euo pipefail # Exit on error, undefined vars, and pipeline failures
IFS=$'\n\t'       # Stricter word splitting

# Trap Ctrl-C (SIGINT) and exit gracefully
trap 'echo -e "\nInterrupted. Exiting..."; exit 130' INT

# Dotfiles sync - pull, then packages, symlinks and language runtimes
# Runs repack, restow and reenv in that order (reenv needs rv, which repack
# installs). Each prints its own plan and asks before applying, so this script
# only orchestrates — it asks nothing of its own.
# Supports:
#   - macOS (via Homebrew)
#
# Usage:
#   ./redot.sh [--install-only | --prune] [-y]  (--help for the options)
#
# Prerequisites:
#   - dotfiles repository must be present

DOT_DIR="${DOTFILES_PATH:-$HOME/.dotfiles}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source-path=SCRIPTDIR source=lib/common.sh
source "$SCRIPT_DIR/lib/common.sh"

usage() {
  cat <<'EOF'
redot — pull the dotfiles repo, then apply all of it

Usage: redot.sh [--install-only | --prune] [-y | --yes]

Runs repack, then restow, then reenv (reenv needs rv, which repack installs).
Each prints its own plan and asks before applying — answer no to preview only.

Options (passed through to repack):
  --install-only  Install what's declared and missing; no upgrades, no removals.
  --prune         Use Brewfile.keep as it stands, removing anything not on it.

Options (redot's own):
  -y, --yes       Auto-confirm every plan instead of prompting. A bare repack
                  rebuilds Brewfile.keep from installed-by-hand apps before it
                  zaps, so this never removes anything undeclared and untracked;
                  --prune is itself the explicit request to remove what's on the
                  keep-list, -y or not.
  --help, -h      Show this.

restow and reenv take no options.
EOF
}

redot() {
  # Validate here rather than letting repack reject it later: by then this has
  # already pulled, and the error would name repack for a flag typed at redot.
  local yes=false
  local -a repack_args=()
  local arg
  for arg in "$@"; do
    case "$arg" in
      --help | -h)
        usage
        return 0
        ;;
      --install-only | --prune) repack_args+=("$arg") ;;
      -y | --yes) yes=true ;;
      *)
        print_failure "Unknown option: $arg"
        print_status "Try 'redot.sh --help'."
        return 1
        ;;
    esac
  done

  print_header redot

  require_terminal || return 1

  pull_dotfiles || return 1

  if [[ "$yes" == "true" ]]; then
    print_status "-y: auto-confirming every plan"
    export DOTFILES_ASSUME_YES=true
  fi

  # Only repack takes options; the other two are argument-free by design.
  if [[ ${#repack_args[@]} -gt 0 ]]; then
    "$SCRIPT_DIR/repack.sh" "${repack_args[@]}" || return 1
  else
    "$SCRIPT_DIR/repack.sh" || return 1
  fi
  echo
  "$SCRIPT_DIR/restow.sh" || return 1
  echo
  "$SCRIPT_DIR/reenv.sh" || return 1
}

# ------------------------------------------------------------------------------------------------------
# Fast-forward the repo before applying it. A checkout with no upstream (a local
# branch, a fresh bootstrap onto a detached branch) is not an error.
pull_dotfiles() {
  cd "$DOT_DIR" || {
    print_failure "No dotfiles repository at $DOT_DIR"
    return 1
  }

  if ! git rev-parse --abbrev-ref '@{upstream}' >/dev/null 2>&1; then
    print_status "No upstream configured, skipping pull"
    return 0
  fi

  print_status "Pulling $(git branch --show-current) from upstream"
  git pull || {
    print_failure "Failed to pull from upstream"
    return 1
  }
}

# ------------------------------------------------------------------------------------------------------
if ! redot "$@"; then
  print_status "Sync failed"
  exit 1
fi
