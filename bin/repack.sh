#!/usr/bin/env bash

set -euo pipefail # Exit on error, undefined vars, and pipeline failures
IFS=$'\n\t'       # Stricter word splitting

# Trap Ctrl-C (SIGINT) and exit gracefully
trap 'echo -e "\nInterrupted. Exiting..."; exit 130' INT

# Dotfiles repack script
# Supports:
#   - macOS (via Homebrew)
#
# Usage:
#   ./repack.sh [--plan] [--update-only] [--skip-cache] [--clear-cache]
#
# Options:
#   --plan         Print a read-only summary of what would change, then exit
#                  without touching anything
#   --update-only  Run brew bundle without --zap and --force-cleanup
#   --skip-cache   Skip refreshing Brewfile.cache; honour the existing cache but
#                  zap anything not in the Brewfiles or that cache
#   --clear-cache  Delete Brewfile.cache then run with --skip-cache, zapping
#                  every untracked app. Lists the cache and confirms first
#
# Prerequisites:
#   - Homebrew must be already installed for macOS
#   - dotfiles repository must be present

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/status.sh
source "$SCRIPT_DIR/lib/status.sh"
# shellcheck source=lib/ui.sh
source "$SCRIPT_DIR/lib/ui.sh"

repack() {
  local update_only=false
  local skip_cache=false
  local clear_cache=false
  local plan=false
  for arg in "$@"; do
    [[ "$arg" == "--plan" ]] && plan=true
    [[ "$arg" == "--update-only" ]] && update_only=true
    [[ "$arg" == "--skip-cache" ]] && skip_cache=true
    [[ "$arg" == "--clear-cache" ]] && clear_cache=true
  done

  if [[ "$plan" == "true" ]]; then
    plan_repack
    return 0
  fi

  echo -e "\033[1;36m== repack ==\033[0m"

  if ! is_macos; then
    print_failure "Unsupported operating system"
    return 1
  fi

  ensure_homebrew || print_failure "Homebrew could not be set up"

  if [[ "$clear_cache" == "true" ]]; then
    if clear_cache_prompt; then
      rm -f "${DOTFILES_PATH:-$HOME/.dotfiles}/Brewfile.cache"
      skip_cache=true
    else
      print_status "Clear cache cancelled"
      return 0
    fi
  fi

  update_homebrew || print_failure "Homebrew could not be updated"
  if [[ "$skip_cache" == "true" ]]; then
    if [[ -s "${DOTFILES_PATH:-$HOME/.dotfiles}/Brewfile.cache" ]]; then
      print_status "Skipping cache refresh; honouring existing Brewfile.cache"
    else
      print_status "Skipping cache refresh; no cache to honour"
    fi
  else
    cache_untracked || print_failure "Untracked apps could not be cached"
  fi
  bundle_homebrew "$update_only" || print_failure "Homebrew could not be bundled"
  cleanup_homebrew || print_failure "Homebrew could not be cleaned up"
  print_status "Repack complete"
}

# ------------------------------------------------------------------------------------------------------
# Echo the Brewfiles a real bundle would load (intent + cache), in order.
bundle_brewfiles() {
  local filepath line
  filepath="${DOTFILES_PATH:-$HOME/.dotfiles}"
  intent_brewfiles
  [[ -s "$filepath/Brewfile.cache" ]] && echo "$filepath/Brewfile.cache"
}

# ------------------------------------------------------------------------------------------------------
# Read-only preview: what a default repack would install, upgrade, shield and
# remove. No side effects — every probe runs against the existing system state.
plan_repack() {
  local line names outdated missing removable shielded
  local brewfiles=()
  while IFS= read -r line; do brewfiles+=("$line"); done < <(bundle_brewfiles)

  names="$(for line in "${brewfiles[@]}"; do basename "$line"; done | paste -sd ',' - | sed 's/,/, /g')"

  echo "Plan — repack (dry run, nothing applied)"
  echo
  echo "Environment: $(detect_environment)"
  echo "Brewfiles:   $names"
  echo

  outdated="$(brew outdated --quiet 2>/dev/null || true)"
  echo "Would upgrade (outdated):"
  _plan_section "$outdated"

  missing="$(cat "${brewfiles[@]}" | brew bundle check --verbose --file=- 2>&1 | grep -E '^→|not installed' || true)"
  echo "Missing / would install:"
  _plan_section "$missing" "(all satisfied)"

  # On a default apply, untracked apps are cached (shielded) before the zap, so
  # they are NOT removed. Reflect that here.
  shielded="$(compute_untracked 2>/dev/null || true)"
  echo "Shielded (cached, NOT removed):"
  _plan_section "$shielded"

  # Simulate the post-cache state: cleanup against intent + the apps that would
  # be shielded, then drop brew's download-cache cleanup noise so only app/tap
  # removals remain.
  removable="$(cat "${brewfiles[@]}" <(printf '%s\n' "$shielded") | brew bundle cleanup --file=- 2>/dev/null \
    | grep -vE '^Run \`brew|brew cleanup|Caches/Homebrew' || true)"
  echo "Would remove on --zap (uncached drift):"
  _plan_section "$removable"
}

