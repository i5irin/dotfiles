#!/bin/sh
#
#  Install Google Chrome.
# =========================================================

curl -sSO https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
sudo apt-get install -qq -y ./google-chrome-stable_current_amd64.deb > /dev/null
rm google-chrome-stable_current_amd64.deb
