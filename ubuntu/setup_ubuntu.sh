#!/bin/bash

readonly INSTALL_SCRIPT_PATH=$(cd "$(dirname ${BASH_SOURCE})/../"; pwd)

setup_info() {
  app="$1"
  echo "⬇  Start to install ${app}."
}

configure_info() {
  app="$1"
  echo "⚙️  Start to configure ${app}."
}

complete_setup_info() {
  app="$1"
  # reference https://qiita.com/ko1nksm/items/095bdb8f0eca6d327233#1-echo-%E3%81%A7%E3%81%AF%E3%81%AA%E3%81%8F-printf-%E3%82%92%E4%BD%BF%E3%81%86
  ESC=$(printf '\033')
  echo "${ESC}[32m✔ ${ESC}[m ${app} installation is complete."
}

complete_configure_info() {
  app="$1"
  # reference https://qiita.com/ko1nksm/items/095bdb8f0eca6d327233#1-echo-%E3%81%A7%E3%81%AF%E3%81%AA%E3%81%8F-printf-%E3%82%92%E4%BD%BF%E3%81%86
  ESC=$(printf '\033')
  echo "${ESC}[32m✔ ${ESC}[m ${app} configuration is complete."
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
      complete_setup_info $app
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
      complete_setup_info $app
    else
      failed_info $app
    fi
  done
}

# ---------------------------------------------------------
#  Configure Environment
# ---------------------------------------------------------

mkdir -p ~/bin

# Create a symbolic link for the library to be used by dotfiles placed in symbolic links such as .bashrc and .bash_profile.
if [ ! -e '~/dotfiles/lib/posix_dotfiles_utils/utils.sh' ] && [ ! -h '~/dotfiles/lib/posix_dotfiles_utils/utils.sh' ]; then
  mkdir -p ~/dotfiles/lib/posix_dotfiles_utils && ln -is "${INSTALL_SCRIPT_PATH}/lib/posix_dotfiles_utils/utils.sh" ~/dotfiles/lib/posix_dotfiles_utils/utils.sh
fi

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
# Configure Git
# ---------------------------------------------------------
configure_info 'Git'
/bin/sh "${INSTALL_SCRIPT_PATH}/apps/git/setup_git.sh" "${INSTALL_SCRIPT_PATH}/apps/git"
complete_configure_info 'Git'

# ---------------------------------------------------------
# Install Docker
# ---------------------------------------------------------
setup_info 'Docker'
/bin/sh "${INSTALL_SCRIPT_PATH}/apps/setup_docker_ubuntu.sh"
complete_setup_info 'Docker'

# ---------------------------------------------------------
# Configure Visual Studio Code
# ---------------------------------------------------------
configure_info 'Visual Studio Code'
/bin/sh "${INSTALL_SCRIPT_PATH}/apps/vscode/setup_vscode.sh" "${INSTALL_SCRIPT_PATH}/apps/vscode" "ubuntu"
complete_configure_info 'Visual Studio Code'

# ---------------------------------------------------------
# Install Hyper
# ---------------------------------------------------------
setup_info 'Hyper'
/bin/sh "${INSTALL_SCRIPT_PATH}/apps/hyper/setup_hyper_ubuntu.sh" "${INSTALL_SCRIPT_PATH}/apps/hyper"
complete_setup_info 'Hyper'

# ---------------------------------------------------------
# Install gibo
# ---------------------------------------------------------
setup_info 'gibo'
/bin/sh "${INSTALL_SCRIPT_PATH}/apps/setup_gibo.sh"
complete_setup_info 'gibo'

# ---------------------------------------------------------
# Install Google Chrome
# ---------------------------------------------------------
setup_info 'Google Chrome'
/bin/sh "${INSTALL_SCRIPT_PATH}/apps/setup_chrome_ubuntu.sh"
complete_setup_info 'Google Chrom'

# ---------------------------------------------------------
# Install Zoom
# ---------------------------------------------------------
setup_info 'Zoom'
/bin/sh "${INSTALL_SCRIPT_PATH}/apps/setup_zoom_ubuntu.sh"
complete_setup_info 'Zoom'

# ---------------------------------------------------------
# Install Geekbench
# ---------------------------------------------------------
setup_info 'Geekbench'
/bin/sh "${INSTALL_SCRIPT_PATH}/apps/setup_geekbench_ubuntu.sh"
complete_setup_info 'Geekbench'
