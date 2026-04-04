#!/bin/bash

set -eu

log_message() {
  if command -v logger > /dev/null 2>&1; then
    logger -t dotfiles-linux-update "$1"
  else
    printf '%s\n' "$1"
  fi
}

main() {
  log_message '==============================================================='
  log_message '    Update packages'
  log_message '==============================================================='
  log_message "Current time $(date '+%Y-%m-%dT%H:%M:%S%z')"

  sudo -n apt-get update
  sudo -n env DEBIAN_FRONTEND=noninteractive apt-get upgrade -y
}

main "$@"
