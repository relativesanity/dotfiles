# The dotfiles scripts. redot runs the lot; the others do one part each. Every
# one prints a plan and asks before applying, so they are safe to run bare.
redot() {
  "${DOTFILES_PATH:-$HOME/.dotfiles}/bin/redot.sh" "$@"
}

restow() {
  "${DOTFILES_PATH:-$HOME/.dotfiles}/bin/restow.sh" "$@"
}

repack() {
  "${DOTFILES_PATH:-$HOME/.dotfiles}/bin/repack.sh" "$@"
}

reenv() {
  "${DOTFILES_PATH:-$HOME/.dotfiles}/bin/reenv.sh" "$@"
}

# Open (or attach to) a tmux session for editing dotfiles, with claude
# running in a vertical split.
dot() {
  local session="dotfiles"
  local dir="${DOTFILES_PATH:-$HOME/.dotfiles}"

  if ! tmux has-session -t "$session" 2>/dev/null; then
    tmux new-session -d -s "$session" -c "$dir"
    tmux split-window -h -t "$session" -c "$dir" "claude"
    tmux select-pane -t "$session:0.0"
  fi

  if [ -n "$TMUX" ]; then
    tmux switch-client -t "$session"
  else
    tmux attach-session -t "$session"
  fi
}

drag-toggle() {
  local current
  current=$(defaults read -g NSWindowShouldDragOnGesture 2>/dev/null || echo "false")

  if [[ "$current" == "1" || "$current" == "true" ]]; then
    defaults write -g NSWindowShouldDragOnGesture -bool false
    echo "Window drag on gesture: disabled"
  else
    defaults write -g NSWindowShouldDragOnGesture -bool true
    echo "Window drag on gesture: enabled (ctrl+cmd drag)"
  fi
}

git-ssh() {
  local url
  url=$(git remote get-url origin 2>/dev/null) || { echo "No remote 'origin' found"; return 1; }

  if [[ "$url" != *github.com* ]]; then
    echo "Remote is not GitHub: $url"
    return 1
  fi

  if [[ "$url" == git@* ]]; then
    echo "Already using SSH: $url"
    return 0
  fi

  local new_url
  new_url=$(echo "$url" | sed 's|https://github.com/|git@github.com:|')

  git remote set-url origin "$new_url"
  echo "Updated origin:"
  echo "  $url → $new_url"
}
