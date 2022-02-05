#!/bin/sh
#
#  Configure Clipy.
#  WARNING: This script is intended to be run on macOS.
# =========================================================

if [ -d /Applications/Clipy.app ]; then
  killall Clipy &> /dev/null
  alived=$?
  # Activate Clipy at login.
  defaults write com.clipy-app.Clipy loginItem -bool true
  if [ $alived = 0 ]; then
    open /Applications/Clipy.app
  fi
fi