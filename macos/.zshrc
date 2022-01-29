# Load the library functions.
. ~/dotfiles/lib/posix_dotfiles_utils/utils.sh

ZSHRC_MACOS_PATH="$(dirname "$(readlinkf ${(%):-%N})")"

# Ignore case when no candidate is found.
zstyle ':completion:*' matcher-list '' 'm:{[:lower:]}={[:upper:]}' '+m:{[:upper:]}={[:lower:]}'

# configure Zsh completion.
if type brew &>/dev/null; then
  FPATH=$(brew --prefix)/share/zsh-completions:$FPATH
  autoload -Uz compinit
  compinit
fi

# Terminal coloring, displaying Git information and reducing directory information.
if [ -f "${ZSHRC_MACOS_PATH}/../lib/vendor/git-prompt.sh" ]; then
  source "${ZSHRC_MACOS_PATH}/../lib/vendor/git-prompt.sh"
  GIT_PS1_SHOWDIRTYSTATE=1
  GIT_PS1_SHOWUPSTREAM=1
  GIT_PS1_SHOWUNTRACKEDFILES=1
  GIT_PS1_SHOWSTASHSTATE=1
  PROMPT="%B%F{green}%n@%m%f%b:%B%F{blue}%(5~|%-1~/…/%3~|%4~)%f%F{red}$(__git_ps1)%f%b $ "
else
  PROMPT='%B%F{green}%n@%m%f%b:%B%F{blue}%(5~|%-1~/…/%3~|%4~)%f%b $ '
fi

# For lesspipe installed by brew.
# Make less more friendly for non-text input files, see lesspipe(1)
if [ -x /usr/local/bin/lesspipe.sh ]; then
  eval "$(SHELL=/bin/sh lesspipe.sh)"
fi

# Load the functions definition.
. "${ZSHRC_MACOS_PATH}/../alias/functions.sh"
