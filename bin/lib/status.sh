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
#
# Returns non-zero, having echoed nothing, if either probe fails. Callers MUST
# check that status: the cache built from this list is what shields undeclared
# apps from `brew bundle --zap`, so a failed probe read as "nothing untracked"
# would uninstall the very apps it exists to protect.
compute_untracked() {
  # `probe_rc`, not `status`: this file is sourced, and `status` is read-only in zsh.
  local line id name declared out mas_list probe_rc=0
  local intent=() result=()
  while IFS= read -r line; do intent+=("$line"); done < <(intent_brewfiles)

  # Casks: defer matching to brew (handles tap prefixes, versions, metacharacters).
  # Piping the Brewfile via stdin makes stdin a non-tty, suppressing the cleanup
  # prompt. brew exits 1 both when it finds drift and when it fails outright, so
  # the status alone can't tell those apart — but a run that got far enough to
  # report either exits 0 or ends with brew's "Run `brew bundle cleanup --force`"
  # trailer. Anything else (invalid Brewfile, broken tap) is a genuine failure.
  out="$(cat "${intent[@]}" | brew bundle cleanup --casks --file=- 2>&1)" || probe_rc=$?
  if ((probe_rc != 0)) && ! grep -qF 'Run `brew bundle cleanup --force`' <<<"$out"; then
    return 1
  fi

  # Parse only the casks section; tokens never contain spaces, so
  # whitespace-splitting the columns is safe.
  while IFS= read -r line; do
    [[ -n "$line" ]] && result+=("$line")
  done < <(awk '
    /^Would uninstall casks:/ { grab = 1; next }
    /^Would / || /^Run `brew/ { grab = 0 }
    grab { for (i = 1; i <= NF; i++) print "cask \"" $i "\"" }
  ' <<<"$out")

  # mas: pure integer-id comparison, computed locally (no normalization needed).
  # `mas list` prints "<id>  <name>  (<version>)"; take the id, drop the trailing
  # version, and join the middle fields back into the name.
  if command -v mas >/dev/null 2>&1; then
    mas_list="$(mas list)" || return 1
    declared=$(grep -rhoE 'id: [0-9]+' "${intent[@]}" | grep -oE '[0-9]+' | sort -u)
    while IFS=$'\t' read -r id name; do
      [[ -n "$id" ]] || continue
      grep -qxF "$id" <<<"$declared" && continue
      result+=("mas \"$name\", id: $id")
    done < <(awk '{ id=$1; n=$2; for (i=3; i<NF; i++) n=n" "$i; print id "\t" n }' <<<"$mas_list")
  fi

  # Buffered until here so a late failure can never leave a caller holding a
  # partial list it would mistake for the whole picture.
  ((${#result[@]})) && printf '%s\n' "${result[@]}"
  return 0
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
  local untracked outdated list
  command -v brew >/dev/null 2>&1 || { printf 'brew not installed'; return 0; }
  # '?' rather than 0 when the probe fails — "0 untracked" would read as "nothing
  # to shield", which is the opposite of what an unknown answer means here.
  if list="$(compute_untracked 2>/dev/null)"; then
    untracked="$(grep -c . <<<"$list" || true)"
  else
    untracked='?'
  fi
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

# ------------------------------------------------------------------------------------------------------
# Global npm tools declared in ~/.default-npm vs what npm has installed.
# Lists installed packages once and matches locally: `npm ls` costs ~0.3s, and
# this runs on every menu render.
status_npm() {
  local installed declared=0 missing=0 pkg
  command -v npm >/dev/null 2>&1 || { printf 'not installed'; return 0; }
  [[ -e "$HOME/.default-npm" ]] || { printf 'no .default-npm'; return 0; }

  installed="$(npm ls -g --depth=0 --parseable 2>/dev/null || true)"

  while IFS= read -r pkg || [[ -n "$pkg" ]]; do
    pkg="$(sed -e 's/#.*//' -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' <<<"$pkg")"
    [[ -z "$pkg" ]] && continue
    declared=$((declared + 1))
    grep -q "/${pkg}\$" <<<"$installed" || missing=$((missing + 1))
  done < "$HOME/.default-npm"

  if [[ "$declared" -eq 0 ]]; then
    printf 'none declared'
  elif [[ "$missing" -eq 0 ]]; then
    printf '%s tool(s)  (in sync)' "$declared"
  else
    printf '%s of %s to install' "$missing" "$declared"
  fi
}
