# set vi movement keys
bindkey -v

# set editor to vim
export EDITOR=nvim
export VISUAL=nvim

# set command prompt
source /opt/homebrew/opt/zsh-git-prompt/zshrc.sh
# setopt prompt_subst
export PS1='%n@%m %. $(git_super_status)
%# '

# set up command history
# much taken from https://www.soberkoder.com/better-zsh-history/
export HISTSIZE=1000000000 # total loaded in session
export SAVEHIST=1000000000 # total saved
export HISTFILE=~/.zsh_history # where to store history
setopt INC_APPEND_HISTORY # immediately append history to file
export HISTTIMEFORMAT="[%F %T] " # sets the time format
setopt EXTENDED_HISTORY # and allows the time to be recorded

# set up completions in general
autoload -U compinit
compinit

# configure chruby to be available and auto-detecting
source /opt/homebrew/opt/chruby/share/chruby/chruby.sh
source /opt/homebrew/opt/chruby/share/chruby/auto.sh

# set up some useful aliases
source ~/.dotfiles/zsh/rc/aliases.sh
