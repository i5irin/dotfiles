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
  mkdir -p -- "$1" && cd -- "$1"
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
  local at="$1"
  local comment="$2"
  GIT_COMMITTER_DATE="${at}" git commit --date="${at}" -m "${comment}"
}

#######################################
# Git-commit at the specified time with specified comments
# Globals:
#   None
# Arguments:
#   Extensions that count the number of lines
#   Paths to exclude from line count
# Returns:
#   Std-Out: Number of lines and total for files with the specified extension
#######################################
function line_count() {
  local extension="$1"
  local exclude="$2"
  find . -type f -name "*.${extension}" ! -path "*${exclude}*" -exec wc -l {} +
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
  local session_name="${1:-localhost}"

  if ! tmux has-session -t "${session_name}" 2> /dev/null; then
    TMUX='' tmux new-session -d -s "${session_name}"
  fi

  # Attach if outside of tmux, switch if you're in tmux.
  if [ -z "${TMUX:-}" ]; then
    tmux attach -t "${session_name}"
  else
    tmux switch-client -t "${session_name}"
  fi
}
