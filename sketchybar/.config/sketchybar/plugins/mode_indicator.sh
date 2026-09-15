#!/usr/bin/env bash
#
# AeroSpace service-mode indicator
# MODE comes from aerospace_mode_change, triggered by aerospace.toml's
# ctrl-alt-shift-semicolon (which both enters and, from inside service mode,
# toggles back out of it) and every other exit in mode.service.binding

if [ "$MODE" = "service" ]; then
    LABEL=$(awk '{ print toupper(substr($0,1,1)) substr($0,2) }' <<< "$MODE")
    sketchybar --set $NAME label="$LABEL" drawing=on
else
    sketchybar --set $NAME drawing=off
fi
