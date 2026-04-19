#!/bin/bash

set -eu

SCRIPT_DIR="$(CDPATH='' cd -- "$(dirname -- "$0")" && pwd)"
readonly SCRIPT_DIR
REPO_ROOT="${DOTFILES_REPO_ROOT:-$(CDPATH='' cd -- "${SCRIPT_DIR}/../../.." && pwd)}"
readonly REPO_ROOT

readonly CRON_TEMPLATE="${REPO_ROOT}/assets/linux/cron/dotfiles-update.cron"
readonly UPDATE_SCRIPT="${REPO_ROOT}/modules/linux/update/update_packages.sh"
readonly AUTO_UPDATE_ENABLED="${DOTFILES_LINUX_ENABLE_AUTO_UPDATE:-0}"

. "${REPO_ROOT}/modules/shared/utils/message.sh"

main() {
  local current_crontab
  local generated_crontab

  if [ "${AUTO_UPDATE_ENABLED}" != '1' ]; then
    skip_info 'Linux auto-update is disabled by DOTFILES_LINUX_ENABLE_AUTO_UPDATE.'
    return 0
  fi

  if ! command -v crontab > /dev/null 2>&1; then
    skip_info 'crontab is not installed.'
    return 0
  fi

  if ! sudo -n true > /dev/null 2>&1; then
    skip_info 'Passwordless sudo is not configured for unattended apt updates.'
    return 0
  fi

  current_crontab="$(mktemp "${TMPDIR:-/tmp}/dotfiles-linux-crontab-current.XXXXXX")"
  generated_crontab="$(mktemp "${TMPDIR:-/tmp}/dotfiles-linux-crontab-generated.XXXXXX")"
  trap "rm -f '${current_crontab}' '${generated_crontab}'" EXIT

  crontab -l 2>/dev/null | sed '/# BEGIN DOTFILES AUTO UPDATE/,/# END DOTFILES AUTO UPDATE/d' > "${current_crontab}" || true
  sed "s|__DOTFILES_UPDATE_SCRIPT__|${UPDATE_SCRIPT}|g" "${CRON_TEMPLATE}" > "${generated_crontab}"
  cat "${current_crontab}" "${generated_crontab}" | crontab -
}

main "$@"
