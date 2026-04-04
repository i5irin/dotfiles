#!/bin/bash

set -eu

SCRIPT_DIR="$(CDPATH='' cd -- "$(dirname -- "$0")" && pwd)"
readonly SCRIPT_DIR
REPO_ROOT="$(CDPATH='' cd -- "${SCRIPT_DIR}/.." && pwd)"
readonly REPO_ROOT

readonly BOOTSTRAP_MODULE="${REPO_ROOT}/modules/linux/bootstrap/run.sh"

if [ ! -x "${BOOTSTRAP_MODULE}" ]; then
  echo "Linux bootstrap module was not found or not executable: ${BOOTSTRAP_MODULE}" >&2
  exit 1
fi

exec /bin/bash "${BOOTSTRAP_MODULE}" "$@"
