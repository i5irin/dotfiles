#!/bin/bash

readonly INSTALL_SCRIPT_PATH=$(cd $(dirname ${BASH_SOURCE}); pwd)

# ---------------------------------------------------------
# Ask username and email for git config
# ---------------------------------------------------------

while true; do
  read -p 'Enter your name for use in git > ' GIT_USER_NAME
  read -p 'Enter your email address for use in git > ' GIT_USER_EMAIL
  while true; do
    read -p "Make sure name($GIT_USER_NAME) and email($GIT_USER_EMAIL) you input, is this ok? [Y/n] > " YN
    case $YN in
      [YNn] ) break;;
      * ) echo '[Y/n]'
    esac
  done
  case $YN in
    [Y] ) break;;
  esac
done

# ---------------------------------------------------------
# Install Xcode CommandLineTool
# ---------------------------------------------------------

xcode-select --install

# ---------------------------------------------------------
# Configure Homebrew
# ---------------------------------------------------------

/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
brew doctor
brew update
brew install mas

# ---------------------------------------------------------
# Install applications
# ---------------------------------------------------------

brew bundle

# ---------------------------------------------------------
# Configure Bash
# ---------------------------------------------------------

# link .bash_profile and .bashrc
ln -is "${INSTALL_SCRIPT_PATH}/.bash_profile" ~/.bash_profile
ln -is "${INSTALL_SCRIPT_PATH}/.bashrc" ~/.bashrc

# link readline config
ln -s "${INSTALL_SCRIPT_PATH}/.inputrc" ~/.inputrc

# ---------------------------------------------------------
# Configure Git
# ---------------------------------------------------------

git config --global --add include.path "${INSTALL_SCRIPT_PATH}/.gitconfig"
git config --global user.name $GIT_USER_NAME
git config --global user.email $GIT_USER_EMAIL

# ---------------------------------------------------------
# Configure macOS preference
# ---------------------------------------------------------

source "${INSTALL_SCRIPT_PATH}/macos/macos-preferences.sh"

# ---------------------------------------------------------
# Configure Visual Studio Code
# ---------------------------------------------------------

source "${INSTALL_SCRIPT_PATH}/vscode/vscode-setup.sh"

# ---------------------------------------------------------
# Configure Alacritty (terminal emulator)
# ---------------------------------------------------------

ln -is "${INSTALL_SCRIPT_PATH}/alacritty" ~/.config/alacritty

# ---------------------------------------------------------
# Configure Karabiner-Elements
# ---------------------------------------------------------

ln -s "${INSTALL_SCRIPT_PATH}/karabiner" ~/.config/karabiner

# ---------------------------------------------------------
# Register periodic tasks.
# ---------------------------------------------------------

# Grant execution permissions to ShellScript executed from cron.
chmod u+x "${INSTALL_SCRIPT_PATH}/macos/update_brew.sh"
sed "s:^# DOTFILES_PATH.*$:DOTFILES_PATH=${INSTALL_SCRIPT_PATH}:" crontab | crontab -
