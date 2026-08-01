#!/usr/bin/env bash

set -euo pipefail # Exit on error, undefined vars, and pipeline failures
IFS=$'\n\t'       # Stricter word splitting

# Trap Ctrl-C (SIGINT) and exit gracefully
trap 'echo -e "\nInterrupted. Exiting..."; exit 130' INT

# Dotfiles repack script - converge Homebrew on what the Brewfiles declare
# Run bare it upgrades everything, installs what's declared, keeps the apps you
# installed by hand (Brewfile.keep) and removes the rest. It prints that plan and
# asks before applying.
# Supports:
#   - macOS (via Homebrew)
#
# Usage:
#   ./repack.sh [--install-only | --prune]      (--help for the options)
#
# Brewfile.keep lists the casks and App Store apps you installed by hand. A bare
# run rebuilds it, so those survive. To remove one: delete its line, then --prune.
#
# Prerequisites:
#   - Homebrew must be already installed for macOS
#   - dotfiles repository must be present

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source-path=SCRIPTDIR source=lib/common.sh
source "$SCRIPT_DIR/lib/common.sh"

usage() {
  cat <<'EOF'
repack — converge Homebrew on what the Brewfiles declare

Usage: repack.sh [--install-only | --prune]

Run bare it upgrades everything installed, installs what the Brewfiles declare,
keeps the apps you installed by hand (Brewfile.keep), and removes the rest.
It prints that plan and asks before applying — answer no to preview only.

Options:
  --install-only  Install what's declared and missing. No upgrades, nothing
                  removed, and the keep-list is left untouched.
  --prune         Use Brewfile.keep exactly as it stands rather than rebuilding
                  it, so anything not declared and not on it is removed.
  --help, -h      Show this.

The two options are mutually exclusive: one removes nothing, the other exists
to remove. To drop an app you installed by hand, delete its line from
Brewfile.keep and run --prune.
EOF
}

repack() {
  local install_only=false
  local prune=false
  local arg
  for arg in "$@"; do
    case "$arg" in
      --help | -h)
        usage
        return 0
        ;;
      --install-only) install_only=true ;;
      --prune) prune=true ;;
      *)
        print_failure "Unknown option: $arg"
        print_status "Try 'repack.sh --help'."
        return 1
        ;;
    esac
  done

  if [[ "$install_only" == "true" && "$prune" == "true" ]]; then
    print_failure "--install-only and --prune contradict: one removes nothing, the other exists to remove"
    return 1
  fi

  print_header repack

  require_terminal || return 1

  if ! is_macos; then
    print_failure "Unsupported operating system"
    return 1
  fi

  # Every step below returns explicitly rather than leaning on `set -e`: repack is
  # called from an `if !` condition, which disables errexit for everything it
  # calls, so a bare `|| print_failure` would print in red and carry on into the
  # removals regardless.
  ensure_homebrew || {
    print_failure "Homebrew could not be set up"
    return 1
  }
  migrate_legacy_keep_list

  local mode=full
  if [[ "$install_only" == "true" ]]; then
    mode=install-only
  elif [[ "$prune" == "true" ]]; then
    mode=prune
  fi

  # Show what this run would do and ask first — `brew bundle --zap` uninstalls
  # whatever the Brewfiles and the keep-list don't between them cover.
  plan_repack "$mode"
  if ! confirm "Apply this plan?"; then
    print_status "Nothing applied"
    return 0
  fi
  echo

  # Snapshot installed packages + keep-list before changes, so the summary can
  # show what this run actually installed, removed and kept.
  local before_formulae before_casks before_keep
  before_formulae="$(brew list --formula -1 2>/dev/null | sort || true)"
  before_casks="$(brew list --cask -1 2>/dev/null | sort || true)"
  before_keep="$(read_keep_list)"

  update_homebrew "$install_only" || {
    print_failure "Homebrew could not be updated"
    return 1
  }

  if [[ "$install_only" == "true" ]]; then
    print_status "Install only; leaving Brewfile.keep alone"
  elif [[ "$prune" == "true" ]]; then
    if [[ -s "${DOTFILES_PATH:-$HOME/.dotfiles}/Brewfile.keep" ]]; then
      print_status "Pruning: using Brewfile.keep as it stands"
    else
      print_status "Pruning: no Brewfile.keep, so nothing undeclared is kept"
    fi
  else
    # The keep-list is what survives the removals below. If it can't be rebuilt,
    # stop while nothing has been uninstalled yet rather than bundle without it.
    refresh_keep_list || {
      print_failure "The keep-list could not be rebuilt — stopping before cleanup so nothing is uninstalled"
      print_status "--install-only skips it entirely and removes nothing; --prune bundles against Brewfile.keep as it stands."
      return 1
    }
  fi

  # Past this point brew changes the system, so failures fall through to the
  # summary instead of returning early: it is the record of what did happen.
  local rc=0
  bundle_homebrew "$install_only" || {
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

  summarize_repack "$before_formulae" "$before_casks" "$before_keep"
  return "$rc"
}

