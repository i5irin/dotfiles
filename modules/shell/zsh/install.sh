#!/bin/zsh

set -eu

SCRIPT_DIR="${0:A:h}"
readonly SCRIPT_DIR
REPO_ROOT="${DOTFILES_REPO_ROOT:-${SCRIPT_DIR:h:h:h}}"
readonly REPO_ROOT

readonly DOTFILES_DATA_HOME="${DOTFILES_DATA_HOME:-${XDG_DATA_HOME:-${HOME}/.local/share}/dotfiles}"
readonly ZSH_COMPLETIONS_DIR="${DOTFILES_ZSH_COMPLETIONS_DIR:-${DOTFILES_DATA_HOME}/zsh-completions}"
readonly ZSH_ASSET_DIR="${REPO_ROOT}/modules/shell/zsh"

source "${REPO_ROOT}/modules/shared/utils/message.sh"

main() {
  ln -sfn "${ZSH_ASSET_DIR}/.zprofile" "${HOME}/.zprofile"
  ln -sfn "${ZSH_ASSET_DIR}/.zshrc" "${HOME}/.zshrc"

  setup_info 'zsh-completions'
  if [ -d "${ZSH_COMPLETIONS_DIR}" ]; then
    skip_info "\"${ZSH_COMPLETIONS_DIR}\" already exists."
  else
    mkdir -p "${DOTFILES_DATA_HOME}"
    git clone https://github.com/zsh-users/zsh-completions.git "${ZSH_COMPLETIONS_DIR}"
  fi
  complete_setup_info 'zsh-completions'
}

main "$@"
