local icons = require("icons")
local colors = require("colors")
local settings = require("settings")

local popup_width = 220

local battery = sbar.add("item", "widgets.battery", {
  position = "right",
  icon = {
    font = { style = settings.font.style_map["Regular"], size = 19.0 },
  },
  label = { font = { family = settings.font.numbers } },
  update_freq = 60,
  popup = {
    align = "center",
    background = {
      color = colors.popup.bg,
      border_color = colors.popup.border,
      border_width = 1,
      corner_radius = 10,
    },
  },
})

-- Static progress bar: track background fills from left
local bar_bg = sbar.add("item", {
  position = "popup." .. battery.name,
  width = popup_width,
  padding_left = 12,
  padding_right = 12,
  icon = { drawing = false },
  label = { drawing = false },
  background = {
    height = 6,
    corner_radius = 3,
    color = colors.bg2,
    border_width = 0,
  },
})
local bar_fill = sbar.add("item", {
  position = "popup." .. battery.name,
  padding_left = 0,
  padding_right = 0,
  width = 0,
  icon = { drawing = false },
  label = { drawing = false },
  background = {
    height = 6,
    corner_radius = 3,
    color = colors.green,
    border_width = 0,
    clip = 1.0,
  },
})

local source_row = sbar.add("item", {
  position = "popup." .. battery.name,
  width = popup_width,
  padding_left = 12,
  padding_right = 12,
  icon = { align = "left", string = "Source",         color = colors.grey, width = popup_width * 0.5, font = { size = 12.0 } },
  label = { align = "right", string = "—",            width = popup_width * 0.5, color = colors.white, font = { family = settings.font.numbers, size = 12.0 } },
})

local time_row = sbar.add("item", {
  position = "popup." .. battery.name,
  width = popup_width,
  padding_left = 12,
  padding_right = 12,
  icon = { align = "left", string = "Time Remaining", color = colors.grey, width = popup_width * 0.5, font = { size = 12.0 } },
  label = { align = "right", string = "—",            width = popup_width * 0.5, color = colors.white, font = { family = settings.font.numbers, size = 12.0 } },
})

-- Cache updated every routine tick so popup opens instantly
local cache = { time = "—", source = "—", charge = 0, color = colors.green }
local popup_open = false

battery:subscribe({ "routine", "power_source_change", "system_woke" }, function()
  sbar.exec("pmset -g batt", function(batt_info)
    local icon  = "!"
    local label = "?"

    local found, _, charge = batt_info:find("(%d+)%%")
    if found then
      charge = tonumber(charge)
      label  = charge .. "%"
      cache.charge = charge
    end

    local color    = colors.green
    local charging = batt_info:find("AC Power")

    if charging then
      icon             = icons.battery.charging
      color            = colors.blue
      cache.source     = "AC Power"
    else
      cache.source = "Battery"
      if found and charge > 80 then
        icon  = icons.battery._100
      elseif found and charge > 60 then
        icon  = icons.battery._75
      elseif found and charge > 40 then
        icon  = icons.battery._50
      elseif found and charge > 20 then
        icon  = icons.battery._25
        color = colors.orange
      else
        icon  = icons.battery._0
        color = colors.red
      end
    end

    local found_time, _, remaining = batt_info:find(" (%d+:%d+) remaining")
    cache.time  = found_time and (remaining .. "h") or (charging and "Calculating…" or "—")
    cache.color = color

    local lead = (found and charge < 10) and "0" or ""
    battery:set({
      icon  = { string = icon, color = color },
      label = { string = lead .. label },
    })
    -- Keep fill bar in sync if popup is open
    if popup_open then
      bar_fill:set({ background = { color = cache.color }, width = math.floor((popup_width - 24) * cache.charge / 100) })
    end
  end)
end)

battery:subscribe("mouse.clicked", function(env)
  if not popup_open then
    bar_fill:set({
      background = { color = cache.color },
      width = math.floor((popup_width - 24) * cache.charge / 100),
    })
    source_row:set({ label = cache.source })
    time_row:set({ label = cache.time })
    battery:set({ popup = { drawing = true } })
    popup_open = true
  else
    battery:set({ popup = { drawing = false } })
    popup_open = false
  end
end)

battery:subscribe("mouse.exited.global", function()
  if popup_open then
    battery:set({ popup = { drawing = false } })
    popup_open = false
  end
end)


