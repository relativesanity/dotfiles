VAULT_NAME = "emOSv2"

hs.hotkey.bind(meh, "Z", function()
	hs.application.launchOrFocus("zoom.us")
end)

hs.hotkey.bind(meh, "C", function()
	hs.application.launchOrFocus("Slack")
end)

hs.alert.show("Work config loaded")
