#!/usr/bin/env bash

# Only surface Time Machine while a backup is actively running, mirroring
# vpn.sh: nothing worth showing in the bar while idle.
STATUS=$(tmutil status)

RUNNING=$(grep -oE 'Running = [01]' <<< "$STATUS" | grep -oE '[01]')

if [ "$RUNNING" != "1" ]; then
    sketchybar --set $NAME drawing=off
    exit 0
fi

PHASE=$(grep -E '^\s*BackupPhase = ' <<< "$STATUS" | sed -E 's/.*= (.*);/\1/')
PERCENT_RAW=$(grep -E '^\s*Percent = ' <<< "$STATUS" | grep -Eo '[0-9]+\.[0-9]+' | head -1)

# Early phases (e.g. FindingChanges) haven't populated Progress.Percent yet,
# so fall back to the phase name until a percentage is available.
if [ -n "$PERCENT_RAW" ]; then
    LABEL="$(awk "BEGIN { printf \"%.0f\", $PERCENT_RAW * 100 }")%"
elif [ -n "$PHASE" ]; then
    LABEL="$PHASE"
else
    LABEL="Backing up"
fi

sketchybar --set $NAME drawing=on icon="󰁯" label="$LABEL"
