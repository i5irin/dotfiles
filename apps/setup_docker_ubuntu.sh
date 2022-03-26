#!/bin/sh
#
#  Install Docker.
#  TODO: Allow handling of Docker commands without sudo.
# =========================================================

sudo apt-get -qq update
sudo apt-get -qq install apt-transport-https ca-certificates curl software-properties-common
curl -sSfL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable"
sudo apt-get -qq update
sudo apt-get -qq install docker-ce
