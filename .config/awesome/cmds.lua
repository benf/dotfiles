local os = os

module("eminent")

local upower = "dbus-send --system --print-reply " ..
               "--dest=org.freedesktop.UPower " ..
               "/org/freedesktop/UPower "

local cmds = {
	suspend   = upower .. "org.freedesktop.UPower.Suspend",
	hibernate = upower .. "org.freedesktop.UPower.Hibernate",
	urxvtd    = "urxvtd -q -o -f",
	swIcon    = os.getenv("HOME") .. "/.local/bin/swIcon.py",
	tggle_tpd = os.getenv("HOME") .. "/.scripts/toggle_touchpad.sh"
}

return cmds
