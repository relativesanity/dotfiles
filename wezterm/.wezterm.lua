local wezterm = require("wezterm")

local config = wezterm.config_builder()

config.font = wezterm.font("JetBrainsMono Nerd Font Mono")
config.font_size = 17
config.hide_tab_bar_if_only_one_tab = true
config.window_decorations = "RESIZE"
config.color_scheme = "Catppuccin Mocha"
config.window_background_opacity = 0.85
config.macos_window_background_blur = 100

config.initial_cols = 144
config.initial_rows = 39

return config
