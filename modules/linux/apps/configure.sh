#!/bin/bash

set -eu

SCRIPT_DIR="$(CDPATH='' cd -- "$(dirname -- "$0")" && pwd)"
readonly SCRIPT_DIR
REPO_ROOT="${DOTFILES_REPO_ROOT:-$(CDPATH='' cd -- "${SCRIPT_DIR}/../../.." && pwd)}"
readonly REPO_ROOT

. "${REPO_ROOT}/modules/shared/utils/posix.sh"
. "${REPO_ROOT}/modules/shared/utils/message.sh"
. "${REPO_ROOT}/modules/shared/utils/posix_app_config.sh"

refresh_linux_tool_path() {
  add_path "${HOME}/.local/bin" > /dev/null 2>&1 || true
  add_path "${HOME}/bin" > /dev/null 2>&1 || true
  add_path '/usr/local/bin' > /dev/null 2>&1 || true
  export PATH
}

main() {
  refresh_linux_tool_path
  configure_posix_git
  configure_posix_tmux
  configure_posix_starship
  configure_posix_neovim
}

main "$@"
