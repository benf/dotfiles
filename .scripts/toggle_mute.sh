dev="alsa_output.pci-0000_00_1b.0.analog-stereo"
tp=ink

if [[ "x$1" = "xinput" ]]; then
	dev="alsa_input.pci-0000_00_1b.0.analog-stereo"
	tp=ource
fi

LC_ALL=C pactl list | \
	sed -n -e:a -eN -e"/^S$tp.*Name: $dev.*Mute: no/q1" -e'/\n$/d' -eba
pactl "set-s$tp-mute" $dev $?
