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

TMUX_DEFAULT_SESSION_NAME="tmux"
switch() {
  local session
  if [[ -n "$1" ]]; then
    session="$1"
  else
    local sessions
    sessions=$(tmux list-sessions -F '#S' 2>/dev/null)
    if [[ -z "$sessions" ]]; then
      session="$TMUX_DEFAULT_SESSION_NAME"
    else
      local fzf_out fzf_exit query selection
      fzf_out=$(echo "$sessions" | fzf --height=~10 --layout=reverse --border --prompt="session: " --print-query)
      fzf_exit=$?
      [[ $fzf_exit -eq 130 ]] && return 0
      query=$(echo "$fzf_out" | sed -n '1p')
      selection=$(echo "$fzf_out" | sed -n '2p')
      if [[ -n "$selection" ]]; then
        session="$selection"
      elif [[ -n "$query" ]]; then
        session="$query"
      else
        return 0
      fi
    fi
  fi
  tmux new-session -d -s "$session" 2>/dev/null || true
  if [[ -n "$TMUX" ]]; then
    tmux switch-client -t "$session"
  else
    tmux attach-session -t "$session"
  fi
}
alias start=switch

alias msh='mosh --server=/opt/homebrew/bin/mosh-server'
alias mx='cmatrix -ab -u3'

alias ld='lazydocker'
alias crom='docker run -d --rm --name=crom --security-opt seccomp=unconfined --security-opt no-new-privileges --dns=1.1.1.1 --memory=2g --pids-limit=512 -e PUID=1000 -e PGID=1000 -e TZ=Europe/London -p 9000:3000 -p 9001:3001 --shm-size=1gb lscr.io/linuxserver/chromium:latest'
alias krom='docker kill crom'
alias lg='lazygit'
alias gs='git status'
alias gd='git diff'

alias dotfiles='cd ${DOTFILES_PATH:-$HOME/.dotfiles}'

ICLOUD_PATH="$HOME/Library/Mobile Documents/com~apple~CloudDocs"
alias icloud='cd "$ICLOUD_PATH"'

OBSIDIAN_PATH="$HOME/Library/Mobile Documents/iCloud~md~obsidian/Documents"
alias obmd='cd "$OBSIDIAN_PATH"'
alias jbos='cd "$OBSIDIAN_PATH/jbOS"'

alias restart="osascript -e 'tell app \"loginwindow\" to «event aevtrrst»'"

alias reclaude='claude --resume'
