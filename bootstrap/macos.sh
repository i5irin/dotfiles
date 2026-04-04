#!/bin/zsh

set -eu

SCRIPT_DIR="${0:A:h}"
readonly SCRIPT_DIR
REPO_ROOT="${SCRIPT_DIR:h}"
readonly REPO_ROOT

readonly BOOTSTRAP_MODULE="${REPO_ROOT}/modules/macos/bootstrap/run.sh"

if [ ! -x "${BOOTSTRAP_MODULE}" ]; then
  echo "macOS bootstrap module was not found or not executable: ${BOOTSTRAP_MODULE}" >&2
  exit 1
fi

exec /bin/zsh "${BOOTSTRAP_MODULE}" "$@"
