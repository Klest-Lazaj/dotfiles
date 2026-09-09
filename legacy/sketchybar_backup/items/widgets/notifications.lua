local colors   = require("colors")
local settings = require("settings")

local BELL     = "􀋚"
local BELL_DND = "􀋜"

local notif = sbar.add("item", "widgets.notifications", {
  position      = "right",
  padding_left  = 1,
  padding_right = 4,
  icon = {
    string        = BELL,
    color         = colors.white,
    font          = { style = settings.font.style_map["Regular"], size = 13.0 },
    padding_left  = 6,
    padding_right = 4,
  },
  label      = { drawing = false },
  update_freq = 10,
})

local function check_dnd()
  -- storeAssertionRecords only exists when a Focus mode is active
  sbar.exec("python3 -c \""
    .. "import json,os;"
    .. "p=os.path.expanduser('~/Library/DoNotDisturb/DB/Assertions.json');"
    .. "d=json.load(open(p)) if os.path.exists(p) else {};"
    .. "recs=d.get('data',[{}])[0].get('storeAssertionRecords',None);"
    .. "print('1' if recs is not None and len(recs)>0 else '0')"
    .. "\" 2>/dev/null || echo 0", function(result)
    local dnd = result:gsub("%s+", "") == "1"
    notif:set({
      icon = {
        string = dnd and BELL_DND or BELL,
        color  = dnd and colors.yellow or colors.white,
      },
    })
  end)
end

notif:subscribe({ "routine", "system_woke", "power_source_change" }, function(_)
  check_dnd()
end)

-- Open Notification Center by clicking the clock (last item) in ControlCenter's menu bar
notif:subscribe("mouse.clicked", function(env)
  sbar.exec([[osascript -e '
    tell application "System Events"
      tell process "ControlCenter"
        set n to count menu bar items of menu bar 1
        click menu bar item n of menu bar 1
      end tell
    end tell
  ']])
end)
