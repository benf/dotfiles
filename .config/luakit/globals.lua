dofile("/etc/xdg/luakit/globals.lua")

globals.homepage = "http://google.de/"
globals.scroll_step = 30

domain_props = {
	["mail.google.com"] = {
		user_stylesheet_uri = "file://" ..luakit.data_dir .. "/styles/gmail.css"
	},
}
