# This shell script is run before Openbox launches.
# Environment variables set here are passed to the Openbox session.

# D-bus
if which dbus-launch >/dev/null && [ -z "$DBUS_SESSION_BUS_ADDRESS" ]; then
       eval `dbus-launch --sh-syntax --exit-with-session`
fi

#xrandr --output VGA-0 --mode 1280x1024 --rate 60
# start compositing - shadows and fading
#xcompmgr -cCfF -t-5 -l-5 -r4.2 -o0.55 -D6 & >> /dev/null 2>&1

# set background
#eval $(cat ~/.fehbg) &
nitrogen --restore &

#Force OpenOffice.org to use GTK theme
export OOO_FORCE_DESKTOP=gnome

~/bin/swIcon.py &

#volwheel &
#trayer --widthtype request --height 24 --align right --margin 0 --padding 0 \
#  --transparent true --alpha 256 --tint 0xffffff --SetDockType true &
stalonetray &
~/voltray.py &
#volwheel &

# Run XDG autostart things.  By default don't run anything desktop-specific
# See xdg-autostart --help more info
DESKTOP_ENV=""
if which /usr/lib64/openbox/xdg-autostart >/dev/null; then
  /usr/lib64/openbox/xdg-autostart $DESKTOP_ENV &
fi

# start tray
#trayer --widthtype request --height 22 \
#  --align right --margin 0 --padding 3 \
#  --transparent true --alpha 128 --tint 0x050505 &
# start panel
tint2 &
urxvtd -q -o -f
synergys
