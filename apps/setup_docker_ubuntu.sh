#!/bin/sh
#
#  Install Docker.
#  TODO: Allow handling of Docker commands without sudo.
# =========================================================

apt-get update
apt-get install apt-transport-https ca-certificates curl software-properties-common
curl -fL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable"
apt-get update
apt-get install docker-ce
