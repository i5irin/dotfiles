#!/bin/sh

set -eu

readonly TMUX_SCRIPT_PATH=$1

# install plugin manager
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

# link .tmux.conf
ln -sf "${TMUX_SCRIPT_PATH}/.tmux.conf" ~/.tmux.conf
tmux source ~/.tmux.conf
