local settings = require("settings")
local colors = require("colors")

local cal = sbar.add("item", "widgets.calendar", {
  icon = {
    color = colors.white,
    padding_left = 8,
    y_offset = 1,
    font = {
      style = settings.font.style_map["Black"],
      size = 12.0,
    },
  },
  label = {
    color = colors.white,
    padding_right = 8,
    width = 65,
    align = "right",
    y_offset = -1,
    font = { family = settings.font.numbers },
  },
  position = "right",
  update_freq = 1,
  padding_left = 1,
  padding_right = 8,
  background = {
    color = colors.bg2,
    border_color = colors.black,
    border_width = 1
  },
  click_script = "open -a 'Calendar'"
})

cal:subscribe({ "forced", "routine", "system_woke" }, function(env)
  cal:set({ icon = os.date("%a. %d %b."), label = os.date("%H:%M:%S") })
end)
