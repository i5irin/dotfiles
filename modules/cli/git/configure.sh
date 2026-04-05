#!/bin/sh

set -eu

SCRIPT_DIR="$(CDPATH='' cd -- "$(dirname -- "$0")" && pwd)"
readonly SCRIPT_DIR
REPO_ROOT="${DOTFILES_REPO_ROOT:-$(CDPATH='' cd -- "${SCRIPT_DIR}/../../.." && pwd)}"
readonly REPO_ROOT

readonly GIT_CONFIG_ASSET="${REPO_ROOT}/assets/cli/git/.gitconfig"
readonly DOTFILES_DATA_HOME="${DOTFILES_DATA_HOME:-${XDG_DATA_HOME:-${HOME}/.local/share}/dotfiles}"
readonly GIT_PROMPT_DIR="${DOTFILES_GIT_PROMPT_DIR:-${DOTFILES_DATA_HOME}/git-prompt}"
readonly DOTFILES_STATE_DIR="${DOTFILES_DATA_HOME}/state"
readonly GIT_IDENTITY_STATE_FILE="${DOTFILES_STATE_DIR}/git-identity"

validate_git_user_name() {
  if [ -n "$1" ]; then
    return 0
  fi

  echo 'The git user name must not be empty.' >&2
  return 1
}

validate_git_user_email() {
  if echo "$1" | grep -q -E '.+@.+'; then
    return 0
  fi

  echo 'The git user email must include "@".' >&2
  return 1
}

load_identity_from_git_config() {
  current_git_user_name="$(git config --global --get user.name 2> /dev/null || true)"
  current_git_user_email="$(git config --global --get user.email 2> /dev/null || true)"

  if [ -n "${current_git_user_name}" ] && [ -n "${current_git_user_email}" ]; then
    printf '%s\n%s\n' "${current_git_user_name}" "${current_git_user_email}"
    return 0
  fi

  return 1
}

load_identity_from_state() {
  if [ ! -f "${GIT_IDENTITY_STATE_FILE}" ]; then
    return 1
  fi

  state_git_user_name="$(sed -n '1p' "${GIT_IDENTITY_STATE_FILE}")"
  state_git_user_email="$(sed -n '2p' "${GIT_IDENTITY_STATE_FILE}")"

  if [ -n "${state_git_user_name}" ] && [ -n "${state_git_user_email}" ]; then
    printf '%s\n%s\n' "${state_git_user_name}" "${state_git_user_email}"
    return 0
  fi

  return 1
}

persist_git_identity() {
  mkdir -p "${DOTFILES_STATE_DIR}"
  umask 077 && printf '%s\n%s\n' "$1" "$2" > "${GIT_IDENTITY_STATE_FILE}"
}

configure_include_path() {
  if ! git config --global --get-all include.path | grep -Fx "${GIT_CONFIG_ASSET}" > /dev/null 2>&1; then
    git config --global --add include.path "${GIT_CONFIG_ASSET}"
  fi
}

install_git_prompt() {
  if [ -s "${GIT_PROMPT_DIR}/git-prompt.sh" ] && [ "${DOTFILES_REFRESH_GIT_PROMPT:-0}" != '1' ]; then
    return 0
  fi

  mkdir -p "${GIT_PROMPT_DIR}"
  curl -fsSL 'https://raw.githubusercontent.com/git/git/master/contrib/completion/git-prompt.sh' \
    -o "${GIT_PROMPT_DIR}/git-prompt.sh"
}

main() {
  git_user_name=''
  git_user_email=''
  identity_lines=''

  if [ -n "${DOTFILES_GIT_USER_NAME:-}" ] && [ -n "${DOTFILES_GIT_USER_EMAIL:-}" ]; then
    git_user_name="${DOTFILES_GIT_USER_NAME}"
    git_user_email="${DOTFILES_GIT_USER_EMAIL}"
  elif identity_lines="$(load_identity_from_git_config)"; then
    git_user_name="$(printf '%s\n' "${identity_lines}" | sed -n '1p')"
    git_user_email="$(printf '%s\n' "${identity_lines}" | sed -n '2p')"
  elif identity_lines="$(load_identity_from_state)"; then
    git_user_name="$(printf '%s\n' "${identity_lines}" | sed -n '1p')"
    git_user_email="$(printf '%s\n' "${identity_lines}" | sed -n '2p')"
  else
    echo "Git identity is not configured. Set DOTFILES_GIT_USER_NAME and DOTFILES_GIT_USER_EMAIL in ${DOTFILES_BOOTSTRAP_CONFIG_PATH:-config/<platform>.env} or in the environment." >&2
    return 1
  fi

  validate_git_user_name "${git_user_name}"
  validate_git_user_email "${git_user_email}"
  configure_include_path
  git config --global user.name "${git_user_name}"
  git config --global user.email "${git_user_email}"
  persist_git_identity "${git_user_name}" "${git_user_email}"
  install_git_prompt
}

main "$@"
