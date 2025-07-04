VAULT_NAME = "emOSv2"

hs.hotkey.bind({ "ctrl", "alt", "shift" }, "Z", function()
	hs.application.launchOrFocus("zoom.us")
end)

hs.hotkey.bind({ "ctrl", "alt", "shift" }, "C", function()
	hs.application.launchOrFocus("Slack")
end)

hs.alert.show("Work config loaded")
