#!/bin/zsh

set -eu

readonly HOMEBREW_PREFIX="${DOTFILES_HOMEBREW_PREFIX:-/opt/homebrew}"

if [ -x "${HOMEBREW_PREFIX}/bin/brew" ]; then
  eval "$("${HOMEBREW_PREFIX}/bin/brew" shellenv)"
fi

echo '==============================================================='
echo '    Update applications'
echo '==============================================================='
echo "Current time $(date '+%Y-%m-%dT%H:%M:%S%z')"
echo 'brew doctor ---------------------------------------------------';
if brew doctor; then
  echo 'brew update ---------------------------------------------------';
  brew update;
  echo 'brew upgrade --------------------------------------------------';
  brew upgrade
  # The "brew cleanup" is automatically executed every 30 days by default in Homebrew,
  # and is omitted here in consideration of problems that may occur after a package update.

  # WARNING: Update applications installed from the Mac App Store, but some of them cannot be updated.
  if type mas > /dev/null 2>&1; then
    echo 'mas upgrade ---------------------------------------------------'
    mas upgrade
  fi
fi

# Update the OS, Xcode Command Line Tools, and other system-related items.
# softwareupdate --install --all
