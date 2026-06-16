#!/usr/bin/env bash

# Presentation helpers for the dotfiles scripts — the ONLY file that knows about
# gum. Source it, don't execute it.
#
# Every wrapper degrades gracefully: when gum is missing or output is not a TTY
# it falls back to plain text, and the interactive wrappers (menu/confirm/prompt)
# take a safe default (decline / no selection) rather than hang. This keeps the
# piped `curl | bash` bootstrap and any non-interactive/CI run working with zero
# hard dependency on gum.

# ------------------------------------------------------------------------------------------------------
# gum is available AND we can draw to stdout.
_ui_can_render() { command -v gum >/dev/null 2>&1 && [[ -t 1 ]]; }
# gum is available AND we can read keys from the terminal. Gated on stdin only:
# prompts are typically captured via `$(ui_menu …)`, where stdout is a pipe but
# stdin (and the terminal gum renders to) is still attached. Checking -t 1 here
# would wrongly disable every prompt used in a command substitution.
_ui_can_prompt() { command -v gum >/dev/null 2>&1 && [[ -t 0 ]]; }

# ------------------------------------------------------------------------------------------------------
# Plain status lines (kept for parity with the existing scripts' output).
print_status() { echo "$1"; }
print_warning() { echo -e "\033[0;33m$1\033[0m"; }
print_failure() {
  echo -e "\033[0;31m$1\033[0m"
  return 1
}

# ------------------------------------------------------------------------------------------------------
# Titled header. ui_header "title" ["right-label"]
ui_header() {
  local title="$1" right="${2:-}"
  local line="$title"
  [[ -n "$right" ]] && line="$title  ·  $right"

  if _ui_can_render; then
    gum style --border rounded --padding "0 1" --border-foreground 212 "$line"
  else
    echo
    echo "== $line =="
  fi
}

# ------------------------------------------------------------------------------------------------------
# Render one or more lines inside a box (each argument is a line).
ui_box() {
  if _ui_can_render; then
    gum style --border rounded --padding "0 1" --border-foreground 240 "$@"
  else
    printf '%s\n' "$@"
  fi
}

# ------------------------------------------------------------------------------------------------------
# Menu: ui_menu "prompt" opt1 opt2 …  — echoes the chosen option to stdout.
# Returns non-zero if nothing is chosen (cancelled, or non-interactive).
ui_menu() {
  local prompt="$1"
  shift

  if _ui_can_prompt; then
    gum choose --header "$prompt" "$@"
    return
  fi

  # Numbered fallback when there is a TTY but no gum. Prompts go to stderr so
  # stdout carries only the selection for clean capture.
  if [[ -t 0 ]]; then
    local opt i=1 choice
    printf '%s\n' "$prompt" >&2
    for opt in "$@"; do
      printf '  %d) %s\n' "$i" "$opt" >&2
      i=$((i + 1))
    done
    read -r -p "Select [1-$#]: " choice
    [[ "$choice" =~ ^[0-9]+$ ]] && ((choice >= 1 && choice <= $#)) || return 1
    printf '%s\n' "${!choice}"
    return 0
  fi

  return 1
}

# ------------------------------------------------------------------------------------------------------
# Multi-select: ui_choose_multi "header" -- item1 item2 …  — echoes the chosen
# items, one per line. Nothing is pre-selected, so submitting an empty selection
# (the safe default) chooses nothing. Returns non-zero only when there is no way
# to prompt (no TTY); an empty selection is a successful "chose nothing".
ui_choose_multi() {
  local header="$1"
  shift
  [[ "${1:-}" == "--" ]] && shift

  if _ui_can_prompt; then
    gum choose --no-limit --header "$header" "$@"
    return
  fi

  # Numbered fallback when there is a TTY but no gum. Prompts go to stderr so
  # stdout carries only the chosen items.
  if [[ -t 0 ]]; then
    local item i=1 line n
    printf '%s\n' "$header" >&2
    for item in "$@"; do
      printf '  %d) %s\n' "$i" "$item" >&2
      i=$((i + 1))
    done
    read -r -p "Numbers to select (space-separated, blank = none): " line
    local nums=()
    IFS=' ' read -ra nums <<<"$line"
    for n in ${nums[@]+"${nums[@]}"}; do
      [[ "$n" =~ ^[0-9]+$ ]] && ((n >= 1 && n <= $#)) && printf '%s\n' "${!n}"
    done
    return 0
  fi

  return 1
}

# ------------------------------------------------------------------------------------------------------
# Yes/no. Returns 0 for yes, 1 for no. Declines in non-interactive contexts.
ui_confirm() {
  local msg="$1"

  if _ui_can_prompt; then
    gum confirm "$msg"
    return
  fi

  if [[ -t 0 ]]; then
    local reply
    read -r -p "$msg [y/N] " reply
    [[ "$reply" =~ ^[Yy]([Ee][Ss])?$ ]]
    return
  fi

  return 1
}

# ------------------------------------------------------------------------------------------------------
# Run a command behind a spinner. ui_spin "title" -- cmd args…
# Falls back to a plain "… title" line plus the command's normal output.
ui_spin() {
  local title="$1"
  shift
  [[ "${1:-}" == "--" ]] && shift

  if _ui_can_render; then
    gum spin --spinner dot --show-error --title "$title" -- "$@"
    return
  fi

  printf '… %s\n' "$title"
  "$@"
}
