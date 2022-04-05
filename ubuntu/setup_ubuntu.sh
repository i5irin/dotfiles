#!/bin/bash

readonly INSTALL_SCRIPT_PATH=$(cd "$(dirname ${BASH_SOURCE})/../"; pwd)

setup_info() {
  app="$1"
  echo "⬇  Start to install ${app}."
}

complete_info() {
  app="$1"
  # reference https://qiita.com/ko1nksm/items/095bdb8f0eca6d327233#1-echo-%E3%81%A7%E3%81%AF%E3%81%AA%E3%81%8F-printf-%E3%82%92%E4%BD%BF%E3%81%86
  ESC=$(printf '\033')
  echo "${ESC}[32m✔ ${ESC}[m ${app} installation is complete."
}

failed_info() {
  app="$1"
  ESC=$(printf '\033')
  echo "${ESC}[31m💔${ESC}[m Something went wrong during the installation of ${app}."
}

bulk_install_apt() {
  while read app
  do
    setup_info $app
    sudo apt-get install -qq -y $app > /dev/null
    if [ "$?" = 0 ]; then
      complete_info $app
    else
      failed_info $app
    fi
  done
}

bulk_install_snap() {
  while read app
  do
    setup_info $app
    sudo snap install $app > /dev/null
    if [ "$?" = 0 ]; then
      complete_info $app
    else
      failed_info $app
    fi
  done
}

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
cd ~/.fonts/ && curl -LsS \
  -O 'https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/FiraCode/Bold/complete/Fira Code Bold Nerd Font Complete.ttf' \
  -O 'https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/FiraCode/Light/complete/Fira Code Light Nerd Font Complete.ttf' \
  -O 'https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/FiraCode/Medium/complete/Fira Code Medium Nerd Font Complete.ttf' \
  -O 'https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/FiraCode/Regular/complete/Fira Code Regular Nerd Font Complete.ttf' \
  -O 'https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/FiraCode/Retina/complete/Fira Code Retina Nerd Font Complete.ttf' \
  -O 'https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/FiraCode/SemiBold/complete/Fira Code SemiBold Nerd Font Complete.ttf'
fc-cache -fv > /dev/null
# Install Starship
curl -fsSL https://starship.rs/install.sh | sh /dev/stdin -y > /dev/null

# ---------------------------------------------------------
# Install applications
# ---------------------------------------------------------

sudo apt-get -qq update
sudo apt-get -qq upgrade -y > /dev/null

# Install gdebi to install deb package application with resolving dependencies.
sudo apt-get -qq install -y gdebi > /dev/null

# Install Snap package management system.
sudo apt-get -qq install -y snapd > /dev/null

# ---------------------------------------------------------
# Install applications
# ---------------------------------------------------------

# Update the application to be installed according to the user's apt_installs.txt if it exists.
if [ -f "${INSTALL_SCRIPT_PATH}/ubuntu/my_apt_installs.txt" ]; then
  sort "${INSTALL_SCRIPT_PATH}/ubuntu/apt_installs.txt" "${INSTALL_SCRIPT_PATH}/ubuntu/my_apt_installs.txt" \
    | uniq -u | sed 's/^#.*//g' | sed '/^$/d' | bulk_install_apt
else
  cat "${INSTALL_SCRIPT_PATH}/ubuntu/apt_installs.txt" | bulk_install_apt
fi

# TODO: Support installations that require the classic option, such as slack and code.
cat "${INSTALL_SCRIPT_PATH}/ubuntu/snap.txt" | bulk_install_snap

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
