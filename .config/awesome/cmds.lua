module("eminent")

local upower = "dbus-send --system --print-reply " ..
               "--dest=org.freedesktop.UPower " ..
               "/org/freedesktop/UPower "

local cmds = {
	suspend   = upower .. "org.freedesktop.UPower.Suspend",
	hibernate = upower .. "org.freedesktop.UPower.Hibernate",
}

return cmds
