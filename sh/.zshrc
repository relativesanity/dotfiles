#
# ~/.zshrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# vim motions
bindkey -v

# Restore a steady bar cursor at every prompt. TUI apps (nvim, less, …) reset
# the cursor to a block on exit and neither terminfo nor tmux reliably reasserts
# it, so do it here — matches Ghostty/tmux's configured bar (\e[6 q = steady bar).
autoload -Uz add-zsh-hook
_cursor_to_bar() { print -n '\e[6 q' }
add-zsh-hook precmd _cursor_to_bar

# set up common environment
export EDITOR=nvim
export VISUAL=nvim
export RIPGREP_CONFIG_PATH=$HOME/.config/ripgrep/config
[[ -e $HOME/.env.local.sh ]] && source $HOME/.env.local.sh


# -------- manage plugins with zinit
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
if [ ! -d "$ZINIT_HOME" ];
then
  mkdir -p "$(dirname $ZINIT_HOME)"
  git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi
source "${ZINIT_HOME}/zinit.zsh"
# -------- load plugins
zinit light zsh-users/zsh-autosuggestions
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-syntax-highlighting
# -------- end plugins


# initialise completions
autoload -Uz compinit && compinit
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu select

# set up history
export HISTSIZE=1000000000
export SAVEHIST=1000000000
export HISTFILE=$HOME/.zsh_history
export HISTDUP=erase
setopt inc_append_history
setopt sharehistory
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_find_no_dups


# initialise integrations
command -v zoxide >/dev/null 2>&1 && eval "$(zoxide init --cmd gg zsh)"
command -v starship >/dev/null 2>&1 && eval "$(starship init zsh)"
command -v fzf >/dev/null 2>&1 && eval "$(fzf --zsh)"
if command -v rv >/dev/null 2>&1;
then
  # rv drives PATH/GEM_HOME per-directory via a preexec hook; it also reads
  # ~/.ruby-version and project .ruby-version/.tool-versions files.
  eval "$(rv shell init zsh)"
  eval "$(rv shell completions zsh)"
fi

# load common aliases
source $HOME/.aliases.sh

# load common functions
source $HOME/.zfunctions.sh

# load local config
[[ -f $HOME/.zshrc.local ]] && source $HOME/.zshrc.local

# specific to zsh
alias resource='source $HOME/.zshrc'
