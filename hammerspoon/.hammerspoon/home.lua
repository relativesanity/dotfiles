VAULT_NAME = "jbOS"

hs.hotkey.bind({ "ctrl", "alt", "shift" }, "E", function()
	hs.application.launchOrFocus("YouTube")
end)

hs.hotkey.bind({ "ctrl", "alt", "shift" }, "R", function()
	hs.application.launchOrFocus("Mail")
end)

hs.hotkey.bind({ "ctrl", "alt", "shift" }, "S", function()
	hs.application.launchOrFocus("Safari")
end)

hs.hotkey.bind({ "ctrl", "alt", "shift" }, "D", function()
	hs.application.launchOrFocus("Reader")
end)

hs.hotkey.bind({ "ctrl", "alt", "shift", "cmd" }, "F", function()
	hs.application.launchOrFocus("FindMy")
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

hs.alert.show("Home config loaded")
