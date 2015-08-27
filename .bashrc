#!/bin/bash

# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
[ -z "$PS1" ] && return

# don't put duplicate lines in the history. See bash(1) for more options
# ... or force ignoredups and ignorespace
HISTCONTROL=ignoredups:ignorespace

# append to the history file, don't overwrite it
shopt -s histappend

# # for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
# HISTSIZE=1000
# HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "$debian_chroot" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
#force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
	# We have color support; assume it's compliant with Ecma-48
	# (ISO/IEC-6429). (Lack of such support is extremely rare, and such
	# a case would tend to support setf rather than setaf.)
	color_prompt=yes
    else
	color_prompt=
    fi
fi

if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls -rt --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep -i --color=auto' # -i ignores case
    alias fgrep='fgrep -i --color=auto'
    alias egrep='egrep -i --color=auto'
    # Don't use color=always, it'll mess up some commands when you pipe
fi

# some more ls aliases
alias ll='ls -alhFrt'
alias la='ls -Art'

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if [ -f /etc/bash_completion ] && ! shopt -oq posix; then
    . /etc/bash_completion
fi

############################################# MY COMMANDS

export PATH=.:~:~/nt/bin:$PATH

# infinite history
export HISTFILESIZE=''
export HISTSIZE=''
export HISTTIMEFORMAT="%F %T "

# lets you type cx ce in the terminal to start emacs . . . on second
# thought, don't use this: it opens up bash-fc-<some number>
# export VISUAL=emacs
# export EDITOR=emacs

##################################################################
#
#                   define aliases below and their functions above
#
##################################################################
alias ci="git ci -m"
alias co="git checkout"
alias hist="git hist"
alias st="git status"
alias br="git branch"

# SETS TERM TITLE before executing every command
preexec () {
    shortcurrentdir=$(pwd)
    printf "\e]0;%s    %s    terminal\007" "$(history 1 | sed -e "s/^[ ]*[0-9]*[ ]*//g")" "${shortcurrentdir/#$HOME/~}"
}
preexec_invoke_exec () {
    [ -n "$COMP_LINE" ] && return  # do nothing if completing
    this_command_for_console_and_title_bar=`history 1 | sed -e "s/^[ ]*[0-9]*[ ]*//g"`;
    preexec "$this_command_for_console_and_title_bar"
}
trap 'preexec_invoke_exec' DEBUG

mkdir ~/logs
console_log=~/logs/console
export PROMPT_COMMAND='if test $? -eq 0; then \
    PS1="$(date +"%F %a %R:%S") \e[1;33m\h \w\e[m\n\n    "; \
else \
    PS1="\e[1;31m$(date +"%F %a %R:%S") \h \w\e[m\n\n    "; \
fi; \
echo "$this_command_for_console_and_title_bar" >> $console_log; \
'

# makes terminal editing like mint emacs (without your
# customizations). This is default, I think.
set -o emacs
