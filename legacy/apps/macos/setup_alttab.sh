#!/bin/sh
#
#  Configure AltTab.
#  WARNING: This script is intended to be run on macOS.
# =========================================================
set -eu

set +e
killall AltTab > /dev/null 2>&1
alived=$?
set -e
# Limit the target window to be displayed to the current desktop.
echo 'aaa'
defaults write com.lwouis.alt-tab-macos spacesToShow -bool true
echo 'bbb'
if [ $alived = 0 ]; then
  open /Applications/AltTab.app
fi
