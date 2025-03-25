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

alias start='tmux new-session -A -s'

alias msh='mosh --server=/opt/homebrew/bin/mosh-server'

alias lg='lazygit'
alias gs='git status'
alias gd='git diff'

DOTFILES_PATH="$HOME/.dotfiles"
alias dotfiles='cd $DOTFILES_PATH'
alias restow="$DOTFILES_PATH/bin/restow.sh"
alias repack="$DOTFILES_PATH/bin/repack.sh"
