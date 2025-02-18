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

  # Disable shellcheck warning about $ in single quotes
  # shellcheck disable=SC2016
  # enables men and hyper key window management
  defaults write -g NSUserKeyEquivalents '{
    "\033Window\033Center" = "~^$,";
    "\033Window\033Centre" = "~^$,";
    "\033Window\033Fill" = "~^$.";
    "\033Window\033Move & Resize\033Bottom" = "~^$j";
    "\033Window\033Move & Resize\033Bottom & Top" = "@~^$m";
    "\033Window\033Move & Resize\033Left" = "~^$h";
    "\033Window\033Move & Resize\033Left & Right" = "~^$n";
    "\033Window\033Move & Resize\033Right" = "~^$l";
    "\033Window\033Move & Resize\033Right & Left" = "@~^$n";
    "\033Window\033Move & Resize\033Top" = "~^$k";
    "\033Window\033Move & Resize\033Top & Bottom" = "~^$m";
    "Hide Others" = "~^$'\''";
  }'
fi
