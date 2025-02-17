#!/usr/bin/env bash

mkdir -p "$HOME"/.config/ # a noop if it exists

echo "stowing ghostty" && stow -d "$HOME"/.dotfiles/ --restow ghostty
echo "stowing git" && stow -d "$HOME"/.dotfiles/ --restow git
echo "stowing sh" && stow -d "$HOME"/.dotfiles/ --restow sh
