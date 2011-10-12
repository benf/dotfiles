# this is HIGHLY TEMPORARELY - until I set this global
xset r on
xset r rate 250 50

# Xdefault is splitted so load the splitted files at startup
[[ -x ~/.scripts/set_xressources.sh ]] && ~/.scripts/set_xressources.sh

[[ -x ~/.scripts/disable_touchpad.sh ]] && ~/.scripts/disable_touchpad.sh

unset command

# temporarily unset XDG_SESSION_COOKIE so consolekit launches a new session
realxdgcookie="$XDG_SESSION_COOKIE"
XDG_SESSION_COOKIE=
# run all system xinitrc shell scripts which will update $command
if [ -d /etc/X11/xinit/xinitrc.d ]; then
  for i in /etc/X11/xinit/xinitrc.d/* ; do
    if [ -x "$i" ]; then
      . "$i"
    fi
  done
  unset i
fi
# restore XDG_SESSION_COOKIE
XDG_SESSION_COOKIE="$realxdgcookie"
unset realxdgcookie

exec $command $(XSESSION="${2:-${XSESSION}}" /etc/X11/chooser.sh)
