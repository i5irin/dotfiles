#!/bin/sh

set -eu

SCRIPT_DIR="$(CDPATH='' cd -- "$(dirname -- "$0")" && pwd)"
readonly SCRIPT_DIR
REPO_ROOT="${DOTFILES_REPO_ROOT:-$(CDPATH='' cd -- "${SCRIPT_DIR}/../../.." && pwd)}"
readonly REPO_ROOT

readonly GIT_CONFIG_ASSET="${REPO_ROOT}/assets/cli/git/.gitconfig"
readonly DOTFILES_DATA_HOME="${DOTFILES_DATA_HOME:-${XDG_DATA_HOME:-${HOME}/.local/share}/dotfiles}"
readonly GIT_PROMPT_DIR="${DOTFILES_GIT_PROMPT_DIR:-${DOTFILES_DATA_HOME}/git-prompt}"

validate_github_username() {
  if echo "$1" | grep -q -E '^[a-zA-Z0-9]([a-zA-Z0-9]?|[\-]?([a-zA-Z0-9])){0,38}$'; then
    return 0
  fi

  echo 'The username you entered is invalid for GitHub.' >&2
  return 1
}

prompt_for_git_identity() {
  git_user_name=''
  git_user_email=''
  answer=''

  while true; do
    printf 'Enter your name for use in git > '
    IFS= read -r git_user_name
    printf 'Enter your email address for use in git > '
    IFS= read -r git_user_email

    if ! validate_github_username "${git_user_name}"; then
      continue
    fi

    while true; do
      printf 'Make sure name(%s) and email(%s) you input, is this ok? [Y/n] > ' "${git_user_name}" "${git_user_email}"
      read -r answer
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
        printf '%s\n%s\n' "${git_user_name}" "${git_user_email}"
        return 0
        ;;
    esac
  done
}

configure_include_path() {
  if ! git config --global --get-all include.path | grep -Fx "${GIT_CONFIG_ASSET}" > /dev/null 2>&1; then
    git config --global --add include.path "${GIT_CONFIG_ASSET}"
  fi
}

install_git_prompt() {
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
    validate_github_username "${git_user_name}"
  else
    identity_lines="$(prompt_for_git_identity)"
    git_user_name="$(printf '%s\n' "${identity_lines}" | sed -n '1p')"
    git_user_email="$(printf '%s\n' "${identity_lines}" | sed -n '2p')"
  fi

  configure_include_path
  git config --global user.name "${git_user_name}"
  git config --global user.email "${git_user_email}"
  install_git_prompt
}

main "$@"
