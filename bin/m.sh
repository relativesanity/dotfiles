#!/usr/bin/env bash

if command -v m >/dev/null 2>&1; then
  m dock prune
  m dock autohide YES
  m dock showdelay 0.0
  # fast dock hide and show
  # to reset:
  #   defaults delete com.apple.dock autohide-delay
  #   defaults write com.apple.dock autohide-time-modifier -float "0.5"
  #   killall Dock
  defaults write com.apple.dock autohide-delay -float 0
  defaults write com.apple.dock autohide-time-modifier -int 0
  killall Dock

  # disable window opening animations
  # to reset:
  #   defaults write -g NSAutomaticWindowAnimationsEnabled -bool true
  defaults write -g NSAutomaticWindowAnimationsEnabled -bool false
fi
