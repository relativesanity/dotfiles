#!/usr/bin/env bash

set -euo pipefail # Exit on error, undefined vars, and pipeline failures
IFS=$'\n\t'       # Stricter word splitting

# Trap Ctrl-C (SIGINT) and exit gracefully
trap 'echo -e "\nInterrupted. Exiting..."; exit 130' INT

# dot — the dotfiles front door
# Supports:
#   - macOS (via Homebrew + gum)
#
# Usage:
#   ./dot.sh                 interactive menu
#   ./dot.sh sync [flags]    pull, then packages + symlinks + runtimes
#   ./dot.sh pack [flags]    preview & apply Brewfile changes (repack)
#   ./dot.sh stow            preview & apply stow symlinks (restow)
#   ./dot.sh env             preview & install asdf runtimes (reenv)
#   ./dot.sh doctor          environment health check
#
# Any flags after a subcommand pass straight through to the underlying engine
# (e.g. `dot pack --clear-cache`), which keeps the legacy re* commands working.
#
# Prerequisites:
#   - dotfiles repository must be present
#   - gum is optional; without it every screen falls back to plain text

DOT_DIR="${DOTFILES_PATH:-$HOME/.dotfiles}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/status.sh
source "$SCRIPT_DIR/lib/status.sh"
# shellcheck source=lib/ui.sh
source "$SCRIPT_DIR/lib/ui.sh"

# A real interactive terminal on both ends.
_interactive() { [[ -t 0 && -t 1 ]]; }

# ------------------------------------------------------------------------------------------------------
dot_menu() {
  # No menu without a terminal — show the health check instead.
  if ! _interactive; then
    dot_doctor
    return 0
  fi

  local env git brew stow asdf
  env="$(detect_environment)"
  print_status "Gathering status…"
  git="$(status_git)"
  brew="$(status_brew)"
  stow="$(status_stow)"
  asdf="$(status_asdf)"

  ui_header "dotfiles · $(whoami)" "$env · ${git%% *}"
  ui_box \
    "⎇  $git" \
    "📦 brew   $brew" \
    "🔗 stow   $stow" \
    "🔧 asdf   $asdf"
  echo

  # Labels lead with the subcommand verb (what `dot <verb>` runs) plus a gloss.
  local choice
  choice="$(ui_menu "What would you like to do?" \
    "Sync      pull & apply everything" \
    "Pack      brew packages" \
    "Stow      config symlinks" \
    "Env       asdf runtimes" \
    "Doctor    environment health check" \
    "Quit")" || return 0

  case "$choice" in
    Sync*) dot_sync ;;
    Pack*) dot_pack ;;
    Stow*) dot_stow ;;
    Env*) dot_env ;;
    Doctor*) dot_doctor ;;
    *) return 0 ;;
  esac
}

# ------------------------------------------------------------------------------------------------------
# Full sync: pull, then packages → symlinks → runtimes. Mirrors the original
# redot orchestration; flags (e.g. --update-only) pass through to repack.
dot_sync() {
  cd "$DOT_DIR"
  ui_header "Syncing dotfiles" "$(detect_environment)"

  local branch
  branch="$(git branch --show-current)"
  if git rev-parse --abbrev-ref '@{upstream}' >/dev/null 2>&1; then
    if ! ui_spin "Pulling $branch from upstream" -- git pull; then
      print_failure "Failed to pull from upstream"
      return 1
    fi
  else
    print_status "No upstream configured, skipping pull"
  fi

  "$DOT_DIR/bin/repack.sh" "$@"
  echo
  "$DOT_DIR/bin/restow.sh"
  echo
  "$DOT_DIR/bin/reenv.sh"
}

# ------------------------------------------------------------------------------------------------------
dot_pack() {
  # Passthrough: explicit flags or no terminal → run the engine directly so
  # `repack --clear-cache` and non-interactive callers behave exactly as before.
  if [[ $# -gt 0 ]] || ! _interactive; then
    exec "$DOT_DIR/bin/repack.sh" "$@"
  fi

  ui_header "Pack" "$(detect_environment)"
  "$DOT_DIR/bin/repack.sh" --plan
  echo

  local choice
  choice="$(ui_menu "Apply changes?" \
    "Apply this plan" \
    "Refresh only (no removals)" \
    "Review cached apps" \
    "Prune drift (zap uncached)" \
    "Clear cache & prune" \
    "Back")" || return 0

  case "$choice" in
    "Apply this plan") "$DOT_DIR/bin/repack.sh" ;;
    "Refresh only"*) "$DOT_DIR/bin/repack.sh" --update-only ;;
    "Review cached apps") "$DOT_DIR/bin/repack.sh" --select-cache ;;
    "Prune drift"*) "$DOT_DIR/bin/repack.sh" --skip-cache ;;
    "Clear cache & prune") "$DOT_DIR/bin/repack.sh" --clear-cache ;;
    *) return 0 ;;
  esac
}

