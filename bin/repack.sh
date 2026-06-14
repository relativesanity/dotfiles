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
#   ./repack.sh [--update-only] [--skip-cache] [--clear-cache]
#
# Options:
#   --update-only  Run brew bundle without --zap and --force-cleanup
#   --skip-cache   Skip refreshing Brewfile.cache; honour the existing cache but
#                  zap anything not in the Brewfiles or that cache
#   --clear-cache  Delete Brewfile.cache then run with --skip-cache, zapping
#                  every untracked app. Lists the cache and confirms first
#
# Prerequisites:
#   - Homebrew must be already installed for macOS
#   - dotfiles repository must be present

repack() {
  local update_only=false
  local skip_cache=false
  local clear_cache=false
  for arg in "$@"; do
    [[ "$arg" == "--update-only" ]] && update_only=true
    [[ "$arg" == "--skip-cache" ]] && skip_cache=true
    [[ "$arg" == "--clear-cache" ]] && clear_cache=true
  done

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
detect_environment() {
  if [[ "$(whoami)" == "relativesanity" ]]; then
    echo "home"
  else
    echo "work"
  fi
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
# Echo the tracked (intended) Brewfiles, in load order, one per line.
# Deliberately excludes Brewfile.cache so the cache is always recomputed
# against intent and shrinks as entries are promoted into a real Brewfile.
intent_brewfiles() {
  local filepath environment
  filepath="${DOTFILES_PATH:-$HOME/.dotfiles}"
  environment=$(detect_environment)

  echo "$filepath/Brewfile"
  echo "$filepath/Brewfile.$environment"
  [[ -f "$filepath/Brewfile.local" ]] && echo "$filepath/Brewfile.local"
}

# ------------------------------------------------------------------------------------------------------
# Echo untracked mas apps and casks — installed but not declared in any tracked
# Brewfile — as Brewfile entries, one per line. No side effects.
compute_untracked() {
  local line id name declared
  local intent=()
  while IFS= read -r line; do intent+=("$line"); done < <(intent_brewfiles)

  # Casks: defer matching to brew (handles tap prefixes, versions, metacharacters).
  # Piping the Brewfile via stdin makes stdin a non-tty, suppressing the cleanup
  # prompt; `|| true` absorbs the exit-1-on-drift. Parse only the casks section;
  # tokens never contain spaces, so whitespace-splitting the columns is safe.
  cat "${intent[@]}" | brew bundle cleanup --casks --file=- 2>/dev/null | awk '
    /^Would uninstall casks:/ { grab = 1; next }
    /^Would / || /^Run `brew/ { grab = 0 }
    grab { for (i = 1; i <= NF; i++) print "cask \"" $i "\"" }
  ' || true

  # mas: pure integer-id comparison, computed locally (no normalization needed).
  # `mas list` prints "<id>  <name>  (<version>)"; take the id, drop the trailing
  # version, and join the middle fields back into the name.
  if command -v mas >/dev/null 2>&1; then
    declared=$(grep -rhoE 'id: [0-9]+' "${intent[@]}" | grep -oE '[0-9]+' | sort -u)
    while IFS=$'\t' read -r id name; do
      grep -qxF "$id" <<<"$declared" && continue
      echo "mas \"$name\", id: $id"
    done < <(mas list | awk '{ id=$1; n=$2; for (i=3; i<NF; i++) n=n" "$i; print id "\t" n }')
  fi
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
  filepath="${DOTFILES_PATH:-$HOME/.dotfiles}"
  environment=$(detect_environment)

  print_status "Bundling Homebrew packages for environment: $environment"

  brewfiles=()
  while IFS= read -r line; do brewfiles+=("$line"); done < <(intent_brewfiles)

  if [[ -s "$filepath/Brewfile.cache" ]]; then
    brewfiles+=("$filepath/Brewfile.cache")
  fi

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
print_status() {
  echo "$1"
}

print_failure() {
  echo -e "\033[0;31m$1\033[0m"
  return 1
}

# ------------------------------------------------------------------------------------------------------
is_macos() {
  [[ "$(uname)" == "Darwin" ]]
}

# ------------------------------------------------------------------------------------------------------
if ! repack "$@"; then
  print_status "Repack failed"
  exit 1
fi
