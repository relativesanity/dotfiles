-- windows.lua — Moom-ish window management for Hammerspoon

local meh        = { "ctrl", "alt", "shift" }
local step       = 48   -- pixels per grow/shrink press
local maxFrac    = 0.9  -- grow() won't exceed this fraction of screen width/height
local aerospace  = "/opt/homebrew/bin/aerospace"

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

-- True when AeroSpace has the focused window on its floating layout
local function isFloating()
  local layout = hs.execute(aerospace .. " list-windows --focused --format '%{window-layout}'")
  return layout:match("floating") ~= nil
end

-- Toggle AeroSpace's floating/tiling layout, then centre if it landed on floating
local function toggleFloatAndCentre()
  hs.execute(aerospace .. " layout floating tiling")
  if isFloating() then
    centre()
  end
end

-- Grow/shrink the focused window regardless of layout: AeroSpace owns the
-- frame of tiled windows, so setFrame() on those gets silently overridden —
-- shell out to AeroSpace's own smart resize instead; floating windows resize
-- directly via resize() above.
local function growOrShrink(delta)
  local floatingResize = resize(delta, delta)
  return function()
    if isFloating() then
      floatingResize()
    else
      local sign = delta >= 0 and "+" or ""
      hs.execute(aerospace .. " resize smart " .. sign .. delta)
    end
  end
end

-- Bindings ------------------------------------------------------------------
-- 5th arg = repeat handler, so holding the key keeps resizing

local grow, shrink = growOrShrink(step), growOrShrink(-step)

hs.hotkey.bind(meh, ",", centre)
hs.hotkey.bind(meh, ".", centredAt(0.8, 0.8))
hs.hotkey.bind(meh, "n", shrink, nil, shrink)
hs.hotkey.bind(meh, "m", grow, nil, grow)
hs.hotkey.bind(meh, "/", toggleFloatAndCentre)
