#!/bin/zsh

set -eu

SCRIPT_DIR="${0:A:h}"
readonly SCRIPT_DIR
REPO_ROOT="${DOTFILES_REPO_ROOT:-${SCRIPT_DIR:h:h:h}}"
readonly REPO_ROOT

source "${REPO_ROOT}/modules/shared/utils/posix.sh"

prompt_for_machine_name() {
  local machine_name
  local answer

  while true; do
    echo 'Name your machine. (LocalHostName and ComputerName)'
    echo 'This is used by Bonjour and AppleTalk.'
    printf '> '
    read machine_name

    if ! validate_rfc952_hostname "${machine_name}"; then
      continue
    fi

    while true; do
      printf 'Make sure machine name(%s) you input, is this ok? [Y/n] > ' "${machine_name}"
      read answer
      case "${answer}" in
        [Yy]|[Nn]|"")
          break
          ;;
        *)
          echo '[Y/n]'
          ;;
      esac
    done

    case "${answer}" in
      [Yy]|"")
        printf '%s\n' "${machine_name}"
        return 0
        ;;
    esac
  done
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
  else
    machine_name="$(prompt_for_machine_name)"
  fi

  echo 'Setting up ComputerName.'
  scutil --set ComputerName "${machine_name}"
  echo 'Setting up LocalHostName.'
  scutil --set LocalHostName "${machine_name}"
  echo 'Setting up HostName.'
  scutil --set HostName "${machine_name}"
}

main "$@"
