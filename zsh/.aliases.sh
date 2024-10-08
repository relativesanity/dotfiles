alias ls='eza'
alias ll='ls -lh --icons=always'
alias l='ll'
alias la='ll -a'
alias tree='ls --tree'

alias cl='clear'

alias cat='bat'
alias cd='z'

alias mkdip='mkdir -p'

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
alias rebrew='brew bundle --file ~/.dotfiles/Brewfile --cleanup --zap'
alias restow='~/.dotfiles/bin/restow.sh'

alias rr='bin/rails'

# fast dock hide and show
# to reset:
#   defaults delete com.apple.dock autohide-delay
#   defaults write com.apple.dock autohide-time-modifier -float "0.5"
#   killall Dock
alias dockf='defaults write com.apple.dock autohide-delay -float 0; defaults write com.apple.dock autohide-time-modifier -int 0; killall Dock'

alias start='zellij a Dev'
