-- windows.lua — Moom-ish window management for Hammerspoon

local meh  = { "ctrl", "alt", "shift" }
local step = 60 -- pixels per grow/shrink press

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
-- resize(step, 0) or resize(0, step) if you ever want a single axis.
local function resize(dw, dh)
  return function()
    local win = focused(); if not win then return end
    local f = win:frame()
    f.x, f.w = f.x - dw / 2, f.w + dw
    f.y, f.h = f.y - dh / 2, f.h + dh
    win:setFrame(f)
  end
end

-- Bindings ------------------------------------------------------------------
-- 5th arg = repeat handler, so holding the key keeps resizing

local grow, shrink = resize(step, step), resize(-step, -step)

hs.hotkey.bind(meh, ",", centre)
hs.hotkey.bind(meh, ".", centredAt(0.8, 0.8))
hs.hotkey.bind(meh, "n", grow, nil, grow)
hs.hotkey.bind(meh, "m", shrink, nil, shrink)
