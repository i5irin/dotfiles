#!/bin/bash

set -eu

SCRIPT_DIR="$(CDPATH='' cd -- "$(dirname -- "$0")" && pwd)"
readonly SCRIPT_DIR
REPO_ROOT="$(CDPATH='' cd -- "${SCRIPT_DIR}/../../.." && pwd)"
readonly REPO_ROOT

MODE='smoke'
IMAGE_TAG='dotfiles-linux-validation:ubuntu-24.04'

usage() {
  cat <<'EOF'
Usage: testenv/linux-container/ubuntu-24.04/run-validation.sh [--full] [--help]

Run Linux validation in an Ubuntu 24.04 container.

Options:
  --full  Run bootstrap/linux.sh instead of dry-run only.
  --help  Show this help message.

Environment:
  DOTFILES_GIT_USER_NAME
  DOTFILES_GIT_USER_EMAIL
  DOTFILES_LINUX_ENABLE_AUTO_UPDATE
EOF
}

resolve_runtime() {
  if command -v docker > /dev/null 2>&1; then
    printf '%s\n' 'docker'
    return 0
  fi

  if command -v podman > /dev/null 2>&1; then
    printf '%s\n' 'podman'
    return 0
  fi

  echo 'docker or podman is required to run Linux container validation.' >&2
  return 1
}

main() {
  local runtime
  local container_command

  while [ "$#" -gt 0 ]; do
    case "$1" in
      --full)
        MODE='full'
        shift
        ;;
      --help|-h)
        usage
        return 0
        ;;
      *)
        echo "Unsupported option: $1" >&2
        usage >&2
        return 1
        ;;
    esac
  done

  runtime="$(resolve_runtime)"

  "${runtime}" build -t "${IMAGE_TAG}" "${SCRIPT_DIR}"

  if [ "${MODE}" = 'full' ]; then
    if [ -z "${DOTFILES_GIT_USER_NAME:-}" ] || [ -z "${DOTFILES_GIT_USER_EMAIL:-}" ]; then
      echo 'DOTFILES_GIT_USER_NAME and DOTFILES_GIT_USER_EMAIL are required for --full.' >&2
      return 1
    fi

    container_command='cd /work/dotfiles && ./testenv/validation/run-static-checks.sh && ./bootstrap/linux.sh'
  else
    container_command='cd /work/dotfiles && ./testenv/validation/run-static-checks.sh && ./bootstrap/linux.sh --dry-run'
  fi

  "${runtime}" run --rm \
    -e DOTFILES_GIT_USER_NAME="${DOTFILES_GIT_USER_NAME:-}" \
    -e DOTFILES_GIT_USER_EMAIL="${DOTFILES_GIT_USER_EMAIL:-}" \
    -e DOTFILES_LINUX_ENABLE_AUTO_UPDATE="${DOTFILES_LINUX_ENABLE_AUTO_UPDATE:-0}" \
    -v "${REPO_ROOT}:/work/dotfiles" \
    "${IMAGE_TAG}" \
    /bin/bash -lc "${container_command}"
}

main "$@"
