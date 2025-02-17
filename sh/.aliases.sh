alias ll='ls -lh'
alias l='ll'
alias la='ll -a'

if command -v eza >/dev/null 2>&1; then
  alias ls='eza'
  alias ll='ll --icons=always'
  alias tree='ls --tree'
fi

alias mkdir='mkdir -p'

DOTFILES_PATH="$HOME/.dotfiles/"
alias dotfiles='cd $DOTFILES_PATH'
alias restow='$HOME/.dotfiles/bin/restow.sh'
alias rebrew='$HOME/.dotfiles/bin/rebrew.sh'

if command -v defaults >/dev/null 2>&1; then
  # fast dock hide and show
  # to reset:
  #   defaults delete com.apple.dock autohide-delay
  #   defaults write com.apple.dock autohide-time-modifier -float "0.5"
  #   killall Dock
  alias dockf='defaults write com.apple.dock autohide-delay -float 0; defaults write com.apple.dock autohide-time-modifier -int 0; killall Dock'

  # drag window with ctrl and cmd
  # to reset:
  #   defaults write -g NSWindowShouldDragOnGesture -bool false
  alias grabmove='defaults write -g NSWindowShouldDragOnGesture -bool true'

  # disable window opening animations
  # to reset:
  #   defaults write -g NSAutomaticWindowAnimationsEnabled -bool true
  alias disableanim='defaults write -g NSAutomaticWindowAnimationsEnabled -bool false'
fi
