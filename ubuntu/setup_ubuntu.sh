#!/bin/bash

readonly INSTALL_SCRIPT_PATH=$(cd "$(dirname ${BASH_SOURCE})/../"; pwd)

# ---------------------------------------------------------
#  Configure Environment
# ---------------------------------------------------------

mkdir -p ~/bin

# ---------------------------------------------------------
# Configure Bash
# ---------------------------------------------------------

# link .bash_profile and .bashrc
ln -is "${INSTALL_SCRIPT_PATH}/ubuntu/.bash_profile" ~/.bash_profile
ln -is "${INSTALL_SCRIPT_PATH}/ubuntu/.bashrc" ~/.bashrc
# link readline config
ln -is "${DOTFILES_PATH}/.inputrc" ~/.inputrc

# Install Nerd Font
mkdir -p ~/.fonts/
cd ~/.fonts/ && curl -L \
  -O 'https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/FiraCode/Bold/complete/Fira Code Bold Nerd Font Complete.ttf' \
  -O 'https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/FiraCode/Light/complete/Fira Code Light Nerd Font Complete.ttf' \
  -O 'https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/FiraCode/Medium/complete/Fira Code Medium Nerd Font Complete.ttf' \
  -O 'https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/FiraCode/Regular/complete/Fira Code Regular Nerd Font Complete.ttf' \
  -O 'https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/FiraCode/Retina/complete/Fira Code Retina Nerd Font Complete.ttf' \
  -O 'https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/FiraCode/SemiBold/complete/Fira Code SemiBold Nerd Font Complete.ttf'
fc-cache -fv
# Install Starship
sh -c "$(curl -fsSL https://starship.rs/install.sh)"

# ---------------------------------------------------------
# Install applications
# ---------------------------------------------------------

sudo apt-get -qq update
sudo apt-get -qq upgrade -y

# Install gdebi to install deb package application with resolving dependencies.
sudo apt-get -qq install -y gdebi

# Install Snap package management system.
sudo apt-get -qq install -y snapd

# ---------------------------------------------------------
# Install applications
# ---------------------------------------------------------

# Update the application to be installed according to the user's apt_installs.txt if it exists.
if [ -f "${INSTALL_SCRIPT_PATH}/ubuntu/my_apt_installs.txt" ]; then
  sort "${INSTALL_SCRIPT_PATH}/ubuntu/apt_installs.txt" "${INSTALL_SCRIPT_PATH}/ubuntu/my_apt_installs.txt" \
    | uniq -u | sed 's/^#.*//g' | sed '/^$/d' | sudo xargs apt-get -qq install -y
else
  sudo xargs apt-get -qq install -y < "${INSTALL_SCRIPT_PATH}/ubuntu/apt_installs.txt"
fi

# TODO: Support installations that require the classic option, such as slack and code.
xargs snap install < "${INSTALL_SCRIPT_PATH}/ubuntu/snap.txt"

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

# ---------------------------------------------------------
# Configure Git
# ---------------------------------------------------------
/bin/sh "${INSTALL_SCRIPT_PATH}/apps/git/setup_git.sh" "${INSTALL_SCRIPT_PATH}/apps/git"

# ---------------------------------------------------------
# Install Docker
# ---------------------------------------------------------
which docker 2> /dev/null
if [ "$?" -ne 0 ]; then
  /bin/sh "${INSTALL_SCRIPT_PATH}/apps/setup_gibo.sh" "${INSTALL_SCRIPT_PATH}/apps/git"
fi

# ---------------------------------------------------------
# Install Hyper
# ---------------------------------------------------------
/bin/sh "${INSTALL_SCRIPT_PATH}/apps/hyper/setup_hyper_ubuntu.sh" "${INSTALL_SCRIPT_PATH}/apps/hyper"

# ---------------------------------------------------------
# Install gibo
# ---------------------------------------------------------
/bin/sh "${INSTALL_SCRIPT_PATH}/apps/setup_gibo.sh" "${INSTALL_SCRIPT_PATH}/apps/git"

# ---------------------------------------------------------
# Install Google Chrome
# ---------------------------------------------------------
/bin/sh "${INSTALL_SCRIPT_PATH}/apps/setup_chrome_ubuntu.sh"

# ---------------------------------------------------------
# Install Zoom
# ---------------------------------------------------------
/bin/sh "${INSTALL_SCRIPT_PATH}/apps/setup_zoom_ubuntu.sh"

# ---------------------------------------------------------
# Install Geekbench
# ---------------------------------------------------------
/bin/sh "${INSTALL_SCRIPT_PATH}/apps/setup_geekbench_ubuntu.sh"
