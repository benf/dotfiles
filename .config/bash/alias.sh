# enable bashcompletion
alias ebc="[[ -f /etc/profile.d/bash-completion.sh ]] && source /etc/profile.d/bash-completion.sh"

alias player="/home/ben/coding/cpp/audio/player"
alias packages="eix -I --format \" \" |  grep --color=never Found.*matches."
alias gplay="gnome-mplayer"

# list hidden files  - if directory do NOT show contents and dont display ".."
alias lh="ls -d .[^.]*"
alias la="ls -a"

# resizing terminal
alias s="r 60 17"

# resize terminal before launching curses-apps
alias vim="r; vim"
alias man="r; man"

alias ccat="highlight --ansi"
alias hhtml="highlight --wrap --xhtml --linenumbers --anchors --linenumbers --anchor-prefix=line"

alias use="quse -D"
alias tv="~/.scripts/tv.sh"

# typos
alias sl=ls

# connect to 
alias syn_c="ssh -f -N -R 24801:127.0.0.1:24800"

alias le="libtool --mode=execute"

alias ip="/sbin/ip"
alias iw="/usr/sbin/iw"

alias nsmlab-virsh="virsh -c qemu+ssh://root@nsmlab.et.hs-wismar.de:1337/system"
alias nsmlab-virt-viewer="virt-viewer -c qemu+ssh://root@nsmlab.et.hs-wismar.de:1337/system"