# ------------------------------------------------------------------------------------------------------
# Echo the Brewfiles a real bundle would load (intent + keep-list), in order.
bundle_brewfiles() {
  local filepath
  filepath="${DOTFILES_PATH:-$HOME/.dotfiles}"
  intent_brewfiles
  [[ -s "$filepath/Brewfile.keep" ]] && echo "$filepath/Brewfile.keep"
}

# ------------------------------------------------------------------------------------------------------
# What this run would do, printed before the confirm. No side effects — every
# probe runs against the existing system state.
plan_repack() {
  local mode="${1:-full}"
  local line names outdated missing removable kept
  local brewfiles=()
  while IFS= read -r line; do brewfiles+=("$line"); done < <(bundle_brewfiles)

  names="$(for line in "${brewfiles[@]}"; do basename "$line"; done | paste -sd ',' - | sed 's/,/, /g')"

  echo "Plan — repack (nothing applied yet)"
  echo
  echo "Environment: $(detect_environment)"
  echo "Brewfiles:   $names"
  case "$mode" in
    install-only) echo "Mode:        install only — no upgrades, nothing removed" ;;
    prune) echo "Mode:        prune — Brewfile.keep used as it stands" ;;
    *) echo "Mode:        full — upgrade, install, and remove what isn't kept" ;;
  esac
  echo

  if [[ "$mode" != "install-only" ]]; then
    outdated="$(brew outdated --quiet 2>/dev/null || true)"
    echo "Would upgrade (outdated):"
    _plan_section "$outdated"
  fi

  missing="$(cat "${brewfiles[@]}" | brew bundle check --verbose --file=- 2>&1 | grep -E '^→|not installed' || true)"
  echo "Missing / would install:"
  _plan_section "$missing" "(all satisfied)"

  if [[ "$mode" == "install-only" ]]; then
    echo "Nothing is removed in this mode."
    echo
    return 0
  fi

  # What survives the removals: the keep-list. A full run rebuilds it from what
  # is installed but undeclared; a prune takes the file exactly as it stands.
  echo "Kept (installed by hand, NOT removed):"
  if [[ "$mode" == "prune" ]]; then
    kept="$(read_keep_list)"
    _plan_section "$kept"
  elif kept="$(compute_untracked 2>/dev/null)"; then
    _plan_section "$kept"
  else
    kept=""
    _plan_section "" "(unknown — brew probe failed; an apply would stop here)"
  fi

  # Simulate the post-keep-list state: cleanup against the Brewfiles plus what
  # would be kept, then drop brew's download-cache noise so only real removals
  # remain.
  removable="$(cat "${brewfiles[@]}" <(printf '%s\n' "$kept") | brew bundle cleanup --file=- 2>/dev/null \
    | grep -vE '^Run \`brew|brew cleanup|Caches/Homebrew' || true)"
  echo "Would remove:"
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
# `brew update` always runs so newly declared packages resolve; the upgrade of
# everything already installed is what --install-only skips.
update_homebrew() {
  local install_only="${1:-false}"
  print_status "Updating Homebrew"
  brew update --auto-update
  if [[ "$install_only" == "true" ]]; then
    print_status "Skipping upgrade of installed packages"
    return 0
  fi
  brew upgrade
}

