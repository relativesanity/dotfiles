#!/usr/bin/env bash

set -euo pipefail # Exit on error, undefined vars, and pipeline failures
IFS=$'\n\t'       # Stricter word splitting

# macOS UI customization script
# Configures Dock and window animations
# Supports:
#   - macOS (via m-cli)
#
# Usage:
#   ./m.sh
#
# Prerequisites:
#   - m-cli must be installed (via Homebrew)

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
