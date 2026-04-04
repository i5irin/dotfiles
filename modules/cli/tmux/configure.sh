#!/bin/sh

set -eu

SCRIPT_DIR="$(CDPATH='' cd -- "$(dirname -- "$0")" && pwd)"
readonly SCRIPT_DIR
REPO_ROOT="${DOTFILES_REPO_ROOT:-$(CDPATH='' cd -- "${SCRIPT_DIR}/../../.." && pwd)}"
readonly REPO_ROOT

readonly TMUX_CONFIG_ASSET="${REPO_ROOT}/assets/cli/tmux/.tmux.conf"
readonly TPM_DIR="${HOME}/.tmux/plugins/tpm"

main() {
  if [ ! -d "${TPM_DIR}" ]; then
    mkdir -p "${HOME}/.tmux/plugins"
    git clone https://github.com/tmux-plugins/tpm "${TPM_DIR}"
  fi

  ln -sfn "${TMUX_CONFIG_ASSET}" "${HOME}/.tmux.conf"
  tmux start-server > /dev/null 2>&1 || true
  tmux source-file "${HOME}/.tmux.conf" > /dev/null 2>&1 || true
}

main "$@"
