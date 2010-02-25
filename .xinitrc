[[ -x ~/.scripts/set_xressources.sh ]] && ~/.scripts/set_xressources.sh

#chooser="/etc/X11/chooser.sh"
#session=$(XSESSION="${1}" ${chooser})
#exec ${session:-$(${chooser})}

exec $(XSESSION="${2:-${XSESSION}}" /etc/X11/chooser.sh)
