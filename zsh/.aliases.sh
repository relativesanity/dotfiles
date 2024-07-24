alias ls='eza'
alias ll='ls -lh'
alias l='ll'
alias la='ll -a'
alias tree='ls --tree'

alias cat='bat'
alias cd='z'

alias be='bundle exec'

alias ga='git add'
alias gaa='ga .'
alias gc='git commit'
alias gcv='gc --verbose'
alias gcm='gc -m'
alias gacm='gaa ; gcm'
alias gco='git checkout'
alias gcob='gco -b'
alias gd='git diff'
alias gdc='gd --cached'
alias gl='git log'
alias glo='gl --oneline'
alias gln='gl --name-only'
alias gp='git push'
alias gpo='gp origin'
alias gpom='gpo main'
alias gpu='git pull'
alias gs='git status'

alias dk='docker'
alias dkr='dk run'
alias dkb='dk build'
alias dkc='docker-compose'
alias dkcd='dkc down'
alias dkcu='dkc up'
alias dkcud='dkcu -d'
alias dkcb='dkc build'
alias dkce='dkc exec'
alias dkcr='dkc run'

alias dotfiles='cd ~/.dotfiles'
alias config='echo "USE dotfiles"'

alias rr='bin/rails'

# Bootstrap a tmux session
function start() {
  tmux -2 attach -t ${1-dev} || tmux -2 new -s ${1-dev}
}
