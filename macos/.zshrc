# Load the library functions.
. ~/dotfiles/lib/posix_dotfiles_utils/utils.sh

ZSHRC_MACOS_PATH="$(dirname "$(readlinkf ${(%):-%N})")"

# Ignore case when no candidate is found.
zstyle ':completion:*' matcher-list '' 'm:{[:lower:]}={[:upper:]}' '+m:{[:upper:]}={[:lower:]}'

# Don't let Zsh save meanless command history.
setopt hist_reduce_blanks
setopt hist_ignore_all_dups

# Share command history between Zsh.
setopt share_history

# Make it possible to refer apps installed by Homebrew by name for each Mac architecture.
if [ "$(uname -m)" = "arm64" ] && [ -e /opt/homebrew/bin/brew ]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [ "$(uname -m)" = "x86_64" ] && [ -e /usr/local/bin/brew ]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi

# configure Zsh completion.
if [ -d /usr/local/bin/zsh-completions ]; then
  fpath=(/usr/local/bin/zsh-completions/src $fpath)
  autoload -U compinit && compinit
fi

# Terminal coloring, displaying Git information and reducing directory information.
if [ -f /usr/local/bin/git-prompt/git-prompt.sh ]; then
  setopt PROMPT_SUBST
  source /usr/local/bin/git-prompt/git-prompt.sh
  GIT_PS1_SHOWDIRTYSTATE=1
  GIT_PS1_SHOWUPSTREAM=1
  GIT_PS1_SHOWUNTRACKEDFILES=1
  GIT_PS1_SHOWSTASHSTATE=1
  PROMPT='%B%F{green}%n@%m%f%b:%B%F{blue}%(5~|%-1~/…/%3~|%4~)%f%F{red}$(__git_ps1 "(%s)")%f%b $ '
else
  PROMPT='%B%F{green}%n@%m%f%b:%B%F{blue}%(5~|%-1~/…/%3~|%4~)%f%b $ '
fi

# For lesspipe installed by brew.
# Make less more friendly for non-text input files, see lesspipe(1)
if type brew > /dev/null 2>&1 && [ -x "$(brew --prefix)/bin/lesspipe.sh" ]; then
  eval "$(SHELL=/bin/sh lesspipe.sh)"
fi

# Load the functions and alias definition.
. "${ZSHRC_MACOS_PATH}/../alias/functions.sh"
. "${ZSHRC_MACOS_PATH}/../alias/alias.sh"

# Setup Starship
if type starship > /dev/null 2>&1; then
  eval "$(starship init zsh)"
fi