# ------------------------------------------------------------------------------------------------------
# Write the given entries to Brewfile.keep (with the standard header). With no
# arguments, removes the file. The single writer for the keep-list.
write_keep_list() {
  local keep="${DOTFILES_PATH:-$HOME/.dotfiles}/Brewfile.keep"
  if [[ $# -eq 0 ]]; then
    rm -f "$keep"
    return 0
  fi
  # Build in a temp file and rename: `>"$keep"` truncates first, so a write that
  # died halfway would leave a short keep-list for the removals moments later.
  local tmp="$keep.tmp.$$"
  {
    echo "# Casks and App Store apps installed by hand, not declared in a Brewfile."
    echo "# Rebuilt by repack each run; edit a line out and --prune to remove that app."
    echo "# Promote keepers into Brewfile.home/.work to track them properly."
    printf '%s\n' "$@"
  } >"$tmp" || {
    rm -f "$tmp"
    return 1
  }
  mv -f "$tmp" "$keep"
}

# ------------------------------------------------------------------------------------------------------
# The keep-list was called Brewfile.cache until it was renamed. Carry it over
# rather than dropping it: a --prune run against a missing keep-list would
# uninstall every app it used to protect.
migrate_legacy_keep_list() {
  local dir="${DOTFILES_PATH:-$HOME/.dotfiles}"
  [[ -f "$dir/Brewfile.cache" ]] || return 0

  if [[ -e "$dir/Brewfile.keep" ]]; then
    rm -f "$dir/Brewfile.cache"
    print_status "Removed the superseded Brewfile.cache; Brewfile.keep is the keep-list"
    return 0
  fi

  mv "$dir/Brewfile.cache" "$dir/Brewfile.keep" || return 0
  print_status "Renamed Brewfile.cache to Brewfile.keep"
}

# ------------------------------------------------------------------------------------------------------
# Echo the keep-list's real entries (no comments/blanks), one per line.
read_keep_list() {
  local keep="${DOTFILES_PATH:-$HOME/.dotfiles}/Brewfile.keep"
  [[ -f "$keep" ]] || return 0
  # A keep-list of only comments greps to nothing, which is a legitimate empty
  # result, not an error.
  grep -vE '^[[:space:]]*(#|$)' "$keep" || true
}

# ------------------------------------------------------------------------------------------------------
# ------------------------------------------------------------------------------------------------------
# Rebuild Brewfile.keep from the mas apps and casks that are installed but not
# declared, so `brew bundle --zap` won't uninstall them. Self-correcting: promote
# an entry into Brewfile.home/.work and it stops appearing here.
refresh_keep_list() {
  local line count output
  local entries=()

  print_status "Rebuilding the keep-list from installed-by-hand apps"

  # Command substitution, not `< <(…)`: process substitution discards the probe's
  # exit status, so a failure would arrive here as an empty list — and an empty
  # list means "delete the keep-list", handing the removals every app it protected.
  output="$(compute_untracked)" || return 1
  while IFS= read -r line; do [[ -n "$line" ]] && entries+=("$line"); done <<<"$output"

  if [[ ${#entries[@]} -eq 0 ]]; then
    write_keep_list || return 1
    print_status "Nothing installed by hand; the keep-list is empty"
    return 0
  fi

  write_keep_list "${entries[@]}" || return 1

  count=${#entries[@]}
  print_status "Keeping $count $([[ $count -eq 1 ]] && echo app || echo apps) installed by hand:"
  printf '  %s\n' "${entries[@]}"
  print_warning "Promote keepers into Brewfile.home/.work to track them; the rest reappear here each run."
}

# ------------------------------------------------------------------------------------------------------
# ------------------------------------------------------------------------------------------------------
bundle_homebrew() {
  local install_only="${1:-false}"
  local line
  local brewfiles=()
  while IFS= read -r line; do brewfiles+=("$line"); done < <(bundle_brewfiles)

  print_status "Bundling Homebrew packages for environment: $(detect_environment)"

  # Tap trust is declarative: tapped packages carry `trusted: true` in the
  # Brewfiles, so `brew bundle` trusts them before tapping and rewrites
  # ~/.homebrew/trust.json to match on cleanup. No manual `brew trust` needed.
  if [[ "$install_only" == "true" ]]; then
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
# Post-run summary: package counts, what changed this run, and the kept apps
# with markers for any added or pruned during the run.
summarize_repack() {
  local before_formulae="$1" before_casks="$2" before_keep="$3"
  local after_formulae after_casks after_keep
  after_formulae="$(brew list --formula -1 2>/dev/null | sort || true)"
  after_casks="$(brew list --cask -1 2>/dev/null | sort || true)"
  after_keep="$(read_keep_list)"

  local added_f added_c removed_f removed_c entry lines=()
  added_f="$(count_lines "$(lines_added "$before_formulae" "$after_formulae")")"
  removed_f="$(count_lines "$(lines_added "$after_formulae" "$before_formulae")")"
  added_c="$(count_lines "$(lines_added "$before_casks" "$after_casks")")"
  removed_c="$(count_lines "$(lines_added "$after_casks" "$before_casks")")"

  lines+=("Formulae: $(count_lines "$after_formulae") installed  (+${added_f} / -${removed_f} this run)")
  lines+=("Casks:    $(count_lines "$after_casks") installed  (+${added_c} / -${removed_c} this run)")

  if [[ -n "$after_keep" ]]; then
    lines+=("Kept (installed by hand): $(count_lines "$after_keep")")
    while IFS= read -r entry; do
      [[ -z "$entry" ]] && continue
      if grep -qxF "$entry" <<<"$before_keep"; then
        lines+=("  $entry")
      else
        lines+=("  $entry  (added this run)")
      fi
    done <<<"$after_keep"
  else
    lines+=("Kept (installed by hand): none")
  fi

  # Apps on the keep-list before but gone now were pruned this run.
  while IFS= read -r entry; do
    [[ -z "$entry" ]] && continue
    lines+=("  $entry  (pruned this run)")
  done <<<"$(lines_added "$after_keep" "$before_keep")"

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
