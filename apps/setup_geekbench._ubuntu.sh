#!/bin/sh
#
#  Install Geekbench.
# =========================================================

cd ~/bin
curl -O https://cdn.geekbench.com/Geekbench-5.3.1-Linux.tar.gz
mkdir geekbench && tar xf Geekbench-5.3.1-Linux.tar.gz -C geekbench --strip-components 1 && rm Geekbench-5.3.1-Linux.tar.gz
cd -
