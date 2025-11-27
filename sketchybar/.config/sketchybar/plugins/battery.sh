#!/usr/bin/env bash

# Get battery percentage
PERCENTAGE=$(pmset -g batt | grep -Eo "\d+%" | cut -d% -f1)
CHARGING=$(pmset -g batt | grep 'AC Power')

# Hide battery indicator when at 100% and on AC power
if [ "$PERCENTAGE" -eq 100 ] && [ -n "$CHARGING" ]; then
    sketchybar --set $NAME drawing=off
    exit 0
fi

# Show battery indicator when below 100%
sketchybar --set $NAME drawing=on

# Catppuccin colors
BLUE=0xff89b4fa  # Catppuccin Blue (for AC power)

# Determine icon and color based on battery level
if [ -n "$CHARGING" ]; then
    ICON="󰂄"  # charging icon
    COLOR="$BLUE"
elif [ "$PERCENTAGE" -ge 90 ]; then
    ICON="󰁹"  # full battery
    COLOR=""
elif [ "$PERCENTAGE" -ge 75 ]; then
    ICON="󰂂"
    COLOR=""
elif [ "$PERCENTAGE" -ge 50 ]; then
    ICON="󰂀"
    COLOR=""
elif [ "$PERCENTAGE" -ge 25 ]; then
    ICON="󰁾"
    COLOR=""
else
    ICON="󰁺"  # low battery
    COLOR=""
fi

# Set icon and label with color if on AC power
if [ -n "$COLOR" ]; then
    sketchybar --set $NAME icon="$ICON" icon.color="$COLOR" label="${PERCENTAGE}%"
else
    sketchybar --set $NAME icon="$ICON" label="${PERCENTAGE}%"
fi
