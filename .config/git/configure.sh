#!/bin/bash

do_echo() {
	echo $@
	eval $@
}

do_echo git config --global branch.master.remote origin
do_echo git config --global branch.master.merge refs/heads/master

do_echo git config --global user.name ben
do_echo git config --global user.email benjaminfranzke@googlemail.com
