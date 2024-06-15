#!/usr/bin/env bash

# install homebrew requirements
brew bundle

echo 'Linking'

echo '- git config'
stow -R git

echo '- tmux config'
stow -R tmux

echo '- nvim config'
stow -R nvim

echo '- zsh config'
stow -R zsh

echo '- fzf config'
`brew --prefix`/opt/fzf/install --all

echo '- starship config'
stow -R starship

echo '- ssh config'
stow -R ssh
