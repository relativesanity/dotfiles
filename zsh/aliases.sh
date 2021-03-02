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

alias omp='cd ~/Library/Containers/com.omnigroup.OmniFocus3/Data/Library/Application\ Support/Plug-Ins'
alias ompe='omp; nvim'

alias dotfiles='cd ~/.dotfiles'
alias config=dotfiles



# Bootstrap a tmux session
function start() {
  tmux -2 attach -t ${1-dev} || tmux -2 new -s ${1-dev}
}

# set up some some jump functions
function dev() { jump $1 dev }
function jump() {
  if [ -z $1 ]; then
    cd ~/${2}
  else
    cd `ls -dt1 ~/${2}/${1}* | head -n1`
  fi
}
