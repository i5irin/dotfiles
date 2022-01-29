#!/bin/bash

readonly INSTALL_SCRIPT_PATH=$(cd "$(dirname ${BASH_SOURCE})../"; pwd)

# ---------------------------------------------------------
# Configure Bash
# ---------------------------------------------------------

# link .bash_profile and .bashrc
ln -is "${INSTALL_SCRIPT_PATH}/ubuntu/.bash_profile" ~/.bash_profile
ln -is "${INSTALL_SCRIPT_PATH}/ubuntu/.bashrc" ~/.bashrc
# link readline config
ln -s "${DOTFILES_PATH}/.inputrc" ~/.inputrc

# ---------------------------------------------------------
# Install applications
# ---------------------------------------------------------

apt update
apt upgrade -y

# Install gdebi to install deb package application with resolving dependencies.
apt install -y gdebi

# Install Snap package management system.
apt install -y snapd

# Install applications
xargs apt-get install -y < "${INSTALL_SCRIPT_PATH}/ubuntu/packages.txt"

# ---------------------------------------------------------
# Register periodic tasks.
# ---------------------------------------------------------

# Grant execution permissions to ShellScript executed from cron.
chmod u+x "${INSTALL_SCRIPT_PATH}/ubuntu/update_applications.sh"
sed "s:^# DOTFILES_PATH.*$:DOTFILES_PATH=${INSTALL_SCRIPT_PATH}:" "${INSTALL_SCRIPT_PATH}/ubuntu/crontab_ubuntu" | crontab -

# ---------------------------------------------------------
# Set up settings that are common across platforms.
# ---------------------------------------------------------
source "${INSTALL_SCRIPT_PATH}/setup_common.sh" "${INSTALL_SCRIPT_PATH}"
