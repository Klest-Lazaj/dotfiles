require("items.widgets.battery")
require("items.widgets.volume")
require("items.widgets.wifi")
require("items.widgets.cpu")
require("items.widgets.notifications")

local colors   = require("colors")
local settings = require("settings")

-- Single unified pill around all widgets + calendar (all named "widgets.*")
sbar.add("bracket", "widgets.group", { "/widgets\\..*/" }, {
  background = {
    color = colors.bg1,
    corner_radius = 9,
    height = 28,
  },
})

sbar.add("item", { position = "right", width = settings.group_paddings })
