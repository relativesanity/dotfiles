VAULT_NAME = "jbOSv2"

hs.hotkey.bind(meh, "Q", function()
	hs.application.launchOrFocus("Day One")
end)

hs.hotkey.bind(meh, "E", function()
	hs.application.launchOrFocus("Mail")
end)

hs.hotkey.bind(meh, "R", function()
	hs.application.launchOrFocus("Reader")
end)

hs.hotkey.bind(hyper, "F", function()
	hs.application.launchOrFocus("FindMy")
end)

hs.hotkey.bind(meh, "C", function()
	hs.application.launchOrFocus("Messages")
end)

hs.hotkey.bind(hyper, "C", function()
	hs.application.launchOrFocus("Signal")
end)

hs.hotkey.bind(meh, "V", function()
	hs.application.launchOrFocus("Claude")
end)

hs.hotkey.bind(meh, "Z", function()
	hs.application.launchOrFocus("YouTube")
end)

hs.hotkey.bind(hyper, "Q", function()
	hs.application.launchOrFocus("Music")
end)

hs.alert.show("Home config loaded")
