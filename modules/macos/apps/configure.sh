#!/bin/zsh

set -eu

SCRIPT_DIR="${0:A:h}"
readonly SCRIPT_DIR
REPO_ROOT="${DOTFILES_REPO_ROOT:-${SCRIPT_DIR:h:h:h}}"
readonly REPO_ROOT

readonly KARABINER_ASSET_DIR="${REPO_ROOT}/assets/macos/karabiner"

source "${REPO_ROOT}/modules/shared/utils/message.sh"

configure_karabiner() {
  configure_info 'Karabiner-Elements'
  if [ -d /Applications/Karabiner-Elements.app ]; then
    mkdir -p "${HOME}/.config"
    ln -sfn "${KARABINER_ASSET_DIR}" "${HOME}/.config/karabiner"
    finish_configure_message 'Karabiner-Elements'
  else
    echo 'Skip setup because Karabiner-Elements is not installed.' >&2
  fi
}

configure_git() {
  configure_info 'Git'
  if ! command -v git > /dev/null 2>&1; then
    echo 'Skip setup because Git is not installed.' >&2
    return 0
  fi

  "${REPO_ROOT}/modules/cli/git/configure.sh"
  finish_configure_message 'Git'
}

configure_tmux() {
  configure_info 'tmux'
  if ! command -v tmux > /dev/null 2>&1; then
    echo 'Skip setup because tmux is not installed.' >&2
    return 0
  fi

  "${REPO_ROOT}/modules/cli/tmux/configure.sh"
  finish_configure_message 'tmux'
}

configure_vscode() {
  configure_info 'Visual Studio Code'
  if ! command -v code > /dev/null 2>&1; then
    echo 'Skip setup because Visual Studio Code is not installed.' >&2
    return 0
  fi

  "${REPO_ROOT}/modules/cli/vscode/configure.sh"
  finish_configure_message 'Visual Studio Code'
}

configure_hyper() {
  configure_info 'Hyper'
  if ! command -v hyper > /dev/null 2>&1; then
    echo 'Skip setup because Hyper is not installed.' >&2
    return 0
  fi

  /bin/zsh "${REPO_ROOT}/modules/cli/hyper/configure-macos.sh"
  finish_configure_message 'Hyper'
}

configure_alttab() {
  local was_running=1

  configure_info 'AltTab'
  if [ ! -d /Applications/AltTab.app ]; then
    echo 'Skip setup because AltTab is not installed.' >&2
    return 0
  fi

  set +e
  killall AltTab > /dev/null 2>&1
  was_running=$?
  set -e

  defaults write com.lwouis.alt-tab-macos spacesToShow -bool true

  if [ "${was_running}" -eq 0 ]; then
    open /Applications/AltTab.app
  fi

  finish_configure_message 'AltTab'
}

configure_clipy() {
  local was_running=1

  configure_info 'Clipy'
  if [ ! -d /Applications/Clipy.app ]; then
    echo 'Skip setup because Clipy is not installed.' >&2
    return 0
  fi

  set +e
  killall Clipy > /dev/null 2>&1
  was_running=$?
  set -e

  defaults write com.clipy-app.Clipy loginItem -bool true

  if [ "${was_running}" -eq 0 ]; then
    open /Applications/Clipy.app
  fi

  finish_configure_message 'Clipy'
}

main() {
  configure_karabiner
  configure_git
  configure_tmux
  configure_vscode
  configure_hyper
  configure_alttab
  configure_clipy
}

main "$@"
