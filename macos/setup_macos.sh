#!/bin/zsh

readonly INSTALL_SCRIPT_PATH=$(cd "$(dirname ${(%):-%N})/../"; pwd)

# Load the library functions.
source "${INSTALL_SCRIPT_PATH}/lib/posix_dotfiles_utils/utils.sh"

# ---------------------------------------------------------
# Configure Mac hostnames
# ---------------------------------------------------------

while true; do
  echo 'Name your machine. (LocalHostName and ComputerName)\nThis is used by Bonjour and AppleTalk.'
  echo -n '> '
  read mac_machine_name
  if ! validate_rfc952_hostname $mac_machine_name; then
    continue;
  fi
  while true; do
    echo -n "Make sure machine name($mac_machine_name) you input, is this ok? [Y/n] > "
    read YN
    case $YN in
      [YNn] ) break;;
      * ) echo '[Y/n]'
    esac
  done
  case $YN in
    [Y] ) break;;
  esac
done

echo 'Setting up ComputerName.'
scutil --set ComputerName $mac_machine_name
if [ $? = 0 ]; then
  echo 'completed!'
else
  echo "Failed. Try \`scutil --set ComputerName ${mac_machine_name}\` later."
fi
echo 'Setting up LocalHostName.'
scutil --set LocalHostName $mac_machine_name
if [ $? = 0 ]; then
  echo 'completed!'
else
  echo "Failed. Try \`scutil --set LocalHostName ${mac_machine_name}\` later."
fi
echo 'Setting up HostName.'
scutil --set HostName $mac_machine_name
if [ $? = 0 ]; then
  echo 'completed!'
else
  echo "Failed. Try \`scutil --set HostName ${mac_machine_name}\` later."
fi

# ---------------------------------------------------------
# Configure Zsh
# ---------------------------------------------------------

# Create a symbolic link for the library to be used by dotfiles placed in symbolic links such as .bashrc and .bash_profile.
if [ ! -e '~/dotfiles/lib/posix_dotfiles_utils/utils.sh' ] && [ ! -h '~/dotfiles/lib/posix_dotfiles_utils/utils.sh' ]; then
  mkdir -p ~/dotfiles/lib/posix_dotfiles_utils && ln -is "${DOTFILES_PATH}/lib/posix_dotfiles_utils/utils.sh" ~/dotfiles/lib/posix_dotfiles_utils/utils.sh
fi

# link .zprofile and .zshrc
ln -is "${INSTALL_SCRIPT_PATH}/macos/.zprofile" ~/.zprofile
ln -is "${INSTALL_SCRIPT_PATH}/macos/.zshrc" ~/.zshrc

# Setup zsh-completions.
echo 'Install zsh-completions'
if [ -d /usr/local/bin/zsh-completions ]; then
  echo 'Skip installation because "/usr/local/bin/zsh-completions" already existed.'
else
  git clone git://github.com/zsh-users/zsh-completions.git /usr/local/bin/zsh-completions
  source ~/.zshrc
  rm -f ~/.zcompdump; compinit
fi

echo 'Install Nerd Font'
# Install Nerd Font
cd ~/Library/Fonts && curl -LsS \
  -O 'https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/FiraCode/Bold/complete/Fira Code Bold Nerd Font Complete.ttf' \
  -O 'https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/FiraCode/Light/complete/Fira Code Light Nerd Font Complete.ttf' \
  -O 'https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/FiraCode/Medium/complete/Fira Code Medium Nerd Font Complete.ttf' \
  -O 'https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/FiraCode/Regular/complete/Fira Code Regular Nerd Font Complete.ttf' \
  -O 'https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/FiraCode/Retina/complete/Fira Code Retina Nerd Font Complete.ttf' \
  -O 'https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/FiraCode/SemiBold/complete/Fira Code SemiBold Nerd Font Complete.ttf'
# Install Starship
sh -c "$(curl -fsSL https://starship.rs/install.sh)"

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

# Update the application to be installed according to the user's Brewfile if it exists.
if [ -f "${INSTALL_SCRIPT_PATH}/macos/MyBrewfile" ]; then
  sort "${INSTALL_SCRIPT_PATH}/macos/Brewfile" "${INSTALL_SCRIPT_PATH}/macos/MyBrewfile" \
    | uniq -u | sort_brewfile | brew bundle --file -
else
  brew bundle --file "${INSTALL_SCRIPT_PATH}/macos/Brewfile"
fi

# ---------------------------------------------------------
# Configure macOS preference
# ---------------------------------------------------------

source "${INSTALL_SCRIPT_PATH}/macos/macos-preferences.sh"

# ---------------------------------------------------------
# Configure Karabiner-Elements
# ---------------------------------------------------------

mkdir -p ~/.config/karabiner && ln -s "${INSTALL_SCRIPT_PATH}/apps/karabiner" ~/.config/karabiner

# ---------------------------------------------------------
# Register periodic tasks.
# ---------------------------------------------------------

# Grant execution permissions to ShellScript executed from cron.
chmod u+x "${INSTALL_SCRIPT_PATH}/macos/update_applications.sh"
# In order to be used with launchd, it must be a real file, not a symbolic link.
mkdir -p ~/Library/LaunchAgents && cp "${INSTALL_SCRIPT_PATH}/macos/com.i5irin.dotfiles.updateapps.plist" ~/Library/LaunchAgents/com.i5irin.dotfiles.updateapps.plist
launchctl load ~/Library/LaunchAgents/com.i5irin.dotfiles.updateapps.plist

# ---------------------------------------------------------
# Configure Git
# ---------------------------------------------------------
/bin/zsh "${INSTALL_SCRIPT_PATH}/apps/git/setup_git_macos.sh" "${INSTALL_SCRIPT_PATH}/apps/git"

# ---------------------------------------------------------
# Configure Visual Studio Code
# ---------------------------------------------------------
configure_info 'Visual Studio Code'
code --version > /dev/null 2>&1
if [ $? -ne 0 ]; then
  echo 'Skip setup because Visual Studio Code is not installed.' >&2
else
  /bin/sh "${INSTALL_SCRIPT_PATH}/apps/vscode/setup_vscode.sh" "${INSTALL_SCRIPT_PATH}/apps/vscode" "macos"
  finish_configure_message 'Visual Studio Code'
fi

# ---------------------------------------------------------
#  Configure applications
# ---------------------------------------------------------

# Configure Hyper.js
/bin/sh "${INSTALL_SCRIPT_PATH}/apps/hyper/setup_hyper.sh" "${INSTALL_SCRIPT_PATH}/apps/hyper"
# Configure AltTab
/bin/sh "${DOTFILES_PATH}/apps/setup_alttab.sh"
# Configure Clipy
/bin/sh "${DOTFILES_PATH}/apps/setup_clipy.sh"

