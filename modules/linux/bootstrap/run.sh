#!/bin/bash

set -eu

SCRIPT_DIR="$(CDPATH='' cd -- "$(dirname -- "$0")" && pwd)"
readonly SCRIPT_DIR
REPO_ROOT="${DOTFILES_REPO_ROOT:-$(CDPATH='' cd -- "${SCRIPT_DIR}/../../.." && pwd)}"
readonly REPO_ROOT
readonly CONFIG_ENV_PATH="${DOTFILES_LINUX_CONFIG_PATH:-${REPO_ROOT}/config/linux.env}"

. "${REPO_ROOT}/modules/shared/utils/load_env.sh"
if load_dotfiles_env_file "${CONFIG_ENV_PATH}"; then
  readonly BOOTSTRAP_CONFIG_SOURCE="${CONFIG_ENV_PATH}"
else
  readonly BOOTSTRAP_CONFIG_SOURCE='none'
fi

. "${REPO_ROOT}/modules/shared/utils/sudo.sh"

readonly DOTFILES_DATA_HOME="${DOTFILES_DATA_HOME:-${XDG_DATA_HOME:-${HOME}/.local/share}/dotfiles}"
readonly GIT_PROMPT_DIR="${DOTFILES_GIT_PROMPT_DIR:-${DOTFILES_DATA_HOME}/git-prompt}"
readonly PACKAGE_COMPOSE_HELPER="${REPO_ROOT}/modules/linux/packages/compose_apt_list.sh"
readonly PACKAGE_INSTALL_MODULE="${REPO_ROOT}/modules/linux/packages/install.sh"
readonly BASH_INSTALL_MODULE="${REPO_ROOT}/modules/shell/bash/install.sh"
readonly UPDATE_MODULE="${REPO_ROOT}/modules/linux/update/register_cron.sh"
readonly APP_CONFIGURE_MODULE="${REPO_ROOT}/modules/linux/apps/configure.sh"
readonly CANONICAL_LOCAL_OVERRIDE_APT_LIST="${REPO_ROOT}/modules/linux/packages/local.apt.txt"
readonly INCLUDE_OPTIONAL_PACKAGES="${DOTFILES_INCLUDE_LINUX_OPTIONAL_PACKAGES:-0}"
VALID_STEP_NAMES=('install-apps' 'configure-shell' 'apply-preferences' 'register-update-job' 'configure-apps')
ONLY_STEP=''

. "${REPO_ROOT}/modules/shared/utils/message.sh"

usage() {
  cat <<'EOF'
Usage: bootstrap/linux.sh [--dry-run] [--only <step>] [--help]

Ubuntu/Debian-oriented Linux CLI bootstrap entry point.

Options:
  --dry-run  Print the resolved configuration without executing setup.
  --only     Run only one step: install-apps, configure-shell, apply-preferences, register-update-job, configure-apps.
  --help     Show this help message.
EOF
}

is_valid_step_name() {
  local candidate="$1"
  local valid_name

  for valid_name in "${VALID_STEP_NAMES[@]}"; do
    if [ "${valid_name}" = "${candidate}" ]; then
      return 0
    fi
  done

  return 1
}

require_linux_apt() {
  if [ "$(uname -s)" != 'Linux' ]; then
    echo 'This bootstrap entry only supports Linux.' >&2
    return 1
  fi

  if ! command -v apt-get > /dev/null 2>&1; then
    echo 'This bootstrap entry currently supports Ubuntu/Debian-family systems with apt-get.' >&2
    return 1
  fi
}

validate_layout() {
  local required_path

  for required_path in \
    "${PACKAGE_COMPOSE_HELPER}" \
    "${PACKAGE_INSTALL_MODULE}" \
    "${BASH_INSTALL_MODULE}" \
    "${UPDATE_MODULE}" \
    "${APP_CONFIGURE_MODULE}"
  do
    if [ ! -x "${required_path}" ]; then
      echo "Required module was not found or not executable: ${required_path}" >&2
      return 1
    fi
  done
}

resolve_local_override_source() {
  if [ -f "${CANONICAL_LOCAL_OVERRIDE_APT_LIST}" ]; then
    printf '%s\n' "${CANONICAL_LOCAL_OVERRIDE_APT_LIST}"
    return 0
  fi

  printf '%s\n' 'none'
}

resolve_apt_list() {
  local temp_apt_list

  temp_apt_list="$(mktemp "${TMPDIR:-/tmp}/dotfiles-linux-apt.XXXXXX")"
  "${PACKAGE_COMPOSE_HELPER}" --output "${temp_apt_list}"
  printf '%s\n' "${temp_apt_list}"
}

