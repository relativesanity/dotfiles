#!/usr/bin/env bash

# Get battery percentage
PERCENTAGE=$(pmset -g batt | grep -Eo "\d+%" | cut -d% -f1)
CHARGING=$(pmset -g batt | grep 'AC Power')

# Determine icon based on battery level
if [ -n "$CHARGING" ]; then
    ICON="󰂄"  # charging icon
elif [ "$PERCENTAGE" -ge 90 ]; then
    ICON="󰁹"  # full battery
elif [ "$PERCENTAGE" -ge 75 ]; then
    ICON="󰂂"
elif [ "$PERCENTAGE" -ge 50 ]; then
    ICON="󰂀"
elif [ "$PERCENTAGE" -ge 25 ]; then
    ICON="󰁾"
else
    ICON="󰁺"  # low battery
fi

sketchybar --set $NAME icon="$ICON" label="${PERCENTAGE}%"
