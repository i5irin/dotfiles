#!/bin/sh
#
#  Install gibo.
# =========================================================
set -eu

curl -sSL https://raw.github.com/simonwhitaker/gibo/master/gibo -o ~/bin/gibo
chmod +x ~/bin/gibo
gibo update > /dev/null
