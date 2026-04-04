#!/bin/zsh

set -eu

SCRIPT_DIR="${0:A:h}"
readonly SCRIPT_DIR
REPO_ROOT="${DOTFILES_REPO_ROOT:-${SCRIPT_DIR:h:h:h}}"
readonly REPO_ROOT

readonly HOMEBREW_PREFIX="${DOTFILES_HOMEBREW_PREFIX:-/opt/homebrew}"
readonly LAUNCH_AGENT_LABEL='com.i5irin.dotfiles.updateapps'
readonly LAUNCH_AGENT_TEMPLATE="${REPO_ROOT}/assets/macos/launchd/${LAUNCH_AGENT_LABEL}.plist"
readonly LAUNCH_AGENT_PATH="${HOME}/Library/LaunchAgents/${LAUNCH_AGENT_LABEL}.plist"
readonly DOTFILES_LOG_DIR="${HOME}/Library/Logs/dotfiles"
readonly DOTFILES_LOG_PATH="${DOTFILES_LOG_DIR}/application_update.log"

main() {
  mkdir -p "${HOME}/Library/LaunchAgents" "${DOTFILES_LOG_DIR}"

  sed \
    -e "s|__DOTFILES_REPO_ROOT__|${REPO_ROOT}|g" \
    -e "s|__DOTFILES_HOMEBREW_PREFIX__|${HOMEBREW_PREFIX}|g" \
    -e "s|__DOTFILES_LOG_PATH__|${DOTFILES_LOG_PATH}|g" \
    "${LAUNCH_AGENT_TEMPLATE}" \
    > "${LAUNCH_AGENT_PATH}"

  launchctl bootout "gui/$(id -u)" "${LAUNCH_AGENT_PATH}" > /dev/null 2>&1 || true
  launchctl bootstrap "gui/$(id -u)" "${LAUNCH_AGENT_PATH}"
}

main "$@"