# Print an indented block, or a placeholder when empty.
_plan_section() {
  local body="$1" empty="${2:-(none)}"
  if [[ -n "$body" ]]; then
    printf '%s\n' "$body" | sed 's/^/  /'
  else
    printf '  %s\n' "$empty"
  fi
  echo
}

# ------------------------------------------------------------------------------------------------------
ensure_homebrew() {
  if [[ ! -e /opt/homebrew/bin/brew ]]; then
    print_failure "Homebrew installation not found"
  fi

  if ! command -v brew >/dev/null 2>&1; then
    print_status "Configuring Homebrew"
    if ! eval "$(/opt/homebrew/bin/brew shellenv)"; then
      print_failure "Failed to configure Homebrew"
    fi
  fi
  print_status "Homebrew is available"
}

# ------------------------------------------------------------------------------------------------------
update_homebrew() {
  print_status "Updating Homebrew"
  brew update --auto-update
  brew upgrade
}

# ------------------------------------------------------------------------------------------------------
# Capture untracked mas apps and casks into Brewfile.cache, so `brew bundle --zap`
# won't uninstall them. Self-correcting: promote an entry into Brewfile.home/.work
# and it stops appearing here. See CLAUDE.md for the loading-order note.
cache_untracked() {
  local filepath cache line count
  local entries=()
  filepath="${DOTFILES_PATH:-$HOME/.dotfiles}"
  cache="$filepath/Brewfile.cache"

  print_status "Caching untracked mas apps and casks"

  while IFS= read -r line; do entries+=("$line"); done < <(compute_untracked)

  if [[ ${#entries[@]} -eq 0 ]]; then
    rm -f "$cache"
    print_status "No untracked App Store apps or casks"
    return 0
  fi

  {
    echo "# AUTO-GENERATED by repack — do not edit, gitignored."
    echo "# mas apps & casks installed but not declared in any Brewfile."
    echo "# Promote keepers into Brewfile.home/.work; the rest reappear here each run."
    printf '%s\n' "${entries[@]}"
  } >"$cache"

  count=${#entries[@]}
  print_status "Cached $count untracked $([[ $count -eq 1 ]] && echo entry || echo entries) (shielded from cleanup):"
  printf '  %s\n' "${entries[@]}"
  echo -e "\033[0;33mPromote keepers into Brewfile.home/.work to track them; the rest reappear here each run.\033[0m"
}

# ------------------------------------------------------------------------------------------------------
# List what --clear-cache will uninstall — the current cache plus any untracked
# apps not yet cached — and ask for confirmation. Returns 0 to proceed, 1 to abort.
clear_cache_prompt() {
  local filepath cache cached all_untracked not_cached reply
  filepath="${DOTFILES_PATH:-$HOME/.dotfiles}"
  cache="$filepath/Brewfile.cache"

  cached=""
  [[ -f "$cache" ]] && cached=$(grep -vE '^[[:space:]]*(#|$)' "$cache" || true)

  all_untracked=$(compute_untracked)
  if [[ -n "$cached" ]]; then
    not_cached=$(printf '%s\n' "$all_untracked" | grep -vxF -f <(printf '%s\n' "$cached") || true)
  else
    not_cached="$all_untracked"
  fi

  if [[ -z "$cached" && -z "$not_cached" ]]; then
    print_status "No cache or untracked apps — nothing to clear"
    return 0
  fi

  echo -e "\033[0;33m== clear cache ==\033[0m"
  echo "Deletes Brewfile.cache and zaps every untracked app on this bundle:"
  if [[ -n "$cached" ]]; then
    echo "Currently cached (will be uninstalled):"
    printf '%s\n' "$cached" | sed 's/^/  /'
  fi
  if [[ -n "$not_cached" ]]; then
    echo "Installed but not cached (will also be uninstalled):"
    printf '%s\n' "$not_cached" | sed 's/^/  /'
  fi

  if [[ ! -t 0 ]]; then
    echo "Not an interactive terminal; refusing to clear cache." >&2
    return 1
  fi

  read -r -p "Proceed? [y/N] " reply
  case "$reply" in
    [Yy] | [Yy][Ee][Ss]) return 0 ;;
    *) return 1 ;;
  esac
}

# ------------------------------------------------------------------------------------------------------
bundle_homebrew() {
  local update_only="${1:-false}"
  local line
  brewfiles=()
  while IFS= read -r line; do brewfiles+=("$line"); done < <(bundle_brewfiles)

  print_status "Bundling Homebrew packages for environment: $(detect_environment)"

  if [[ "$update_only" == "true" ]]; then
    cat "${brewfiles[@]}" | brew bundle --file=-
  else
    cat "${brewfiles[@]}" | brew bundle --file=- --zap --force-cleanup
  fi
}

cleanup_homebrew() {
  print_status "Running cleanup"
  brew cleanup
}

# ------------------------------------------------------------------------------------------------------
if ! repack "$@"; then
  print_status "Repack failed"
  exit 1
fi
