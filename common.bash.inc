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
BLUE="\[$(tput setaf 4)\]"
LBLUE="\[$(tput setaf 33)\]"
CYAN="\[$(tput setaf 6)\]"
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

# custom PS1
PS1="${DEFAULT}\n${BOLD}${STANDOUT}"
PS1+="${WHITE}["
PS1+="${LBLUE} \u "
PS1+="${RED} at "
PS1+="${YELLOW} \H "
PS1+="${LBLUE} in "
PS1+="${GREEN} \w "
PS1+="${WHITE}]"
PS1+="${DEFAULT}\n"
PS1+="${DEFAULT}${WHITE}${BOLD}%"
PS1+="${DEFAULT}${WHITE} "
export PS1;
