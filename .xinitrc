#!/bin/sh

# Pass -ardelay 250 -arinterval 20 to X server instead.
#xset r on
#xset r rate 250 50

# Xdefault is splitted so load the splitted files at startup
[[ -x ~/.scripts/set_xresources.sh ]] && ~/.scripts/set_xresources.sh

[[ -x ~/.scripts/toggle_touchpad.sh ]] && ~/.scripts/toggle_touchpad.sh

unset command

#if [ -S $XDG_RUNTIME_DIR/dbus/user_bus_socket ]
#then
#	export DBUS_SESSION_BUS_ADDRESS=unix:path=$XDG_RUNTIME_DIR/dbus/user_bus_socket
##	command="systemd-run --user --scope --unit windowmanager -- "
#else
	# temporarily unset XDG_SESSION_COOKIE so consolekit launches a new session
	realxdgcookie="$XDG_SESSION_COOKIE"
	XDG_SESSION_COOKIE=
	# run all system xinitrc shell scripts which will update $command
	if [ -d /etc/X11/xinit/xinitrc.d ]; then
	  for i in /etc/X11/xinit/xinitrc.d/* ; do
	    [[ -x "$i" ]] && . "$i"
	  done
	fi
	# restore XDG_SESSION_COOKIE
	XDG_SESSION_COOKIE="$realxdgcookie"
	unset realxdgcookie
#fi

exec $command $(XSESSION="${2:-${XSESSION}}" /etc/X11/chooser.sh)
