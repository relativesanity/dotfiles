-- windows.lua — Moom-ish window management for Hammerspoon

local meh     = { "ctrl", "alt", "shift" }
local step    = 60   -- pixels per grow/shrink press
local maxFrac = 0.9  -- grow() won't exceed this fraction of screen width/height

hs.window.animationDuration = 0 -- snap instantly, no easing

local function focused()
  local win = hs.window.focusedWindow()
  if not win then hs.alert.show("No focused window") end
  return win
end

-- Centre the window without changing its size
local function centre()
  local win = focused(); if not win then return end
  local f, s = win:frame(), win:screen():frame()
  f.x = s.x + (s.w - f.w) / 2
  f.y = s.y + (s.h - f.h) / 2
  win:setFrame(f)
end

-- Centre at a given fraction of screen width/height, e.g. centredAt(0.8, 0.8)
local function centredAt(w, h)
  return function()
    local win = focused(); if not win then return end
    local s = win:screen():frame()
    win:setFrame({
      x = s.x + s.w * (1 - w) / 2,
      y = s.y + s.h * (1 - h) / 2,
      w = s.w * w,
      h = s.h * h,
    })
  end
end

-- Grow/shrink from the centre outwards, keeping the window's midpoint fixed.
-- Growth is clamped to maxFrac of the screen's width/height.
-- resize(step, 0) or resize(0, step) if you ever want a single axis.
local function resize(dw, dh)
  return function()
    local win = focused(); if not win then return end
    local f, s = win:frame(), win:screen():frame()
    local cx, cy = f.x + f.w / 2, f.y + f.h / 2
    local w = math.min(f.w + dw, s.w * maxFrac)
    local h = math.min(f.h + dh, s.h * maxFrac)
    win:setFrame({ x = cx - w / 2, y = cy - h / 2, w = w, h = h })
  end
end

-- Toggle AeroSpace's floating/tiling layout, then centre if it landed on floating
local function toggleFloatAndCentre()
  hs.execute("/opt/homebrew/bin/aerospace layout floating tiling")
  local layout = hs.execute("/opt/homebrew/bin/aerospace list-windows --focused --format '%{window-layout}'")
  if layout:match("floating") then
    centre()
  end
end

-- Bindings ------------------------------------------------------------------
-- 5th arg = repeat handler, so holding the key keeps resizing

local grow, shrink = resize(step, step), resize(-step, -step)

hs.hotkey.bind(meh, ",", centre)
hs.hotkey.bind(meh, ".", centredAt(0.8, 0.8))
hs.hotkey.bind(meh, "n", grow, nil, grow)
hs.hotkey.bind(meh, "m", shrink, nil, shrink)
hs.hotkey.bind(meh, "/", toggleFloatAndCentre)
