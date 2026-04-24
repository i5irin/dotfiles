#!/bin/zsh

set -eu

SCRIPT_DIR="${0:A:h}"
readonly SCRIPT_DIR
REPO_ROOT="${DOTFILES_REPO_ROOT:-${SCRIPT_DIR:h:h:h}}"
readonly REPO_ROOT
readonly CONFIG_ENV_PATH="${DOTFILES_MACOS_CONFIG_PATH:-${REPO_ROOT}/config/macos.env}"

source "${REPO_ROOT}/modules/shared/utils/load_env.sh"
if load_dotfiles_env_file "${CONFIG_ENV_PATH}"; then
  readonly BOOTSTRAP_CONFIG_SOURCE="${CONFIG_ENV_PATH}"
else
  readonly BOOTSTRAP_CONFIG_SOURCE='none'
fi

readonly HOMEBREW_PREFIX="${DOTFILES_HOMEBREW_PREFIX:-/opt/homebrew}"
readonly INCLUDE_OPTIONAL_PACKAGES="${DOTFILES_INCLUDE_MACOS_OPTIONAL_PACKAGES:-0}"
readonly DOTFILES_DATA_HOME="${DOTFILES_DATA_HOME:-${XDG_DATA_HOME:-${HOME}/.local/share}/dotfiles}"
readonly ZSH_COMPLETIONS_DIR="${DOTFILES_ZSH_COMPLETIONS_DIR:-${DOTFILES_DATA_HOME}/zsh-completions}"
readonly GIT_PROMPT_DIR="${DOTFILES_GIT_PROMPT_DIR:-${DOTFILES_DATA_HOME}/git-prompt}"
readonly PACKAGE_COMPOSE_HELPER="${REPO_ROOT}/modules/macos/packages/compose_brewfile.sh"
readonly PACKAGE_INSTALL_MODULE="${REPO_ROOT}/modules/macos/packages/install.sh"
readonly FONT_INSTALL_MODULE="${REPO_ROOT}/modules/shared/fonts/install-posix.sh"
readonly HOSTNAME_MODULE="${REPO_ROOT}/modules/macos/system/configure_hostnames.sh"
readonly ZSH_INSTALL_MODULE="${REPO_ROOT}/modules/shell/zsh/install.sh"
readonly PREFERENCES_PREFLIGHT_MODULE="${REPO_ROOT}/modules/macos/preferences/validate_full_disk_access.sh"
readonly PREFERENCES_MODULE="${REPO_ROOT}/modules/macos/preferences/apply.sh"
readonly UPDATE_MODULE="${REPO_ROOT}/modules/macos/update/register_launch_agent.sh"
readonly APP_CONFIGURE_MODULE="${REPO_ROOT}/modules/macos/apps/configure.sh"
readonly LOCAL_OVERRIDE_BREWFILE="${REPO_ROOT}/modules/macos/packages/local.Brewfile"
VALID_STEP_NAMES=('install-apps' 'configure-shell' 'apply-preferences' 'register-update-job' 'configure-apps')
ONLY_STEP=''

source "${REPO_ROOT}/modules/shared/utils/dotfiles.sh"
source "${REPO_ROOT}/modules/shared/utils/message.sh"

