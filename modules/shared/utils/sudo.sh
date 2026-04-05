#!/bin/sh

prime_sudo_session() {
  prompt_message="${1:-Administrator privileges are required to continue.}"

  if sudo -n true >/dev/null 2>&1; then
    return 0
  fi

  echo "${prompt_message}" >&2
  sudo -v
}

start_sudo_keepalive() {
  interval="${1:-50}"
  parent_pid="$$"

  if [ -n "${ZSH_VERSION:-}" ]; then
    setopt localoptions no_bg_nice 2>/dev/null || true
  fi

  stop_sudo_keepalive

  (
    while kill -0 "${parent_pid}" >/dev/null 2>&1; do
      sudo -n true >/dev/null 2>&1 || exit 0
      sleep "${interval}"
    done
  ) &

  DOTFILES_SUDO_KEEPALIVE_PID=$!
  export DOTFILES_SUDO_KEEPALIVE_PID
}

stop_sudo_keepalive() {
  if [ -z "${DOTFILES_SUDO_KEEPALIVE_PID:-}" ]; then
    return 0
  fi

  if kill -0 "${DOTFILES_SUDO_KEEPALIVE_PID}" >/dev/null 2>&1; then
    kill "${DOTFILES_SUDO_KEEPALIVE_PID}" >/dev/null 2>&1 || true
    wait "${DOTFILES_SUDO_KEEPALIVE_PID}" 2>/dev/null || true
  fi

  unset DOTFILES_SUDO_KEEPALIVE_PID
}
