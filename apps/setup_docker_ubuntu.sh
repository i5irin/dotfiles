#!/bin/sh
#
#  Install Docker.
#  TODO: Allow handling of Docker commands without sudo.
# =========================================================

sudo apt-get update
sudo apt-get install apt-transport-https ca-certificates curl software-properties-common
curl -fL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable"
sudo apt-get update
sudo apt-get install docker-ce
