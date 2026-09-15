#!/usr/bin/env bash
#
# AeroSpace service-mode indicator
# Fires on every mode change (aerospace.toml's on-mode-changed), which
# doesn't say which mode it landed in - asking directly is the only way

MODE=$(aerospace list-modes --current)

if [ "$MODE" = "service" ]; then
    LABEL=$(awk '{ print toupper(substr($0,1,1)) substr($0,2) }' <<< "$MODE")
    sketchybar --set $NAME label="$LABEL" drawing=on
else
    sketchybar --set $NAME drawing=off
fi
