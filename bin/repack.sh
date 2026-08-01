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
#   ./repack.sh [--plan] [--yes] [--update-only] [--skip-cache] [--clear-cache] [--select-cache]
#
# Run with no arguments it prints the plan and asks before applying.
#
# Options:
#   --plan          Print a read-only summary of what would change, then exit
#                   without touching anything
#   --yes           Apply without printing the plan or asking
#   --update-only   Run brew bundle without --zap and --force-cleanup
#   --skip-cache    Skip refreshing Brewfile.cache; honour the existing cache but
#                   zap anything not in the Brewfiles or that cache
#   --clear-cache   Delete Brewfile.cache then run with --skip-cache, zapping
#                   every untracked app. Lists the cache and confirms first
#   --select-cache  Interactively pick which untracked apps to prune; the rest
#                   stay cached (shielded). Selected apps are uninstalled on zap
#
# Prerequisites:
#   - Homebrew must be already installed for macOS
#   - dotfiles repository must be present

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "$SCRIPT_DIR/lib/common.sh"

repack() {
  local update_only=false
  local skip_cache=false
  local clear_cache=false
  local select_cache_mode=false
  local plan=false
  local yes=false
  for arg in "$@"; do
    [[ "$arg" == "--plan" ]] && plan=true
    [[ "$arg" == "--yes" ]] && yes=true
    [[ "$arg" == "--update-only" ]] && update_only=true
    [[ "$arg" == "--skip-cache" ]] && skip_cache=true
    [[ "$arg" == "--clear-cache" ]] && clear_cache=true
    [[ "$arg" == "--select-cache" ]] && select_cache_mode=true
  done

  if [[ "$plan" == "true" ]]; then
    plan_repack
    return 0
  fi

  print_header repack

  if ! is_macos; then
    print_failure "Unsupported operating system"
    return 1
  fi

  # Show the plan and ask before changing anything — `brew bundle --zap`
  # uninstalls whatever the Brewfiles don't declare. The two cache modes skip
  # this because they ask their own, more specific question further down.
  if [[ "$yes" == "false" && "$clear_cache" == "false" && "$select_cache_mode" == "false" ]]; then
    plan_repack
    if ! confirm "Apply this plan?"; then
      print_status "Nothing applied"
      return 0
    fi
    echo
  fi

  # Every step below returns explicitly rather than leaning on `set -e`: repack is
  # called from an `if !` condition, which disables errexit for everything it
  # calls, so a bare `|| print_failure` would print in red and carry on into the
  # zap regardless.
  ensure_homebrew || {
    print_failure "Homebrew could not be set up"
    return 1
  }

  if [[ "$clear_cache" == "true" ]]; then
    if clear_cache_prompt; then
      rm -f "${DOTFILES_PATH:-$HOME/.dotfiles}/Brewfile.cache"
      skip_cache=true
    else
      print_status "Clear cache cancelled"
      return 0
    fi
  fi

  if [[ "$select_cache_mode" == "true" ]]; then
    # select_cache writes a curated cache and returns 0 to proceed with the zap
    # that prunes the deselected apps; 1 means "nothing to do, leave things as
    # they are", and 2 means it could not tell — which is a failed run, not a
    # quiet no-op, so it must not exit 0.
    local select_rc=0
    select_cache || select_rc=$?
    case "$select_rc" in
      0) skip_cache=true ;;
      2) return 1 ;;
      *) return 0 ;;
    esac
  fi

  # Snapshot installed packages + cache before changes, so the summary can show
  # what this run actually installed, removed and (un)cached.
  local before_formulae before_casks before_cache
  before_formulae="$(brew list --formula -1 2>/dev/null | sort || true)"
  before_casks="$(brew list --cask -1 2>/dev/null | sort || true)"
  before_cache="$(read_cache_entries)"

  update_homebrew || {
    print_failure "Homebrew could not be updated"
    return 1
  }
  if [[ "$skip_cache" == "true" ]]; then
    if [[ -s "${DOTFILES_PATH:-$HOME/.dotfiles}/Brewfile.cache" ]]; then
      print_status "Skipping cache refresh; honouring existing Brewfile.cache"
    else
      print_status "Skipping cache refresh; no cache to honour"
    fi
  else
    # The cache is the shield the zap below reads. If it can't be built, stop
    # while nothing has been uninstalled yet rather than bundle without it.
    cache_untracked || {
      print_failure "Untracked apps could not be cached — stopping before cleanup so nothing is uninstalled"
      # Named because a reworded brew trailer would block every run, and this is
      # the way through. Deliberately hedged: it honours the *existing* cache and
      # still zaps anything that has drifted in since it was written.
      print_status "If the cache on disk is still current, --skip-cache bundles against it (and zaps uncached drift)."
      return 1
    }
  fi

  # Past this point brew changes the system, so failures fall through to the
  # summary instead of returning early: it is the record of what did happen.
  local rc=0
  bundle_homebrew "$update_only" || {
    print_failure "Homebrew could not be bundled"
    rc=1
  }
  if ((rc == 0)); then
    cleanup_homebrew || {
      print_failure "Homebrew could not be cleaned up"
      rc=1
    }
  fi
  # A plain `((rc == 0)) && print_status …` would itself return 1 when rc is 1,
  # aborting before the summary the moment this runs under a live errexit.
  if ((rc == 0)); then
    print_status "Repack complete"
  fi

  summarize_repack "$before_formulae" "$before_casks" "$before_cache"
  return "$rc"
}

