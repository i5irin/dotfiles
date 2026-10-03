#!/bin/zsh

set -eu
readonly GIT_SCRIPT_PATH=$1

/bin/sh "${GIT_SCRIPT_PATH}/setup_git.sh" $GIT_SCRIPT_PATH

mkdir -p /usr/local/bin/git-prompt && cd $_
curl -o git-prompt.sh https://raw.githubusercontent.com/git/git/master/contrib/completion/git-prompt.sh
