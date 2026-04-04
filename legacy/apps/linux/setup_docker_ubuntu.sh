#!/bin/sh
#
#  Install Docker.
#  TODO: Allow handling of Docker commands without sudo.
# =========================================================
set -eu

sudo apt-get -qq update
sudo apt-get install -qq apt-transport-https ca-certificates curl software-properties-common > /dev/null
(curl -sSfL https://download.docker.com/linux/ubuntu/gpg | sudo APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE=1 apt-key add -) > /dev/null
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable" > /dev/null
sudo apt-get -qq update
sudo apt-get install -qq docker-ce > /dev/null
