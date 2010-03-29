if [ "${SSH_USER}x" = "x" ]; then
	export SSH_USER=$USER
fi
#export PAGER="col -b 2>/dev/null | view -c 'set ft=man' -c 'set titlestring=[view]man' -c 'set number!' -"
#export PAGER="sed 's/\[[^m]*m//g; s/.//g' | view -c 'set ft=man' -c 'set titlestring=[view]man' -c 'set number!' -"

#export MANWIDTH=4294967296
#export PAGER="sed 's/\[[^m]*m//g' | view -c 'set ft=man' -c 'set titlestring=[view]man' -c 'set number!' -"

# from dell-notebook
# \x1b = \e ; \x08 = ^H (backspace)
#PAGER="sed 's/\\x1b\[[^m]*m//g; s/\\x08.//g' | \
#	view -c 'set ft=man' -c 'set titlestring=man' -c 'set number!' -"

# since vim has support - use built in ones..
export MANPAGER="vimmanpager"
export PAGER="vimpager"

if [[ ${EUID} == 0 ]]; then
	DELIM_COL='\[\e[0;31m\]'
	DIR_COL='\[\e[0;34m\]'
	UNAME_COL='\[\e[0;31m\]'
else
	DELIM_COL='\[\e[0;34m\]'
	DIR_COL='\[\e[0;32m\]'
	UNAME_COL='\[\e[1;32m\]'
fi
NOR_COL='\[\e[0m\]'

PS1="${DELIM_COL}[${DIR_COL}\W${DELIM_COL}] \\\$ ${NOR_COL}"
[[ -n $SSH_CLIENT ]] && PS1="${UNAME_COL}`[[ ${EUID} != 0 ]] && echo '\u@'`\h $PS1"

unset BRACKET_COL DIR_COL PROMPT_COL NOR_COL UNAME_COL

#if [[ ${EUID} == 0 ]] ; then
#  PS1='\[\e[0;31m\][\[\e[0;34m\]\W\[\e[0;31m\]] \$\[\e[0m\] '
#  [[ -n $SSH_CLIENT ]] && PS1="\[\e[0;31m\]\h\[\e[0m\] $PS1"
#else
#  PS1='\[\e[0;34m\][\[\e[0;32m\]\W\[\e[0;34m\]] \$\[\e[0m\] '
#  [[ -n $SSH_CLIENT ]] && PS1="\[\e[1;32m\]\u@\h\[\e[0m\] $PS1"

#fi

##PS1="\$(test \$(~/coding/c/get_cursor_pos) -gt 1 && echo '\[\n\]')${PS1}"

##PS1="\$([[ \$(get_cursor_y) -gt 1 ]] && echo -n '\[\n\]')$PS1"
##PS1="\$(prompt_nl_needed && echo '\[\n\]')${PS1}"

#PS1="\$(print_prompt_nl_if_needed)${PS1}"

#PS1="\$(~/coding/c/nl_if_needed)$PS1"

#inspired by http://www.xfce-look.org/content/show.php/My+Destkop+(December)?content=50362
#PS1="\[\e[\$((COLUMNS-\$(echo -n '\W' | wc -c)-2))G\] [\W]\[\e[0G\]\$ "
CMD="\$(date +%H:%M)"

#PS1="\[\e[\$((COLUMNS-\$(echo -n $CMD | wc -c)-2))G\] \[\e[0;34m\][\[\e[0;32m\]$CMD\[\e[0;34m\]]\[\e[0G\]${PS1}" 
#PS1="$PS1\[\e[s\[\e[\$((COLUMNS-\$(echo -n $CMD | wc -c)-2))G\]abc\[\e[u\]"

#if [[ ${EUID} != 0 ]] ; then
  #PS1='\[\033[1;34m\]\W \$\[\033[00m\] '
  #PS1='[\[\e[0;31m\]\W\[\e[0m\]] \$ '
  #PS1='\[\033[01;32m\]\u\[\033[00m\]@\[\033[01;31m\]\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]$ '
  #PS1='\[\e[1;31m\][\[\e[1;32m\]\W\[\e[1;31m\]]\[\e[1;34m\] \$\[\e[0m\] '
  #PS1='\[\e[0;34m\][\[\e[0;32m\]\W\[\e[0;34m\]] \$\[\e[0m\] '
  #PS1='\[\033[01;32m\]\u\[\033[00m\]@\[\033[01;31m\]\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]$ '
  #PS1='[\[\e[36;40m\]\u\[\e[0m\]] \[\e[32;40m\]\W \[\e[0m\]\$ '
  #PS1='[\u \w]\$ '
  #PS1="\[\033[0;36m\]\t\[\033[1;35m\]^\
    #\[\033[0;32m\]\u\[\033[1;34m\]@\[\033[0;32m\]\
    #\h\[\033[1;35m\]:\[\033[1;33m\]\w\[\033[0m\]\
    #\[\033[1;34m\]$\[\033[0m\] "
#fi

#for matlab - wont start with out this
#export LIBXCB_ALLOW_SLOPPY_LOCK=true

# configure audio
export SDL_AUDIODRIVER=alsa
export AUDIODEV=plug:upmix

# set XDG corresponding variables
export XDG_DATA_HOME="${HOME}/.config"
export XDG_CONFIG_HOME="${HOME}/.config"
export XDG_CACHE_HOME="${HOME}/.cache"

# readline should read its user config from this path instead ~/.inputrc
export INPUTRC="${XDG_CONFIG_HOME}/readline/inputrc"

# manually set vim's vimrc variable and then source that file on vim startup
export VIMINIT='let $MYVIMRC="$XDG_CONFIG_HOME/vim/vimrc" | source $MYVIMRC'

# matlow wont start on some system without this
export LIBXCB_ALLOW_SLOPPY_LOCK=true

