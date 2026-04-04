#!/bin/zsh

set -eu

readonly INSTALL_SCRIPT_PATH="${DOTFILES_REPO_ROOT:-$(cd "$(dirname ${(%):-%N})/../"; pwd)}"
readonly HOMEBREW_PREFIX="${DOTFILES_HOMEBREW_PREFIX:-/opt/homebrew}"
readonly DOTFILES_DATA_HOME="${DOTFILES_DATA_HOME:-${XDG_DATA_HOME:-${HOME}/.local/share}/dotfiles}"
readonly ZSH_COMPLETIONS_DIR="${DOTFILES_ZSH_COMPLETIONS_DIR:-${DOTFILES_DATA_HOME}/zsh-completions}"
readonly PACKAGE_COMPOSE_HELPER="${INSTALL_SCRIPT_PATH}/macos/packages/compose_brewfile.sh"
readonly LAUNCH_AGENT_LABEL="com.i5irin.dotfiles.updateapps"
readonly LAUNCH_AGENT_PATH="${HOME}/Library/LaunchAgents/${LAUNCH_AGENT_LABEL}.plist"
readonly DOTFILES_LOG_DIR="${HOME}/Library/Logs/dotfiles"
readonly DOTFILES_LOG_PATH="${DOTFILES_LOG_DIR}/application_update.log"

if [ -n "${DOTFILES_BREWFILE:-}" ]; then
  readonly BREWFILE_PATH="${DOTFILES_BREWFILE}"
elif [ -x "${PACKAGE_COMPOSE_HELPER}" ]; then
  BREWFILE_TEMP_PATH="$(mktemp "${TMPDIR:-/tmp}/dotfiles-macos-brewfile.XXXXXX")"
  readonly BREWFILE_TEMP_PATH
  "${PACKAGE_COMPOSE_HELPER}" --output "${BREWFILE_TEMP_PATH}"
  readonly BREWFILE_PATH="${BREWFILE_TEMP_PATH}"
elif [ -f "${INSTALL_SCRIPT_PATH}/macos/Brewfile" ]; then
  readonly BREWFILE_PATH="${INSTALL_SCRIPT_PATH}/macos/Brewfile"
else
  readonly BREWFILE_PATH="${INSTALL_SCRIPT_PATH}/macos/Brewfile.sample"
fi

cleanup() {
  if [ -n "${BREWFILE_TEMP_PATH:-}" ] && [ -f "${BREWFILE_TEMP_PATH}" ]; then
    rm -f "${BREWFILE_TEMP_PATH}"
  fi
}

trap cleanup EXIT

# Load the library functions.
source "${INSTALL_SCRIPT_PATH}/lib/posix_dotfiles_utils/utils.sh"
source "${INSTALL_SCRIPT_PATH}/lib/shell/message.sh"

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

# link .zprofile and .zshrc
ln -is "${INSTALL_SCRIPT_PATH}/macos/.zprofile" ~/.zprofile
ln -is "${INSTALL_SCRIPT_PATH}/macos/.zshrc" ~/.zshrc

setup_info 'zsh-completions'
if [ -d "${ZSH_COMPLETIONS_DIR}" ]; then
  echo "Skip installation because \"${ZSH_COMPLETIONS_DIR}\" already existed."
else
  mkdir -p "${DOTFILES_DATA_HOME}"
  git clone https://github.com/zsh-users/zsh-completions.git "${ZSH_COMPLETIONS_DIR}"
  set +eu
  source ~/.zshrc
  set -eu
  rm -f ~/.zcompdump; compinit
  complete_setup_info 'zsh-completions command line tools'
fi

# Install Nerd Font
setup_info 'Nerd Font'
cd ~/Library/Fonts && curl -LsS \
  -O 'https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/FiraCode/Bold/complete/Fira Code Bold Nerd Font Complete.ttf' \
  -O 'https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/FiraCode/Light/complete/Fira Code Light Nerd Font Complete.ttf' \
  -O 'https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/FiraCode/Medium/complete/Fira Code Medium Nerd Font Complete.ttf' \
  -O 'https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/FiraCode/Regular/complete/Fira Code Regular Nerd Font Complete.ttf' \
  -O 'https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/FiraCode/Retina/complete/Fira Code Retina Nerd Font Complete.ttf' \
  -O 'https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/FiraCode/SemiBold/complete/Fira Code SemiBold Nerd Font Complete.ttf'
complete_setup_info 'Nerd Font'

# Install Starship
setup_info 'Starship'
sh -c "$(curl -fsSL https://starship.rs/install.sh)"
complete_setup_info 'Starship'

# ---------------------------------------------------------
# X86 applications settings (Apple silicon Mac only)
# TODO: Display current architecture (x86_64 or arm64e) on tmux status bar
# ---------------------------------------------------------

if [ "$(uname -m)" = "arm64" ]; then
  setup_info 'Rosetta'
  softwareupdate --install-rosetta --agree-to-license
  complete_setup_info 'Rosetta'
fi

