#!/bin/bash

device_id=$(xinput list | sed -n "s/^.*Synaptics.*id=\([^\t]*\).*$/\\1/p")

enabled=$(xinput list-props $device_id | sed -n "s/^.*Device Enabled.*\t\(.*\)$/\\1/p")
property=$(xinput list-props $device_id | sed -n "s/^.*Device Enabled (\([^)]*\)).*$/\\1/p")


xinput set-prop $device_id $property $((1-enabled))