print_config() {
  local apt_list_path

  if [ "${ONLY_STEP}" = 'install-apps' ] || [ -z "${ONLY_STEP}" ]; then
    apt_list_path="$(resolve_apt_list)"
  else
    apt_list_path='n/a'
  fi

  cat <<EOF
repo_root=${REPO_ROOT}
bootstrap_module=${SCRIPT_DIR}
selected_step=${ONLY_STEP:-all}
package_list=${apt_list_path}
bootstrap_config_source=${BOOTSTRAP_CONFIG_SOURCE}
include_optional_packages=${INCLUDE_OPTIONAL_PACKAGES}
local_override_source=$(resolve_local_override_source)
dotfiles_data_home=${DOTFILES_DATA_HOME}
git_prompt_dir=${GIT_PROMPT_DIR}
linux_auto_update=${DOTFILES_LINUX_ENABLE_AUTO_UPDATE:-0}
requires_sudo=true
apt_sources=
EOF
  if [ -f "${apt_list_path}" ]; then
    "${PACKAGE_COMPOSE_HELPER}" --print-sources
    rm -f "${apt_list_path}"
  fi
}

validate_linux_privileges() {
  prime_sudo_session 'sudo privileges are required for the Linux bootstrap.'
  start_sudo_keepalive
}

export_bootstrap_environment() {
  export DOTFILES_REPO_ROOT="${REPO_ROOT}"
  export DOTFILES_BOOTSTRAP_CONFIG_PATH="${CONFIG_ENV_PATH}"
  export DOTFILES_DATA_HOME
  export DOTFILES_GIT_PROMPT_DIR="${GIT_PROMPT_DIR}"

  if [ "${1:-}" = '' ]; then
    unset DOTFILES_APT_PACKAGE_LIST_PATH 2>/dev/null || true
  else
    export DOTFILES_APT_PACKAGE_LIST_PATH="$1"
  fi
}

prepare_apt_list_context() {
  local apt_list_path

  progress_info 'Resolving Linux app catalog.'
  apt_list_path="$(resolve_apt_list)"
  progress_success 'Resolved Linux app catalog.'
  export DOTFILES_ACTIVE_APT_LIST_PATH="${apt_list_path}"
  export_bootstrap_environment "${apt_list_path}"
}

run_install_apps() {
  run_step 'Validate Linux privileges' validate_linux_privileges
  prepare_apt_list_context
  run_step 'Install Linux applications' /bin/bash "${PACKAGE_INSTALL_MODULE}"
}

run_configure_shell() {
  export_bootstrap_environment
  run_step 'Configure Linux shell' /bin/bash "${BASH_INSTALL_MODULE}"
}

run_apply_preferences() {
  skip_info 'No tracked Linux preferences are defined.'
}

run_register_update_job() {
  export_bootstrap_environment
  run_step 'Register Linux update job' /bin/bash "${UPDATE_MODULE}"
}

run_configure_apps() {
  export_bootstrap_environment
  run_step 'Configure Linux applications' /bin/bash "${APP_CONFIGURE_MODULE}"
}

run_step() {
  local label="$1"
  shift

  progress_info "${label}"
  if "$@"; then
    progress_success "${label}"
    return 0
  fi

  progress_failure "${label}"
  return 1
}

run_selected_step() {
  case "${ONLY_STEP}" in
    install-apps)
      run_install_apps
      ;;
    configure-shell)
      run_configure_shell
      ;;
    apply-preferences)
      run_apply_preferences
      ;;
    register-update-job)
      run_register_update_job
      ;;
    configure-apps)
      run_configure_apps
      ;;
  esac
}

run_modules() {
  trap 'stop_sudo_keepalive; rm -f "${DOTFILES_ACTIVE_APT_LIST_PATH:-}"' EXIT

  if [ -n "${ONLY_STEP}" ]; then
    run_selected_step
    return 0
  fi

  run_install_apps
  run_configure_shell
  run_apply_preferences
  run_register_update_job
  run_configure_apps
}

main() {
  local dry_run=0

  while [ "$#" -gt 0 ]; do
    case "$1" in
      --help|-h)
        usage
        return 0
        ;;
      --dry-run)
        dry_run=1
        ;;
      --only)
        if [ "$#" -lt 2 ]; then
          echo '--only requires a step name.' >&2
          usage >&2
          return 1
        fi
        ONLY_STEP="$2"
        if ! is_valid_step_name "${ONLY_STEP}"; then
          echo "Unsupported step: ${ONLY_STEP}" >&2
          usage >&2
          return 1
        fi
        shift
        ;;
      *)
        echo "Unsupported option: $1" >&2
        usage >&2
        return 1
        ;;
    esac
    shift
  done

  if [ "${dry_run}" -eq 1 ]; then
    validate_layout
    print_config
    return 0
  fi

  require_linux_apt
  validate_layout
  progress_info 'Starting Linux bootstrap.'
  run_modules
  progress_success 'Linux bootstrap completed.'
}

main "$@"
