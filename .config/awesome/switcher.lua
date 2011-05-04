----------------------------------------------------------------
-- ALt-Tab-style switcher.
----------------------------------------------------------------
-- Benjamin Franzke <benjaminfranzke@googlemail.com
-- Licensed under the GPL-3
----------------------------------------------------------------
-- To use this module add:
--   require("switcher")
-- to the top of your rc.lua. 
--
-- And add the following to your global keybindings:
--   awful.key({ modkey, }, "Tab", function()
--     switcher.start( 1, "Super_L", "Tab", "ISO_Left_Tab")
--   end),
--
--   awful.key({ modkey, }, "ISO_Left_Tab", function()
--     switcher.start(-1, "Super_L", "Tab", "ISO_Left_Tab")
--   end),
--
----------------------------------------------------------------

-- Grab environment
local ipairs = ipairs
local pairs = pairs
local awful = require("awful")
local naughty = require("naughty")
local table = table
local capi = {
	tag = tag,
	mouse = mouse,
	client = client,
	screen = screen,
	wibox = wibox,
	timer = timer,
	keygrabber = keygrabber,
}

-- Switcher: Alt-Tab-like switching
module("switcher")

local state = {
	switcher_idx = 0,
	key_mod = "Super_L",
	key_next = "Tab",
	key_prev = "ISO_Left_Tab",
}

local function switcher_next(rel)

	local cla = awful.client.focus.history.get(capi.mouse.screen, state.switcher_idx)
	local cli = awful.client.focus.history.get(capi.mouse.screen, state.switcher_idx + rel)

	awful.client.unmark(cla)

	state.switcher_idx = state.switcher_idx + rel

	if not cli then
		if rel > 0 then
			state.switcher_idx = rel
		elseif rel < 0 then
			local i = 0
			local c = awful.client.focus.history.get(capi.mouse.screen, 0)
			while c do
				i = i + 1
				c = awful.client.focus.history.get(capi.mouse.screen, i)
			end
			state.switcher_idx = i - rel
		end

		cli = awful.client.focus.history.get(capi.mouse.screen, switcher_idx)
	end

	cli:raise()

	awful.client.mark(cli)
end

local function switcher_end()
	local c = awful.client.focus.history.get(capi.mouse.screen, state.switcher_idx)
	state.switcher_idx = 0
	c:raise()
	awful.client.unmark(c)
	capi.client.focus = c
end

function switch(modifiers, key, event)
	if event == "press" and key == state.key_next then
		switcher_next(1)
	elseif event == "press" and key == state.key_prev then
		switcher_next(-1)
	end

	if event == "release" and key == state.key_mod then
		switcher_end()
		capi.keygrabber.stop()
		return false
	end

	return true
end

function start(rel, key_mod, key_next, key_prev)
	state.switcher_idx = 0
	state.key_mod = key_mod
	state.key_next = key_next
	state.key_prev = key_prev

	switcher_next(rel)
	capi.keygrabber.run(switch)
end

