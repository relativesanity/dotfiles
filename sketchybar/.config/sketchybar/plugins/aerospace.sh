#!/usr/bin/env bash

if [ "$1" = "$FOCUSED_WORKSPACE" ]; then
    sketchybar --set $NAME label.color=0xffcdd6f4
else
    sketchybar --set $NAME label.color=0xff6c7086
fi
