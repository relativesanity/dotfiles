local wezterm = require("wezterm")

local config = wezterm.config_builder()

config.font = wezterm.font("Cascadia Code NF")
config.font_size = 17
config.line_height = 1.1
config.hide_tab_bar_if_only_one_tab = true
config.window_decorations = "RESIZE"
config.color_scheme = "Catppuccin Mocha"
config.window_background_opacity = 0.97
config.macos_window_background_blur = 100
config.default_cursor_style = "SteadyUnderline"
config.cursor_thickness = "2pt"

config.initial_cols = 140
config.initial_rows = 43

config.send_composed_key_when_left_alt_is_pressed = true
config.send_composed_key_when_right_alt_is_pressed = false

return config
