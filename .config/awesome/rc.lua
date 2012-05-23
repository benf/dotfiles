---- After require("naughty")
---- {{{ Error handling
---- Check if awesome encountered an error during startup and fell back to
---- another config (This code will only ever execute for the fallback config)
--if awesome.startup_errors then
--    naughty.notify({ preset = naughty.config.presets.critical,
--                     title = "Oops, there were errors during startup!",
--                     text = awesome.startup_errors })
--end
--
---- Handle runtime errors after startup
--do
--    local in_error = false
--    awesome.add_signal("debug::error", function (err)
--        -- Make sure we don't go into an endless error loop
--        if in_error then return end
--        in_error = true
--
--        naughty.notify({ preset = naughty.config.presets.critical,
--                         title = "Oops, an error happened!",
--                         text = err })
--        in_error = false
--    end)
--end
---- }}}

local rc, err = loadfile(os.getenv("HOME").."/.config/awesome/awesome.lua");
if rc then
	rc, err = pcall(rc);
	if rc then
		return;
	end
end
 
dofile("/etc/xdg/awesome/rc.lua");
 
for s = 1,screen.count() do
	mypromptbox[s].text = awful.util.escape(err:match("[^\n]*"));
end

naughty.notify{text="Awesome crashed during startup on " ..
		os.date("%d%/%m/%Y %T:\n\n")
		.. err .. "\n", timeout = 0}

local f = io.open(os.getenv("HOME").."/tmp/awesome.error", "w+")
f:write("Awesome crashed during startup on ", os.date("%d%/%m/%Y %T:\n\n"))
f:write(err, "\n");
f:close();
