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

DOTFILES_PATH="$HOME/.dotfiles/"
alias dotfiles='cd $DOTFILES_PATH'
alias restow='$HOME/.dotfiles/bin/restow.sh'
alias rebrew='$HOME/.dotfiles/bin/rebrew.sh'
