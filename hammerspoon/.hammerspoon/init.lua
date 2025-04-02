hs = hs

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

hs.hotkey.bind({ "ctrl", "alt", "shift" }, "E", function()
	hs.application.launchOrFocus("YouTube")
end)

hs.hotkey.bind({ "ctrl", "alt", "shift" }, "R", function()
	hs.application.launchOrFocus("Mail")
end)

hs.hotkey.bind({ "ctrl", "alt", "shift", "cmd" }, "R", function()
	hs.reload()
end)

hs.hotkey.bind({ "ctrl", "alt", "shift" }, "T", function()
	hs.application.launchOrFocus("Things3")
end)

hs.hotkey.bind({ "ctrl", "alt", "shift" }, "S", function()
	hs.application.launchOrFocus("Safari")
end)

hs.hotkey.bind({ "ctrl", "alt", "shift" }, "D", function()
	hs.application.launchOrFocus("Reader")
end)

hs.hotkey.bind({ "ctrl", "alt", "shift" }, "F", function()
	hs.application.launchOrFocus("Finder")
end)

hs.hotkey.bind({ "ctrl", "alt", "shift" }, "G", function()
	hs.application.launchOrFocus("Ghostty")
end)

hs.hotkey.bind({ "ctrl", "alt", "shift" }, "Z", function()
	hs.application.launchOrFocus("Oryx")
end)

hs.hotkey.bind({ "ctrl", "alt", "shift" }, "C", function()
	hs.application.launchOrFocus("Messages")
end)

hs.hotkey.bind({ "ctrl", "alt", "shift" }, "V", function()
	hs.application.launchOrFocus("Claude")
end)

hs.hotkey.bind({ "ctrl", "alt", "shift" }, "B", function()
	hs.application.launchOrFocus("Obsidian")
end)

hs.alert.show("Config Loaded")
