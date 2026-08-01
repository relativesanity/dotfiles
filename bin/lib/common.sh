#!/usr/bin/env bash

# Shared helpers for the dotfiles scripts.
#
# This file is meant to be *sourced*, not executed — it only defines functions
# and has no side effects at load time. It holds the plain output/prompt helpers
# every script uses and the brew intent/cache logic, which must live in exactly
# one place (see compute_untracked below).
#
# bootstrap.sh deliberately does NOT source this: it runs from `curl` before the
# repo exists, so it carries its own copies of the few helpers it needs.

# ------------------------------------------------------------------------------------------------------
# Output.
print_status() { echo "$1"; }
print_warning() { echo -e "\033[0;33m$1\033[0m"; }
print_failure() {
  echo -e "\033[0;31m$1\033[0m"
  return 1
}

# The banner each script prints on start.
print_header() { echo -e "\033[1;36m== $1 ==\033[0m"; }

# A titled block of indented lines, for end-of-run summaries.
print_block() {
  local title="$1"
  shift
  echo "$title"
  printf '  %s\n' "$@"
}

# ------------------------------------------------------------------------------------------------------
# Prompts.
#
# These ask on the controlling terminal, never on stdin. A script here can be
# reached through `curl | bash`, where stdin is the script text itself and a
# read would silently swallow it as the answer.

# confirm "question" — 0 for yes. Anything but y/yes is no.
#
# With no terminal reachable there is nobody to ask, so this answers YES: it
# guards "apply the plan I just printed?" in a run the caller started
# deliberately, and an unattended sync must neither stall nor quietly do
# nothing. Destructive one-offs that should refuse instead (--clear-cache) ask
# their own question rather than using this.
confirm() {
  local reply=""
  { printf '%s [y/N] ' "$1" >/dev/tty; read -r reply </dev/tty; } 2>/dev/null || return 0

  # Strict IFS ($'\n\t') leaves surrounding spaces on, so " y" would miss below.
  reply="${reply#"${reply%%[![:space:]]*}"}"
  reply="${reply%"${reply##*[![:space:]]}"}"

  [[ "$reply" =~ ^[Yy]([Ee][Ss])?$ ]]
}

# choose_multi "header" -- item… — echo the chosen items, one per line.
# Nothing is pre-selected, so an empty answer chooses nothing. Returns non-zero
# only when there is no terminal to ask on; choosing nothing is a success.
choose_multi() {
  local header="$1"
  shift
  [[ "${1:-}" == "--" ]] && shift

  local item i=1 line n
  {
    printf '%s\n' "$header"
    for item in "$@"; do
      printf '  %d) %s\n' "$i" "$item"
      i=$((i + 1))
    done
    printf 'Numbers to select (space-separated, blank = none): '
  } >/dev/tty 2>/dev/null || return 1
  read -r line </dev/tty 2>/dev/null || return 1

  local nums=()
  IFS=' ' read -ra nums <<<"$line"
  for n in ${nums[@]+"${nums[@]}"}; do
    [[ "$n" =~ ^[0-9]+$ ]] && ((n >= 1 && n <= $#)) && printf '%s\n' "${!n}"
  done
  return 0
}

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
  #
  # Keep stderr out of it: brew's "Warning: Skipping …" lines share the stream
  # only if merged, and one landing between the casks header and the names below
  # would be parsed word-by-word into bogus cache entries. Both markers this
  # reads — the header and the trailer — are on stdout.
  out="$(cat "${intent[@]}" | brew bundle cleanup --casks --file=- 2>/dev/null)" || probe_rc=$?
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
