# Resolve the dotfiles location from the symlinked shell file itself.
ZSHRC_MODULE_PATH="${${(%):-%N}:A:h}"
DOTFILES_REPO_ROOT="${ZSHRC_MODULE_PATH:h:h:h}"
DOTFILES_DATA_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/dotfiles"
ZSH_COMPLETIONS_DIR="${DOTFILES_ZSH_COMPLETIONS_DIR:-${DOTFILES_DATA_HOME}/zsh-completions}"
GIT_PROMPT_DIR="${DOTFILES_GIT_PROMPT_DIR:-${DOTFILES_DATA_HOME}/git-prompt}"
HOMEBREW_PREFIX="${DOTFILES_HOMEBREW_PREFIX:-/opt/homebrew}"
ZSH_COMPLETION_CACHE_DIR="${DOTFILES_DATA_HOME}/zsh-completion-cache"
ZSH_COMPDUMP_PATH="${DOTFILES_DATA_HOME}/zcompdump"

# Load shared shell utilities.
. "${DOTFILES_REPO_ROOT}/modules/shared/utils/posix.sh"

# Ignore case when no candidate is found.
zstyle ':completion:*' matcher-list '' 'm:{[:lower:]}={[:upper:]}' '+m:{[:upper:]}={[:lower:]}'
zstyle ':completion:*' menu select
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path "${ZSH_COMPLETION_CACHE_DIR}"
zstyle ':completion:*' completer _extensions _complete _approximate
zmodload zsh/complist

# Do not save meaningless command history.
setopt hist_reduce_blanks
setopt hist_ignore_all_dups

# Share command history between Zsh.
setopt share_history

# Make Homebrew-installed tools available on Apple Silicon macOS.
if [ -x "${HOMEBREW_PREFIX}/bin/brew" ]; then
  eval "$("${HOMEBREW_PREFIX}/bin/brew" shellenv)"
fi

# Make OpenJDK installed by Homebrew available as the default JDK.
if type brew > /dev/null 2>&1; then
  add_path "$(brew --prefix)/opt/openjdk/bin" 2> /dev/null
fi

# Apply syntax highlighting to less.
if type brew > /dev/null 2>&1 && [ -x "$(brew --prefix)/bin/src-hilite-lesspipe.sh" ]; then
  export LESSOPEN="| src-hilite-lesspipe.sh %s"
fi

# Configure Zsh completion.
if [ -d "${ZSH_COMPLETIONS_DIR}" ]; then
  mkdir -p "${ZSH_COMPLETION_CACHE_DIR}"
  fpath=("${ZSH_COMPLETIONS_DIR}/src" $fpath)
  autoload -Uz compinit
  compinit -d "${ZSH_COMPDUMP_PATH}"
fi

# Display Git information in the prompt when git-prompt is available.
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

# Make less more friendly for non-text input files.
if type brew > /dev/null 2>&1 && [ -x "$(brew --prefix)/bin/lesspipe.sh" ]; then
  eval "$(SHELL=/bin/sh lesspipe.sh)"
fi

# Load shared functions and aliases.
. "${DOTFILES_REPO_ROOT}/modules/shared/shell/functions.sh"
. "${DOTFILES_REPO_ROOT}/modules/shared/shell/alias.sh"

# Setup Starship when it is available.
if type starship > /dev/null 2>&1; then
  eval "$(starship init zsh)"
fi

# Load machine-specific shell overrides when present.
if [ -f "${DOTFILES_REPO_ROOT}/modules/shell/zsh/.zshrc.local" ]; then
  source "${DOTFILES_REPO_ROOT}/modules/shell/zsh/.zshrc.local"
fi

if command -v nvim > /dev/null 2>&1; then
  export EDITOR='nvim'
  export VISUAL='nvim'
fi
