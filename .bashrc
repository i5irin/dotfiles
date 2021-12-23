# Settings to be applied when the program is launched in interactive mode.
# Aliases and functions used by scripts, periodic tasks, etc. should not be defined here!

# If not running interactively, don't do anything
case $- in
  *i*) ;;
  *) return;;
esac

# configure bash completion
if [ -f $(brew --prefix)/etc/bash_completion ]; then
  source $(brew --prefix)/etc/bash_completion
fi

if [ -f $(brew --prefix)/etc/bash_completion.d/git-prompt.sh ]; then
  source $(brew --prefix)/etc/bash_completion.d/git-prompt.sh
fi

# don't put duplicate lines or lines starting with space in the history.
HISTCONTROL=ignoreboth

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=500
HISTFILESIZE=500

#######################################
# Create a directory and move into it
# Globals:
#   None
# Arguments:
#   Directory name to create
# Returns:
#   None
#######################################
function mkcd() {
  mkdir -p $1 && cd $_
}

#######################################
# Git-commit at the specified time with specified comments
# Globals:
#   None
# Arguments:
#   Date to Git-commit
#   Comments on Git-commit
# Returns:
#   None
#######################################
function git_commit_at() {
  at="$1"
  comment="$2"
  GIT_COMMITTER_DATE="${at}" git commit --date="${at}" -m "${comment}"
}

alias ls='ls -G'

# Attach to a tmux session at shell startup.
tmux_count=$(pgrep tmux | wc -l)
if [ "$tmux_count" -eq 0 ]; then
  tmux
elif [ "$tmux_count" -eq 1 ]; then
  tmux a
fi
