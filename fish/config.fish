# initialise starship prompt
starship init fish | source

# set editor to neovim
set -x EDITOR nvim
set -x VISUAL nvim

# initialise chruby
source (brew --prefix)/share/chruby/chruby.fish
source (brew --prefix)/share/chruby/auto.fish
