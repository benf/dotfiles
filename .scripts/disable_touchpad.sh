#!/bin/bash

# Only disbale Touchpad if there is a TrackPoint
xinput list | grep TrackPoint &> /dev/null || exit

device_id=$(xinput list | sed -n "s/^.*Synaptics.*id=\([^\t]*\).*$/\\1/p")
[[ -z "$device_id" ]] && exit 1

enabled=$(xinput list-props $device_id | sed -n "s/^.*Device Enabled.*\t\(.*\)$/\\1/p")
property=$(xinput list-props $device_id | sed -n "s/^.*Device Enabled (\([^)]*\)).*$/\\1/p")

[[ $enabled -eq 1 ]] && xinput set-prop $device_id $property 0
