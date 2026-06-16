#!/usr/bin/env bash

set -euo pipefail # Exit on error, undefined vars, and pipeline failures
IFS=$'\n\t'       # Stricter word splitting

# Trap Ctrl-C (SIGINT) and exit gracefully
trap 'echo -e "\nInterrupted. Exiting..."; exit 130' INT

# Dotfiles sync and update shim
# Delegates to `dot sync`, which owns the pull → repack → restow → reenv
# orchestration. Kept so the bootstrap entry point and muscle memory still work.
# Supports:
#   - macOS (via Homebrew)
#
# Usage:
#   ./redot.sh [--update-only] [--skip-cache] [--clear-cache]
#
# Options:
#   --update-only  Run brew bundle without --zap and --force-cleanup
#   --skip-cache   Skip refreshing Brewfile.cache; honour the existing cache but
#                  zap anything not in the Brewfiles or that cache
#   --clear-cache  Delete Brewfile.cache then run with --skip-cache, zapping
#                  every untracked app. Lists the cache and confirms first
#
# Prerequisites:
#   - dotfiles repository must be present

exec "${DOTFILES_PATH:-$HOME/.dotfiles}/bin/dot.sh" sync "$@"
