#!/bin/sh

configure_optional_posix_module() {
  label="$1"
  command_name="$2"
  module_path="$3"
  skip_message="$4"

  configure_info "${label}"
  if ! command -v "${command_name}" > /dev/null 2>&1; then
    skip_info "${skip_message}"
    return 0
  fi

  "${module_path}"
  finish_configure_message "${label}"
}

configure_posix_git() {
  configure_optional_posix_module \
    'Git' \
    'git' \
    "${REPO_ROOT}/modules/cli/git/configure.sh" \
    'Git is not installed.'
}

configure_posix_tmux() {
  configure_optional_posix_module \
    'tmux' \
    'tmux' \
    "${REPO_ROOT}/modules/cli/tmux/configure.sh" \
    'tmux is not installed.'
}

configure_posix_starship() {
  configure_optional_posix_module \
    'Starship' \
    'starship' \
    "${REPO_ROOT}/modules/cli/starship/configure.sh" \
    'Starship is not installed.'
}

configure_posix_neovim() {
  configure_optional_posix_module \
    'Neovim' \
    'nvim' \
    "${REPO_ROOT}/modules/cli/neovim/configure.sh" \
    'Neovim is not installed.'
}
