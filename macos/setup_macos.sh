#!/bin/zsh

readonly INSTALL_SCRIPT_PATH=$(cd "$(dirname ${(%):-%N})/../"; pwd)

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

brew bundle --file "${INSTALL_SCRIPT_PATH}/macos/Brewfile"

# ---------------------------------------------------------
# Configure Zsh
# ---------------------------------------------------------

# link .bash_profile and .bashrc
ln -is "${INSTALL_SCRIPT_PATH}/macos/.zprofile" ~/.zprofile
ln -is "${INSTALL_SCRIPT_PATH}/macos/.zshrc" ~/.zshrc

# ---------------------------------------------------------
# Configure macOS preference
# ---------------------------------------------------------

source "${INSTALL_SCRIPT_PATH}/macos/macos-preferences.sh"

# ---------------------------------------------------------
# Configure Karabiner-Elements
# ---------------------------------------------------------

ln -s "${INSTALL_SCRIPT_PATH}/karabiner" ~/.config/karabiner

# ---------------------------------------------------------
# Register periodic tasks.
# ---------------------------------------------------------

# Grant execution permissions to ShellScript executed from cron.
chmod u+x "${INSTALL_SCRIPT_PATH}/macos/update_applications.sh"
# In order to be used with launchd, it must be a real file, not a symbolic link.
cp "${INSTALL_SCRIPT_PATH}/macos/com.i5irin.dotfiles.updateapps.plist" ~/Library/LaunchAgents/com.i5irin.dotfiles.updateapps.plist
launchctl load ~/Library/LaunchAgents/com.i5irin.dotfiles.updateapps.plist

# ---------------------------------------------------------
# Set up settings that are common across platforms.
# ---------------------------------------------------------
source "${INSTALL_SCRIPT_PATH}/setup_common.sh" "${INSTALL_SCRIPT_PATH}"

# ---------------------------------------------------------
# Complete the setup of zsh-completions.
# ---------------------------------------------------------
source ~/.zshrc
chmod go-w '/usr/local/share'
rm -f ~/.zcompdump; compinit
