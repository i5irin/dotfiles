#!/bin/zsh

set -eu

readonly HOMEBREW_PREFIX="${DOTFILES_HOMEBREW_PREFIX:-/opt/homebrew}"

if [ -x "${HOMEBREW_PREFIX}/bin/brew" ]; then
  eval "$("${HOMEBREW_PREFIX}/bin/brew" shellenv)"
fi

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
