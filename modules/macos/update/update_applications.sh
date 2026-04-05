#!/bin/zsh

set -eu

readonly HOMEBREW_PREFIX="${DOTFILES_HOMEBREW_PREFIX:-/opt/homebrew}"

SCRIPT_DIR="${0:A:h}"
readonly SCRIPT_DIR
REPO_ROOT="${DOTFILES_REPO_ROOT:-${SCRIPT_DIR:h:h:h}}"
readonly REPO_ROOT

source "${REPO_ROOT}/modules/shared/utils/dotfiles.sh"

ensure_homebrew_shellenv "${HOMEBREW_PREFIX}"

echo '==============================================================='
echo '    Update applications'
echo '==============================================================='

brew update

if brew doctor; then
  brew outdated
  brew upgrade
  brew upgrade --cask
  brew cleanup

  if type mas > /dev/null 2>&1; then
    echo 'mas upgrade ---------------------------------------------------'
    mas upgrade
  fi
fi

softwareupdate -i -a
