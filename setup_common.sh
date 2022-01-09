#!/bin/bash

set -eu
DOTFILES_PATH=$0

# Create a symbolic link for the library to be used by dotfiles placed in symbolic links such as .bashrc and .bash_profile.
if [ ! -e '~/lib.sh' ] && [ ! -h '~/lib.sh' ]; then
  ln -is "${DOTFILES_PATH}/lib.sh" ~/lib.sh
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
