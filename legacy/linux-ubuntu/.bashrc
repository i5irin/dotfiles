# Settings to be applied when the program is launched in interactive mode.
# Aliases and functions used by scripts, periodic tasks, etc. should not be defined here!

# If not running interactively, don't do anything
case $- in
  *i*) ;;
  *) return;;
esac

# Load the library functions.
. ~/dotfiles/lib/posix_dotfiles_utils/utils.sh

BASHRC_UBUNTU_PATH="$(dirname "$(readlinkf "$(cd $(dirname $BASH_SOURCE); pwd)/.bashrc")")"

# don't put duplicate lines or lines starting with space in the history.
HISTCONTROL=ignoreboth

# 複数の端末でコマンドの履歴を共有する（反映はプロンプトをサイア表示したとき）
export PROMPT_COMMAND="history -a; history -c; history -r; $PROMPT_COMMAND"
shopt -u histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=500
HISTFILESIZE=500

# enable bash completion in interactive shells
if [ -f /etc/bash_completion ] && ! shopt -oq posix; then
  . /etc/bash_completion
fi

# enable git completion in interactive shells
if [ -f /usr/share/bash-completion/completions/git ] && ! shopt -oq posix; then
  . /usr/share/bash-completion/completions/git
fi

# Terminal coloring and displaying Git information
if [ -e /etc/bash_completion.d/git-prompt ]; then
  source /etc/bash_completion.d/git-prompt
  GIT_PS1_SHOWDIRTYSTATE=1
  GIT_PS1_SHOWUPSTREAM=1
  GIT_PS1_SHOWUNTRACKEDFILES=1
  GIT_PS1_SHOWSTASHSTATE=1
  PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\[\033[1;31m\]$(__git_ps1)\[\033[00m\] \$ '
else
  PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
fi

# make less more friendly for non-text input files, see lesspipe(1)
if [ -x /usr/bin/lesspipe ]; then
  eval "$(SHELL=/bin/sh lesspipe)"
fi

# Load the functions and alias definition.
. "${BASHRC_UBUNTU_PATH}/../alias/functions.sh"
. "${BASHRC_UBUNTU_PATH}/../alias/alias.sh"

alias ls='ls -G'

# Setup Starship
eval "$(starship init bash)"
