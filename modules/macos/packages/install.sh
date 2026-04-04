#!/bin/zsh

set -eu

SCRIPT_DIR="${0:A:h}"
readonly SCRIPT_DIR
REPO_ROOT="${DOTFILES_REPO_ROOT:-${SCRIPT_DIR:h:h:h}}"
readonly REPO_ROOT

readonly HOMEBREW_PREFIX="${DOTFILES_HOMEBREW_PREFIX:-/opt/homebrew}"
readonly BREWFILE_PATH="${DOTFILES_BREWFILE:-}"

source "${REPO_ROOT}/modules/shared/utils/dotfiles.sh"
source "${REPO_ROOT}/modules/shared/utils/message.sh"

install_rosetta() {
  if [ "$(uname -m)" = 'arm64' ]; then
    softwareupdate --install-rosetta --agree-to-license > /dev/null 2>&1 || true
  fi
}

install_homebrew_if_needed() {
  if [ -x "${HOMEBREW_PREFIX}/bin/brew" ]; then
    return 0
  fi

  NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
}

main() {
  if [ -z "${BREWFILE_PATH}" ]; then
    echo 'DOTFILES_BREWFILE is required.' >&2
    return 1
  fi

  require_apple_silicon_macos

  setup_info 'Rosetta'
  install_rosetta
  complete_setup_info 'Rosetta'

  setup_info 'Homebrew'
  install_homebrew_if_needed
  ensure_homebrew_shellenv "${HOMEBREW_PREFIX}"
  brew update
  brew bundle --file "${BREWFILE_PATH}"
  complete_setup_info 'Homebrew and Brewfile packages'
}

main "$@"
