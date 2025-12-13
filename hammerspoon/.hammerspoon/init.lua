hs = hs

-- Modifier key combinations
meh = { "ctrl", "alt", "shift" }
hyper = { "ctrl", "alt", "shift", "cmd" }

-- Wallpaper configuration
local wallpaper_light = "10-3-6k.jpg"
local wallpaper_dark = "apple-black-4k.png"

-- Utility functions
hs.hotkey.bind(hyper, "V", function()
	hs.reload()
end)

hs.hotkey.bind(hyper, "C", function()
	hs.eventtap.keyStroke({ "cmd", "shift" }, "4")
end)

hs.hotkey.bind(meh, "X", function()
	hs.eventtap.keyStrokes(os.date("%Y-%m-%d"))
end)

hs.hotkey.bind(hyper, "X", function()
	local weekNumber = os.date("%V")
	local year = os.date("%Y")
	hs.eventtap.keyStrokes(string.format("%s-%02d", year, tonumber(weekNumber)))
end)

-- Dark/Light mode toggle
hs.hotkey.bind(hyper, "Z", function()
	-- Toggle macOS appearance
	hs.osascript.applescript('tell app "System Events" to tell appearance preferences to set dark mode to not dark mode')

	-- Wait a moment for the system to update, then set wallpaper based on new mode
	hs.timer.doAfter(0.3, function()
		local _, isDark = hs.osascript.applescript('tell app "System Events" to tell appearance preferences to get dark mode')
		local wallpaperFilename = isDark and wallpaper_dark or wallpaper_light
		local wallpaperPath = os.getenv("HOME") .. "/.local/share/wallpaper/" .. wallpaperFilename

		-- Set wallpaper for all screens
		hs.osascript.applescript(string.format([[
			tell application "System Events"
				tell every desktop
					set picture to "%s"
				end tell
			end tell
		]], wallpaperPath))
	end)
end)