usage() {
  cat <<'EOF'
Usage: bootstrap/macos.sh [--dry-run] [--only <step>] [--help]

Apple Silicon macOS bootstrap entry point.

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

resolve_brewfile() {
  local temp_brewfile

  temp_brewfile="$(mktemp "${TMPDIR:-/tmp}/dotfiles-macos-brewfile.XXXXXX")"
  "${PACKAGE_COMPOSE_HELPER}" --output "${temp_brewfile}"
  printf '%s\n' "${temp_brewfile}"
}

resolve_local_override_source() {
  if [ -f "${LOCAL_OVERRIDE_BREWFILE}" ]; then
    printf '%s\n' "${LOCAL_OVERRIDE_BREWFILE}"
    return 0
  fi

  printf '%s\n' 'none'
}

validate_layout() {
  local required_path

  for required_path in \
    "${PACKAGE_COMPOSE_HELPER}" \
    "${PACKAGE_INSTALL_MODULE}" \
    "${FONT_INSTALL_MODULE}" \
    "${HOSTNAME_MODULE}" \
    "${ZSH_INSTALL_MODULE}" \
    "${PREFERENCES_PREFLIGHT_MODULE}" \
    "${PREFERENCES_MODULE}" \
    "${UPDATE_MODULE}" \
    "${APP_CONFIGURE_MODULE}"
  do
    if [ ! -x "${required_path}" ]; then
      echo "Required module was not found or not executable: ${required_path}" >&2
      return 1
    fi
  done
}

print_config() {
  local brewfile_path

  if [ "${ONLY_STEP}" = 'install-apps' ] || [ -z "${ONLY_STEP}" ]; then
    brewfile_path="$(resolve_brewfile)"
  else
    brewfile_path='n/a'
  fi

  cat <<EOF
repo_root=${REPO_ROOT}
bootstrap_module=${SCRIPT_DIR}
homebrew_prefix=${HOMEBREW_PREFIX}
include_optional_packages=${INCLUDE_OPTIONAL_PACKAGES}
selected_step=${ONLY_STEP:-all}
brewfile=${brewfile_path}
bootstrap_config_source=${BOOTSTRAP_CONFIG_SOURCE}
requires_admin=true
local_override_source=$(resolve_local_override_source)
dotfiles_data_home=${DOTFILES_DATA_HOME}
zsh_completions_dir=${ZSH_COMPLETIONS_DIR}
git_prompt_dir=${GIT_PROMPT_DIR}
brewfile_sources=
EOF
  if [ -f "${brewfile_path}" ]; then
    "${PACKAGE_COMPOSE_HELPER}" --print-sources
    rm -f "${brewfile_path}"
  fi
}

validate_macos_privileges() {
  if ! is_macos_admin_user; then
    echo 'The current macOS user is not an Administrator. Use an admin account in the VM before running bootstrap/macos.sh.' >&2
    return 1
  fi

  prime_macos_sudo_session
  start_sudo_keepalive
}

export_bootstrap_environment() {
  export DOTFILES_REPO_ROOT="${REPO_ROOT}"
  export DOTFILES_BOOTSTRAP_CONFIG_PATH="${CONFIG_ENV_PATH}"
  export DOTFILES_HOMEBREW_PREFIX="${HOMEBREW_PREFIX}"
  export DOTFILES_INCLUDE_MACOS_OPTIONAL_PACKAGES="${INCLUDE_OPTIONAL_PACKAGES}"
  export DOTFILES_DATA_HOME
  export DOTFILES_ZSH_COMPLETIONS_DIR="${ZSH_COMPLETIONS_DIR}"
  export DOTFILES_GIT_PROMPT_DIR="${GIT_PROMPT_DIR}"

  if [ "${1:-}" = '' ]; then
    unset DOTFILES_BREWFILE 2>/dev/null || true
  else
    export DOTFILES_BREWFILE="$1"
  fi
}

prepare_brewfile_context() {
  local brewfile_path

  progress_info 'Resolving macOS app catalog.'
  brewfile_path="$(resolve_brewfile)"
  progress_success 'Resolved macOS app catalog.'
  export DOTFILES_ACTIVE_BREWFILE_PATH="${brewfile_path}"
  export_bootstrap_environment "${brewfile_path}"
}

run_install_apps() {
  validate_macos_privileges
  prepare_brewfile_context

  run_step 'Install macOS applications' /bin/zsh "${PACKAGE_INSTALL_MODULE}"
  run_step 'Install terminal/editor fonts' /bin/sh "${FONT_INSTALL_MODULE}"
}

run_configure_shell() {
  export_bootstrap_environment
  run_step 'Configure macOS shell' /bin/zsh "${ZSH_INSTALL_MODULE}"
}

run_apply_preferences_steps() {
  export_bootstrap_environment
  run_step 'Validate macOS Full Disk Access' /bin/zsh "${PREFERENCES_PREFLIGHT_MODULE}"
  run_step 'Configure macOS hostname' /bin/zsh "${HOSTNAME_MODULE}"
  run_step 'Apply macOS preferences' /bin/zsh "${PREFERENCES_MODULE}"
}

run_apply_preferences() {
  validate_macos_privileges
  run_apply_preferences_steps
}

run_register_update_job() {
  export_bootstrap_environment
  run_step 'Register macOS update job' /bin/zsh "${UPDATE_MODULE}"
}

run_configure_apps() {
  export_bootstrap_environment
  run_step 'Configure macOS applications' /bin/zsh "${APP_CONFIGURE_MODULE}"
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
  trap 'stop_sudo_keepalive; rm -f "${DOTFILES_ACTIVE_BREWFILE_PATH:-}"' EXIT

  if [ -n "${ONLY_STEP}" ]; then
    run_selected_step
    return 0
  fi

  run_step 'Validate macOS privileges' validate_macos_privileges
  prepare_brewfile_context
  run_step 'Install macOS applications' /bin/zsh "${PACKAGE_INSTALL_MODULE}"
  run_step 'Install terminal/editor fonts' /bin/sh "${FONT_INSTALL_MODULE}"
  run_step 'Configure macOS shell' /bin/zsh "${ZSH_INSTALL_MODULE}"
  run_apply_preferences_steps
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
    require_apple_silicon_macos
    validate_layout
    print_config
    return 0
  fi

  require_apple_silicon_macos
  validate_layout
  progress_info 'Starting macOS bootstrap.'
  run_modules
  progress_success 'macOS bootstrap completed.'
}

main "$@"
