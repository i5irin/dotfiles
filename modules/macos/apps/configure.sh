#!/bin/zsh

set -eu

SCRIPT_DIR="${0:A:h}"
readonly SCRIPT_DIR
REPO_ROOT="${DOTFILES_REPO_ROOT:-${SCRIPT_DIR:h:h:h}}"
readonly REPO_ROOT
HOMEBREW_PREFIX="${DOTFILES_HOMEBREW_PREFIX:-/opt/homebrew}"
readonly HOMEBREW_PREFIX

readonly KARABINER_ASSET_DIR="${REPO_ROOT}/assets/macos/karabiner"

source "${REPO_ROOT}/modules/shared/utils/message.sh"
source "${REPO_ROOT}/modules/shared/utils/posix.sh"
source "${REPO_ROOT}/modules/shared/utils/posix_app_config.sh"

refresh_macos_tool_path() {
  add_path "${HOMEBREW_PREFIX}/bin" > /dev/null 2>&1 || true
  add_path "${HOMEBREW_PREFIX}/sbin" > /dev/null 2>&1 || true
}

configure_karabiner() {
  configure_info 'Karabiner-Elements'
  if [ -d /Applications/Karabiner-Elements.app ]; then
    mkdir -p "${HOME}/.config"
    ln -sfn "${KARABINER_ASSET_DIR}" "${HOME}/.config/karabiner"
    finish_configure_message 'Karabiner-Elements'
  else
    skip_info 'Karabiner-Elements is not installed.'
  fi
}

configure_vscode() {
  configure_info 'Visual Studio Code'
  "${REPO_ROOT}/modules/cli/vscode/configure.sh"
  finish_configure_message 'Visual Studio Code'
}

configure_ghostty() {
  configure_info 'Ghostty'
  if [ ! -d /Applications/Ghostty.app ] && ! command -v ghostty > /dev/null 2>&1; then
    skip_info 'Ghostty is not installed.'
    return 0
  fi

  "${REPO_ROOT}/modules/cli/ghostty/configure.sh"
  finish_configure_message 'Ghostty'
}

configure_alttab() {
  local was_running=1

  configure_info 'AltTab'
  if [ ! -d /Applications/AltTab.app ]; then
    skip_info 'AltTab is not installed.'
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
    skip_info 'Clipy is not installed.'
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
  refresh_macos_tool_path
  configure_karabiner
  configure_posix_git
  configure_posix_tmux
  configure_posix_starship
  configure_posix_neovim
  configure_vscode
  configure_ghostty
  configure_alttab
  configure_clipy
}

main "$@"
