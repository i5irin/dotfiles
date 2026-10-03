#!/bin/sh
#
#  Configure Hyper Terminal.
# =========================================================

set -eu
readonly HYPER_SCRIPT_PATH=$1

# Link .hyper.js
# Modify dotfiles/apps/hyper/.hyper.js to configure Hyper.js.
ln -sf "${HYPER_SCRIPT_PATH}/.hyper.js" ~/Library/Application\ Support/Hyper/.hyper.js
