#!/usr/bin/env bash

# One osascript call covers both volume and mute state.
SETTINGS=$(osascript -e "get volume settings")
VOLUME=$(grep -o 'output volume:[0-9]*' <<< "$SETTINGS" | cut -d: -f2)
MUTED=$(grep -o 'output muted:[a-z]*' <<< "$SETTINGS" | cut -d: -f2)

# system_profiler SPAudioDataType is fast (unlike SPAirPortDataType, which
# wifi.sh already pays for) — find the device header line preceding the
# "Default Output Device: Yes" flag.
DEVICE=$(system_profiler SPAudioDataType | awk -F: '
    /^        [^ ]/ && /:$/ { name=$0 }
    /Default Output Device: Yes/ { gsub(/^ +/, "", name); gsub(/:$/, "", name); print name; exit }
')

if [ "$MUTED" = "true" ]; then
    ICON="󰝟"  # muted
    LABEL="Muted"
elif grep -qiE 'headphone|airpods|earpods|beats' <<< "$DEVICE"; then
    ICON="󰋋"  # headphones
    LABEL="${VOLUME}%"
else
    ICON="󰓃"  # speaker
    LABEL="${VOLUME}%"
fi

sketchybar --set $NAME icon="$ICON" label="$LABEL"
