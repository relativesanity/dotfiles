hs = hs

local function getCurrentUser()
	return (os.getenv("USER") or ""):gsub("[\n\r]", "")
end

if getCurrentUser() == "relativesanity" then
	require("home")
else
	require("work")
end

hs.hotkey.bind({ "ctrl", "alt", "shift" }, "W", function()
	hs.osascript.applescript([[
    tell application "Finder"
        open (path to home folder as text) & ".local:share:wallpaper:"
    end tell
  ]])
	hs.application.launchOrFocus("Finder")
end)

hs.hotkey.bind({ "ctrl", "alt", "shift", "cmd" }, "W", function()
	hs.osascript.applescript([[
    tell application "Finder"
        set theFile to selection as alias
        set desktop picture to theFile
    end tell
  ]])
end)

hs.hotkey.bind({ "ctrl", "alt", "shift" }, "X", function()
	hs.eventtap.keyStrokes(os.date("%Y-%m-%d"))
end)

hs.hotkey.bind({ "ctrl", "alt", "shift", "cmd" }, "X", function()
	hs.eventtap.keyStrokes(os.date("%Y-%m-%d - "))
end)

hs.hotkey.bind({ "ctrl", "alt", "shift" }, "Q", function()
	local hour = tonumber(os.date("%I"))
	local rest = os.date(":%M%p")
	local timeString = tostring(hour) .. rest
	hs.eventtap.keyStrokes(string.lower(timeString))
end)

hs.hotkey.bind({ "ctrl", "alt", "shift", "cmd" }, "R", function()
	hs.reload()
end)

hs.hotkey.bind({ "ctrl", "alt", "shift" }, "T", function()
	hs.application.launchOrFocus("Things3")
end)

hs.hotkey.bind({ "ctrl", "alt", "shift" }, "F", function()
	hs.application.launchOrFocus("Finder")
end)

hs.hotkey.bind({ "ctrl", "alt", "shift" }, "G", function()
	hs.application.launchOrFocus("Ghostty")
end)

hs.hotkey.bind({ "ctrl", "alt", "shift" }, "B", function()
	hs.application.launchOrFocus("Obsidian")
end)

hs.hotkey.bind({ "ctrl", "alt", "shift", "cmd" }, "B", function()
	local uri = string.format(
		"obsidian://adv-uri?vault=%s&commandid=periodic-notes%%3Aopen-daily-note",
		hs.http.encodeForQuery(VAULT_NAME)
	)
	hs.urlevent.openURL(uri)
end)
