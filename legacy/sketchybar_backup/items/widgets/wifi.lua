local icons = require("icons")
local colors = require("colors")
local settings = require("settings")

sbar.exec("killall network_load >/dev/null; $CONFIG_DIR/helpers/event_providers/network_load/bin/network_load en0 network_update 2.0")

local popup_width = 240

local wifi_up = sbar.add("item", "widgets.wifi1", {
  position = "right",
  padding_left = -5,
  width = 0,
  icon = {
    padding_right = 0,
    font = { style = settings.font.style_map["Bold"], size = 9.0 },
    string = icons.wifi.upload,
  },
  label = {
    font = { family = settings.font.numbers, style = settings.font.style_map["Bold"], size = 9.0 },
    color = colors.grey,
    string = "— Bps",
  },
  y_offset = 4,
})

local wifi_down = sbar.add("item", "widgets.wifi2", {
  position = "right",
  padding_left = -5,
  icon = {
    padding_right = 0,
    font = { style = settings.font.style_map["Bold"], size = 9.0 },
    string = icons.wifi.download,
  },
  label = {
    font = { family = settings.font.numbers, style = settings.font.style_map["Bold"], size = 9.0 },
    color = colors.grey,
    string = "— Bps",
  },
  y_offset = -4,
})

local wifi = sbar.add("item", "widgets.wifi.padding", {
  position = "right",
  label = { drawing = false },
})

local wifi_bracket = sbar.add("bracket", "widgets.wifi.bracket", {
  wifi.name, wifi_up.name, wifi_down.name
}, {
  background = { color = colors.transparent },
  popup = {
    align = "center",
    height = 32,
    background = {
      color = colors.popup.bg,
      border_color = colors.popup.border,
      border_width = 1,
      corner_radius = 10,
    },
  },
})

local function row(icon_str, label_str)
  return sbar.add("item", {
    position = "popup." .. wifi_bracket.name,
    width = popup_width,
    padding_left = 12,
    padding_right = 12,
    icon = {
      align = "left",
      string = icon_str,
      color = colors.grey,
      width = popup_width * 0.46,
      font = { size = 12.0 },
    },
    label = {
      align = "right",
      string = label_str,
      width = popup_width * 0.54,
      color = colors.white,
      font = { family = settings.font.numbers, size = 12.0 },
    },
  })
end

local ssid_row     = row(icons.wifi.router .. "  Network",  "—")
local ip_row       = row("IP Address",                      "—")
local hostname_row = row("Hostname",                        "—")
local router_row   = row("Router",                          "—")
local mask_row     = row("Subnet Mask",                     "—")

sbar.add("item", { position = "right", width = settings.group_paddings })

-- Cache populated on wifi_change / system_woke so popup opens instantly
local cache = { ssid = "—", ip = "—", hostname = "—", router = "—", mask = "—" }
local popup_open = false

local function refresh_cache(cb)
  sbar.exec("ipconfig getsummary en0 | awk -F ' SSID : ' '/ SSID : / {print $2}'", function(r)
    cache.ssid = (r ~= "") and r:gsub("%s+$", "") or "—"
    if cb then cb() end
  end)
  sbar.exec("ipconfig getifaddr en0", function(r)
    cache.ip = (r ~= "") and r:gsub("%s+$", "") or "—"
  end)
  sbar.exec("networksetup -getcomputername", function(r)
    cache.hostname = (r ~= "") and r:gsub("%s+$", "") or "—"
  end)
  sbar.exec("networksetup -getinfo Wi-Fi | awk -F 'Router: ' '/^Router: / {print $2}'", function(r)
    cache.router = (r ~= "") and r:gsub("%s+$", "") or "—"
  end)
  sbar.exec("networksetup -getinfo Wi-Fi | awk -F 'Subnet mask: ' '/^Subnet mask: / {print $2}'", function(r)
    cache.mask = (r ~= "") and r:gsub("%s+$", "") or "—"
  end)
end

local function apply_cache()
  ssid_row:set({ label = cache.ssid })
  ip_row:set({ label = cache.ip })
  hostname_row:set({ label = cache.hostname })
  router_row:set({ label = cache.router })
  mask_row:set({ label = cache.mask })
end

wifi_up:subscribe("network_update", function(env)
  local up_color   = (env.upload   == "000 Bps") and colors.grey or colors.red
  local down_color = (env.download == "000 Bps") and colors.grey or colors.blue
  wifi_up:set({   icon = { color = up_color },   label = { string = env.upload,   color = up_color } })
  wifi_down:set({ icon = { color = down_color }, label = { string = env.download, color = down_color } })
end)

wifi:subscribe({ "wifi_change", "system_woke" }, function(env)
  sbar.exec("ipconfig getifaddr en0", function(ip)
    local connected = ip ~= ""
    wifi:set({ icon = {
      string = connected and icons.wifi.connected or icons.wifi.disconnected,
      color  = connected and colors.white or colors.red,
    }})
  end)
  refresh_cache()
end)

local function hide_details()
  if popup_open then
    wifi_bracket:set({ popup = { drawing = false } })
    popup_open = false
  end
end

local function toggle_details()
  if not popup_open then
    apply_cache()
    wifi_bracket:set({ popup = { drawing = true } })
    popup_open = true
    refresh_cache(function() apply_cache() end)
  else
    hide_details()
  end
end

wifi_up:subscribe("mouse.clicked", toggle_details)
wifi_down:subscribe("mouse.clicked", toggle_details)
wifi:subscribe("mouse.clicked", toggle_details)
wifi:subscribe("mouse.exited.global", hide_details)

local function copy_label_to_clipboard(env)
  local label = sbar.query(env.NAME).label.value
  sbar.exec("echo \"" .. label .. "\" | pbcopy")
  sbar.set(env.NAME, { label = { string = icons.clipboard, align = "center" } })
  sbar.delay(1, function()
    sbar.set(env.NAME, { label = { string = label, align = "right" } })
  end)
end

ssid_row:subscribe("mouse.clicked", copy_label_to_clipboard)
hostname_row:subscribe("mouse.clicked", copy_label_to_clipboard)
ip_row:subscribe("mouse.clicked", copy_label_to_clipboard)
mask_row:subscribe("mouse.clicked", copy_label_to_clipboard)
router_row:subscribe("mouse.clicked", copy_label_to_clipboard)
