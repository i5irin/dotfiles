# Resolve the dotfiles location from the symlinked shell file itself.
ZSHRC_MACOS_PATH="${${(%):-%N}:A:h}"
DOTFILES_REPO_ROOT="${ZSHRC_MACOS_PATH:h:h}"
DOTFILES_DATA_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/dotfiles"
ZSH_COMPLETIONS_DIR="${DOTFILES_ZSH_COMPLETIONS_DIR:-${DOTFILES_DATA_HOME}/zsh-completions}"
GIT_PROMPT_DIR="${DOTFILES_GIT_PROMPT_DIR:-${DOTFILES_DATA_HOME}/git-prompt}"
HOMEBREW_PREFIX="${DOTFILES_HOMEBREW_PREFIX:-/opt/homebrew}"

# Load the library functions.
. "${DOTFILES_REPO_ROOT}/lib/posix_dotfiles_utils/utils.sh"

# Ignore case when no candidate is found.
zstyle ':completion:*' matcher-list '' 'm:{[:lower:]}={[:upper:]}' '+m:{[:upper:]}={[:lower:]}'

# Don't let Zsh save meanless command history.
setopt hist_reduce_blanks
setopt hist_ignore_all_dups

# Share command history between Zsh.
setopt share_history

# Make Homebrew-installed tools available on Apple Silicon macOS.
if [ -x "${HOMEBREW_PREFIX}/bin/brew" ]; then
  eval "$("${HOMEBREW_PREFIX}/bin/brew" shellenv)"
fi

# Make OpenJDK that is installed with Homebrew be used as default.
if type brew > /dev/null 2>&1; then
  add_path "$(brew --prefix)/opt/openjdk/bin" 2> /dev/null
fi

# Apply syntax highlighting to less.
if type brew > /dev/null 2>&1 && [ -x "$(brew --prefix)/bin/src-hilite-lesspipe.sh" ]; then
  export LESSOPEN="| src-hilite-lesspipe.sh %s"
fi

# configure Zsh completion.
if [ -d "${ZSH_COMPLETIONS_DIR}" ]; then
  fpath=("${ZSH_COMPLETIONS_DIR}/src" $fpath)
  autoload -U compinit && compinit
fi

# Terminal coloring, displaying Git information and reducing directory information.
if [ -f "${GIT_PROMPT_DIR}/git-prompt.sh" ]; then
  setopt PROMPT_SUBST
  source "${GIT_PROMPT_DIR}/git-prompt.sh"
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

# Load machine-specific shell overrides when present.
if [ -f "${DOTFILES_REPO_ROOT}/macos/.zshrc.local" ]; then
  source "${DOTFILES_REPO_ROOT}/macos/.zshrc.local"
fi
