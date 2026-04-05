#!/bin/sh

set -eu

SCRIPT_DIR="$(CDPATH='' cd -- "$(dirname -- "$0")" && pwd)"
readonly SCRIPT_DIR
REPO_ROOT="${DOTFILES_REPO_ROOT:-$(CDPATH='' cd -- "${SCRIPT_DIR}/../../.." && pwd)}"
readonly REPO_ROOT

readonly NVIM_ASSET="${REPO_ROOT}/assets/cli/nvim/init.lua"
readonly NVIM_CONFIG_DIR="${HOME}/.config/nvim"
readonly NVIM_CONFIG_PATH="${NVIM_CONFIG_DIR}/init.lua"

main() {
  mkdir -p "${NVIM_CONFIG_DIR}"
  ln -sfn "${NVIM_ASSET}" "${NVIM_CONFIG_PATH}"
}

main "$@"
