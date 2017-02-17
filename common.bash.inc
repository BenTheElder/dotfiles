# this is all I want when editing a commit message etc.
# other editors can be opened explicitly
export EDITOR=nano

# ls colors
export LSCOLORS=ExFxCxDxBxegedabagacad

# colors
export CLICOLOR=1

# Formatting
DEFAULT="\[$(tput sgr0)$(tput rmso)\]"
BOLD="\[$(tput bold)\]"
STANDOUT="\[$(tput smso)\]"
# define colors
WHITE="\[$(tput setaf 7)\]"
BLACK="\[$(tput setaf 0)\]"
RED="\[$(tput setaf 1)\]"
GREEN="\[$(tput setaf 2)\]"
YELLOW="\[$(tput setaf 3)\]"
BLUE="\[$(tput setf 4)\]"
CYAN="\[$(tput setaf 6)\]"
LBLUE256="\[$(tput setaf 33)\]"
GREEN256="\[$(tput setaf 71)\]"
BLACK256="\[$(tput setaf 232)\]"
# more colors
BG_BLACK="\[$(tput setab 0)\]"
BG_WHITE="\[$(tput setab 7)\]"
BG_BLACK="\[$(tput setab 0)\]"
BG_RED="\[$(tput setab 1)\]"
BG_GREEN="\[$(tput setab 2)\]"
BG_YELLOW="\[$(tput setab 3)\]"
BG_BLUE="\[$(tput setab 4)\]"
BT_LBLUE="\[$(tput setab 33)\]"
BT_CYAN="\[$(tput setab 6)\]"
BG_BLUE256="\[$(tput setab 33)\]"
BG_RED256="\[$(tput setab 160)\]"
BG_YELLOW256="\[$(tput setab 178)\]"
BG_GREEN256="\[$(tput setab 34)\]"

# custom PS1
PS1="${DEFAULT}\n${BOLD}"
PS1+="${BG_WHITE}${BLACK256}["
PS1+="${WHITE}${BG_BLUE256} \u "
PS1+="${BG_RED256} at "
PS1+="${BG_YELLOW256} \H "
PS1+="${BG_BLUE256} in "
PS1+="${BG_GREEN256} \w "
PS1+="${BLACK256}${BG_WHITE}]"
PS1+="${DEFAULT}\n"
PS1+="${DEFAULT}${WHITE}${BOLD}%"
PS1+="${DEFAULT}${WHITE} "
export PS1;
