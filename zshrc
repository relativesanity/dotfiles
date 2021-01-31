# set vi movement keys
bindkey -v

# set editor to vim
export EDITOR=nvim
export VISUAL=nvim

# set command prompt
source "/opt/homebrew/opt/zsh-git-prompt/zshrc.sh"
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

#
#
#
#
# set history params
# HISTSIZE=1000
# SAVEHIST=1000
# HISTFILE=~/.history

# set up completions in general
autoload -U compinit
compinit

# set up some useful aliases
alias resource='. ~/.zshrc'
# alias ll='ls -lh'
# alias be='bundle exec'
# alias gs='git status'
# alias gl='git log'
# alias config='cd ~/.conf'
# alias facenv='devkit env start; eval "$(devkit env vars)"'
# alias facstart='facenv; bundle exec rails server'
# function work() { jump $1 dev }
# alias dev='work'
# function hack() { jump $1 dev/hacks }
# function doc() { jump $1 dev/docs }
# function hiring() { jump $1 dev/hiring }
# function jump() {
  # if [ -z $1 ]; then
    # cd ~/${2}
  # else
    # cd `ls -dt1 ~/${2}/${1}* | head -n1`
  # fi
# }

# Bootstrap a tmux session
# function start() {
  # tmux -2 attach -t ${1-dev} || tmux -2 new -s ${1-dev}
# }

# Bootstrap a puppet agent
# function bootstrap() {
  # local _host
  # for _host in "$@";
  # do
    # echo $_host | ssh root@$_host 'cat > /etc/hostname; bash < <(wget -qO - https://gist.githubusercontent.com/relativesanity/3dedd2335345b180eae2/raw/78ad6d4848f70332a21b0ec7d111bfbfc0170ce4/puppet-bootstrap.sh)'
  # done
# }

# configure chruby to be available and auto-detecting
source /opt/homebrew/opt/chruby/share/chruby/chruby.sh
source /opt/homebrew/opt/chruby/share/chruby/auto.sh

# ensure brew python is used if installed
# PATH="/usr/local/opt/python/libexec/bin:$PATH"
# PATH="/usr/local/sbin:$PATH"

# allow default scripts to live in ./bin
# PATH="./bin:$PATH"
