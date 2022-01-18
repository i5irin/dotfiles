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

#######################################
# Attaches to or creates a tmux session with the specified name.
# Globals:
#   $TMUX: Path to tmux temporary files
# Arguments:
#   Tmux sesesion name
# Returns:
#   None
#######################################
function tmux_start() {
  session_name="${1:-localhost}"
  tmux has-session -t=$session_name 2> /dev/null
  # Create the session if it doesn't exists. (Only create!)
  if [ "$?" -ne 0 ]; then
    TMUX='' tmux new-session -d -s "$session_name"
  fi
  # Attach if outside of tmux, switch if you're in tmux.
  if [ -z "$TMUX" ]; then
    tmux attach -t "$session_name"
  else
    tmux switch-client -t "$session_name"
  fi
}

alias ls='ls -G'
