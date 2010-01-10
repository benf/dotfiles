#!/bin/bash

source "/etc/make.conf"
installed=$(find /var/db/pkg -maxdepth 2 -mindepth 2 -printf "%P\n" | xargs qatom | awk '{print $1 "/" $2}')

for package in ${installed}
do
	for overlay in "/usr/portage/" ${PORTDIR_OVERLAY}
	do
		# as soon as we find a package => got to next package in outer loop
		[[ -d "${overlay}/${package}" ]] && continue 2;
	done
	# this is reached ONLY if the package was NOT found
	echo "${package}"
done
