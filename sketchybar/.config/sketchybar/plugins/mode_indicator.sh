#!/usr/bin/env bash
#
# AeroSpace binding-mode indicator: shows the mode's name outside main
# Fires on every mode change (aerospace.toml's on-mode-changed), which
# doesn't say which mode it landed in - asking directly is the only way.
# theme.sh fires the same event on a theme change, so the colour follows.

MODE=$(aerospace list-modes --current)

if [ "$MODE" = "main" ]; then
    sketchybar --set $NAME drawing=off
    exit 0
fi

# Omarchy mode is one you stay in, so it reads green. Anything else (service)
# is a one-shot mode to get back out of, so it reads red.
if defaults read -g AppleInterfaceStyle &> /dev/null; then
    if [ "$MODE" = "omarchy" ]; then
        COLOR=0xffa6e3a1 # Catppuccin Mocha Green
    else
        COLOR=0xfff38ba8 # Catppuccin Mocha Red
    fi
else
    if [ "$MODE" = "omarchy" ]; then
        COLOR=0xff40a02b # Catppuccin Latte Green
    else
        COLOR=0xffd20f39 # Catppuccin Latte Red
    fi
fi

LABEL=$(awk '{ print toupper(substr($0,1,1)) substr($0,2) }' <<< "$MODE")
sketchybar --set $NAME label="$LABEL" icon.color="$COLOR" label.color="$COLOR" drawing=on
