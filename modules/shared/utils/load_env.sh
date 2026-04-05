#!/bin/sh

load_dotfiles_env_file() {
  env_path="$1"

  if [ ! -f "${env_path}" ]; then
    return 1
  fi

  set -a
  # shellcheck disable=SC1090
  . "${env_path}"
  set +a
  return 0
}
