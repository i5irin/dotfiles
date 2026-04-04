#!/bin/bash

set -eu

SCRIPT_DIR="$(CDPATH='' cd -- "$(dirname -- "$0")" && pwd)"
readonly SCRIPT_DIR
REPO_ROOT="${DOTFILES_REPO_ROOT:-$(CDPATH='' cd -- "${SCRIPT_DIR}/../../.." && pwd)}"
readonly REPO_ROOT

. "${REPO_ROOT}/modules/shared/utils/message.sh"

configure_git() {
  configure_info 'Git'
  if ! command -v git > /dev/null 2>&1; then
    echo 'Skip setup because Git is not installed.' >&2
    return 0
  fi

  "${REPO_ROOT}/modules/cli/git/configure.sh"
  finish_configure_message 'Git'
}

configure_tmux() {
  configure_info 'tmux'
  if ! command -v tmux > /dev/null 2>&1; then
    echo 'Skip setup because tmux is not installed.' >&2
    return 0
  fi

  "${REPO_ROOT}/modules/cli/tmux/configure.sh"
  finish_configure_message 'tmux'
}

main() {
  configure_git
  configure_tmux
}

main "$@"
