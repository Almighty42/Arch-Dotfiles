-- If LuaRocks is installed, make sure that packages installed through it are
-- found (e.g. lgi). If LuaRocks is not installed, do nothing.
pcall(require, "luarocks.loader")
warn_about_missing_glyphs = false
-- Standard awesome library
local gears = require("gears")
local awful = require("awful")
require("awful.autofocus")
-- Widget and layout library
local wibox = require("wibox")
-- Theme handling library
local beautiful = require("beautiful")
-- Notification library
local naughty = require("naughty")
local menubar = require("menubar")
local hotkeys_popup = require("awful.hotkeys_popup")
local naughty = require("naughty")
-- Enable hotkeys help widget for VIM and other apps
-- when client with a matching name is opened:
require("awful.hotkeys_popup.keys")

awful.tag.attached_connect_signal(s, "property::selected", function()
	awesome.emit_signal("layout::changed")
end)

beautiful.useless_gap = 10

-- AwesomeWM notifications
local function show_volume_notification()
	awful.spawn.easy_async_with_shell("pamixer --get-volume-human", function(stdout)
		local volume = stdout:gsub("\n", "")
		naughty.notify({
			title = "Volume",
			text = "Current volume: " .. volume,
			timeout = 1,
			urgency = "low",
		})
	end)
end

-- Function to increase volume
local function volume_up()
	awful.spawn("pamixer --increase 5")
	show_volume_notification()
end

-- Function to decrease volume
local function volume_down()
	awful.spawn("pamixer --decrease 5")
	show_volume_notification()
end

-- Function to toggle mute
local function volume_toggle()
	awful.spawn("pamixer --toggle-mute")
	show_volume_notification()
end

-- local fifo = "/tmp/polybar_awesome_layout.fifo"
-- awful.tag.connect_signal("property::layout", function(t)
-- 	local f = io.open(fifo, "w")
-- 	if f then
-- 		f:write("update\n")
-- 		f:close()
-- 	end
-- end)

-- Function to display brightness notification
awful.spawn.with_shell("~/.local/bin/bt-audio-watcher")
local function show_brightness_notification()
	awful.spawn.easy_async_with_shell("brightnessctl get", function(stdout)
		local current = tonumber(stdout)
		awful.spawn.easy_async_with_shell("brightnessctl max", function(max_out)
			local max = tonumber(max_out)
			local percent = math.floor((current / max) * 100)
			naughty.notify({
				title = "Brightness",
				text = "Current brightness: " .. percent .. "%",
				timeout = 1,
				urgency = "low",
			})
		end)
	end)
end

-- Function to increase brightness
local function brightness_up()
	awful.spawn("backlight_control +5")
	show_brightness_notification()
end

-- Function to decrease brightness
local function brightness_down()
	awful.spawn("backlight_control -5")
	show_brightness_notification()
end

-- Replace '1' with your actual microphone source index
local mic_source_index = 51

-- Function to display microphone mute status notification
local function show_mic_notification()
	awful.spawn.easy_async_with_shell("pamixer --source " .. mic_source_index .. " --get-mute", function(stdout)
		local muted = stdout:gsub("\n", "") == "true"
		local status = muted and "Muted" or "Unmuted"
		naughty.notify({
			title = "Microphone",
			text = "Microphone is now: " .. status,
			timeout = 1,
			urgency = "low",
		})
	end)
end

-- Function to toggle microphone mute state
local function mic_toggle()
	awful.spawn("pamixer --source " .. mic_source_index .. " --toggle-mute")
	show_mic_notification()
end

local naughty = require("naughty")

local warned_low = false
local warned_critical = false

local function read_trimmed(path)
	local f = io.open(path)
	if not f then
		return nil
	end
	local content = f:read("*all")
	f:close()
	return content and content:match("^%s*(.-)%s*$")
end

local function check_battery()
	local battery_path = "/sys/class/power_supply/BAT0/"
	local capacity = tonumber(read_trimmed(battery_path .. "capacity"))
	local status = read_trimmed(battery_path .. "status")

	if not capacity or not status then
		return
	end

	-- Reset warnings when charging or when battery recovered enough
	if status == "Charging" then
		warned_low = false
		warned_critical = false
		return
	end

	-- Optional recovery reset:
	-- if it goes back above thresholds, allow future alerts again
	if capacity > 15 then
		warned_low = false
		warned_critical = false
	elseif capacity > 5 then
		warned_critical = false
	end

	-- Check critical first
	if capacity <= 5 and not warned_critical then
		naughty.notify({
			title = "Battery Critical",
			text = "Battery critically low (" .. capacity .. "%). System may suspend soon.",
			urgency = "critical",
			timeout = 10,
		})
		warned_critical = true
		warned_low = true
	elseif capacity <= 15 and not warned_low then
		naughty.notify({
			title = "Battery Warning",
			text = "Battery low (" .. capacity .. "%). Please connect to a power source.",
			urgency = "critical",
			timeout = 10,
		})
		warned_low = true
	end
