#!/bin/sh

set -eu

SCRIPT_DIR="$(CDPATH='' cd -- "$(dirname -- "$0")" && pwd)"
readonly SCRIPT_DIR
REPO_ROOT="${DOTFILES_REPO_ROOT:-$(CDPATH='' cd -- "${SCRIPT_DIR}/../../.." && pwd)}"
readonly REPO_ROOT

readonly VSCODE_SETTINGS_ASSET="${REPO_ROOT}/assets/cli/vscode/settings.json"
readonly VSCODE_EXTENSIONS_FILE="${REPO_ROOT}/assets/cli/vscode/extensions"

resolve_code_command() {
  if command -v code > /dev/null 2>&1; then
    command -v code
    return 0
  fi

  case "$(uname -s)" in
    Darwin)
      if [ -x '/Applications/Visual Studio Code.app/Contents/Resources/app/bin/code' ]; then
        printf '%s\n' '/Applications/Visual Studio Code.app/Contents/Resources/app/bin/code'
        return 0
      fi

      if [ -x "${HOME}/Applications/Visual Studio Code.app/Contents/Resources/app/bin/code" ]; then
        printf '%s\n' "${HOME}/Applications/Visual Studio Code.app/Contents/Resources/app/bin/code"
        return 0
      fi
      ;;
  esac

  return 1
}

resolve_vscode_user_dir() {
  if [ -n "${DOTFILES_VSCODE_USER_DIR:-}" ]; then
    printf '%s\n' "${DOTFILES_VSCODE_USER_DIR}"
    return 0
  fi

  if [ "$(uname -s)" = 'Darwin' ]; then
    printf '%s\n' "${HOME}/Library/Application Support/Code/User"
    return 0
  fi

  printf '%s\n' "${HOME}/.config/Code/User"
}

install_extensions() {
  local extension
  local installed_extensions
  local code_command

  if ! code_command="$(resolve_code_command)"; then
    return 0
  fi

  installed_extensions="$("${code_command}" --list-extensions 2> /dev/null || true)"
  while IFS= read -r extension; do
    if [ -z "${extension}" ]; then
      continue
    fi

    if printf '%s\n' "${installed_extensions}" | grep -Fx "${extension}" > /dev/null 2>&1; then
      continue
    fi

    "${code_command}" --install-extension "${extension}" --force > /dev/null

    installed_extensions="$("${code_command}" --list-extensions 2> /dev/null || true)"
    if ! printf '%s\n' "${installed_extensions}" | grep -Fx "${extension}" > /dev/null 2>&1; then
      echo "Failed to install VS Code extension: ${extension}" >&2
      return 1
    fi
  done < "${VSCODE_EXTENSIONS_FILE}"
}

main() {
  VSCODE_USER_DIR="$(resolve_vscode_user_dir)"
  readonly VSCODE_USER_DIR

  mkdir -p "${VSCODE_USER_DIR}"
  install_extensions
  ln -sfn "${VSCODE_SETTINGS_ASSET}" "${VSCODE_USER_DIR}/settings.json"
}

main "$@"
