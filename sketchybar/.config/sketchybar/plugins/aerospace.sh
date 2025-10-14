#!/usr/bin/env bash

if [ "$1" = "$FOCUSED_WORKSPACE" ]; then
    sketchybar --set $NAME icon="●" icon.color=0xffcdd6f4
else
    sketchybar --set $NAME icon="○" icon.color=0xff9399b2
fi
