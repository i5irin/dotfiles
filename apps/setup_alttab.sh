#!/bin/sh
#
#  Configure AltTab.
#  WARNING: This script is intended to be run on macOS.
# =========================================================

if [ -d /Applications/AltTab.app ]; then
  killall AltTab &> /dev/null
  alived=$?
  # Limit the target window to be displayed to the current desktop.
  defaults write com.lwouis.alt-tab-macos spacesToShow -bool true
  if [ $alived = 0 ]; then
    open /Applications/AltTab.app
  fi
fi
