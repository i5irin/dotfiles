#!/bin/zsh

default_homebrew_prefix() {
  printf '%s\n' '/opt/homebrew'
}

require_apple_silicon_macos() {
  if [ "$(uname -s)" != 'Darwin' ]; then
    echo 'This bootstrap entry only supports macOS.' >&2
    return 1
  fi

  if [ "$(uname -m)" != 'arm64' ]; then
    echo 'This bootstrap entry only supports Apple Silicon macOS.' >&2
    return 1
  fi
}

ensure_homebrew_shellenv() {
  local prefix

  prefix="${1:-${DOTFILES_HOMEBREW_PREFIX:-$(default_homebrew_prefix)}}"

  if [ -x "${prefix}/bin/brew" ]; then
    eval "$("${prefix}/bin/brew" shellenv)"
  fi
}