end

-- Set up a timer to check battery status every 60 seconds
gears.timer({
	timeout = 60,
	autostart = true,
	callback = check_battery,
})

-- Variable to track previous network status
local was_connected = true

-- Function to check network connectivity
-- local function check_network()
-- 	-- Ping a reliable external host
-- 	awful.spawn.easy_async_with_shell("ping -c 1 8.8.8.8", function(stdout, stderr, reason, exit_code)
-- 		local is_connected = (exit_code == 0)
--
-- 		if is_connected and not was_connected then
-- 			naughty.notify({
-- 				title = "Network Status",
-- 				text = "Network connection restored.",
-- 				urgency = "normal",
-- 				timeout = 5,
-- 			})
-- 		elseif not is_connected and was_connected then
-- 			naughty.notify({
-- 				title = "Network Status",
-- 				text = "Network connection lost.",
-- 				urgency = "critical",
-- 				timeout = 5,
-- 			})
-- 		end
--
-- 		was_connected = is_connected
-- 	end)
-- end

-- Set up a timer to check network connectivity every 30 seconds
-- gears.timer({
-- 	timeout = 30,
-- 	autostart = true,
-- 	callback = check_network,
-- })

-- {{{ Error handling
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
	naughty.notify({
		preset = naughty.config.presets.critical,
		title = "Oops, there were errors during startup!",
		text = awesome.startup_errors,
	})
end

-- Handle runtime errors after startup
do
	local in_error = false
	awesome.connect_signal("debug::error", function(err)
		-- Make sure we don't go into an endless error loop
		if in_error then
			return
		end
		in_error = true

		naughty.notify({
			preset = naughty.config.presets.critical,
			title = "Oops, an error happened!",
			text = tostring(err),
		})
		in_error = false
	end)
end
-- }}}

-- {{{ Variable definitions
-- Themes define colours, icons, font and wallpapers.init(gears.filesystem.get_themes_dir() .. "default/theme.lua")
beautiful.init(os.getenv("HOME") .. "/.config/awesome/theme.lua")

beautiful.useless_gap = 6

-- This is used later as the default terminal and editor to run.
terminal = "st"
editor = "nvim"
editor_cmd = terminal .. " -e " .. editor

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
modkey = "Mod4"
altkey = "Mod1"
local work_mode = false
local work_mode_cooldown = false
local work_mode_exit_timer = nil

-- Sync state on startup/restart — prevent restart bypass
if io.open("/tmp/work_mode") then
	work_mode = true
	work_mode_cooldown = false
	-- Immediately start exit timer so restart doesn't skip cooldown
	work_mode_exit_timer = gears.timer({
		timeout = 120,
		autostart = true,
		single_shot = true,
		callback = function()
			work_mode_cooldown = true
			work_mode_exit_timer = nil
			naughty.notify({
				title = "Work mode",
				text = "You may now turn off work mode.",
				timeout = 3,
				urgency = "low",
			})
		end,
	})
	naughty.notify({
		title = "Work mode",
		text = "ON (restored after restart — 2 min cooldown restarted)",
		timeout = 4,
		urgency = "normal",
	})
end

-- Autostart
awful.spawn.with_shell(
	'if (xrdb -query | grep -q "^awesome\\.started:\\s*true$"); then exit; fi;'
		.. 'xrdb -merge <<< "awesome.started:true";'
		.. 'dex --environment Awesome --autostart --search-paths "${XDG_CONFIG_HOME:-$HOME/.config}/autostart:${XDG_CONFIG_DIRS:-/etc/xdg}/autostart";'
)

awful.spawn.with_shell("~/.config/awesome/autorun.sh")

-- Table of layouts to cover with awful.layout.inc, order matters.
awful.layout.layouts = {
	awful.layout.suit.corner.nw,
	awful.layout.suit.corner.ne,
	awful.layout.suit.corner.sw,
	awful.layout.suit.corner.se,
	awful.layout.suit.floating,
	awful.layout.suit.tile,
	awful.layout.suit.tile.left,
	awful.layout.suit.tile.bottom,
	awful.layout.suit.tile.top,
	-- awful.layout.suit.spiral,
	-- awful.layout.suit.spiral.dwindle,
	awful.layout.suit.max,
	awful.layout.suit.max.fullscreen,
	awful.layout.suit.magnifier,
	awful.layout.suit.fair,
	awful.layout.suit.fair.horizontal,
}
-- }}}

