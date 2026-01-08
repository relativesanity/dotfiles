if command -v eza >/dev/null 2>&1; then
  alias ls='eza'
  alias ll='ls -lh --icons=always'
  alias tree='ls --tree'
else
  alias ll='ls -lh'
fi
alias l='ll'
alias la='ll -a'

alias mkdir='mkdir -p'

TMUX_DEFAULT_SESSION_NAME="jbOS"
start() { tmux new-session -A -s "${1:-$TMUX_DEFAULT_SESSION_NAME}"; }
switch() {
  local session="${1:-$TMUX_DEFAULT_SESSION_NAME}"
  tmux new-session -d -s "$session" 2>/dev/null || true
  tmux switch-client -t "$session"
}
swap() {
  local current_session=$(tmux display-message -p '#S')
  local target_session="${1:-$TMUX_DEFAULT_SESSION_NAME}"

  if [[ "$current_session" == "$target_session" ]]; then
    echo "Error: Cannot swap to the same session you're killing."
    return 1
  fi

  echo -n "Kill session $current_session and swap to $target_session? "
  read -k 1 response
  echo
  if [[ "$response" =~ ^[Yy]$ ]]; then
    tmux new-session -d -s "$target_session" 2>/dev/null || true
    tmux switch-client -t "$target_session"
    tmux kill-session -t "$current_session"
  fi
}

alias msh='mosh --server=/opt/homebrew/bin/mosh-server'
alias mx='cmatrix -ab -u3'

alias ld='lazydocker'
alias lg='lazygit'
alias gs='git status'
alias gd='git diff'

DOTFILES_PATH="$HOME/.dotfiles"
alias dotfiles='cd $DOTFILES_PATH'

alias restart="osascript -e 'tell app \"loginwindow\" to «event aevtrrst»'"

alias ao-project='$HOME/.agent-os/setup/project.sh'
