local os = os

module("eminent")

local cmds = {
	urxvtd    = "urxvtd -q -o -f",
	swIcon    = os.getenv("HOME") .. "/.local/bin/swIcon.py",
	tggle_tpd = os.getenv("HOME") .. "/.scripts/toggle_touchpad.sh"
}

return cmds
