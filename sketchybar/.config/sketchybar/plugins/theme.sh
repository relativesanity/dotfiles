#!/usr/bin/env bash
#
# Theme manager for sketchybar
# Detects system appearance (dark/light mode) and applies appropriate color scheme
# Uses Catppuccin color names for easy flavor swapping
#
# Usage:
#   theme.sh         - Check cache and update only if theme changed
#   theme.sh --force - Force update regardless of cache

# Cache file to track theme state
CACHE_FILE="/tmp/sketchybar_theme_cache"

# Detect if dark mode is enabled
if defaults read -g AppleInterfaceStyle &> /dev/null; then
    CURRENT_THEME="dark"
    TEXT_COLOR=0xffcdd6f4      # Catppuccin Text
    BAR_COLOR=0x66181825       # Catppuccin Mantle
    BORDER_COLOR=0xff6c7086    # Catppuccin Overlay0
    WORKSPACE_COLOR=0xffcdd6f4 # Catppuccin Text
    CHARGING_COLOR=0xff89b4fa  # Catppuccin Mocha Blue
else
    CURRENT_THEME="light"
    TEXT_COLOR=0xff11111b      # Catppuccin Crust
    BAR_COLOR=0x66cdd6f4       # Catppuccin Text
    BORDER_COLOR=0xff6c7086    # Catppuccin Overlay0
    WORKSPACE_COLOR=0xff11111b # Catppuccin Crust
    CHARGING_COLOR=0xff1e66f5  # Catppuccin Latte Blue
fi

# Check if theme has changed (unless force flag is passed)
if [ "$1" != "--force" ]; then
    LAST_THEME=""
    if [ -f "$CACHE_FILE" ]; then
        LAST_THEME=$(cat "$CACHE_FILE")
    fi

    # Only update if theme changed
    if [ "$CURRENT_THEME" = "$LAST_THEME" ]; then
        # No change, exit early
        exit 0
    fi
fi

# Update cache
echo "$CURRENT_THEME" > "$CACHE_FILE"

# Export colors where plugins need to make runtime decisions about color usage
export SKETCHYBAR_CHARGING_COLOR="$CHARGING_COLOR"

# Apply color scheme
sketchybar --bar color="$BAR_COLOR" border_color="$BORDER_COLOR"
sketchybar --default icon.color="$TEXT_COLOR" label.color="$TEXT_COLOR"

# Update workspace colors (aerospace.sh handles icon state)
for sid in $(aerospace list-workspaces --all); do
    sketchybar --set space.$sid icon.color="$WORKSPACE_COLOR"
done

# Update existing items (--default only affects new items)
sketchybar --set window_title icon.color="$TEXT_COLOR" label.color="$TEXT_COLOR"
sketchybar --set battery icon.color="$TEXT_COLOR" label.color="$TEXT_COLOR"
sketchybar --set wifi icon.color="$TEXT_COLOR" label.color="$TEXT_COLOR"

# Refresh workspace states
sketchybar --trigger aerospace_workspace_change FOCUSED_WORKSPACE=$(aerospace list-workspaces --focused)
