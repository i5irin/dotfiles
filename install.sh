#!/bin/bash

readonly INSTALL_SCRIPT_PATH=$(cd $(dirname ${BASH_SOURCE}); pwd)

# Load the library functions.
. "${INSTALL_SCRIPT_PATH}/lib.sh"

# Create a symbolic link for the library to be used by dotfiles placed in symbolic links such as .bashrc and .bash_profile.
if [ ! -e '~/lib.sh' ] && [ ! -h '~/lib.sh' ]; then
  ln -is "${INSTALL_SCRIPT_PATH}/lib.sh" ~/lib.sh
fi

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
source "${INSTALL_SCRIPT_PATH}/setup_git.sh" "${INSTALL_SCRIPT_PATH}"

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
