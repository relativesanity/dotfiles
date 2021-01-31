alias za='$EDITOR ~/.dotfiles/zsh/rc/aliases.sh'
alias zc='$EDITOR ~/.zshrc'
alias zr='. ~/.zshrc'

alias ll='ls -lh'
alias be='bundle exec'

alias ga='git add'
alias gc='git commit'
alias gcm='gc -m'
alias gd='git diff'
alias gdc='gd --cached'
alias gl='git log'
alias gp='git push'
alias gs='git status'

alias dotfiles='cd ~/.dotfiles'
alias config=dotfiles



# Bootstrap a tmux session
function start() {
  tmux -2 attach -t ${1-dev} || tmux -2 new -s ${1-dev}
}
