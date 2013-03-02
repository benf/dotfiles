#!/bin/sh

sed -n "s/^ *# revdep-rebuild --library '\([^']*\)'.*$/\1/p" /var/log/portage/elog/*.log  | \
	sort | uniq  | \
	while read lib
	do
		cmd="test -e '${lib}' && revdep-rebuild -i --library '${lib}' && rm '${lib}'"
		echo $cmd
		eval $cmd
	done
