#!/usr/bin/env bash

# install homebrew
if [[ "" == "$(command -v brew)" ]]; then
  echo 'Installing homebrew'
  /usr/bin/env bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
  echo 'Updating homebrew'
  brew update
  # ensure we have git to get dotfiles
  brew install git
fi

if [[ ! -e $HOME/.dotfiles ]]; then
  echo 'Downloading dotfiles'
  git clone https://github.com/relativesanity/dotfiles $HOME/.dotfiles
else
  echo 'Dotfiles downloaded'
fi

cd $HOME/.dotfiles
bin/install.sh
