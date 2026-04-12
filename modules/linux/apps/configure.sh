#!/bin/bash

set -eu

SCRIPT_DIR="$(CDPATH='' cd -- "$(dirname -- "$0")" && pwd)"
readonly SCRIPT_DIR
REPO_ROOT="${DOTFILES_REPO_ROOT:-$(CDPATH='' cd -- "${SCRIPT_DIR}/../../.." && pwd)}"
readonly REPO_ROOT

. "${REPO_ROOT}/modules/shared/utils/posix.sh"
. "${REPO_ROOT}/modules/shared/utils/message.sh"

refresh_linux_tool_path() {
  add_path "${HOME}/.local/bin" > /dev/null 2>&1 || true
  add_path "${HOME}/bin" > /dev/null 2>&1 || true
  add_path '/usr/local/bin' > /dev/null 2>&1 || true
  export PATH
}

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

configure_starship() {
  configure_info 'Starship'
  if ! command -v starship > /dev/null 2>&1; then
    echo 'Skip setup because Starship is not installed.' >&2
    return 0
  fi

  "${REPO_ROOT}/modules/cli/starship/configure.sh"
  finish_configure_message 'Starship'
}

configure_neovim() {
  configure_info 'Neovim'
  if ! command -v nvim > /dev/null 2>&1; then
    echo 'Skip setup because Neovim is not installed.' >&2
    return 0
  fi

  "${REPO_ROOT}/modules/cli/neovim/configure.sh"
  finish_configure_message 'Neovim'
}

main() {
  refresh_linux_tool_path
  configure_git
  configure_tmux
  configure_starship
  configure_neovim
}

main "$@"
