#!/bin/sh

set -eu

SCRIPT_DIR="$(CDPATH='' cd -- "$(dirname -- "$0")" && pwd)"
readonly SCRIPT_DIR
REPO_ROOT="${DOTFILES_REPO_ROOT:-$(CDPATH='' cd -- "${SCRIPT_DIR}/../../.." && pwd)}"
readonly REPO_ROOT

readonly GHOSTTY_ASSET="${REPO_ROOT}/assets/cli/ghostty/config"
readonly GHOSTTY_CONFIG_DIR="${HOME}/.config/ghostty"
readonly GHOSTTY_CONFIG_PATH="${GHOSTTY_CONFIG_DIR}/config"

main() {
  mkdir -p "${GHOSTTY_CONFIG_DIR}"
  ln -sfn "${GHOSTTY_ASSET}" "${GHOSTTY_CONFIG_PATH}"
}

main "$@"
