#!/usr/bin/env bash
#
# Theme manager for sketchybar
# Detects system appearance (dark/light mode) and applies appropriate color scheme
# Automatically switches between Catppuccin Mocha (dark) and inverted colors (light)
#
# Usage:
#   theme.sh         - Check cache and update only if theme changed
#   theme.sh --force - Force update regardless of cache

# Cache file to track theme state
CACHE_FILE="/tmp/sketchybar_theme_cache"

# Detect if dark mode is enabled
if defaults read -g AppleInterfaceStyle &> /dev/null; then
    CURRENT_THEME="dark"
    # Dark mode - Catppuccin Mocha
    TEXT_COLOR=0xffcdd6f4
    BAR_COLOR=0x66181825
    BORDER_COLOR=0xff6c7086
    WORKSPACE_COLOR=0xffcdd6f4
else
    CURRENT_THEME="light"
    # Light mode - Inverted Mocha colors
    TEXT_COLOR=0xff32290b
    BAR_COLOR=0x66e7e7da
    BORDER_COLOR=0xff938f79
    WORKSPACE_COLOR=0xff32290b
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