# ------------------------------------------------------------------------------------------------------
# Echo the Brewfiles a real bundle would load (intent + cache), in order.
bundle_brewfiles() {
  local filepath
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
  # they are NOT removed. Reflect that here — including when the probe fails,
  # since "(none)" would promise an apply that silently removes nothing.
  echo "Shielded (cached, NOT removed):"
  if shielded="$(compute_untracked 2>/dev/null)"; then
    _plan_section "$shielded"
  else
    shielded=""
    _plan_section "" "(unknown — brew probe failed; an apply would stop here)"
  fi

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
    return 1
  fi

  if ! command -v brew >/dev/null 2>&1; then
    print_status "Configuring Homebrew"
    if ! eval "$(/opt/homebrew/bin/brew shellenv)"; then
      print_failure "Failed to configure Homebrew"
      return 1
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
# Write the given entries to Brewfile.cache (with the standard header). With no
# arguments, removes the cache. The single writer for the cache file.
write_cache() {
  local cache="${DOTFILES_PATH:-$HOME/.dotfiles}/Brewfile.cache"
  if [[ $# -eq 0 ]]; then
    rm -f "$cache"
    return 0
  fi
  # Build in a temp file and rename: `>"$cache"` truncates first, so a write that
  # died halfway would leave a short shield for the zap that runs moments later.
  local tmp="$cache.tmp.$$"
  {
    echo "# AUTO-GENERATED by repack — do not edit, gitignored."
    echo "# mas apps & casks installed but not declared in any Brewfile."
    echo "# Promote keepers into Brewfile.home/.work; the rest reappear here each run."
    printf '%s\n' "$@"
  } >"$tmp" || {
    rm -f "$tmp"
    return 1
  }
  mv -f "$tmp" "$cache"
}

# ------------------------------------------------------------------------------------------------------
# Echo the cache's real entries (no comments/blanks), one per line.
read_cache_entries() {
  local cache="${DOTFILES_PATH:-$HOME/.dotfiles}/Brewfile.cache"
  [[ -f "$cache" ]] && grep -vE '^[[:space:]]*(#|$)' "$cache" || true
}

# ------------------------------------------------------------------------------------------------------
# Interactively curate the cache: show the untracked apps, let the user pick which
# to prune, and write the rest back as the cache. Returns 0 when there is something
# to prune (caller proceeds with a --skip-cache zap that uninstalls them); returns
# non-zero to leave the system untouched.
select_cache() {
  local line c s in_selected untracked
  local candidates=() selected=() keepers=()

  # 2, not 1: the caller distinguishes "could not tell" from "nothing to do".
  untracked="$(compute_untracked)" || {
    print_failure "Could not determine which apps are untracked — leaving the cache untouched"
    return 2
  }
  while IFS= read -r line; do [[ -n "$line" ]] && candidates+=("$line"); done <<<"$untracked"

  if [[ ${#candidates[@]} -eq 0 ]]; then
    print_status "No untracked apps are being cached — nothing to review"
    return 1
  fi

  local prune_output
  prune_output="$(choose_multi "Apps to prune (unselected stay cached and shielded)" -- "${candidates[@]}")" || {
    print_status "Cache review cancelled — no changes"
    return 1
  }

  while IFS= read -r line; do [[ -n "$line" ]] && selected+=("$line"); done <<<"$prune_output"

  if [[ ${#selected[@]} -eq 0 ]]; then
    print_status "Nothing selected to prune — all ${#candidates[@]} stay cached"
    return 1
  fi

  for c in "${candidates[@]}"; do
    in_selected=false
    for s in ${selected[@]+"${selected[@]}"}; do
      [[ "$c" == "$s" ]] && {
        in_selected=true
        break
      }
    done
    [[ "$in_selected" == false ]] && keepers+=("$c")
  done

  print_warning "== prune cached apps =="
  echo "Will be removed from the cache and uninstalled on this run:"
  printf '  %s\n' "${selected[@]}"
  if [[ ${#keepers[@]} -gt 0 ]]; then
    echo "Staying cached (shielded):"
    printf '  %s\n' "${keepers[@]}"
  fi

  if ! confirm "Prune ${#selected[@]} app(s)?"; then
    print_status "Prune cancelled — no changes"
    return 1
  fi

  write_cache ${keepers[@]+"${keepers[@]}"}
  print_status "Curated cache written (${#keepers[@]} kept); pruning ${#selected[@]} on this run"
  return 0
}

# ------------------------------------------------------------------------------------------------------
# Capture untracked mas apps and casks into Brewfile.cache, so `brew bundle --zap`
# won't uninstall them. Self-correcting: promote an entry into Brewfile.home/.work
# and it stops appearing here. See CLAUDE.md for the loading-order note.
cache_untracked() {
  local line count output
  local entries=()

  print_status "Caching untracked mas apps and casks"

  # Command substitution, not `< <(…)`: process substitution discards the probe's
  # exit status, so a failure would arrive here as an empty list — and an empty
  # list means "delete the cache", handing the zap every app it was shielding.
  output="$(compute_untracked)" || return 1
  while IFS= read -r line; do [[ -n "$line" ]] && entries+=("$line"); done <<<"$output"

  if [[ ${#entries[@]} -eq 0 ]]; then
    write_cache || return 1
    print_status "No untracked App Store apps or casks"
    return 0
  fi

  write_cache "${entries[@]}" || return 1

  count=${#entries[@]}
  print_status "Cached $count untracked $([[ $count -eq 1 ]] && echo entry || echo entries) (shielded from cleanup):"
  printf '  %s\n' "${entries[@]}"
  print_warning "Promote keepers into Brewfile.home/.work to track them; the rest reappear here each run."
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

  # Fail closed: without a trustworthy list, this prompt would under-report what
  # is about to be uninstalled — the one thing it exists to show.
  all_untracked=$(compute_untracked) || {
    print_failure "Could not determine which apps are untracked — refusing to clear the cache"
    return 1
  }
  if [[ -n "$cached" ]]; then
    not_cached=$(printf '%s\n' "$all_untracked" | grep -vxF -f <(printf '%s\n' "$cached") || true)
  else
    not_cached="$all_untracked"
  fi

  if [[ -z "$cached" && -z "$not_cached" ]]; then
    print_status "No cache or untracked apps — nothing to clear"
    return 0
  fi

  print_warning "== clear cache =="
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
  local brewfiles=()
  while IFS= read -r line; do brewfiles+=("$line"); done < <(bundle_brewfiles)

  print_status "Bundling Homebrew packages for environment: $(detect_environment)"

  # Tap trust is declarative: tapped packages carry `trusted: true` in the
  # Brewfiles, so `brew bundle` trusts them before tapping and rewrites
  # ~/.homebrew/trust.json to match on cleanup. No manual `brew trust` needed.
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
# Count non-empty lines in a string.
count_lines() {
  [[ -z "$1" ]] && {
    echo 0
    return 0
  }
  grep -c . <<<"$1"
}

# Lines present in $2 but not $1 (both newline-sorted). Used for added/removed diffs.
lines_added() { comm -13 <(printf '%s\n' "$1") <(printf '%s\n' "$2"); }

# ------------------------------------------------------------------------------------------------------
# Post-run summary: package counts, what changed this run, and the cached
# (shielded) apps with markers for any added or pruned during the run.
summarize_repack() {
  local before_formulae="$1" before_casks="$2" before_cache="$3"
  local after_formulae after_casks after_cache
  after_formulae="$(brew list --formula -1 2>/dev/null | sort || true)"
  after_casks="$(brew list --cask -1 2>/dev/null | sort || true)"
  after_cache="$(read_cache_entries)"

  local added_f added_c removed_f removed_c entry lines=()
  added_f="$(count_lines "$(lines_added "$before_formulae" "$after_formulae")")"
  removed_f="$(count_lines "$(lines_added "$after_formulae" "$before_formulae")")"
  added_c="$(count_lines "$(lines_added "$before_casks" "$after_casks")")"
  removed_c="$(count_lines "$(lines_added "$after_casks" "$before_casks")")"

  lines+=("Formulae: $(count_lines "$after_formulae") installed  (+${added_f} / -${removed_f} this run)")
  lines+=("Casks:    $(count_lines "$after_casks") installed  (+${added_c} / -${removed_c} this run)")

  if [[ -n "$after_cache" ]]; then
    lines+=("Cached (shielded): $(count_lines "$after_cache")")
    while IFS= read -r entry; do
      [[ -z "$entry" ]] && continue
      if grep -qxF "$entry" <<<"$before_cache"; then
        lines+=("  $entry")
      else
        lines+=("  $entry  (added this run)")
      fi
    done <<<"$after_cache"
  else
    lines+=("Cached (shielded): none")
  fi

  # Apps that were cached before but are gone now were pruned this run.
  while IFS= read -r entry; do
    [[ -z "$entry" ]] && continue
    lines+=("  $entry  (pruned this run)")
  done <<<"$(lines_added "$after_cache" "$before_cache")"

  # update_homebrew already ran `brew upgrade`, so anything still outdated was
  # held back — pinned or version-locked. Surface it so a pinned formula (e.g.
  # kanata, pinned to keep macOS from revoking its keyboard permissions) doesn't
  # go stale unnoticed.
  local held
  held="$(brew outdated --formula --verbose 2>/dev/null || true)"
  if [[ -n "$held" ]]; then
    lines+=("Held back (pinned/outdated):")
    while IFS= read -r entry; do
      [[ -n "$entry" ]] && lines+=("  $entry")
    done <<<"$held"
  fi

  echo
  print_block "repack summary" "${lines[@]}"
}

# ------------------------------------------------------------------------------------------------------
if ! repack "$@"; then
  print_status "Repack failed"
  exit 1
fi
