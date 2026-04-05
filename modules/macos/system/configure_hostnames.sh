#!/bin/zsh

set -eu

SCRIPT_DIR="${0:A:h}"
readonly SCRIPT_DIR
REPO_ROOT="${DOTFILES_REPO_ROOT:-${SCRIPT_DIR:h:h:h}}"
readonly REPO_ROOT
readonly DOTFILES_DATA_HOME="${DOTFILES_DATA_HOME:-${XDG_DATA_HOME:-${HOME}/.local/share}/dotfiles}"
readonly DOTFILES_STATE_DIR="${DOTFILES_DATA_HOME}/state"
readonly MACHINE_NAME_STATE_FILE="${DOTFILES_STATE_DIR}/macos-machine-name"

source "${REPO_ROOT}/modules/shared/utils/posix.sh"

load_machine_name_from_state() {
  if [ ! -f "${MACHINE_NAME_STATE_FILE}" ]; then
    return 1
  fi

  state_machine_name="$(cat "${MACHINE_NAME_STATE_FILE}")"
  if [ -n "${state_machine_name}" ]; then
    printf '%s\n' "${state_machine_name}"
    return 0
  fi

  return 1
}

persist_machine_name() {
  mkdir -p "${DOTFILES_STATE_DIR}"
  printf '%s\n' "$1" > "${MACHINE_NAME_STATE_FILE}"
}

current_machine_name_matches() {
  current_computer_name="$(scutil --get ComputerName 2> /dev/null || true)"
  current_local_host_name="$(scutil --get LocalHostName 2> /dev/null || true)"
  current_host_name="$(scutil --get HostName 2> /dev/null || true)"

  [ "${current_computer_name}" = "$1" ] \
    && [ "${current_local_host_name}" = "$1" ] \
    && [ "${current_host_name}" = "$1" ]
}

main() {
  local machine_name

  if [ "${DOTFILES_SKIP_HOSTNAME_SETUP:-0}" = '1' ]; then
    echo 'Skip hostname configuration because DOTFILES_SKIP_HOSTNAME_SETUP=1.'
    return 0
  fi

  if [ -n "${DOTFILES_MAC_MACHINE_NAME:-}" ]; then
    machine_name="${DOTFILES_MAC_MACHINE_NAME}"
    validate_rfc952_hostname "${machine_name}"
  elif machine_name="$(load_machine_name_from_state)"; then
    validate_rfc952_hostname "${machine_name}"
  else
    echo "macOS machine name is not configured. Set DOTFILES_MAC_MACHINE_NAME in ${DOTFILES_BOOTSTRAP_CONFIG_PATH:-config/macos.env} or in the environment." >&2
    return 1
  fi

  if current_machine_name_matches "${machine_name}"; then
    echo "Skip hostname configuration because it is already set to ${machine_name}."
    persist_machine_name "${machine_name}"
    return 0
  fi

  echo 'Setting up ComputerName.'
  scutil --set ComputerName "${machine_name}"
  echo 'Setting up LocalHostName.'
  scutil --set LocalHostName "${machine_name}"
  echo 'Setting up HostName.'
  scutil --set HostName "${machine_name}"
  persist_machine_name "${machine_name}"
}

main "$@"
