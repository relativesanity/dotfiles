hs = hs

-- Modifier key combinations
hyper = { "ctrl", "alt", "shift", "cmd" }

require("windows")

-- Formats the current time like 2:32pm
local function currentTime()
	local hour = tonumber(os.date("%I"))
	local minute = os.date("%M")
	local ampm = os.date("%p"):lower()
	return string.format("%d:%s%s", hour, minute, ampm)
end

-- Insert today's date at the cursor, e.g. 2026-08-16
hs.hotkey.bind(hyper, "Z", function()
	hs.eventtap.keyStrokes(os.date("%Y-%m-%d"))
end)

-- Insert the current time at the cursor, e.g. 2:32pm
hs.hotkey.bind(hyper, "X", function()
	hs.eventtap.keyStrokes(currentTime())
end)

-- Obsidian titles its windows "<file> - <vault> - Obsidian <version>" (or
-- just "<vault> - Obsidian <version>" for an empty vault). Match against a
-- specific, known vault name rather than parsing "the vault name" out in
-- the abstract - that's ambiguous whenever the open file's own name
-- contains " - ", and this way there's no version-format assumption (e.g.
-- a pre-release build's "1.13.7-beta" suffix) to go stale against.
local function obsidianWindowIsVault(win, vaultName)
	local pattern = vaultName:gsub("%W", "%%%1")
	local title = win:title()
	return title:match("%- " .. pattern .. " %- Obsidian .+$") ~= nil
		or title:match("^" .. pattern .. " %- Obsidian .+$") ~= nil
end

-- Waits for a new window to appear on the app with the given bundle ID and
-- focuses it directly, instead of trusting the app's own focus handling,
-- which raises whichever window was last active before settling on the
-- right one - visible as a flicker (Ghostty), or as a straight-up steal
-- (Obsidian, which can take long enough to open a vault that the user has
-- moved on to another app entirely by the time the window's ready). Five
-- seconds covers a cold vault open; if it's still not there by then,
-- something's wrong and keeping the app pinned open no longer helps.
--
-- Polling (rather than an event) is what makes that steal possible: if any
-- *other* app gets activated while we're waiting, that's the user (or
-- something else) deliberately choosing where focus goes next, so the
-- pending focus is dropped instead of yanking them back once the window
-- turns up. Window ids only increase, so if this fires twice in quick
-- succession, the highest new id is the one this call actually produced.
--
-- hs.window.filter's windowCreated event would replace this poll with a
-- proper accessibility-notification callback - no timer bookkeeping, no
-- fixed budget to tune. Not worth the swap while this is still a ~30-line
-- helper with one caller pattern; worth revisiting if it grows further.
local function focusNewWindowWhenReady(existingIds, bundleID)
	local abandoned = false
	local watcher
	watcher = hs.application.watcher.new(function(_, event, watchedApp)
		if event == hs.application.watcher.activated and watchedApp:bundleID() ~= bundleID then
			abandoned = true
		end
	end)
	watcher:start()

	local attempts = 0
	local function tick()
		attempts = attempts + 1
		local app = hs.application.find(bundleID)
		local newest
		if app then
			for _, win in ipairs(app:allWindows()) do
				if not existingIds[win:id()] and (not newest or win:id() > newest:id()) then
					newest = win
				end
			end
		end
		if newest then
			watcher:stop()
			if not abandoned then
				newest:focus()
			end
		elseif attempts < 50 then
			hs.timer.doAfter(0.1, tick)
		else
			watcher:stop()
			if not abandoned and app then
				app:activate()
			end
		end
	end
	tick()
end

-- Open an Obsidian vault, focusing its window directly rather than going
-- through the obsidian:// URL scheme's own focus handling.
local function openObsidianVault(vaultName)
	local app = hs.application.find("md.obsidian")
	if app then
		for _, win in ipairs(app:allWindows()) do
			if obsidianWindowIsVault(win, vaultName) then
				win:focus()
				return
			end
		end
	end

	local existing = {}
	if app then
		for _, win in ipairs(app:allWindows()) do
			existing[win:id()] = true
		end
	end

	hs.urlevent.openURL("obsidian://open?vault=" .. vaultName)
	focusNewWindowWhenReady(existing, "md.obsidian")
end

-- Open the notes Obsidian vault
hs.hotkey.bind(hyper, "N", function()
	openObsidianVault("Notes")
end)

-- Open the writing Obsidian vault
hs.hotkey.bind(hyper, "M", function()
	openObsidianVault("Writing")
end)

-- Launch Ghostty if it isn't running; if it is, always pop a new window
-- rather than just refocusing whatever window was last active.
hs.hotkey.bind(hyper, "return", function()
	local app = hs.application.find("com.mitchellh.ghostty")
	if app then
		local existing = {}
		for _, win in ipairs(app:allWindows()) do
			existing[win:id()] = true
		end
		app:selectMenuItem({ "File", "New Window" })

		-- Activating the app leaves macOS/ghostty to pick which window goes
		-- key, and it picks the pre-existing one instead of the new one; so
		-- poll for the new window's id and focus that window directly.
		-- Window ids only increase, so if more than one new id shows up
		-- (e.g. this hotkey fired twice in quick succession), the highest
		-- is the one this invocation actually created.
		local attempts = 0
		local function focusNewWindow()
			attempts = attempts + 1
			local newest
			for _, win in ipairs(app:allWindows()) do
				if not existing[win:id()] and (not newest or win:id() > newest:id()) then
					newest = win
				end
			end
			if newest then
				newest:focus()
			elseif attempts < 50 then
				hs.timer.doAfter(0.02, focusNewWindow)
			else
				app:activate()
			end
		end
		focusNewWindow()
	else
		hs.application.launchOrFocus("Ghostty")
	end
end)

-- Catppuccin Mocha, matching the neovim/btop colourscheme
local function hexColor(hex, alpha)
	hex = hex:gsub("#", "")
	return {
		red = tonumber(hex:sub(1, 2), 16) / 255,
		green = tonumber(hex:sub(3, 4), 16) / 255,
		blue = tonumber(hex:sub(5, 6), 16) / 255,
		alpha = alpha or 1,
	}
end

local timeAlertStyle = {
	strokeColor = hexColor("#6c7086"), -- overlay0, matching sketchybar's bar border_color
	fillColor = hexColor("#1e1e2e", 0.84), -- base, matching ghostty's background-opacity
	textColor = hexColor("#cdd6f4"), -- text
	textFont = "JetBrainsMono Nerd Font",
	textSize = 32,
	radius = 12,
	strokeWidth = 2, -- matching jankyborders' width
	padding = 12, -- hs.alert only supports uniform padding; this covers top/bottom
	fadeInDuration = 0.25,
	fadeOutDuration = 0.25,
}
local timeAlertHorizontalPad = "   " -- extra left/right-only space, since padding above is uniform

-- Pop the current time on screen as an overlay; pressing again dismisses it.
-- A non-number `seconds` argument tells hs.alert to show it indefinitely,
-- with no auto-close timer, until closeSpecific() is called.
local timeAlertID = nil
hs.hotkey.bind(hyper, "C", function()
	if timeAlertID then
		hs.alert.closeSpecific(timeAlertID, timeAlertStyle.fadeOutDuration)
		timeAlertID = nil
	else
		local message = timeAlertHorizontalPad .. currentTime() .. timeAlertHorizontalPad
		timeAlertID = hs.alert.show(message, timeAlertStyle, hs.screen.mainScreen(), true)
	end
end)
