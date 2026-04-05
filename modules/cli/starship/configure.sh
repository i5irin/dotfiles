#!/bin/sh

set -eu

SCRIPT_DIR="$(CDPATH='' cd -- "$(dirname -- "$0")" && pwd)"
readonly SCRIPT_DIR
REPO_ROOT="${DOTFILES_REPO_ROOT:-$(CDPATH='' cd -- "${SCRIPT_DIR}/../../.." && pwd)}"
readonly REPO_ROOT

readonly STARSHIP_ASSET="${REPO_ROOT}/assets/cli/starship/starship.toml"
readonly STARSHIP_CONFIG_DIR="${HOME}/.config"
readonly STARSHIP_CONFIG_PATH="${STARSHIP_CONFIG_DIR}/starship.toml"

main() {
  mkdir -p "${STARSHIP_CONFIG_DIR}"
  ln -sfn "${STARSHIP_ASSET}" "${STARSHIP_CONFIG_PATH}"
}

main "$@"
