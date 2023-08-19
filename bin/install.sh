#!/usr/bin/env bash

# install homebrew requirements
brew bundle

echo 'Linking'

echo '- git config'
if [ -e ~/.gitconfig -o -L ~/.gitconfig ]; then rm ~/.gitconfig; fi
ln -s ~/.dotfiles/git/gitconfig ~/.gitconfig

echo '- tmux config'
if [ -e ~/.tmux.conf -o -L ~/.tmux.conf ]; then rm ~/.tmux.conf; fi
ln -s ~/.dotfiles/tmux/tmux.conf ~/.tmux.conf

echo '- nvim config'
if [ ! -d ~/.config ]; then mkdir -p ~/.config; fi
if [ -e ~/.config/nvim -o -L ~/.config/nvim ]; then rm -rf ~/.config/nvim; fi
ln -s ~/.dotfiles/nvim ~/.config/nvim

echo '- zsh config'
if [ -e ~/.zprofile -o -L ~/.zprofile ]; then rm ~/.zprofile; fi
ln -s ~/.dotfiles/zsh/zprofile ~/.zprofile
if [ -e ~/.zshrc -o -L ~/.zshrc ]; then rm ~/.zshrc; fi
ln -s ~/.dotfiles/zsh/zshrc ~/.zshrc

echo '- fzf config'
`brew --prefix`/opt/fzf/install --all

echo '- starship config'
if [ -e ~/.config/starship.toml -o -L ~/.config/starship.toml ]; then rm ~/.config/starship.toml; fi
ln -s ~/.dotfiles/starship/starship.toml ~/.config/starship.toml

echo '- ssh config'
if [ ! -d ~/.ssh ]; then mkdir ~/.ssh; fi
if [ -e ~/.ssh/config -o -L ~/.ssh/config ]; then rm ~/.ssh/config; fi
ln -s ~/.dotfiles/ssh/config ~/.ssh/config
