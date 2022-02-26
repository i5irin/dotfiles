#!/bin/sh
#
#  Install Zoom.
# =========================================================

curl -LO https://zoom.us/client/latest/zoom_amd64.deb
apt install -y ./zoom_amd64.deb
rm zoom_amd64.deb
