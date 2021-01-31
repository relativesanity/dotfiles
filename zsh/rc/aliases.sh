alias za='$EDITOR ~/.zsh/rc/aliases.sh'
alias zc='$EDITOR ~/.zshrc'
alias zr='. ~/.zshrc'

alias ll='ls -lh'
alias be='bundle exec'

alias ga='git add'
alias gc='git commit'
alias gd='git diff'
alias gdc='gd --cached'
alias gl='git log'
alias gs='git status'

alias config='cd ~/dev/dotfiles'



# Bootstrap a tmux session
function start() {
  tmux -2 attach -t ${1-dev} || tmux -2 new -s ${1-dev}
}
