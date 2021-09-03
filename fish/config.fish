set fish_greeting ''
source ~/.dotfiles/fish/local.fish
fish_add_path $brew_path/bin
eval (eval $brew_path/bin/brew shellenv)


# initialise starship prompt
starship init fish | source

# set vi keybindings
set fish_key_bindings fish_vi_key_bindings

# set editor to neovim
set -x EDITOR nvim
set -x VISUAL nvim

# use most for paging
set -gx PAGER most

# set FZF commands
fzf_key_bindings

# initialise chruby
set -x CHRUBY_ROOT (brew --prefix)
source (brew --prefix)/share/chruby/chruby.fish
source (brew --prefix)/share/chruby/auto.fish

# sets up autojump
[ -f (brew --prefix)/share/autojump/autojump.fish ]; and source (brew --prefix)/share/autojump/autojump.fish

# loads aliases
source ~/.dotfiles/fish/aliases.fish

# Bootstrap a tmux session
function start -a name
  if test -z $name; set name 'dev'; end
  tmux -2 attach -t $name || tmux -2 new -s $name
end
