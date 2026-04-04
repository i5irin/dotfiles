#!/bin/bash

set -eu

SCRIPT_DIR="$(CDPATH='' cd -- "$(dirname -- "$0")" && pwd)"
readonly SCRIPT_DIR
REPO_ROOT="${DOTFILES_REPO_ROOT:-$(CDPATH='' cd -- "${SCRIPT_DIR}/../../.." && pwd)}"
readonly REPO_ROOT

readonly BASH_ASSET_DIR="${REPO_ROOT}/modules/shell/bash"

main() {
  ln -sfn "${BASH_ASSET_DIR}/.bash_profile" "${HOME}/.bash_profile"
  ln -sfn "${BASH_ASSET_DIR}/.bashrc" "${HOME}/.bashrc"
  ln -sfn "${BASH_ASSET_DIR}/.inputrc" "${HOME}/.inputrc"
}

main "$@"
