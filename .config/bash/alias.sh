# enable bashcompletion
alias ebc="[[ -f /etc/profile.d/bash-completion.sh ]] && source /etc/profile.d/bash-completion.sh"

alias player="/home/ben/coding/cpp/audio/player"
alias packages="eix -I --format \" \" |  grep --color=never Found.*matches."
alias gplay="gnome-mplayer"

# list hidden files  - if directory do NOT show contents and dont display ".."
alias lh="ls -d .[^.]*"
alias la="ls -a"
alias r="resize_to_min 100 35"
alias vim="r; vim"
alias man="r; man"

alias ccat="highlight --ansi"
alias hhtml="highlight --wrap --xhtml --linenumbers --anchors --linenumbers --anchor-prefix=line"

alias use="quse -D"
alias tv="~/.scripts/tv.sh"

