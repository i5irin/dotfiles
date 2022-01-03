#!/bin/bash

readonly INSTALL_SCRIPT_PATH=$(cd "$(dirname ${BASH_SOURCE})../"; pwd)

# ---------------------------------------------------------
# Configure Bash
# ---------------------------------------------------------

# link .bash_profile and .bashrc
ln -is "${INSTALL_SCRIPT_PATH}/.bash_profile" ~/.bash_profile
ln -is "${INSTALL_SCRIPT_PATH}/.bashrc" ~/.bashrc

# link readline config
ln -s "${INSTALL_SCRIPT_PATH}/.inputrc" ~/.inputrc

apt install -y bash-completion
