#!/bin/sh

unit=$1

which systemctl &> /dev/null || exit 1
systemctl --user &> /dev/null || exit 1

if systemctl --user --quiet is-enabled $unit; then
	systemctl --quiet --user is-active $unit &&
		systemctl --user stop $unit || \
		systemctl --user start $unit
fi
