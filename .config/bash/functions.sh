max() { [[ $# -eq  2 ]] && ( [[ $1 -ge $2 ]] && echo $1 || echo $2 ) }

# param: width = $1, height = $2
resize() {
	printf "\e[8;%d;%dt" $2 $1
}

#s() {
#	local name=${HOSTNAME}.${1}
#	if [ $1 ]; then
#		if [ -e /var/run/screen/S-$(whoami)/[0-9]*.${name} ]; then
#			echo foo
#			#      screen -x -r -S ${name}
#		else
#			screen -S ${name}
#		fi
#	else
#		screen -ls
#	fi
#}

resize_to_min() {
	#  eval $(resize -s $(max $LINES $2) $(max $COLUMNS $1))
	printf "\e[8;%d;%dt" $(max $LINES $2) $(max $COLUMNS $1)
}

nh() {
	nohup "$@" &> /dev/null &
}
gvim() {
	/usr/bin/gvim $([[ $# > 0 ]] && echo --remote-tab-silent $@)
}

print_prompt_nl_if_needed() {
	local pos
	local char
	local ok=0
	local save=$(stty -g)

	stty -echo -icanon
	echo -en '\e[6n' 1>&2
	#response format: \e[n;mR (m is needed)
	while true 
	do
		#char=$(dd bs=1 count=1 2>/dev/null)
		char=$(head -c1)
		[[ $char == 'R' ]] && break
		[[ $ok -eq 1 ]]    && pos="${pos}${char}"
		[[ $char == ';' ]] && ok=1
	done

	stty $save
	[[ $pos -gt 1 ]] && echo 1>&2
}

qjoypad() {
	$(which qjoypad) --device /dev/input $@
}

jdownloader() {
	$(java-config --java) -jar ~/Desktop/jdownloader/JDownloader.jar
}

start() {
	#local dir=/home/ben/coding/cpp/starter/
	#"${dir}"start "${dir}"command.sh $@ >> /dev/null 2>&1
	#  nohup "$@" &>/dev/null &
	/home/ben/coding/cpp/starter/start \
	bash -c "source ~/.bashrc.functions; ${@} >> /dev/null 2>&1"
}

ts() {
	start /opt/bin/TeamSpeak $@
}

eworld() {
	local packages=$(/usr/bin/eix -u --only-names)
	[[ -n $packages ]] && /usr/bin/sudo /usr/bin/emerge --verbose --ask --update --oneshot $packages
}



uflag() {
	local use=`echo ${1} | sed -n "s/[^a-Z0-9\-]//g; p"`
	#  [[ -n $use ]] && sed -n "/\(^\|:\)$use -/p" /usr/portage/profiles/use* | grep --color $use
	files="/usr/portage/profiles/use.desc /usr/portage/profiles/desc/*"
	echo "global use flags (searching: ${use})"
	[[ -n $use ]] && sed -n "s~^\(\(.*/.*\):\)\?\(${use} \)\(.*\)$~&~p" $files

	echo -e "\nlocal useflags (searching: ${use})"
	[[ -n $use ]] && sed -n "s~^\(\(.*/.*\):\)\?\(${use}\)[[:space:]]*-[[:space:]]*\(.*\)$~\3 (\2):\n\4~p" /usr/portage/profiles/use.local.desc
}

tstart() {
	[[ -n `ps -C $1 | sed -n 's/^.\([0-9][0-9]*\).*$/\1/p'` ]] && killall $1 || $1
}

up() {
	local server=netdirekt

	if [[ -f $1 ]]; then 
		local rand=`date +%s | md5sum | sed -n 's/^\(...\).*$/\1/p'`
		local r="${rand}"
		local s=`basename $1`

		local name="$r-$s"
		# local name="${rand}-`basename $1`"
		scp -q $1 $server:"/home/benjamin/uploads/${name}" || exit

		local cmd="sudo chown lighttpd:lighttpd /home/benjamin/uploads/${name}"
		ssh -q $server $cmd || exit

		local ext=$(echo $1 | sed "s/^.*\.\([^\.]*\)$/\\1/")
		local types="dummy txt $(sed -n "s/^\$ext(\(.*\))=\(.*\)$/\\1 \\2/p" /etc/highlight/filetypes.conf) dummy"

		[[ -n $(echo $types | grep " $ext ") ]] && \
		local url="http://89.149.199.86/highlight/${name}" || \
		local url="http://89.149.199.86/files/$r/$s"

		echo -n $url | xclip -selection clipboard
		echo -n $url | xclip -selection primary
		echo $url
	fi
}

function calc() { echo "$*" | bc; }

pdftojpeg() {
	if [ -z $2 ]  || [ $1 = "--help" ] || [ $1 = "-h" ]; then
		echo "Usage: pdftojpeg <input.pdf> <output.jpg>"
	elif [ -e $2 ]; then
		echo "Error: $2 existiert bereits!"
	else
		pdftoppm -l 1 "$1" | convert - -resize "176x248" "$2"
		#pdftoppm -l 1 -scale-to 248 "$1" -- | cjpeg > "$2"
	fi
}

unpack() {
	local srcdir
	local x
	local y
	local myfail
	local tar_opts=""
	[ -z "$*" ] && die "Nothing passed to the 'unpack' command"

	for x in "$@"; do
		echo ">>> Unpacking ${x} to ${PWD}"
		y=${x%.*}
		y=${y##*.}

		#		if [[ ${x} == "./"* ]] ; then
		#			srcdir=""
		#		elif [[ ${x} == ${DISTDIR%/}/* ]] ; then
		#			die "Arguments to unpack() cannot begin with \${DISTDIR}."
		#		elif [[ ${x} == "/"* ]] ; then
		#			die "Arguments to unpack() cannot be absolute"
		#		else
		#			srcdir="${DISTDIR}/"
		#		fi
		[[ ! -s ${x} ]] && die "${x} does not exist"

		myfail="failure unpacking ${x}"
		case "${x##*.}" in
			tar)
			tar xof "${x}" ${tar_opts} || die "$myfail"
			;;
			tgz)
			tar xozf "${x}" ${tar_opts} || die "$myfail"
			;;
			tbz|tbz2)
			bzip2 -dc "${x}" | tar xof - ${tar_opts}
			#assert "$myfail"
			;;
			ZIP|zip|jar)
			unzip -qo "${x}" || die "$myfail"
			;;
			gz|Z|z)
			if [ "${y}" == "tar" ]; then
				tar zoxf "${x}" ${tar_opts} || die "$myfail"
			else
				gzip -dc "${x}" > ${x%.*} || die "$myfail"
			fi
			;;
			bz2|bz)
			if [ "${y}" == "tar" ]; then
				bzip2 -dc "${x}" | tar xof - ${tar_opts}
				assert "$myfail"
			else
				bzip2 -dc "${x}" > ${x%.*} || die "$myfail"
			fi
			;;
			7Z|7z)
			local my_output
			my_output="$(7z x -y "${x}")"
			if [ $? -ne 0 ]; then
				echo "${my_output}" >&2
				die "$myfail"
			fi
			;;
			RAR|rar)
			unrar x -idq -o+ "${x}" || die "$myfail"
			;;
			LHa|LHA|lha|lzh)
			lha xfq "${x}" || die "$myfail"
			;;
			a|deb)
			ar x "${x}" || die "$myfail"
			;;
			lzma)
			if [ "${y}" == "tar" ]; then
				lzma -dc "${x}" | tar xof - ${tar_opts}
				assert "$myfail"
			else
				lzma -dc "${x}" > ${x%.*} || die "$myfail"
			fi
			;;
			*)
			echo "unpack ${x}: file format not recognized. Ignoring."
			;;
		esac
	done
	#	# Do not chmod '.' since it's probably ${WORKDIR} and PORTAGE_WORKDIR_MODE
	#	# should be preserved.
	#	find . -mindepth 1 -maxdepth 1 ! -type l -print0 | \
	#		${XARGS} -0 chmod -fR a+rX,u+w,g-w,o-w
}



die() {
	echo " * ${*:-(no error message)}"
}

wscan() {
	local dev=$1
	local pattern=$2

	iw $dev scan | \
	sed -e '/^[^\t]/{x;p;x;}' | sed  -e '/./{H;$!d;}' -e "x;/$pattern/!d;" | sed "/^$/d"
}
