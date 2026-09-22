# POSIX shell library. Source this file; do not execute it directly.

configure_optional_posix_module() {
  configure_info "$1"
  if ! command -v "$2" > /dev/null 2>&1; then
    skip_info "$4"
    return 0
  fi

  "$3" || return $?
  complete_configure_info "$1"
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
