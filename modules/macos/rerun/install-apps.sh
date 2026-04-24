#!/bin/zsh

set -eu

SCRIPT_DIR="${0:A:h}"
readonly SCRIPT_DIR
REPO_ROOT="${DOTFILES_REPO_ROOT:-${SCRIPT_DIR:h:h:h}}"
readonly REPO_ROOT

exec /bin/zsh "${REPO_ROOT}/modules/macos/bootstrap/run.sh" --only install-apps "$@"
