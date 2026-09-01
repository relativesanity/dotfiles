#!/usr/bin/env bash

ASSERTIONS="$HOME/Library/DoNotDisturb/DB/Assertions.json"
MODE_ID=$(jq -r '.data[0].storeAssertionRecords[0].assertionDetails.assertionDetailsModeIdentifier // empty' "$ASSERTIONS" 2>/dev/null)

# Only surface this while a Focus mode is actually active, mirroring
# vpn.sh/timemachine.sh/dotfiles.sh: nothing worth showing while off.
if [ -z "$MODE_ID" ]; then
    sketchybar --set $NAME drawing=off
    exit 0
fi

MODE_NAME=$(jq -r --arg id "$MODE_ID" '.data[0].modeConfigurations[$id].mode.name // empty' "$HOME/Library/DoNotDisturb/DB/ModeConfigurations.json" 2>/dev/null)
[ -z "$MODE_NAME" ] && MODE_NAME="$MODE_ID"

sketchybar --set $NAME drawing=on icon="󰽥" label="$MODE_NAME"
