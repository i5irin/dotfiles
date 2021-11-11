# configure bash completion
if [ -f $(brew --prefix)/etc/bash_completion ]; then
  source $(brew --prefix)/etc/bash_completion
fi

if [ -f $(brew --prefix)/etc/bash_completion.d/git-prompt.sh ]; then
  source $(brew --prefix)/etc/bash_completion.d/git-prompt.sh
fi

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

alias ls='ls --color'
