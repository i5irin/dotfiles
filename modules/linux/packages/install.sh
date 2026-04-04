#!/bin/bash

set -eu

SCRIPT_DIR="$(CDPATH='' cd -- "$(dirname -- "$0")" && pwd)"
readonly SCRIPT_DIR
REPO_ROOT="${DOTFILES_REPO_ROOT:-$(CDPATH='' cd -- "${SCRIPT_DIR}/../../.." && pwd)}"
readonly REPO_ROOT

readonly PACKAGE_COMPOSE_HELPER="${REPO_ROOT}/modules/linux/packages/compose_apt_list.sh"
readonly ACTIVE_APT_LIST_PATH="${DOTFILES_APT_PACKAGE_LIST_PATH:-}"

install_starship() {
  if command -v starship > /dev/null 2>&1; then
    return 0
  fi

  curl -fsSL https://starship.rs/install.sh | sh -s -- -y
}

main() {
  local apt_list_path
  local created_temp_list=0
  local packages

  if [ "$(uname -s)" != 'Linux' ]; then
    echo 'Linux package installation only supports Linux hosts.' >&2
    return 1
  fi

  if ! command -v apt-get > /dev/null 2>&1; then
    echo 'apt-get was not found. This package installer currently supports Ubuntu/Debian-family systems only.' >&2
    return 1
  fi

  if [ -n "${ACTIVE_APT_LIST_PATH}" ] && [ -f "${ACTIVE_APT_LIST_PATH}" ]; then
    apt_list_path="${ACTIVE_APT_LIST_PATH}"
  else
    apt_list_path="$(mktemp "${TMPDIR:-/tmp}/dotfiles-linux-apt.XXXXXX")"
    created_temp_list=1
    "${PACKAGE_COMPOSE_HELPER}" --output "${apt_list_path}"
  fi

  mapfile -t packages < "${apt_list_path}"

  sudo apt-get update
  if [ "${#packages[@]}" -gt 0 ]; then
    sudo apt-get install -y "${packages[@]}"
  fi

  install_starship

  if [ "${created_temp_list}" -eq 1 ]; then
    rm -f "${apt_list_path}"
  fi
}

main "$@"
