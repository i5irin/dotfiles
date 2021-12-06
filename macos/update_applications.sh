#!/bin/bash

{ {
  echo 'brew doctor ---------------------------------------------------';
  if brew doctor; then
    echo 'brew update ---------------------------------------------------';
    brew update;
    echo 'brew upgrade --------------------------------------------------';
    brew upgrade
    # The "brew cleanup" is automatically executed every 30 days by default in Homebrew,
    # and is omitted here in consideration of problems that may occur after a package update.
  fi
  # WARNING: Update applications installed from the Mac App Store, but some of them cannot be updated.
  echo 'mas upgrade ---------------------------------------------------'
  mas upgrade
} 2>&1 1>&3 3>&- | logger -ip 'user.warning'; } 3>&1 1>&2 | logger -ip 'user.notice'