#!/usr/bin/env python
# -*- coding: utf-8 -*-

# Copyright © 2010 Benjamin Franzke

# config
apps = (
	{ "wm_class": "URxvt",  "icon": "terminal" },
	{ "wm_class": "XTerm",  "icon": "terminal" },
	{ "wm_class": "xmoto",  "icon": "xmoto" },
	{ "wm_class": "Mumble", "icon": "/home/ben/tmp/mumble/mumble-1.2.2/icons/mumble.ico" }
)

from Xlib import X, display, Xatom, error
from PIL import Image
import os

path = ""
def find_gtk_icon(icon):
	icondir = "/usr/share/icons/Tango/48x48/"
	for root, dirs, files in os.walk(icondir):
		if icon+".png" in files:
			global path
			path = root
			return True
	return False

def change_icon(window, icon):
	if os.access(icon, os.F_OK|os.R_OK):
		im = Image.open(icon)
	elif find_gtk_icon(icon):
		im = Image.open(path + "/" + icon + ".png")
	elif os.access("/usr/share/pixmaps/" + icon + ".xpm", os.F_OK|os.R_OK):
		im = Image.open("/usr/share/pixmaps/" + icon + ".xpm")
	elif os.access("/usr/share/pixmaps/" + icon + ".png", os.F_OK|os.R_OK):
		im = Image.open("/usr/share/pixmaps/" + icon + ".png")
	else:
		return False
	data_rgba = im.convert('RGBA').getdata()
	
	data = []
	data.extend(im.size)
	for rgba in data_rgba:
		# ewmh wants argb, so lets convert
		data.append((rgba[3] << 24) + (rgba[0] << 16) + (rgba[1] << 8) + rgba[2])

	window.change_property(disp.intern_atom("_NET_WM_ICON"), Xatom.CARDINAL, 32, data)

def match(window,app):
	try:
		#print window.get_wm_name(), window.get_wm_class()
		ret = False
		if "wm_name" in app:
			if window.get_wm_name() != app["wm_name"]:
				return ret
			else:
				ret = True
				
		wm_class = window.get_wm_class()
		if wm_class != None and "wm_class" in app:
			if wm_class[1] != app["wm_class"]:
				return False
			else:
				return True
		return ret
	except error.BadWindow, e:
		#print "error: BadWindow"
		return False

def handler(event):
	global apps
	if event.type == X.CreateNotify:
		for app in apps:
			if match(event.window, app):
				change_icon(event.window, app["icon"])
				break;

if __name__ == "__main__":
	disp = display.Display()
	screen = disp.screen()
	root = screen.root
	root.change_attributes(event_mask=X.SubstructureNotifyMask)

	while 1:
		ev = disp.next_event()
		handler(ev)

