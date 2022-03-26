#!/bin/sh
#
#  Install and configure Hyper Terminal.
# =========================================================

sudo apt-get -qq install -y hyper_3.2.0_amd64.deb
rm hyper_3.2.0_amd64.deb

# Link .hyper.js
# Modify dotfiles/apps/hyper/.hyper.js to configure Hyper.js.
mkdir -p ~/.config/Hyper
ln -sf "${HYPER_SCRIPT_PATH}/.hyper.js" ~/.config/Hyper/.hyper.js
