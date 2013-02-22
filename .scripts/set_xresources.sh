#!/bin/sh

#find ~/.config/ \
#	-mindepth 2 -maxdepth 2 \
#	-type f -iname "*.xdefaults" \
#	-exec xrdb -merge {} \;

# It is faster to concat first and execute xrdb only once.
find ~/.config/ \
	-mindepth 2 -maxdepth 2 \
	-type f -iname "*.xdefaults" \
	-exec cat {} + | xrdb -merge
