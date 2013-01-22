dofile("/etc/xdg/luakit/binds.lua")

local key = lousy.bind.key

add_binds("normal", {
    key({}, "J", "Go to previous tab.",
            function (w) w:prev_tab() end),
    key({}, "K", "Go to next tab.",
            function (w) w:next_tab() end),
})
