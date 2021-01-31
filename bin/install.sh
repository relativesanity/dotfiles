#!/usr/bin/env zsh

# install homebrew
if [[ "" == "$(command -v brew)" ]]; then
  echo 'Installing homebrew'
  /usr/bin/env bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
  echo 'Updating homebrew'
  brew update
fi

# install homebrew requirements
brew bundle -v

echo 'linking gitconfig'
if [ -e ~/.gitconfig -o -L ~/.gitconfig ]; then rm ~/.gitconfig; fi
ln -s ~/.dotfiles/gitconfig ~/.gitconfig

echo 'linking tmux.conf'
if [ -e ~/.tmux.conf -o -L ~/.tmux.conf ]; then rm ~/.tmux.conf; fi
ln -s ~/.dotfiles/tmux.conf ~/.tmux.conf

echo 'linking vimrc'
if [ -e ~/.vimrc -o -L ~/.vimrc ]; then rm ~/.vimrc; fi
ln -s ~/.dotfiles/vimrc ~/.vimrc

echo 'linking zprofile'
if [ -e ~/.zprofile -o -L ~/.zprofile ]; then rm ~/.zprofile; fi
ln -s ~/.dotfiles/zprofile ~/.zprofile

echo 'linking zshrc'
if [ -e ~/.zshrc -o -L ~/.zshrc ]; then rm ~/.zshrc; fi
ln -s ~/.dotfiles/zshrc ~/.zshrc

