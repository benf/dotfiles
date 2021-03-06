# enable bashcompletion
alias ebc="[[ -f /etc/profile.d/bash-completion.sh ]] && source /etc/profile.d/bash-completion.sh"

alias player="/home/ben/coding/cpp/audio/player"
alias packages="eix -I --format \" \" |  grep --color=never Found.*matches."

# list hidden files  - if directory do NOT show contents and dont display ".."
alias lh="ls -d .[^.]*"
alias la="ls -a"

# resizing terminal
alias s="r 60 17"

# resize terminal before launching curses-apps
alias vim="r; vim"
alias man="r; man"

alias systemctl="systemctl --full"

# typos
alias sl=ls

# connect to
alias syn_c="ssh -f -N -R 24801:127.0.0.1:24800"

alias le="libtool --mode=execute"

alias iw="/usr/sbin/iw"

alias nsmlab-virsh="virsh -c qemu+ssh://root@nsmlab.et.hs-wismar.de:1337/system"
alias nsmlab-virt-viewer="virt-viewer -c qemu+ssh://root@nsmlab.et.hs-wismar.de:1337/system"

alias cstrike="steam steam://rungameid/10"

alias ssh="TERM=xterm ssh"

alias vpn-kill="nmcli dev disconnect tun0"
alias vpn-qbus="vpn-kill; nmcli con up id qbus-vpn"
alias vpn-lallf="vpn-kill; nmcli con up id lallf"
alias vpn-home="vpn-kill; nmcli con up id home.bnfr.net"

alias revolver="virt-viewer -c qemu+ssh://qbus@192.168.40.11/system revolver"

[ -f ~/.config/bash/alias-qbus.sh ] && source ~/.config/bash/alias-qbus.sh
