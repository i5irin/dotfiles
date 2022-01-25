#!/bin/bash

set -eu
DOTFILES_PATH=$0

# Create a symbolic link for the library to be used by dotfiles placed in symbolic links such as .bashrc and .bash_profile.
if [ ! -e '~/dotfiles/lib/posix_dotfiles_utils/utils.sh' ] && [ ! -h '~/dotfiles/lib/posix_dotfiles_utils/utils.sh' ]; then
  mkdir ~/dotfiles/lib/posix_dotfiles_utils && ln -is "${DOTFILES_PATH}/lib/posix_dotfiles_utils/utils.sh" ~/dotfiles/lib/posix_dotfiles_utils/utils.sh
fi

# link readline config
ln -s "${DOTFILES_PATH}/.inputrc" ~/.inputrc

# ---------------------------------------------------------
# Configure Git
# ---------------------------------------------------------
source "${DOTFILES_PATH}/setup_git.sh" "${DOTFILES_PATH}"

# ---------------------------------------------------------
# Configure Visual Studio Code
# ---------------------------------------------------------

source "${DOTFILES_PATH}/vscode/vscode-setup.sh"

# ---------------------------------------------------------
# Configure Alacritty (terminal emulator)
# ---------------------------------------------------------

ln -is "${DOTFILES_PATH}/alacritty" ~/.config/alacritty
