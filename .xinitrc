#chooser="/etc/X11/chooser.sh"
#session=$(XSESSION="${1}" ${chooser})
#exec ${session:-$(${chooser})}
exec $(XSESSION="${1:-${XSESSION}}" /etc/X11/chooser.sh)
