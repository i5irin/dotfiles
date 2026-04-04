#!/bin/zsh

set -eu

SCRIPT_DIR="${0:A:h}"
readonly SCRIPT_DIR
REPO_ROOT="${DOTFILES_REPO_ROOT:-${SCRIPT_DIR:h:h:h}}"
readonly REPO_ROOT

readonly HYPER_CONFIG_ASSET="${REPO_ROOT}/assets/cli/hyper/.hyper.js"
readonly HYPER_USER_DIR="${HOME}/Library/Application Support/Hyper"

main() {
  mkdir -p "${HYPER_USER_DIR}"
  ln -sfn "${HYPER_CONFIG_ASSET}" "${HYPER_USER_DIR}/.hyper.js"
}

main "$@"
