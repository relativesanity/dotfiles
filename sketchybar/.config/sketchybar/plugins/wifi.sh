#!/usr/bin/env bash

# Get wifi information using system_profiler
WIFI_INFO=$(system_profiler SPAirPortDataType 2>/dev/null)
SSID=$(echo "$WIFI_INFO" | grep -A 1 "Current Network Information:" | grep -v "Current Network Information:" | grep -v "^--$" | head -1 | awk '{print $1}' | tr -d ':')
SIGNAL=$(echo "$WIFI_INFO" | awk '/Signal \/ Noise:/ {print $4}' | head -1)

# Determine icon based on signal strength
# RSSI typically ranges from -30 (excellent) to -90 (poor)
# Never show SSID label, just the icon
if [ -n "$SIGNAL" ] && [ "$SIGNAL" -lt 0 ]; then
    # Connected - show signal strength icon
    if [ "$SIGNAL" -ge -50 ]; then
        ICON="󰤨"  # excellent signal
    elif [ "$SIGNAL" -ge -60 ]; then
        ICON="󰤥"  # good signal
    elif [ "$SIGNAL" -ge -70 ]; then
        ICON="󰤢"  # fair signal
    elif [ "$SIGNAL" -ge -80 ]; then
        ICON="󰤟"  # weak signal
    else
        ICON="󰤯"  # very weak signal
    fi
    LABEL=""
else
    # Disconnected
    ICON="󰤮"  # wifi off
    LABEL=""
fi

sketchybar --set $NAME icon="$ICON" label="$LABEL"
