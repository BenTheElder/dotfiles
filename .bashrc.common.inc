#!/bin/bash
# ^- this is so that this file is detected as bash
# this is an include file, not a script.
#===============================================================================
# Environment Settings
#===============================================================================
# git rid of all those pesky --set-upstream
git config --global push.default current
# this is all I want when editing a commit message etc.
# other editors can be opened explicitly
export EDITOR=nano
# GOLANG
[[ -s "$HOME/.gvm/scripts/gvm" ]] && source "$HOME/.gvm/scripts/gvm"
export GOPATH=$HOME/go
export PATH=$PATH:$GOPATH/bin
#===============================================================================
# Aliases and Functions
#===============================================================================
# - BASH -
# reload bash config
alias re-source="source $HOME/.bashrc && source $HOME/dotfiles/.bashrc.common.inc"
# - SCREEN -
alias s="screen -dRL"
# - GIT -
# https://stackoverflow.com/a/21148981
alias git-fixlast="git commit -a --fixup=HEAD && GIT_EDITOR=true git rebase -i --autosquash HEAD~2"
alias git-sync-upstream-master="git fetch upstream && git checkout master && git reset --hard upstream/master && git push origin"
function github-checkout-upstream-pr(){ git fetch upstream "pull/$@/head:pr$@" && git checkout "pr$@"; }
alias git-cleanup-branches="git checkout master; git pull origin master; git fetch --all -p; git remote prune origin && git branch -vv | grep ': gone]' | awk '{print $1}' | xargs -r git branch -d"
# - DOCKER - 
alias docker-stop-all="docker ps -a -q | xargs docker stop"
alias docker-rm-all="docker ps -a -q | xargs docker rm"
alias docker-rmi-all="docker images -f dangling=true -q | xargs docker rmi"
# - GVM -
alias gvm-use='gvm use $@; export GOPATH=~/go'
# - PYTHON -
alias rm-pyc="find . -name \*.pyc -delete"
# - FUN -
alias nyan='telnet -e ^c nyancat.dakko.us'
#===============================================================================
# Shell settings
#===============================================================================
# fix colors
if [ -n "$DISPLAY" -a "$TERM" == "xterm" ]; then
    export TERM=xterm-256color
fi
# fix gnome keyring over ssh
if [[ -z $DBUS_SESSION_BUS_ADDRESS ]]; then
    if [[ -f ~/.dbus/session-bus/$(dbus-uuidgen --get)-0 ]]; then
        source ~/.dbus/session-bus/$(dbus-uuidgen --get)-0
        export DBUS_SESSION_BUS_ADDRESS
    fi
fi
# ls colors
export LSCOLORS=ExFxCxDxBxegedabagacad
# colors
export CLICOLOR=1
# Formatting
DEFAULT="\[$(tput sgr0)\]\[$(tput rmso)\]"
BOLD="\[$(tput bold)\]"
STANDOUT="\[$(tput smso)\]"
# define colors
WHITE="\[$(tput setaf 7)\]"
BLACK="\[$(tput setaf 0)\]"
RED="\[$(tput setaf 1)\]"
GREEN="\[$(tput setaf 2)\]"
YELLOW="\[$(tput setaf 3)\]"
BLUE="\[$(tput setaf 4)\]"
CYAN="\[$(tput setaf 6)\]"
BLUE256="\[$(tput setaf 20)\]"
LBLUE256="\[$(tput setaf 33)\]"
GREEN256="\[$(tput setaf 71)\]"
BLACK256="\[$(tput setaf 232)\]"
GRAY256="\[$(tput setaf 239)\]"
YELLOW256="\[$(tput setaf 178)\]"
RED256="\[$(tput setaf 160)\]"
WHITE256="\[$(tput setaf 255)\]"
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
PS1+="${WHITE256}${BG_BLUE256} \u "
PS1+="${BG_RED256} @ "
PS1+="${BG_YELLOW256} \H "
PS1+="${BG_BLUE256} : "
PS1+="${BG_GREEN256} \w "
PS1+="${BLACK256}${BG_WHITE}]"
PS1+="${DEFAULT}"
PS1+="${DEFAULT}${WHITE}${BOLD}\n$"
PS1+="${DEFAULT}${WHITE} "
export PS1;
