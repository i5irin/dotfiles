# Resolve the dotfiles location from the symlinked shell file itself.
DOTFILES_BASH_PROFILE_SOURCE_PATH="${BASH_SOURCE[0]}"
if command -v readlink > /dev/null 2>&1; then
  DOTFILES_BASH_PROFILE_SOURCE_PATH="$(readlink -f "${DOTFILES_BASH_PROFILE_SOURCE_PATH}" 2>/dev/null || printf '%s' "${DOTFILES_BASH_PROFILE_SOURCE_PATH}")"
fi
DOTFILES_BASH_PROFILE_PATH="$(CDPATH='' cd -- "$(dirname -- "${DOTFILES_BASH_PROFILE_SOURCE_PATH}")" && pwd)"
DOTFILES_REPO_ROOT="$(CDPATH='' cd -- "${DOTFILES_BASH_PROFILE_PATH}/../../.." && pwd)"

# Load shared shell utilities.
. "${DOTFILES_REPO_ROOT}/modules/shared/utils/posix.sh"

# Configure PATH.
add_path "${HOME}/bin" 2> /dev/null || true
add_path "${HOME}/.local/bin" 2> /dev/null || true

# Load .bashrc when it exists.
if [ -f "${HOME}/.bashrc" ]; then
  . "${HOME}/.bashrc"
fi

export PROMPT_DIRTRIM=4
export LESS='-iMR'

# Apply syntax highlighting to less when source-highlight is available.
if [ -x /usr/share/source-highlight/src-hilite-lesspipe.sh ]; then
  export LESSOPEN='| /usr/share/source-highlight/src-hilite-lesspipe.sh %s'
fi
