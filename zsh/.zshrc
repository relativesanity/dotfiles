# set vi movement keys
bindkey -v

# set editor to vim
export EDITOR=nvim
export VISUAL=nvim

# initialise starship prompt
eval "$(starship init zsh)"

# set up command history
# much taken from https://www.soberkoder.com/better-zsh-history/
export HISTSIZE=1000000000 # total loaded in session
export SAVEHIST=1000000000 # total saved
export HISTFILE=~/.zsh_history # where to store history
setopt INC_APPEND_HISTORY # immediately append history to file
export HISTTIMEFORMAT="[%F %T] " # sets the time format
setopt EXTENDED_HISTORY # and allows the time to be recorded

# use most for paging, to enable colour man pages
# as per https://www.howtogeek.com/683134/how-to-display-man-pages-in-color-on-linux/
export PAGER=most

# set up completions in general
autoload -U compinit
compinit

# set up rbenv
eval "$(rbenv init - zsh)"

# set up nvm
export NVM_DIR="$HOME/.nvm"
[ -s "$(brew --prefix)/opt/nvm/nvm.sh" ] && \. "$(brew --prefix)/opt/nvm/nvm.sh"  # This loads nvm
[ -s "$(brew --prefix)/opt/nvm/etc/bash_completion.d/nvm" ] && \. "$(brew --prefix)/opt/nvm/etc/bash_completion.d/nvm"  # This loads nvm bash_completion

# set up some useful aliases
source ~/.aliases.sh

# configure fzf
export FZF_DEFAULT_COMMAND="rg --files --hidden --follow --glob '!.git'"
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# set up zoxide
eval "$(zoxide init zsh)"

# set up syntax highlighting
source "$(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"

# load local env
[ -f ~/.env.local.sh ] && source ~/.env.local.sh