# ---------------------------------------------------------
# Configure Homebrew
# ---------------------------------------------------------

# Xcodeがインストールされていたら実行する（２度目以降にXcodeがあるとき対策）agree
sudo xcodebuild -license

/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
set +eu
if [ -x "${HOMEBREW_PREFIX}/bin/brew" ]; then
  eval "$("${HOMEBREW_PREFIX}/bin/brew" shellenv)"
fi
source ~/.zshrc
set -eu
brew doctor
brew update
brew install mas

# ---------------------------------------------------------
# Install applications
# ---------------------------------------------------------

brew bundle --file "${BREWFILE_PATH}"

# ---------------------------------------------------------
# Configure macOS preference
# ---------------------------------------------------------
echo 'debug1'
echo 'Configure macOS preference'
/bin/sh "${INSTALL_SCRIPT_PATH}/macos/preference_macos.sh"
echo 'debug2'
# ---------------------------------------------------------
# Register periodic tasks.
# ---------------------------------------------------------

echo 'Configure pediodic tasks'
# Grant execution permissions to ShellScript executed from cron.
chmod u+x "${INSTALL_SCRIPT_PATH}/macos/update_applications.sh"
# In order to be used with launchd, it must be a real file, not a symbolic link.
mkdir -p "${HOME}/Library/LaunchAgents" "${DOTFILES_LOG_DIR}"
sed \
  -e "s|__DOTFILES_REPO_ROOT__|${INSTALL_SCRIPT_PATH}|g" \
  -e "s|__DOTFILES_HOMEBREW_PREFIX__|${HOMEBREW_PREFIX}|g" \
  -e "s|__DOTFILES_LOG_PATH__|${DOTFILES_LOG_PATH}|g" \
  "${INSTALL_SCRIPT_PATH}/macos/com.i5irin.dotfiles.updateapps.plist" \
  > "${LAUNCH_AGENT_PATH}"
launchctl bootout "gui/$(id -u)" "${LAUNCH_AGENT_PATH}" > /dev/null 2>&1 || true
launchctl bootstrap "gui/$(id -u)" "${LAUNCH_AGENT_PATH}"

# ---------------------------------------------------------
#  Configure applications
# ---------------------------------------------------------

# Configure Karabiner-Elements
configure_info 'Karabiner-Elements'
if [ -d /Applications/Karabiner-Elements.app ]; then
  mkdir -p ~/.config/karabiner && ln -fs "${INSTALL_SCRIPT_PATH}/apps/karabiner" ~/.config/karabiner
  finish_configure_message 'Karabiner-Elements'
else
  echo 'Skip setup because Karabiner-Elements is not installed.' >&2
fi
# Configure Git
configure_info 'Git'
git version > /dev/null 2>&1
if [ $? -ne 0 ]; then
  echo 'Skip setup because Git is not installed.' >&2
Elements
  /bin/zsh "${INSTALL_SCRIPT_PATH}/apps/git/setup_git_macos.sh" "${INSTALL_SCRIPT_PATH}/apps/git"
  finish_configure_message 'Git'
fi
# Configure tmux
configure_info 'tmux'
tmux -V > /dev/null 2>&1
if [ $? -ne 0 ]; then
  echo 'Skip setup because tmux is not installed.' >&2
else
  /bin/sh "${INSTALL_SCRIPT_PATH}/apps/tmux/setup_tmux.sh" "${INSTALL_SCRIPT_PATH}/apps/tmux"
  finish_configure_message 'tmux'
fi
# Configure Visual Studio Code
configure_info 'Visual Studio Code'
code --version > /dev/null 2>&1
if [ $? -ne 0 ]; then
  echo 'Skip setup because Visual Studio Code is not installed.' >&2
else
  /bin/sh "${INSTALL_SCRIPT_PATH}/apps/vscode/setup_vscode.sh" "${INSTALL_SCRIPT_PATH}/apps/vscode" "macos"
  finish_configure_message 'Visual Studio Code'
fi
# Configure Hyper.js
configure_info 'Hyper.js'
hyper version > /dev/null 2>&1
if [ $? -ne 0 ]; then
  echo 'Skip setup because Hyper.js is not installed.' >&2
else
  /bin/sh "${INSTALL_SCRIPT_PATH}/apps/hyper/setup_hyper_mac.sh" "${INSTALL_SCRIPT_PATH}/apps/hyper"
  finish_configure_message 'Hyper.js'
fi
# Configure AltTab
configure_info 'AltTab'
if [ -d /Applications/AltTab.app ]; then
  /bin/sh "${INSTALL_SCRIPT_PATH}/apps/setup_alttab.sh"
  finish_configure_message 'AltTab'
else
  echo 'Skip setup because AltTab is not installed.' >&2
fi
# Configure Clipy
configure_info 'Clipy'
if [ -d /Applications/Clipy.app ]; then
  /bin/sh "${INSTALL_SCRIPT_PATH}/apps/setup_clipy.sh"
  finish_configure_message 'Clipy'
else
  echo 'Skip setup because Clipy is not installed.' >&2
fi
