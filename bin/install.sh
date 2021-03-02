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
if [ ! -d ~/.config/nvim ]; then mkdir -p ~/.config/nvim; fi
if [ -e ~/.config/nvim/init.vim -o -L ~/.config/nvim/init.vim ]; then rm ~/.config/nvim/init.vim; fi
ln -s ~/.dotfiles/nvim/init.vim ~/.config/nvim/init.vim
if [ -e ~/.vimrc -o -L ~/.vimrc ]; then rm ~/.vimrc; fi
ln -s ~/.dotfiles/vim/vimrc ~/.vimrc

echo '- zsh config'
if [ -e ~/.zprofile -o -L ~/.zprofile ]; then rm ~/.zprofile; fi
ln -s ~/.dotfiles/zsh/zprofile ~/.zprofile
if [ -e ~/.zshrc -o -L ~/.zshrc ]; then rm ~/.zshrc; fi
ln -s ~/.dotfiles/zsh/zshrc ~/.zshrc
if [ -e ~/.fzf.zsh -o -L ~/.fzf.zsh ]; then rm ~/.fzf.zsh; fi
ln -s ~/.dotfiles/zsh/fzf.zsh ~/.fzf.zsh

echo '- ssh config'
if [ ! -d ~/.ssh ]; then mkdir ~/.ssh; fi
if [ -e ~/.ssh/config -o -L ~/.ssh/config ]; then rm ~/.ssh/config; fi
ln -s ~/.dotfiles/ssh/config ~/.ssh/config
