hs = hs

-- Modifier key combinations
meh = { "ctrl", "alt", "shift" }
hyper = { "ctrl", "alt", "shift", "cmd" }

-- Utility functions
hs.hotkey.bind(hyper, "V", function()
	hs.reload()
end)

hs.hotkey.bind(hyper, "C", function()
	hs.eventtap.keyStroke({ "cmd", "shift" }, "4")
end)

hs.hotkey.bind(meh, "X", function()
	hs.eventtap.keyStrokes(os.date("%Y-%m-%d"))
end)

hs.hotkey.bind(hyper, "X", function()
	local weekNumber = os.date("%V")
	local year = os.date("%Y")
	hs.eventtap.keyStrokes(string.format("%s-%02d", year, tonumber(weekNumber)))
end)

-- Dark/Light mode toggle
hs.hotkey.bind(hyper, "Z", function()
	-- Toggle macOS appearance
	hs.osascript.applescript('tell app "System Events" to tell appearance preferences to set dark mode to not dark mode')
end)
