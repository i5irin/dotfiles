# Settings to be applied when the program is launched in interactive mode.
# Aliases and functions used by scripts, periodic tasks, etc. should not be defined here!

# If not running interactively, don't do anything
case $- in
  *i*) ;;
  *) return;;
esac

# don't put duplicate lines or lines starting with space in the history.
HISTCONTROL=ignoreboth

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=500
HISTFILESIZE=500

# Load the functions definition.
. "${BASHRC_UBUNTU_PATH}/../alias/functions.sh"

alias ls='ls -G'
