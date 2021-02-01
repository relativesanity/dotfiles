alias za='$EDITOR ~/.dotfiles/zsh/aliases.sh'
alias zc='$EDITOR ~/.zshrc'
alias zr='. ~/.zshrc'

alias ll='ls -lh'
alias la='ll -a'
alias be='bundle exec'

alias ga='git add'
alias gaa='ga .'
alias gc='git commit'
alias gcv='gc --verbose'
alias gcm='gc -m'
alias gd='git diff'
alias gdc='gd --cached'
alias gl='git log'
alias gp='git push'
alias gpom='gp origin main'
alias gs='git status'

alias dotfiles='cd ~/.dotfiles'
alias config=dotfiles



# Bootstrap a tmux session
function start() {
  tmux -2 attach -t ${1-dev} || tmux -2 new -s ${1-dev}
}
