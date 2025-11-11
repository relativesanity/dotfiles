#!/usr/bin/env bash

# Get the focused window app name from aerospace
APP_NAME=$(aerospace list-windows --focused --format '%{app-name}' | head -n 1)

sketchybar --set $NAME label="$APP_NAME"
