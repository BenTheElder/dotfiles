#!/bin/bash
# ^- this is so that this file is detected as bash
# this is an include file, not a script.
#===============================================================================
# zsh fixes
#===============================================================================
if [ -n "$ZSH_VERSION" ]; then
    autoload bashcompinit
    bashcompinit
    # for PS1
    set -o PROMPT_SUBST
    setopt prompt_subst
fi
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
# for disabling bracketed paste mode
alias bracketed-paste-off="printf '\e[?2004l'"
# - SCREEN -
alias s="screen -dRL"
# - GIT -
# https://stackoverflow.com/a/21148981
alias git-fixlast="git commit -a --fixup=HEAD && GIT_EDITOR=true git rebase -i --autosquash HEAD~2"
alias sync-git-upstream-origin='(DEFAULT_BRANCH="$(git rev-parse --abbrev-ref origin/HEAD | cut -d/ -f2)" && git fetch upstream && git checkout "${DEFAULT_BRANCH}" && git reset --hard upstream/"${DEFAULT_BRANCH}" && git push origin)'
function github-checkout-upstream-pr(){ git fetch upstream "pull/$@/head:pr$@" && git checkout "pr$@"; }
alias git-cleanup-branches="git checkout master; git pull origin master; git fetch --all -p; git remote prune origin && git branch -vv | grep ': gone]' | awk '{print $1}' | xargs -r git branch -d"
# - DOCKER - 
alias docker-stop-all="docker ps -a -q | xargs docker stop"
alias docker-rm-all="docker ps -a -q | xargs docker rm"
alias docker-rmi-all="docker images -f dangling=true -q | xargs docker rmi"
# - GVM -
function gvm-use(){ gopath=${GOPATH}; gvm use "$@"; export GOPATH=${gopath}; }
export -f gvm-use
# - PYTHON -
alias rm-pyc="find . -name \*.pyc -delete"
# - FUN -
alias nyan='telnet -e ^c nyancat.dakko.us'
#===============================================================================
# Shell settings
#===============================================================================
# fix colors
if [ -n "$DISPLAY" ] && [ "$TERM" = "xterm" ]; then
    export TERM=xterm-256color
fi
# fix gnome keyring over ssh
if [[ -n $(command -v dbus-uuidgen) ]]; then
    if [[ -z $DBUS_SESSION_BUS_ADDRESS ]]; then
        if [[ -f ~/.dbus/session-bus/$(dbus-uuidgen --get)-0 ]]; then
            source ~/.dbus/session-bus/$(dbus-uuidgen --get)-0
            export DBUS_SESSION_BUS_ADDRESS
        fi
    fi
fi
# ls colors
export LSCOLORS=ExFxCxDxBxegedabagacad
# colors
export CLICOLOR=1
# Formatting
tput() {
    # in zsh don't wrap with \[\]
    [ -n "$ZSH_VERSION" ] || echo -n "\["
    command tput "$@"
    [ -n "$ZSH_VERSION" ] || echo -n "\]"
}
DEFAULT="$(tput sgr0)$(tput rmso)"
BOLD="$(tput bold)"
STANDOUT="$(tput smso)"
# define colors
WHITE="$(tput setaf 7)"
BLACK="$(tput setaf 0)"
RED="$(tput setaf 1)"
GREEN="$(tput setaf 2)"
YELLOW="$(tput setaf 3)"
BLUE="$(tput setaf 4)"
CYAN="$(tput setaf 6)"
BLUE256="$(tput setaf 20)"
LBLUE256="$(tput setaf 33)"
GREEN256="$(tput setaf 71)"
LGREEN256="$(tput setaf 34)"
BLACK256="$(tput setaf 232)"
GRAY256="$(tput setaf 239)"
YELLOW256="$(tput setaf 178)"
RED256="$(tput setaf 124)"
WHITE256="$(tput setaf 255)"
# more colors
BG_BLACK="$(tput setab 0)"
BG_WHITE="$(tput setab 7)"
BG_BLACK="$(tput setab 0)"
BG_RED="$(tput setab 1)"
BG_GREEN="$(tput setab 2)"
BG_YELLOW="$(tput setab 3)"
BG_BLUE="$(tput setab 4)"
BT_LBLUE="$(tput setab 33)"
BT_CYAN="$(tput setab 6)"
BG_BLUE256="$(tput setab 33)"
BG_RED256="$(tput setab 160)"
BG_YELLOW256="$(tput setab 178)"
BG_GREEN256="$(tput setab 34)"
# git status for PS1
__git_ps1() {
    if git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
        echo -ne "$(command tput setaf 7)·"
        echo -ne "$(command tput setaf 33)$(git symbolic-ref -q --short HEAD)"
        echo -ne "$(command tput setaf 124)@"
        echo -ne "$(command tput setaf 178)$(git rev-parse --short HEAD)"
        echo -e "$(command tput setaf 7)"
    fi
}
__pretty_pwd() {
    pwd | sed "s#$HOME#~#"
}
# custom PS1
PS1="${DEFAULT}"
PS1+="${BOLD}["
PS1+="${LBLUE256}${USER}"
PS1+="${RED256}@"
PS1+="${YELLOW256}$(hostname -s)"
PS1+="${LBLUE256}:"
PS1+="${LGREEN256}"
PS1+='$(__pretty_pwd)'
PS1+="${DEFAULT}${BOLD}·"
PS1+="${LBLUE256}"
PS1+='$(date +%Y-%m-%d)'
PS1+="${RED256}T${YELLOW256}"
PS1+='$(date +%T%z)'
PS1+="${DEFAULT}${BOLD}"
PS1+='$(__git_ps1)'
PS1+="${DEFAULT}${BOLD}]"$'\n'"${DEFAULT}$"
PS1+="${DEFAULT} "
export PS1;
