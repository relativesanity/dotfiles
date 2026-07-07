#!/usr/bin/env bash

# Shared data + summary helpers for the dotfiles scripts.
#
# This file is meant to be *sourced*, not executed — it only defines
# functions and has no side effects at load time. It is the single home for
# the brew intent/cache logic (shared by repack.sh and the status summaries)
# and for the one-line status builders the dot menu header and doctor render.
#
# Every status_* builder is defensive (2>/dev/null, || true) so it can be used
# in a command substitution from a caller running under `set -euo pipefail`
# without aborting that caller when a probe legitimately fails.

# ------------------------------------------------------------------------------------------------------
is_macos() {
  [[ "$(uname)" == "Darwin" ]]
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
# Echo the stowable top-level package directories, one per line. Mirrors the
# discovery in restow.sh: skip dotdirs, bin, and the non-stowed kanata package.
stow_packages_list() {
  find "${DOTFILES_PATH:-$HOME/.dotfiles}" -maxdepth 1 -mindepth 1 -type d \
    ! -name '.*' ! -name 'bin' ! -name 'kanata' \
    -exec basename {} \; | sort
}

# ------------------------------------------------------------------------------------------------------
# One-line status summaries. Each echoes a short human string; callers compose
# them into the menu header and the doctor view.

status_git() {
  local dir branch behind ahead
  dir="${DOTFILES_PATH:-$HOME/.dotfiles}"
  branch="$(git -C "$dir" branch --show-current 2>/dev/null || echo '?')"

  if git -C "$dir" rev-parse --abbrev-ref '@{upstream}' >/dev/null 2>&1; then
    # rev-list --left-right --count prints "<behind>\t<ahead>" for @{upstream}...HEAD
    { read -r behind ahead; } < <(git -C "$dir" rev-list --left-right --count '@{upstream}...HEAD' 2>/dev/null || echo '0	0')
    if [[ "${behind:-0}" -gt 0 ]]; then
      printf '%s ↑%s ↓%s  (behind upstream)' "$branch" "${ahead:-0}" "${behind:-0}"
    else
      printf '%s ↑%s ↓%s' "$branch" "${ahead:-0}" "${behind:-0}"
    fi
  else
    printf '%s  (no upstream)' "$branch"
  fi
}

status_brew() {
  local untracked outdated
  command -v brew >/dev/null 2>&1 || { printf 'brew not installed'; return 0; }
  untracked="$(compute_untracked 2>/dev/null | grep -c . || true)"
  outdated="$(brew outdated --quiet 2>/dev/null | grep -c . || true)"
  printf '%s untracked · %s outdated' "${untracked:-0}" "${outdated:-0}"
}

status_stow() {
  local dir pkg total conflict
  dir="${DOTFILES_PATH:-$HOME/.dotfiles}"
  command -v stow >/dev/null 2>&1 || { printf 'stow not installed'; return 0; }
  total=0
  conflict=0
  while IFS= read -r pkg; do
    total=$((total + 1))
    if stow -n -d "$dir" -t "$HOME" --restow "$pkg" 2>&1 | grep -qi 'conflict'; then
      conflict=$((conflict + 1))
    fi
  done < <(stow_packages_list)

  if [[ "$conflict" -gt 0 ]]; then
    printf '%s packages linked · %s conflict(s)' "$total" "$conflict"
  else
    printf '%s packages linked' "$total"
  fi
}

status_rv() {
  local version
  command -v rv >/dev/null 2>&1 || { printf 'not installed'; return 0; }
  [[ -e "$HOME/.ruby-version" ]] || { printf 'no .ruby-version'; return 0; }

  # First non-blank, non-comment line, trimmed of surrounding whitespace.
  version="$(sed -e 's/#.*//' -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' "$HOME/.ruby-version" | grep -m1 .)"
  [[ -n "$version" ]] || { printf 'no .ruby-version'; return 0; }

  if rv ruby find "$version" >/dev/null 2>&1; then
    printf 'ruby %s  (in sync)' "$version"
  else
    printf 'ruby %s  (to install)' "$version"
  fi
}
