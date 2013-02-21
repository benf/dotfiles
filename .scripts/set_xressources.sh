#!/bin/sh

find ~/.config/ \
	-mindepth 2 -maxdepth 2 \
	-type f -iname "*.xdefaults" \
	-exec xrdb -merge {} \;
