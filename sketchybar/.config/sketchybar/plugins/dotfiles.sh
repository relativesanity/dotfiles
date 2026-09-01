#!/usr/bin/env bash

# Only surface this while ~/.dotfiles has uncommitted or untracked changes,
# mirroring vpn.sh/timemachine.sh: nothing worth showing in the bar while clean.
CHANGES=$(git -C "$HOME/.dotfiles" status --porcelain)

if [ -z "$CHANGES" ]; then
    sketchybar --set $NAME drawing=off
    exit 0
fi

COUNT=$(wc -l <<< "$CHANGES" | tr -d ' ')

sketchybar --set $NAME drawing=on icon="~" label="$COUNT"
