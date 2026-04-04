#!/bin/zsh

set -eu
readonly GIT_SCRIPT_PATH=$1
readonly DOTFILES_DATA_HOME="${DOTFILES_DATA_HOME:-${XDG_DATA_HOME:-${HOME}/.local/share}/dotfiles}"
readonly GIT_PROMPT_DIR="${DOTFILES_GIT_PROMPT_DIR:-${DOTFILES_DATA_HOME}/git-prompt}"

/bin/sh "${GIT_SCRIPT_PATH}/setup_git.sh" $GIT_SCRIPT_PATH

mkdir -p "${GIT_PROMPT_DIR}" && cd "${GIT_PROMPT_DIR}"
curl -o git-prompt.sh https://raw.githubusercontent.com/git/git/master/contrib/completion/git-prompt.sh
