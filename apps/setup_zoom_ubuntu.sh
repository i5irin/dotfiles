#!/bin/sh
#
#  Install Zoom.
# =========================================================

curl -sSLO https://zoom.us/client/latest/zoom_amd64.deb
sudo apt-get install -qq -y ./zoom_amd64.deb > /dev/null
rm ./zoom_amd64.deb
