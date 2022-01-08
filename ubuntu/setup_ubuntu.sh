#!/bin/bash

readonly INSTALL_SCRIPT_PATH=$(cd "$(dirname ${BASH_SOURCE})../"; pwd)

# ---------------------------------------------------------
# Configure Bash
# ---------------------------------------------------------

# link .bash_profile and .bashrc
ln -is "${INSTALL_SCRIPT_PATH}/.bash_profile" ~/.bash_profile
ln -is "${INSTALL_SCRIPT_PATH}/ubuntu/.bashrc_ubuntu" ~/.bashrc

# link readline config
ln -s "${INSTALL_SCRIPT_PATH}/.inputrc" ~/.inputrc

# Install applications
xargs apt-get install -y < "${INSTALL_SCRIPT_PATH}/ubuntu/packages.txt"
