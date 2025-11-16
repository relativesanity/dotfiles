#!/usr/bin/env bash
#
# Aerospace workspace indicator
# Sets workspace icon state (filled/empty) based on focus

if [ "$1" = "$FOCUSED_WORKSPACE" ]; then
    sketchybar --set $NAME icon="●"
else
    sketchybar --set $NAME icon="○"
fi
