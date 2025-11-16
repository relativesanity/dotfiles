#!/usr/bin/env bash

# Colors match those defined in sketchybarrc
WORKSPACE_ACTIVE_COLOR=0xffcdd6f4
WORKSPACE_INACTIVE_COLOR=0xff6c7086

if [ "$1" = "$FOCUSED_WORKSPACE" ]; then
    sketchybar --set $NAME icon="●" icon.color=$WORKSPACE_ACTIVE_COLOR
else
    sketchybar --set $NAME icon="○" icon.color=$WORKSPACE_INACTIVE_COLOR
fi
