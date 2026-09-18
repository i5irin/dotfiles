# Resolve the dotfiles location from the symlinked shell file itself.
ZPROFILE_MODULE_PATH="${${(%):-%N}:A:h}"
DOTFILES_REPO_ROOT="${ZPROFILE_MODULE_PATH:h:h:h}"

# Load the library functions.
. "${DOTFILES_REPO_ROOT}/modules/shared/utils/posix.sh"

HOMEBREW_PREFIX="${DOTFILES_HOMEBREW_PREFIX:-/opt/homebrew}"

# Configure PATH
add_path "${HOME}/bin" 2> /dev/null
add_path "${HOME}/.local/bin" 2> /dev/null
add_path "${HOME}/go/bin" 2> /dev/null
add_path "${HOMEBREW_PREFIX}/opt/rustup/bin" 2> /dev/null

# Set the default options for less.
export LESS='-iMR'