-- {{{ Menu
-- Create a launcher widget and a main menu
myawesomemenu = {
	{
		"hotkeys",
		function()
			hotkeys_popup.show_help(nil, awful.screen.focused())
		end,
	},
	{ "manual", terminal .. " -e man awesome" },
	{ "edit config", editor_cmd .. " " .. awesome.conffile },
	{ "restart", awesome.restart },
	{
		"quit",
		function()
			awesome.quit()
		end,
	},
}

mymainmenu = awful.menu({
	items = {
		{ "awesome", myawesomemenu, beautiful.awesome_icon },
		{ "open terminal", terminal },
	},
})

mylauncher = awful.widget.launcher({ image = beautiful.awesome_icon, menu = mymainmenu })

-- Menubar configuration
menubar.utils.terminal = terminal -- Set the terminal for applications that require it
-- }}}

-- Keyboard map indicator and switcher
mykeyboardlayout = awful.widget.keyboardlayout()

-- {{{ Wibar
-- Create a textclock widget
mytextclock = wibox.widget.textclock()

-- Create a wibox for each screen and add it
local taglist_buttons = gears.table.join(
	awful.button({}, 1, function(t)
		t:view_only()
	end),
	awful.button({ modkey }, 1, function(t)
		if client.focus then
			client.focus:move_to_tag(t)
		end
	end),
	awful.button({}, 3, awful.tag.viewtoggle),
	awful.button({ modkey }, 3, function(t)
		if client.focus then
			client.focus:toggle_tag(t)
		end
	end),
	awful.button({}, 4, function(t)
		awful.tag.viewnext(t.screen)
	end),
	awful.button({}, 5, function(t)
		awful.tag.viewprev(t.screen)
	end)
)

local tasklist_buttons = gears.table.join(
	awful.button({}, 1, function(c)
		if c == client.focus then
			c.minimized = true
		else
			c:emit_signal("request::activate", "tasklist", { raise = true })
		end
	end),
	awful.button({}, 3, function()
		awful.menu.client_list({ theme = { width = 250 } })
	end),
	awful.button({}, 4, function()
		awful.client.focus.byidx(1)
	end),
	awful.button({}, 5, function()
		awful.client.focus.byidx(-1)
	end)
)

local function set_wallpaper(s)
	-- Wallpaper
	if beautiful.wallpaper then
		local wallpaper = beautiful.wallpaper
		-- If wallpaper is a function, call it with the screen
		if type(wallpaper) == "function" then
			wallpaper = wallpaper(s)
		end
		gears.wallpaper.maximized(wallpaper, s, true)
	end
end

-- Re-set wallpaper when a screen's geometry changes (e.g. different resolution)
screen.connect_signal("property::geometry", set_wallpaper)

local hidden_tags = {}

awful.screen.connect_for_each_screen(function(s)
	-- Wallpaper
	set_wallpaper(s)

	-- Tags 1–10
	local tags = awful.tag({ "1", "2", "3", "4", "5", "6", "7", "8", "9", "10" }, s, awful.layout.layouts[1])

	-- On screen 1, treat tag 10 as the hidden WhatsApp tag
	if s.index == 1 then
		local wa_tag = tags[10]
		wa_tag.hidden = true -- don’t show in taglist when empty (and with your noempty filter)
		wa_tag.selected = false
		hidden_tags[s] = wa_tag
	end

	s.mypromptbox = awful.widget.prompt()

	-- Create a promptbox for each screen
	s.mypromptbox = awful.widget.prompt()
	-- Create an imagebox widget which will contain an icon indicating which layout we're using.
	-- We need one layoutbox per screen.
	s.mylayoutbox = awful.widget.layoutbox(s)
	s.mylayoutbox:buttons(gears.table.join(
		awful.button({}, 1, function()
			awful.layout.inc(1)
		end),
		awful.button({}, 3, function()
			awful.layout.inc(-1)
		end),
		awful.button({}, 4, function()
			awful.layout.inc(1)
		end),
		awful.button({}, 5, function()
			awful.layout.inc(-1)
		end)
	))
	-- Create a taglist widget
	s.mytaglist = awful.widget.taglist({
		screen = s,
		filter = awful.widget.taglist.filter.noempty, -- hides empty tags
		buttons = taglist_buttons,
	})

	-- Create a tasklist widget
	s.mytasklist = awful.widget.tasklist({
		screen = s,
		filter = awful.widget.tasklist.filter.currenttags,
		buttons = tasklist_buttons,
	})

	--   Create the wibox
	-- s.mywibox = awful.wibar({ position = "top", screen = s })
	--
	-- -- Add widgets to the wibox
	-- s.mywibox:setup({
	-- 	layout = wibox.layout.align.horizontal,
	-- 	{ -- Left widgets
	-- 		layout = wibox.layout.fixed.horizontal,
	-- 		mylauncher,
	-- 		s.mytaglist,
	-- 		s.mypromptbox,
	-- 	},
	-- 	s.mytasklist, -- Middle widget
	-- 	{ -- Right widgets
	-- 		layout = wibox.layout.fixed.horizontal,
	-- 		--mykeyboardlayout,
	-- 		wibox.widget.systray(),
	-- 		mytextclock,
	-- 		s.mylayoutbox,
	-- 	},
	-- })
end)

gears.timer({
	timeout = 1,
	autostart = true,
	single_shot = true,
	callback = function()
		awful.spawn.once("st -c nchat -n nchat -e nchat")
	end,
})

-- {{{ Mouse bindings
root.buttons(gears.table.join(
	awful.button({}, 3, function()
		mymainmenu:toggle()
	end),
	awful.button({}, 4, awful.tag.viewnext),
	awful.button({}, 5, awful.tag.viewprev)
))
-- }}}

-- {{{ Key bindings
globalkeys = gears.table.join(

	-- NOTE:
	-- Old system hotkeys

	--awful.key({ modkey }, "s", hotkeys_popup.show_help, { description = "show help", group = "awesome" }),
	--awful.key({ modkey }, "Left", awful.tag.viewprev, { description = "view previous", group = "tag" }),
	--awful.key({ modkey }, "Right", awful.tag.viewnext, { description = "view next", group = "tag" }),
	--awful.key({ modkey }, "Escape", awful.tag.history.restore, { description = "go back", group = "tag" }),k
	--awful.key({ modkey }, "w", function()
	--	mymainmenu:show()
	--end, { description = "show main menu", group = "awesome" }),

	-- NOTE:
	-- Layout hotkeys

	-- Switch between indexes
	awful.key({ altkey }, "j", function()
		awful.client.focus.byidx(1)
	end, { description = "focus next by index", group = "client" }),

	awful.key({ altkey }, "k", function()
		awful.client.focus.byidx(-1)
	end, { description = "focus previous by index", group = "client" }),

	-- Swap clients
	awful.key({ altkey, "Shift" }, "j", function()
		awful.client.swap.byidx(1)
	end, { description = "swap with next client by index", group = "client" }),

	awful.key({ altkey, "Shift" }, "k", function()
		awful.client.swap.byidx(-1)
	end, { description = "swap with previous client by index", group = "client" }),

	-- Change width of focused client
	awful.key({ altkey }, "l", function()
		awful.tag.incmwfact(0.05)
	end, { description = "increase master width factor", group = "layout" }),

	awful.key({ altkey }, "h", function()
		awful.tag.incmwfact(-0.05)
	end, { description = "decrease master width factor", group = "layout" }),

	-- Jump between 2 clients / old school hotkey
	-- awful.key({ altkey }, "Tab", function()
	-- 	awful.client.focus.history.previous()
	-- 	if client.focus then
	-- 		client.focus:raise()
	-- 	end
	-- end, { description = "go back", group = "client" }),

	-- Change number of master clients
	awful.key({ modkey, "Shift" }, "h", function()
		awful.tag.incnmaster(1, nil, true)
	end, { description = "increase the number of master clients", group = "layout" }),

	awful.key({ modkey, "Shift" }, "l", function()
		awful.tag.incnmaster(-1, nil, true)
	end, { description = "decrease the number of master clients", group = "layout" }),

	-- Change number of columns
	awful.key({ modkey, "Control" }, "h", function()
		awful.tag.incncol(1, nil, true)
	end, { description = "increase the number of columns", group = "layout" }),

	awful.key({ modkey, "Control" }, "l", function()
		awful.tag.incncol(-1, nil, true)
	end, { description = "decrease the number of columns", group = "layout" }),

	-- Change layout
	awful.key({ modkey }, "space", function()
		awful.layout.inc(1)
	end, { description = "select next", group = "layout" }),

	awful.key({ modkey, "Shift" }, "space", function()
		awful.layout.inc(-1)
	end, { description = "select previous", group = "layout" }),

	-- Jump to urgent client
	awful.key({ modkey }, "u", awful.client.urgent.jumpto, { description = "jump to urgent client", group = "client" }),

	-- awful.key({ modkey, "Control" }, "j", function()
	-- 	awful.screen.focus_relative(1)
	-- end, { description = "focus the next screen", group = "screen" }),
	-- awful.key({ modkey, "Control" }, "k", function()
	-- 	awful.screen.focus_relative(-1)
	-- end, { description = "focus the previous screen", group = "screen" }),

	-- awful.key({ modkey, "Control" }, "n", function()
	-- 	local c = awful.client.restore()
	-- 	-- Focus restored client
	-- 	if c then
	-- 		c:emit_signal("request::activate", "key.unminimize", { raise = true })
	-- 	end
	-- end, { description = "restore minimized", group = "client" }),

	-- Prompt
	--awful.key({ modkey }, "r", function()
	--	awful.screen.focused().mypromptbox:run()
	--end, { description = "run prompt", group = "launcher" }),

	-- awful.key({ modkey }, "x", function()
	-- 	awful.prompt.run({
	-- 		prompt = "Run Lua code: ",
	-- 		textbox = awful.screen.focused().mypromptbox.widget,
	-- 		exe_callback = awful.util.eval,
	-- 		history_path = awful.util.get_cache_dir() .. "/history_eval",
	-- 	})
	-- end, { description = "lua execute prompt", group = "awesome" }),
	-- NOTE:
	-- Standard AwesomeWM controls

	-- Reload AwesomeWM
	awful.key({ modkey, "Control" }, "r", awesome.restart, { description = "reload awesome", group = "awesome" }),

	-- Quit AwesomeWM
	awful.key({ modkey, "Shift" }, "q", awesome.quit, { description = "quit awesome", group = "awesome" }),

	-- NOTE:
	-- Rofi hotkeys

	-- Open Rofi Menu
	awful.key({ modkey }, "p", function()
		awful.spawn(os.getenv("HOME") .. "/.config/rofi/scripts/launcher_t1")
	end, { description = "show the menubar", group = "launcher" }),

	-- Open Rofi based Volume Menu / F1
	awful.key({ modkey }, "F1", function()
		awful.spawn.with_shell(os.getenv("HOME") .. "/.config/rofi/applets/bin/volume.sh")
	end, { description = "open volume screen", group = "media" }),

	-- Open Rofi based Volume Menu / F2
	awful.key({ modkey }, "F2", function()
		awful.spawn.with_shell(os.getenv("HOME") .. "/.config/rofi/applets/bin/volume.sh")
	end, { description = "open volume screen", group = "media" }),

	-- Open Rofi based Volume Menu / F3
	awful.key({ modkey }, "F3", function()
		awful.spawn.with_shell(os.getenv("HOME") .. "/.config/rofi/applets/bin/volume.sh")
	end, { description = "open volume screen", group = "media" }),

	-- Open Rofi based Volume Menu / F4
	awful.key({ modkey }, "F4", function()
		awful.spawn.with_shell(os.getenv("HOME") .. "/.config/rofi/applets/bin/volume.sh")
	end, { description = "open volume screen", group = "media" }),

	-- Open Rofi based Brightness Menu / F5
	awful.key({ modkey }, "F5", function()
		awful.spawn.with_shell(os.getenv("HOME") .. "/.config/rofi/applets/bin/brightness.sh")
	end, { description = "open brightness screen", group = "media" }),

	-- Open Rofi based Brightness Menu / F6
	awful.key({ modkey }, "F6", function()
		awful.spawn.with_shell(os.getenv("HOME") .. "/.config/rofi/applets/bin/brightness.sh")
	end, { description = "open brightness screen", group = "media" }),

	-- Open Rofi based Battery Menu / F7
	awful.key({ modkey }, "F7", function()
		awful.spawn.with_shell(os.getenv("HOME") .. "/.config/rofi/applets/bin/battery.sh")
	end, { description = "open battery screen", group = "media" }),

	-- Open Rofi based Music Menu / F8
	awful.key({ modkey }, "F8", function()
		awful.spawn.with_shell(os.getenv("HOME") .. "/.config/rofi/applets/bin/mpd.sh")
	end, { description = "open music screen", group = "media" }),

	-- Open Rofi based Power Menu
	awful.key({ modkey }, "F9", function()
		awful.spawn.with_shell(os.getenv("HOME") .. "/.config/rofi/scripts/powermenu_t2")
	end, { description = "open powermenu screen", group = "launcher" }),

	-- Open Rofi based Screenshot Menu / F10
	awful.key({ modkey }, "F10", function()
		awful.spawn.with_shell(os.getenv("HOME") .. "/.config/rofi/applets/bin/screenshot.sh")
	end, { description = "open screenshot screen", group = "media" }),

	-- Lock screen
	awful.key({ modkey }, "F12", function()
		awful.spawn("betterlockscreen -l")
	end, { description = "lock screen", group = "launcher" }),

	-- NOTE:
	-- Quick launch shortcuts

	-- TERMINAL
	awful.key({ modkey }, "Return", function()
		awful.spawn(terminal)
	end, { description = "open a terminal", group = "launcher" }),

	-- RANGER
	awful.key({ modkey }, "r", function()
		awful.spawn("st -e ranger")
	end, { description = "open ranger file manager", group = "launcher" }),

	-- DUA
	awful.key({ modkey }, "z", function()
		awful.spawn("st -e dua i")
	end, { description = "open dui file system analyzer", group = "launcher" }),

	-- BROWSER
	awful.key({ modkey }, "f", function()
		awful.spawn("qutebrowser")
	end, { description = "open qutebrowser", group = "launcher" }),

	-- MUSIC PLAYER
	awful.key({ modkey }, "m", function()
		awful.spawn("st -e termusic")
	end, { description = "open termusic music player", group = "launcher" }),

	-- DARKTABLE
	awful.key({ modkey }, "d", function()
		awful.spawn("darktable")
	end, { description = "open darktable", group = "launcher" }),

	-- PACSEEK
	awful.key({ modkey }, "o", function()
		awful.spawn("st -e pacseek")
	end, { description = "open pacseek", group = "launcher" }),

	-- NMTUI
	awful.key({ modkey }, "n", function()
		awful.spawn("st -e nmtui")
	end, { description = "open nmtui", group = "launcher" }),

	-- OPENOCD-SVD
	awful.key({ modkey }, "9", function()
		awful.spawn("/home/Almighty42/.local/bin/openocd-svd")
	end, { description = "open openocd-svd menu", group = "launcher" }),

	-- BTOP
	awful.key({ modkey }, "s", function()
		awful.spawn("st -e btop")
	end, { description = "open btop status menu", group = "launcher" }),

	-- NOTE:
	-- Other hotkeys

	-- NOTE:
	-- Hidden whatsapp tag toggle

	awful.key({ modkey }, "w", function()
		if work_mode then
			-- In work mode, ignore the toggle
			return
		end

		local s = awful.screen.focused()
		local wa = hidden_tags[screen[1]] or hidden_tags[s]
		if not wa then
			return
		end

		if wa.selected then
			awful.tag.history.restore(s)
		else
			wa:view_only()
		end
	end, { description = "toggle hidden WhatsApp tag", group = "launcher" }),

	-- NOTE:
	-- Toggle WORK mode on/off
	awful.key({ modkey, "Shift" }, "w", function()
		if work_mode then
			-- User wants to EXIT work mode
			if work_mode_cooldown then
				-- Cooldown elapsed, actually turn off
				work_mode = false
				work_mode_cooldown = false
				work_mode_exit_timer = nil
				awful.spawn.with_shell("dunstctl set-paused false")
				awful.spawn.with_shell("rm -f /tmp/work_mode")
				awful.spawn.with_shell("sudo chattr -i /home/Almighty42/.config/qutebrowser/blocked-hosts")
				awful.spawn.with_shell("chmod 644 /home/Almighty42/.config/qutebrowser/blocked-hosts")
				naughty.notify({
					title = "Work mode",
					text = "OFF",
					timeout = 2,
					urgency = "normal",
				})
			elseif not work_mode_exit_timer then
				-- First attempt to exit — start the 60s countdown
				naughty.notify({
					title = "Work mode",
					text = "Exit requested. You can turn off in 2 minutes.",
					timeout = 4,
					urgency = "normal",
				})
				work_mode_exit_timer = gears.timer({
					timeout = 120,
					autostart = true,
					single_shot = true,
					callback = function()
						work_mode_cooldown = true
						work_mode_exit_timer = nil
						naughty.notify({
							title = "Work mode",
							text = "You may now turn off work mode.",
							timeout = 3,
							urgency = "low",
						})
					end,
				})
			else
				-- Timer already running
				naughty.notify({
					title = "Work mode",
					text = "Please wait, cooldown in progress...",
					timeout = 2,
					urgency = "normal",
				})
			end
		else
			-- Turning ON: immediate
			work_mode = true
			work_mode_cooldown = false
			work_mode_exit_timer = nil
			awful.spawn.with_shell("dunstctl set-paused true")
			awful.spawn.with_shell("touch /tmp/work_mode")
			awful.spawn.with_shell("chmod 444 /home/Almighty42/.config/qutebrowser/blocked-hosts")
			awful.spawn.with_shell("sudo chattr +i /home/Almighty42/.config/qutebrowser/blocked-hosts")
			naughty.notify({
				title = "Work mode",
				text = "ON",
				timeout = 2,
				urgency = "normal",
			})
		end
	end, { description = "toggle work mode", group = "launcher" }),

	-- Brightness Down
	awful.key({}, "XF86MonBrightnessDown", brightness_down, { description = "lower brightness", group = "media" }),

	-- Brightness Up
	awful.key({}, "XF86MonBrightnessUp", brightness_up, { description = "increase brightness", group = "media" }),

	-- Volume Up
	awful.key({}, "XF86AudioRaiseVolume", volume_up, { description = "increase volume", group = "media" }),

	-- Volume Down
	awful.key({}, "XF86AudioLowerVolume", volume_down, { description = "decrease volume", group = "media" }),

	-- Mute Toggle
	awful.key({}, "XF86AudioMute", volume_toggle, { description = "toggle mute", group = "media" }),

	-- Mic Mute Toggle
	awful.key({}, "XF86AudioMicMute", mic_toggle, { description = "toggle mic mute", group = "media" }),

	-- Show / hide polybar
	awful.key({ modkey }, "b", function()
		awful.spawn("st -e polybar-msg cmd toggle")
	end, { description = "toggle polybar", group = "bar" })
)

clientkeys = gears.table.join(

	-- Close window
	awful.key({ modkey }, "q", function(c)
		c:kill()
	end, { description = "close window", group = "client" }),

	awful.key({ modkey }, "f", function(c)
		c.fullscreen = not c.fullscreen
		c:raise()
	end, { description = "toggle fullscreen", group = "client" }),
	awful.key({ modkey, "Shift" }, "c", function(c)
		c:kill()
	end, { description = "close", group = "client" }),
	awful.key(
		{ modkey, "Control" },
		"space",
		awful.client.floating.toggle,
		{ description = "toggle floating", group = "client" }
	),
	awful.key({ modkey, "Control" }, "Return", function(c)
		c:swap(awful.client.getmaster())
	end, { description = "move to master", group = "client" }),
	awful.key({ modkey }, "o", function(c)
		c:move_to_screen()
	end, { description = "move to screen", group = "client" }),
	awful.key({ modkey }, "t", function(c)
		c.ontop = not c.ontop
	end, { description = "toggle keep on top", group = "client" }),
	awful.key({ modkey }, "n", function(c)
		-- The client currently has the input focus, so it cannot be
		-- minimized, since minimized clients can't have the focus.
		c.minimized = true
	end, { description = "minimize", group = "client" }),
	-- awful.key({ altkey }, "e", function(c)
	-- 	c.maximized = not c.maximized
	-- 	c:raise()
	-- end, { description = "(un)maximize", group = "client" }),
	awful.key({ modkey, "Control" }, "m", function(c)
		c.maximized_vertical = not c.maximized_vertical
		c:raise()
	end, { description = "(un)maximize vertically", group = "client" }),
	awful.key({ modkey, "Shift" }, "m", function(c)
		c.maximized_horizontal = not c.maximized_horizontal
		c:raise()
	end, { description = "(un)maximize horizontally", group = "client" })
)

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it work on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 9 do
	globalkeys = gears.table.join(
		globalkeys,
		-- View tag only.
		awful.key({ altkey }, "#" .. i + 9, function()
			local screen = awful.screen.focused()
			local tag = screen.tags[i]
			if tag then
				tag:view_only()
			end
		end, { description = "view tag #" .. i, group = "tag" }),
		-- Toggle tag display.
		awful.key({ modkey, "Control" }, "#" .. i + 9, function()
			local screen = awful.screen.focused()
			local tag = screen.tags[i]
			if tag then
				awful.tag.viewtoggle(tag)
			end
		end, { description = "toggle tag #" .. i, group = "tag" }),
		-- Move client to tag.
		awful.key({ altkey, "Shift" }, "#" .. i + 9, function()
			if client.focus then
				local tag = client.focus.screen.tags[i]
				if tag then
					client.focus:move_to_tag(tag)
				end
			end
		end, { description = "move focused client to tag #" .. i, group = "tag" }),
		-- Toggle tag on focused client.
		awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9, function()
			if client.focus then
				local tag = client.focus.screen.tags[i]
				if tag then
					client.focus:toggle_tag(tag)
				end
			end
		end, { description = "toggle focused client on tag #" .. i, group = "tag" })
	)
end

clientbuttons = gears.table.join(
	awful.button({}, 1, function(c)
		c:emit_signal("request::activate", "mouse_click", { raise = true })
	end),
	awful.button({ modkey }, 1, function(c)
		c:emit_signal("request::activate", "mouse_click", { raise = true })
		awful.mouse.client.move(c)
	end),
	awful.button({ modkey }, 3, function(c)
		c:emit_signal("request::activate", "mouse_click", { raise = true })
		awful.mouse.client.resize(c)
	end)
)

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
-- Rules to apply to new clients (through the "manage" signal).
awful.rules.rules = {
	-- All clients will match this rule.
	{
		rule = {},
		except_any = { class = { "Polybar" } },
		properties = {
			border_width = beautiful.border_width,
			border_color = beautiful.border_normal,
			focus = awful.client.focus.filter,
			raise = true,
			keys = clientkeys,
			buttons = clientbuttons,
			screen = awful.screen.preferred,
			placement = awful.placement.no_overlap + awful.placement.no_offscreen,
		},
	},

	-- Floating clients.
	{
		rule_any = {
			instance = {
				"DTA", -- Firefox addon DownThemAll.
				"copyq", -- Includes session name in class.
				"pinentry",
			},
			class = {
				"Arandr",
				"Blueman-manager",
				"Gpick",
				"Kruler",
				"MessageWin",
				"Sxiv",
				"Tor Browser",
				"Wpa_gui",
				"veromix",
				"xtightvncviewer",
			},

			-- Note that the name property shown in xprop might be set slightly after creation of the client
			-- and the name shown there might not match defined rules here.
			name = {
				"Event Tester", -- xev.
			},
			role = {
				"AlarmWindow", -- Thunderbird's calendar.
				"ConfigManager", -- Thunderbird's about:config.
				"pop-up", -- e.g. Google Chrome's (detached) Developer Tools.
			},
		},
		properties = { floating = true },
	},

	{
		rule = { class = "qutebrowser" }, -- Use the class name from xprop!
		properties = {
			maximized = true,
			honors_workarea = false,
		},
	},

	{
		rule = { instance = "nchat" },
		properties = { screen = 1, tag = "10" }, -- replace "2" with whichever tag you use as "work"
	},

	-- Add titlebars to normal clients and dialogs
	{ rule_any = { type = { "normal", "dialog" } }, properties = { titlebars_enabled = false } },

	-- Set Firefox to always map on the tag named "2" on screen 1.
	-- { rule = { class = "Firefox" },
	--   properties = { screen = 1, tag = "2" } },
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function(c)
	-- Set the windows at the slave,
	-- i.e. put it at the end of others instead of setting it master.
	-- if not awesome.startup then awful.client.setslave(c) end

	if awesome.startup and not c.size_hints.user_position and not c.size_hints.program_position then
		-- Prevent clients from being unreachable after screen count changes.
		awful.placement.no_offscreen(c)
	end

	-- Move WhatsApp qutebrowser window to hidden tag 10
	if c.class == "qutebrowser" then
		gears.timer.delayed_call(function()
			local s = screen[1] or awful.screen.focused()
			local wa = hidden_tags[s]
			if wa and c.valid then
				local name = (c.name or ""):lower()
				if name:match("whatsapp") then
					c:move_to_tag(wa)
				end
			end
		end)
	end
end)

-- Add a titlebar if titlebars_enabled is set to true in the rules.
client.connect_signal("request::titlebars", function(c)
	-- buttons for the titlebar
	local buttons = gears.table.join(
		awful.button({}, 1, function()
			c:emit_signal("request::activate", "titlebar", { raise = true })
			awful.mouse.client.move(c)
		end),
		awful.button({}, 3, function()
			c:emit_signal("request::activate", "titlebar", { raise = true })
			awful.mouse.client.resize(c)
		end)
	)

	awful.titlebar(c):setup({
		{ -- Left
			awful.titlebar.widget.iconwidget(c),
			buttons = buttons,
			layout = wibox.layout.fixed.horizontal,
		},
		{ -- Middle
			{ -- Title
				align = "center",
				widget = awful.titlebar.widget.titlewidget(c),
			},
			buttons = buttons,
			layout = wibox.layout.flex.horizontal,
		},
		{ -- Right
			awful.titlebar.widget.floatingbutton(c),
			awful.titlebar.widget.maximizedbutton(c),
			awful.titlebar.widget.stickybutton(c),
			awful.titlebar.widget.ontopbutton(c),
			awful.titlebar.widget.closebutton(c),
			layout = wibox.layout.fixed.horizontal(),
		},
		layout = wibox.layout.align.horizontal,
	})
end)

-- Enable sloppy focus, so that focus follows mouse.
client.connect_signal("mouse::enter", function(c)
	c:emit_signal("request::activate", "mouse_enter", { raise = false })
end)

awful.spawn("picom")
awful.spawn.with_shell("$HOME/.config/polybar/launch.sh --forest")

client.connect_signal("focus", function(c)
	c.border_color = beautiful.border_focus
end)
client.connect_signal("unfocus", function(c)
	c.border_color = beautiful.border_normal
end)
-- }}}
