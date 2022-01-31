#!/bin/zsh

readonly INSTALL_SCRIPT_PATH=$(cd "$(dirname ${(%):-%N})/../"; pwd)

# ---------------------------------------------------------
# Configure Zsh
# ---------------------------------------------------------

# link .zprofile and .zshrc
ln -is "${INSTALL_SCRIPT_PATH}/macos/.zprofile" ~/.zprofile
ln -is "${INSTALL_SCRIPT_PATH}/macos/.zshrc" ~/.zshrc

# ---------------------------------------------------------
# Install Xcode CommandLineTool
# ---------------------------------------------------------

xcode-select --install

# ---------------------------------------------------------
# X86 applications settings (Apple silicon Mac only)
# TODO: Display current architecture (x86_64 or arm64e) on tmux status bar
# ---------------------------------------------------------

if [ "$(uname -m)" = "arm64" ]; then
  softwareupdate --install-rosetta --agree-to-license
fi

# ---------------------------------------------------------
# Configure Homebrew
# ---------------------------------------------------------

/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
source ~/.zshrc
brew doctor
brew update
brew install mas

# ---------------------------------------------------------
# Install applications
# ---------------------------------------------------------

brew bundle --file "${INSTALL_SCRIPT_PATH}/macos/Brewfile"

# ---------------------------------------------------------
# Configure macOS preference
# ---------------------------------------------------------

source "${INSTALL_SCRIPT_PATH}/macos/macos-preferences.sh"

# ---------------------------------------------------------
# Configure Karabiner-Elements
# ---------------------------------------------------------

mkdir -p ~/.config/karabiner && ln -s "${INSTALL_SCRIPT_PATH}/karabiner" ~/.config/karabiner

# ---------------------------------------------------------
# Register periodic tasks.
# ---------------------------------------------------------

# Grant execution permissions to ShellScript executed from cron.
chmod u+x "${INSTALL_SCRIPT_PATH}/macos/update_applications.sh"
# In order to be used with launchd, it must be a real file, not a symbolic link.
mkdir -p ~/Library/LaunchAgents && cp "${INSTALL_SCRIPT_PATH}/macos/com.i5irin.dotfiles.updateapps.plist" ~/Library/LaunchAgents/com.i5irin.dotfiles.updateapps.plist
launchctl load ~/Library/LaunchAgents/com.i5irin.dotfiles.updateapps.plist

# ---------------------------------------------------------
# Set up settings that are common across platforms.
# ---------------------------------------------------------
source "${INSTALL_SCRIPT_PATH}/setup_common.sh" "${INSTALL_SCRIPT_PATH}"

# ---------------------------------------------------------
# Setup zsh-completions.
# ---------------------------------------------------------
git clone git://github.com/zsh-users/zsh-completions.git
source ~/.zshrc
rm -f ~/.zcompdump; compinit

# ---------------------------------------------------------
#  Configure applications
# ---------------------------------------------------------

# Configure AltTab
/bin/sh "${DOTFILES_PATH}/apps/setup_alttab.sh"
# Configure Clipy
/bin/sh "${DOTFILES_PATH}/apps/setup_clipy.sh"

