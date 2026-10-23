-- Port of home/.skhdrc. Right Alt became SUPER, which is free on Linux.
local mainMod = "SUPER"
local terminal = "ghostty"

hl.monitor({ output = "", mode = "preferred", position = "auto", scale = "auto" })

hl.config({
	dwindle = {
		preserve_split = true,
	},
	input = {
		kb_layout = "us",
		touchpad = {
			natural_scroll = true,
		},
	},
})

-- Three-finger swipe between workspaces, like macOS Spaces
hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })

hl.on("hyprland.start", function()
	hl.exec_cmd("waybar")
end)

-- SWAP WINDOWS
hl.bind(mainMod .. " + A", hl.dsp.window.swap({ direction = "left" }))
hl.bind(mainMod .. " + D", hl.dsp.window.swap({ direction = "right" }))
hl.bind(mainMod .. " + W", hl.dsp.window.swap({ direction = "up" }))
hl.bind(mainMod .. " + S", hl.dsp.window.swap({ direction = "down" }))

-- RESIZE WINDOWS
hl.bind(mainMod .. " + SHIFT + A", hl.dsp.window.resize({ x = -50, y = 0, relative = true }))
hl.bind(mainMod .. " + SHIFT + D", hl.dsp.window.resize({ x = 50, y = 0, relative = true }))
hl.bind(mainMod .. " + SHIFT + W", hl.dsp.window.resize({ x = 0, y = -50, relative = true }))
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.window.resize({ x = 0, y = 50, relative = true }))

-- LAYOUT CONTROL
hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen({ mode = "maximized" }))
hl.bind(mainMod .. " + T", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + Q", hl.dsp.window.close())
hl.bind(mainMod .. " + C", hl.dsp.window.center())
hl.bind(mainMod .. " + R", hl.dsp.layout("rotatesplit"))
hl.bind(mainMod .. " + X", hl.dsp.layout("togglesplit"))
hl.bind(mainMod .. " + M", hl.dsp.layout("swapsplit"))

-- WORKSPACES. Moving a window follows it, and empty workspaces disappear on their own.
for i = 1, 8 do
	hl.bind(mainMod .. " + " .. i, hl.dsp.focus({ workspace = i }))
	hl.bind(mainMod .. " + SHIFT + " .. i, hl.dsp.window.move({ workspace = i }))
end
hl.bind(mainMod .. " + SHIFT + P", hl.dsp.window.move({ workspace = "r-1" }))
hl.bind(mainMod .. " + SHIFT + N", hl.dsp.window.move({ workspace = "r+1" }))

-- Workspaces on the focused monitor. Plain CTRL + arrows is word-jump in text on Linux.
hl.bind(mainMod .. " + CTRL + left", hl.dsp.focus({ workspace = "m-1" }))
hl.bind(mainMod .. " + CTRL + right", hl.dsp.focus({ workspace = "m+1" }))

-- OPEN APPS
hl.bind(mainMod .. " + Return", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + SHIFT + Return", hl.dsp.exec_cmd(terminal .. " -e zsh -ic n"))
hl.bind(mainMod .. " + V", hl.dsp.exec_cmd("code -n"))
hl.bind(mainMod .. " + B", hl.dsp.exec_cmd("thunar"))
hl.bind(mainMod .. " + space", hl.dsp.exec_cmd("fuzzel"))
hl.bind(mainMod .. " + SHIFT + E", hl.dsp.exit())

-- Alt tabbing
hl.bind(mainMod .. " + TAB", hl.dsp.window.cycle_next())
hl.bind(mainMod .. " + SHIFT + TAB", hl.dsp.window.cycle_next({ next = false }))

-- Laptop volume and brightness keys
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"), { locked = true, repeating = true })
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), { locked = true })
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl set 5%+"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl set 5%-"), { locked = true, repeating = true })
