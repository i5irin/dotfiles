#!/bin/sh
#
#  Install and configure Hyper Terminal.
# =========================================================
set -eu

curl -sSLO https://github.com/vercel/hyper/releases/download/v3.2.0/hyper_3.2.0_amd64.deb
sudo apt-get install -qq  -y ./hyper_3.2.0_amd64.deb > /dev/null
rm ./hyper_3.2.0_amd64.deb

# Link .hyper.js
# Modify dotfiles/apps/hyper/.hyper.js to configure Hyper.js.
mkdir -p ~/.config/Hyper
ln -isf "${HYPER_SCRIPT_PATH}/.hyper.js" ~/.config/Hyper/.hyper.js
