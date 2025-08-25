hs = hs

-- Modifier key combinations
meh = { "ctrl", "alt", "shift" }
hyper = { "ctrl", "alt", "shift", "cmd" }

-- Utility functions
hs.hotkey.bind(hyper, "R", function()
	hs.reload()
end)

hs.hotkey.bind(hyper, "V", function()
	hs.eventtap.keyStroke({ "cmd", "shift" }, "4")
end)


hs.hotkey.bind(meh, "X", function()
	hs.eventtap.keyStrokes(os.date("%Y-%m-%d"))
end)

hs.hotkey.bind(hyper, "X", function()
	local hour = tonumber(os.date("%I"))
	local rest = os.date(":%M%p")
	local timeString = tostring(hour) .. rest
	hs.eventtap.keyStrokes(string.lower(timeString))
end)
