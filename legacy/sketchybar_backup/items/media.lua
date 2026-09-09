local icons = require("icons")
local colors = require("colors")

local whitelist = { ["Spotify"] = true,
                    ["Music"] = true    };

local media_cover = sbar.add("item", {
  position = "right",
  background = {
    image = {
      string = "media.artwork",
      scale = 0.85,
    },
    color = colors.transparent,
  },
  label = { drawing = false },
  icon = { drawing = false },
  drawing = false,
  updates = true,
  popup = {
    align = "center",
    horizontal = true,
  }
})

local media_artist = sbar.add("item", {
  position = "right",
  drawing = false,
  padding_left = 3,
  padding_right = 0,
  width = 0,
  icon = { drawing = false },
  label = {
    width = 0,
    font = { size = 9 },
    color = colors.with_alpha(colors.white, 0.6),
    max_chars = 18,
    y_offset = 6,
  },
})

local media_title = sbar.add("item", {
  position = "right",
  drawing = false,
  padding_left = 3,
  padding_right = 0,
  icon = { drawing = false },
  label = {
    font = { size = 11 },
    width = 0,
    max_chars = 16,
    y_offset = -5,
  },
})

sbar.add("item", {
  position = "popup." .. media_cover.name,
  icon = { string = icons.media.back },
  label = { drawing = false },
  click_script = "nowplaying-cli previous",
})
sbar.add("item", {
  position = "popup." .. media_cover.name,
  icon = { string = icons.media.play_pause },
  label = { drawing = false },
  click_script = "nowplaying-cli togglePlayPause",
})
sbar.add("item", {
  position = "popup." .. media_cover.name,
  icon = { string = icons.media.forward },
  label = { drawing = false },
  click_script = "nowplaying-cli next",
})

-- Animated equalizer bars (render to the left of album art in the bar)
local EQ_COUNT = 4
local eq_bars = {}
local eq_playing = false
local eq_frame = 0

for i = 1, EQ_COUNT do
  eq_bars[i] = sbar.add("item", "media.eq." .. i, {
    position = "right",
    drawing = false,
    width = 4,
    padding_left = 1,
    padding_right = 1,
    icon  = { drawing = false },
    label = { drawing = false },
    background = {
      height = 4,
      color = colors.blue,
      corner_radius = 2,
      drawing = true,
    },
  })
end

local function tick_eq()
  if not eq_playing then return end
  eq_frame = eq_frame + 1
  sbar.animate("tanh", 3, function()
    for i = 1, EQ_COUNT do
      local phase = eq_frame * 0.45 + i * 1.6
      local h = math.floor(4 + 12 * ((math.sin(phase) + 1) / 2))
      eq_bars[i]:set({ background = { height = h } })
    end
  end)
  sbar.delay(0.12, tick_eq)
end

local function start_eq()
  if eq_playing then return end
  eq_playing = true
  sbar.animate("tanh", 15, function()
    for i = 1, EQ_COUNT do
      eq_bars[i]:set({ drawing = true })
    end
  end)
  tick_eq()
end

local function stop_eq()
  eq_playing = false
  sbar.animate("tanh", 15, function()
    for i = 1, EQ_COUNT do
      eq_bars[i]:set({ drawing = false, background = { height = 4 } })
    end
  end)
end

local interrupt = 0
local function animate_detail(detail)
  if (not detail) then interrupt = interrupt - 1 end
  if interrupt > 0 and (not detail) then return end

  sbar.animate("tanh", 30, function()
    media_artist:set({ label = { width = detail and "dynamic" or 0 } })
    media_title:set({ label = { width = detail and "dynamic" or 0 } })
  end)
end

media_cover:subscribe("media_change", function(env)
  if whitelist[env.INFO.app] then
    local drawing = (env.INFO.state == "playing")
    media_artist:set({ drawing = drawing, label = env.INFO.artist, })
    media_title:set({ drawing = drawing, label = env.INFO.title, })
    media_cover:set({ drawing = drawing })

    if drawing then
      start_eq()
      animate_detail(true)
      interrupt = interrupt + 1
      sbar.delay(5, animate_detail)
    else
      stop_eq()
      media_cover:set({ popup = { drawing = false } })
    end
  end
end)

media_cover:subscribe("mouse.entered", function(env)
  interrupt = interrupt + 1
  animate_detail(true)
end)

media_cover:subscribe("mouse.exited", function(env)
  animate_detail(false)
end)

media_cover:subscribe("mouse.clicked", function(env)
  media_cover:set({ popup = { drawing = "toggle" }})
end)

media_title:subscribe("mouse.exited.global", function(env)
  media_cover:set({ popup = { drawing = false }})
end)
