# Settings to be applied when the program is launched in interactive mode.
# Aliases and functions used by scripts or periodic tasks should not be defined here.

case $- in
  *i*) ;;
  *) return ;;
esac

# Resolve the dotfiles location from the symlinked shell file itself.
DOTFILES_BASH_MODULE_PATH="$(CDPATH='' cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_REPO_ROOT="${DOTFILES_REPO_ROOT:-$(CDPATH='' cd -- "${DOTFILES_BASH_MODULE_PATH}/../../.." && pwd)}"
DOTFILES_DATA_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/dotfiles"
DOTFILES_GIT_PROMPT_DIR="${DOTFILES_GIT_PROMPT_DIR:-${DOTFILES_DATA_HOME}/git-prompt}"

# Load shared shell utilities.
. "${DOTFILES_REPO_ROOT}/modules/shared/utils/posix.sh"

# Do not save duplicate history entries.
HISTCONTROL=ignoreboth
export HISTCONTROL

# Share command history across interactive bash sessions.
PROMPT_COMMAND="history -a; history -c; history -r; ${PROMPT_COMMAND:-}"
export PROMPT_COMMAND
shopt -u histappend

HISTSIZE=500
HISTFILESIZE=500
export HISTSIZE HISTFILESIZE

# Enable bash completion in interactive shells when available.
if [ -f /usr/share/bash-completion/bash_completion ] && ! shopt -oq posix; then
  . /usr/share/bash-completion/bash_completion
elif [ -f /etc/bash_completion ] && ! shopt -oq posix; then
  . /etc/bash_completion
fi

# Enable git completion when available.
for git_completion in \
  /usr/share/bash-completion/completions/git \
  /etc/bash_completion.d/git \
  /usr/share/git/completion/git-completion.bash
do
  if [ -f "${git_completion}" ] && ! shopt -oq posix; then
    . "${git_completion}"
    break
  fi
done

# Display Git information in the prompt when git-prompt is available.
if [ -f "${DOTFILES_GIT_PROMPT_DIR}/git-prompt.sh" ]; then
  . "${DOTFILES_GIT_PROMPT_DIR}/git-prompt.sh"
elif [ -f /usr/lib/git-core/git-sh-prompt ]; then
  . /usr/lib/git-core/git-sh-prompt
elif [ -f /etc/bash_completion.d/git-prompt ]; then
  . /etc/bash_completion.d/git-prompt
fi

if command -v __git_ps1 > /dev/null 2>&1; then
  GIT_PS1_SHOWDIRTYSTATE=1
  GIT_PS1_SHOWUPSTREAM=1
  GIT_PS1_SHOWUNTRACKEDFILES=1
  GIT_PS1_SHOWSTASHSTATE=1
  export GIT_PS1_SHOWDIRTYSTATE GIT_PS1_SHOWUPSTREAM GIT_PS1_SHOWUNTRACKEDFILES GIT_PS1_SHOWSTASHSTATE
  PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\[\033[1;31m\]$(__git_ps1 " (%s)")\[\033[00m\]\$ '
else
  PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
fi
export PS1

# Make less more friendly for non-text input files.
if command -v lesspipe > /dev/null 2>&1; then
  eval "$(SHELL=/bin/sh lesspipe)"
fi

# Load shared functions and aliases.
. "${DOTFILES_REPO_ROOT}/modules/shared/shell/functions.sh"
. "${DOTFILES_REPO_ROOT}/modules/shared/shell/alias.sh"

alias ls='ls --color=auto'

# Setup Starship when it is available.
if command -v starship > /dev/null 2>&1; then
  eval "$(starship init bash)"
fi

# Load machine-specific shell overrides when present.
if [ -f "${DOTFILES_REPO_ROOT}/modules/shell/bash/.bashrc.local" ]; then
  . "${DOTFILES_REPO_ROOT}/modules/shell/bash/.bashrc.local"
fi
