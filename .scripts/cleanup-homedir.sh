#!/bin/bash

# remove vim swap files
find $HOME -maxdepth 1 -type f -name '.sv*' -exec rm {} \;

pids=$(pgrep startx)
ls -1 $HOME/.serverauth.* | grep -v ${pids/ /\\|} | while read file; do
	rm "${file}"
done

rm $HOME/.xsession-errors*

# xsession manager files (maybe obsolete)
rm $HOME/.xsm*
