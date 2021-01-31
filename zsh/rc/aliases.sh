alias resource='. ~/.zshrc'

alias za='$EDITOR ~/.zsh/rc/aliases.sh'


alias ll='ls -lh'
alias be='bundle exec'
alias gs='git status'
alias gl='git log'

alias config='cd ~/dev/dotfiles'



# Bootstrap a tmux session
function start() {
  tmux -2 attach -t ${1-dev} || tmux -2 new -s ${1-dev}
}
