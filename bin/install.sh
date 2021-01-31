#!/usr/bin/env bash

# install homebrew requirements
brew bundle -v

echo 'linking gitconfig'
if [ -e ~/.gitconfig -o -L ~/.gitconfig ]; then rm ~/.gitconfig; fi
ln -s ~/.dotfiles/gitconfig ~/.gitconfig

echo 'linking tmux.conf'
if [ -e ~/.tmux.conf -o -L ~/.tmux.conf ]; then rm ~/.tmux.conf; fi
ln -s ~/.dotfiles/tmux/tmux.conf ~/.tmux.conf

echo 'linking vimrc'
if [ -e ~/.vimrc -o -L ~/.vimrc ]; then rm ~/.vimrc; fi
ln -s ~/.dotfiles/vimrc ~/.vimrc

echo 'linking zprofile'
if [ -e ~/.zprofile -o -L ~/.zprofile ]; then rm ~/.zprofile; fi
ln -s ~/.dotfiles/zprofile ~/.zprofile

echo 'linking zshrc'
if [ -e ~/.zshrc -o -L ~/.zshrc ]; then rm ~/.zshrc; fi
ln -s ~/.dotfiles/zshrc ~/.zshrc

echo 'linking ssh config'
if [ ! -d ~/.ssh ]; then mkdir ~/.ssh; fi
if [ -e ~/.ssh/config -o -L ~/.ssh/config ]; then rm ~/.ssh/config; fi
ln -s ~/.dotfiles/ssh/config ~/.ssh/config
