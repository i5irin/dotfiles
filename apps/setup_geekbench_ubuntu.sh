#!/bin/sh
#
#  Install Geekbench.
# =========================================================
set -eu

cd ~/bin
curl -sSO https://cdn.geekbench.com/Geekbench-5.3.1-Linux.tar.gz
mkdir geekbench && tar xf Geekbench-5.3.1-Linux.tar.gz -C geekbench --strip-components 1 && rm Geekbench-5.3.1-Linux.tar.gz
cd - > /dev/null
