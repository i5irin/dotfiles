# Resolve the dotfiles location from the symlinked shell file itself.
ZPROFILE_MACOS_PATH="${${(%):-%N}:A:h}"
DOTFILES_REPO_ROOT="${ZPROFILE_MACOS_PATH:h:h}"

# Load the library functions.
. "${DOTFILES_REPO_ROOT}/lib/posix_dotfiles_utils/utils.sh"

# ---------------------------------------------------------
# Configure environment variables
# ---------------------------------------------------------

# Configure PATH
# set PATH so it includes user's private bin if it exists. (from Ubuntu's ~/.profile)
add_path "$HOME/bin" 2> /dev/null
# set PATH so it includes user's private bin if it exists. (from Ubuntu's ~/.profile)
add_path "$HOME/.local/bin" 2> /dev/null

# Set the default options for less.
export LESS='-iMR'
