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

is_macos_admin_user() {
  id -Gn | tr ' ' '\n' | grep -Fx 'admin' > /dev/null 2>&1
}

prime_macos_sudo_session() {
  if sudo -n true > /dev/null 2>&1; then
    return 0
  fi

  echo 'Administrator privileges are required for the macOS bootstrap.' >&2
  sudo -v
}

ensure_homebrew_shellenv() {
  local prefix

  prefix="${1:-${DOTFILES_HOMEBREW_PREFIX:-$(default_homebrew_prefix)}}"

  if [ -x "${prefix}/bin/brew" ]; then
    eval "$("${prefix}/bin/brew" shellenv)"
  fi
}
