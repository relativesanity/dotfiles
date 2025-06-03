VAULT_NAME = "emOSv2"

hs.hotkey.bind({ "ctrl", "alt", "shift" }, "E", function()
	-- hs.application.launchOrFocus("YouTube")
end)

hs.hotkey.bind({ "ctrl", "alt", "shift" }, "R", function()
	-- hs.application.launchOrFocus("Mail")
end)

hs.hotkey.bind({ "ctrl", "alt", "shift" }, "S", function()
	hs.application.launchOrFocus("Google Chrome")
end)

hs.hotkey.bind({ "ctrl", "alt", "shift" }, "D", function()
	-- hs.application.launchOrFocus("Reader")
end)

hs.hotkey.bind({ "ctrl", "alt", "shift" }, "Z", function()
	hs.application.launchOrFocus("zoom.us")
end)

hs.hotkey.bind({ "ctrl", "alt", "shift" }, "C", function()
	hs.application.launchOrFocus("Slack")
end)

hs.hotkey.bind({ "ctrl", "alt", "shift" }, "V", function()
	-- hs.application.launchOrFocus("Claude")
end)

hs.alert.show("Work config loaded")
