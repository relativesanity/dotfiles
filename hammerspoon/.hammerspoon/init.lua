hs = hs

require("windows")

-- Modifier key combinations
hyper = { "ctrl", "alt", "shift", "cmd" }

-- Formats the current time like 2:32pm
local function currentTime()
	local hour = tonumber(os.date("%I"))
	local minute = os.date("%M")
	local ampm = os.date("%p"):lower()
	return string.format("%d:%s%s", hour, minute, ampm)
end

-- Insert today's date at the cursor, e.g. 2026-08-16
hs.hotkey.bind(hyper, "Z", function()
	hs.eventtap.keyStrokes(os.date("%Y-%m-%d"))
end)

-- Insert the current time at the cursor, e.g. 2:32pm
hs.hotkey.bind(hyper, "X", function()
	hs.eventtap.keyStrokes(currentTime())
end)

-- Launch Ghostty if it isn't running; if it is, always pop a new window
-- rather than just refocusing whatever window was last active.
hs.hotkey.bind(hyper, "return", function()
	local app = hs.application.find("com.mitchellh.ghostty")
	if app then
		app:activate()
		app:selectMenuItem({ "File", "New Window" })
	else
		hs.application.launchOrFocus("Ghostty")
	end
end)

-- Catppuccin Mocha, matching the neovim/btop colourscheme
local function hexColor(hex, alpha)
	hex = hex:gsub("#", "")
	return {
		red = tonumber(hex:sub(1, 2), 16) / 255,
		green = tonumber(hex:sub(3, 4), 16) / 255,
		blue = tonumber(hex:sub(5, 6), 16) / 255,
		alpha = alpha or 1,
	}
end

local timeAlertStyle = {
	strokeColor = hexColor("#6c7086"), -- overlay0, matching sketchybar's bar border_color
	fillColor = hexColor("#1e1e2e", 0.84), -- base, matching ghostty's background-opacity
	textColor = hexColor("#cdd6f4"), -- text
	textFont = "JetBrainsMono Nerd Font",
	textSize = 32,
	radius = 12,
	strokeWidth = 2, -- matching jankyborders' width
	padding = 12, -- hs.alert only supports uniform padding; this covers top/bottom
	fadeInDuration = 0.25,
	fadeOutDuration = 0.25,
}
local timeAlertHorizontalPad = "   " -- extra left/right-only space, since padding above is uniform

-- Pop the current time on screen as an overlay; pressing again dismisses it.
-- A non-number `seconds` argument tells hs.alert to show it indefinitely,
-- with no auto-close timer, until closeSpecific() is called.
local timeAlertID = nil
hs.hotkey.bind(hyper, "C", function()
	if timeAlertID then
		hs.alert.closeSpecific(timeAlertID, timeAlertStyle.fadeOutDuration)
		timeAlertID = nil
	else
		local message = timeAlertHorizontalPad .. currentTime() .. timeAlertHorizontalPad
		timeAlertID = hs.alert.show(message, timeAlertStyle, hs.screen.mainScreen(), true)
	end
end)
