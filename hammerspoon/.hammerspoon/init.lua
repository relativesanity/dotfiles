hs = hs

-- Modifier key combinations
meh = { "ctrl", "alt", "shift" }
hyper = { "ctrl", "alt", "shift", "cmd" }

-- Primary app launchers (meh + key)
hs.hotkey.bind(meh, "B", function()
	hs.application.launchOrFocus("Obsidian")
end)

hs.hotkey.bind(meh, "C", function()
	hs.application.launchOrFocus("Messages")
end)

hs.hotkey.bind(meh, "D", function()
	hs.application.launchOrFocus("Google Chrome")
end)

hs.hotkey.bind(meh, "E", function()
	hs.application.launchOrFocus("Mail")
end)

hs.hotkey.bind(meh, "F", function()
	hs.application.launchOrFocus("Finder")
end)

hs.hotkey.bind(meh, "G", function()
	hs.application.launchOrFocus("Ghostty")
end)

hs.hotkey.bind(meh, "Q", function()
	hs.application.launchOrFocus("Day One")
end)

hs.hotkey.bind(meh, "R", function()
	hs.application.launchOrFocus("Reader")
end)

hs.hotkey.bind(meh, "S", function()
	hs.application.launchOrFocus("Safari")
end)

hs.hotkey.bind(meh, "T", function()
	hs.application.launchOrFocus("Things3")
end)

hs.hotkey.bind(meh, "V", function()
	hs.application.launchOrFocus("Claude")
end)

hs.hotkey.bind(meh, "Z", function()
	hs.application.launchOrFocus("YouTube")
end)

-- Secondary/utility launchers (hyper + key)
hs.hotkey.bind(hyper, "C", function()
	hs.application.launchOrFocus("Signal")
end)

hs.hotkey.bind(hyper, "F", function()
	hs.application.launchOrFocus("FindMy")
end)

hs.hotkey.bind(hyper, "G", function()
	hs.application.launchOrFocus("Cursor")
end)

hs.hotkey.bind(hyper, "Q", function()
	hs.application.launchOrFocus("Music")
end)

hs.hotkey.bind(hyper, "V", function()
	hs.application.launchOrFocus("Slack")
end)

hs.hotkey.bind(hyper, "Z", function()
	hs.application.launchOrFocus("zoom.us")
end)

-- Utility functions
hs.hotkey.bind(hyper, "R", function()
	hs.reload()
end)

hs.hotkey.bind(hyper, "S", function()
	hs.eventtap.keyStroke({ "cmd", "shift" }, "4")
end)

hs.hotkey.bind(meh, "W", function()
	hs.osascript.applescript([[
    tell application "Finder"
        open (path to home folder as text) & ".local:share:wallpaper:"
    end tell
  ]])
	hs.application.launchOrFocus("Finder")
end)

hs.hotkey.bind(hyper, "W", function()
	hs.osascript.applescript([[
    tell application "Finder"
        set theFile to selection as alias
        set desktop picture to theFile
    end tell
  ]])
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