dofile("/etc/xdg/luakit/globals.lua")

globals.homepage = "http://www.google.de/ig"
globals.scroll_step = 30

domain_props = {
	["mail.google.com"] = {
		user_stylesheet_uri = "file://" ..luakit.data_dir .. "/styles/gmail.css"
	},
	["neu.baptisten-buetzow.de"] = {
		user_stylesheet_uri = "file://" ..luakit.data_dir .. "/styles/symphony-fix.css"
	},
}