# ------------------------------------------------------------------------------------------------------
dot_stow() {
  if [[ $# -gt 0 ]] || ! _interactive; then
    exec "$DOT_DIR/bin/restow.sh" "$@"
  fi

  ui_header "Stow"
  "$DOT_DIR/bin/restow.sh" --plan
  echo
  if ui_confirm "Restow all packages now?"; then
    "$DOT_DIR/bin/restow.sh"
  fi
}

# ------------------------------------------------------------------------------------------------------
dot_env() {
  if [[ $# -gt 0 ]] || ! _interactive; then
    exec "$DOT_DIR/bin/reenv.sh" "$@"
  fi

  ui_header "Env"
  "$DOT_DIR/bin/reenv.sh" --plan
  echo
  if ui_confirm "Install asdf versions now?"; then
    "$DOT_DIR/bin/reenv.sh"
  fi
}

# ------------------------------------------------------------------------------------------------------
dot_doctor() {
  ui_header "Doctor"

  local lines=()
  lines+=("$(_doctor_tool Homebrew brew)")
  lines+=("$(_doctor_tool Stow stow)")
  lines+=("$(_doctor_tool asdf)")
  lines+=("$(_doctor_tool gum)")
  lines+=("$(_doctor_tool mas)")

  # Managed if the path resolves into the repo — covers both an unfolded
  # file-level symlink and a tree-folded ~/.homebrew directory symlink (where
  # trust.json is a real file inside the folded link, so a bare -L on it lies).
  local trust="$HOME/.homebrew/trust.json"
  local repo_trust="$DOT_DIR/homebrew/.homebrew/trust.json"
  if [[ -e "$trust" ]] && [[ "$(realpath "$trust" 2>/dev/null)" == "$(realpath "$repo_trust" 2>/dev/null)" ]]; then
    lines+=("✓ trust.json     symlinked → repo")
  else
    lines+=("⚠ trust.json     not symlinked")
  fi

  lines+=("✓ DOTFILES_PATH  $DOT_DIR")

  if pgrep -x kanata >/dev/null 2>&1; then
    lines+=("✓ kanata         running")
  else
    lines+=("⚠ kanata         not set up (manual — see kanata/kanata.md)")
  fi

  if [[ -f "$HOME/.config/git/config.local" ]]; then
    lines+=("✓ git config     config.local present")
  else
    lines+=("⚠ git config     config.local missing (optional work overrides)")
  fi

  ui_box "${lines[@]}"
  echo
  echo "Drift:"
  echo "  git    $(status_git)"
  echo "  brew   $(status_brew)"
  echo "  stow   $(status_stow)"
  echo "  asdf   $(status_asdf)"
}

# Print "✓ name version" or "✗ name missing" for a tool.
_doctor_tool() {
  local name="$1" bin="${2:-$1}" ver
  if ! command -v "$bin" >/dev/null 2>&1; then
    printf '✗ %-15s missing' "$name"
    return 0
  fi
  ver="$("$bin" --version 2>/dev/null | head -1 || true)"
  ver="$(grep -oE '[0-9]+(\.[0-9]+)+' <<<"$ver" | head -1 || true)"
  [[ -n "$ver" ]] || ver="present"
  printf '✓ %-15s %s' "$name" "$ver"
}

# ------------------------------------------------------------------------------------------------------
dot_help() {
  cat <<'EOF'
dot — the dotfiles front door

Usage:
  dot                 interactive menu
  dot sync [flags]    pull, then packages + symlinks + runtimes (= redot)
  dot pack [flags]    preview & apply Brewfile changes           (= repack)
  dot stow            preview & apply stow symlinks              (= restow)
  dot env             preview & install asdf runtimes            (= reenv)
  dot doctor          environment health check

Flags after pack/sync pass through to repack:
  --update-only   bundle without removing anything
  --skip-cache    zap apps not in the Brewfiles or the cache
  --clear-cache   delete the cache and zap every untracked app
  --select-cache  pick which untracked apps to prune; keep the rest cached
EOF
}

# ------------------------------------------------------------------------------------------------------
main() {
  local cmd="${1:-menu}"
  [[ $# -gt 0 ]] && shift

  case "$cmd" in
    menu) dot_menu ;;
    sync) dot_sync "$@" ;;
    pack) dot_pack "$@" ;;
    stow) dot_stow "$@" ;;
    env) dot_env "$@" ;;
    doctor) dot_doctor "$@" ;;
    help | -h | --help) dot_help ;;
    *)
      print_warning "Unknown command: $cmd"
      dot_help
      return 1
      ;;
  esac
}

main "$@"
