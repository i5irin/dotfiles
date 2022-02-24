#!/bin/sh
#
#  Install gibo.
# =========================================================

curl -L https://raw.github.com/simonwhitaker/gibo/master/gibo \
  -o ~/bin/gibo && chmod +x ~/bin/gibo && gibo update
