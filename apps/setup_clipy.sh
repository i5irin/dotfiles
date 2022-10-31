#!/bin/sh
#
#  Configure Clipy.
#  WARNING: This script is intended to be run on macOS.
# =========================================================
set -eu

source ~/dotfiles/lib/posix_dotfiles_utils/utils.sh

configure_info 'Clipy'
if [ -d /Applications/Clipy.app ]; then
  killall Clipy > /dev/null 2>&1
  alived=$?
  # Activate Clipy at login.
  defaults write com.clipy-app.Clipy loginItem -bool true
  if [ $alived = 0 ]; then
    open /Applications/Clipy.app
  fi
  finish_configure_message 'Clipy'
else
  echo 'Skip setup because Clipy is not installed.' >&2
fi
