#!/bin/zsh

set -eu

SCRIPT_DIR="${0:A:h}"
readonly SCRIPT_DIR
REPO_ROOT="${DOTFILES_REPO_ROOT:-${SCRIPT_DIR:h:h:h}}"
readonly REPO_ROOT

readonly HOMEBREW_PREFIX="${DOTFILES_HOMEBREW_PREFIX:-/opt/homebrew}"
readonly DOTFILES_DATA_HOME="${DOTFILES_DATA_HOME:-${XDG_DATA_HOME:-${HOME}/.local/share}/dotfiles}"
readonly ZSH_COMPLETIONS_DIR="${DOTFILES_ZSH_COMPLETIONS_DIR:-${DOTFILES_DATA_HOME}/zsh-completions}"
readonly GIT_PROMPT_DIR="${DOTFILES_GIT_PROMPT_DIR:-${DOTFILES_DATA_HOME}/git-prompt}"
readonly PACKAGE_COMPOSE_HELPER="${REPO_ROOT}/modules/macos/packages/compose_brewfile.sh"
readonly PACKAGE_INSTALL_MODULE="${REPO_ROOT}/modules/macos/packages/install.sh"
readonly HOSTNAME_MODULE="${REPO_ROOT}/modules/macos/system/configure_hostnames.sh"
readonly ZSH_INSTALL_MODULE="${REPO_ROOT}/modules/shell/zsh/install.sh"
readonly PREFERENCES_MODULE="${REPO_ROOT}/modules/macos/preferences/apply.sh"
readonly UPDATE_MODULE="${REPO_ROOT}/modules/macos/update/register_launch_agent.sh"
readonly APP_CONFIGURE_MODULE="${REPO_ROOT}/modules/macos/apps/configure.sh"
readonly LOCAL_OVERRIDE_BREWFILE="${REPO_ROOT}/modules/macos/packages/local.Brewfile"

source "${REPO_ROOT}/modules/shared/utils/dotfiles.sh"

usage() {
  cat <<'EOF'
Usage: bootstrap/macos.sh [--dry-run] [--help]

Apple Silicon macOS bootstrap entry point.

Options:
  --dry-run  Print the resolved configuration without executing setup.
  --help     Show this help message.
EOF
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
    "${HOSTNAME_MODULE}" \
    "${ZSH_INSTALL_MODULE}" \
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

  brewfile_path="$(resolve_brewfile)"

  cat <<EOF
repo_root=${REPO_ROOT}
bootstrap_module=${SCRIPT_DIR}
homebrew_prefix=${HOMEBREW_PREFIX}
brewfile=${brewfile_path}
local_override_source=$(resolve_local_override_source)
dotfiles_data_home=${DOTFILES_DATA_HOME}
zsh_completions_dir=${ZSH_COMPLETIONS_DIR}
git_prompt_dir=${GIT_PROMPT_DIR}
brewfile_sources=
EOF
  "${PACKAGE_COMPOSE_HELPER}" --print-sources
  rm -f "${brewfile_path}"
}

run_modules() {
  local brewfile_path

  brewfile_path="$(resolve_brewfile)"
  export DOTFILES_ACTIVE_BREWFILE_PATH="${brewfile_path}"
  trap 'rm -f "${DOTFILES_ACTIVE_BREWFILE_PATH:-}"' EXIT

  export DOTFILES_REPO_ROOT="${REPO_ROOT}"
  export DOTFILES_HOMEBREW_PREFIX="${HOMEBREW_PREFIX}"
  export DOTFILES_DATA_HOME="${DOTFILES_DATA_HOME}"
  export DOTFILES_ZSH_COMPLETIONS_DIR="${ZSH_COMPLETIONS_DIR}"
  export DOTFILES_GIT_PROMPT_DIR="${GIT_PROMPT_DIR}"
  export DOTFILES_BREWFILE="${brewfile_path}"

  /bin/zsh "${HOSTNAME_MODULE}"
  /bin/zsh "${PACKAGE_INSTALL_MODULE}"
  /bin/zsh "${ZSH_INSTALL_MODULE}"
  /bin/zsh "${PREFERENCES_MODULE}"
  /bin/zsh "${UPDATE_MODULE}"
  /bin/zsh "${APP_CONFIGURE_MODULE}"
}

main() {
  case "${1:-}" in
    --help|-h)
      usage
      return 0
      ;;
    --dry-run)
      require_apple_silicon_macos
      validate_layout
      print_config
      return 0
      ;;
    "")
      ;;
    *)
      echo "Unsupported option: $1" >&2
      usage >&2
      return 1
      ;;
  esac

  require_apple_silicon_macos
  validate_layout
  run_modules
}

main "$@"
