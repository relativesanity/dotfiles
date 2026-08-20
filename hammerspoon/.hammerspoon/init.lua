hs = hs

require("windows")

-- Modifier key combinations
hyper = { "ctrl", "alt", "shift", "cmd" }

-- Insert today's date at the cursor, e.g. 2026-08-16
hs.hotkey.bind(hyper, "Z", function()
	hs.eventtap.keyStrokes(os.date("%Y-%m-%d"))
end)

-- Insert the current time at the cursor, e.g. 2:32pm
hs.hotkey.bind(hyper, "X", function()
	local hour = tonumber(os.date("%I"))
	local minute = os.date("%M")
	local ampm = os.date("%p"):lower()
	hs.eventtap.keyStrokes(string.format("%d:%s%s", hour, minute, ampm))
end)
