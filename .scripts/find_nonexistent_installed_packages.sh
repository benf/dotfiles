#!/bin/bash
source /etc/make.conf
installed=$(find "`portageq vdb_path`" -maxdepth 2 -mindepth 2 -printf "%P\n" | xargs qatom | awk '{print $1 "/" $2}')

portdirs="$(portageq portdir) $(portageq portdir_overlay)"

for package in ${installed}
do
	for overlay in ${portdirs}:
	do
		# as soon as we find a package => got to next package in outer loop
		[[ -d "${overlay}/${package}" ]] && continue 2;
	done
	# this is reached ONLY if the package was NOT found in the tree
	echo "${package}"
done
