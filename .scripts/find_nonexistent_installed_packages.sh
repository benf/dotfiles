#!/bin/bash

source "/etc/make.conf"
installed=$(find /var/db/pkg -maxdepth 2 -mindepth 2 -printf "%P\n" | xargs qatom | awk '{print $1 "/" $2}')

for package in ${installed}
do
	found=0
	for overlay in "/usr/portage/" ${PORTDIR_OVERLAY}
	do
		[[ -d "${overlay}/${package}" ]] && found=1
	done
	[[ "${found}" -eq 0 ]] && echo "${package}"
done
