#!/bin/bash

set -eu
DOTFILES_PATH=$1

# Create a symbolic link for the library to be used by dotfiles placed in symbolic links such as .bashrc and .bash_profile.
if [ ! -e '~/dotfiles/lib/posix_dotfiles_utils/utils.sh' ] && [ ! -h '~/dotfiles/lib/posix_dotfiles_utils/utils.sh' ]; then
  mkdir ~/dotfiles/lib/posix_dotfiles_utils && ln -is "${DOTFILES_PATH}/lib/posix_dotfiles_utils/utils.sh" ~/dotfiles/lib/posix_dotfiles_utils/utils.sh
fi

# ---------------------------------------------------------
# Configure Git
# ---------------------------------------------------------
/bin/sh "${DOTFILES_PATH}/git/setup_git.sh" "${DOTFILES_PATH}/git"

# ---------------------------------------------------------
# Configure Visual Studio Code
# ---------------------------------------------------------

source "${DOTFILES_PATH}/vscode/vscode-setup.sh"

# ---------------------------------------------------------
# Configure Alacritty (terminal emulator)
# ---------------------------------------------------------

mkdir -p ~/.config && ln -is "${DOTFILES_PATH}/alacritty" ~/.config/alacritty
