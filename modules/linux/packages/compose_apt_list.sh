#!/bin/bash

set -eu

SCRIPT_DIR="$(CDPATH='' cd -- "$(dirname -- "$0")" && pwd)"
readonly SCRIPT_DIR
REPO_ROOT="${DOTFILES_REPO_ROOT:-$(CDPATH='' cd -- "${SCRIPT_DIR}/../../.." && pwd)}"
readonly REPO_ROOT

readonly BASE_APT_LIST="${SCRIPT_DIR}/apt.base.txt"
readonly OPTIONAL_APT_LIST="${SCRIPT_DIR}/apt.optional.txt"
readonly CANONICAL_LOCAL_OVERRIDE_APT_LIST="${SCRIPT_DIR}/local.apt.txt"

usage() {
  cat <<'EOF'
Usage: compose_apt_list.sh [--print-sources] [--output PATH]

Compose the Linux apt package list from base, optional, and local override layers.
EOF
}

print_sources() {
  printf '%s\n' "${BASE_APT_LIST}"
  printf '%s\n' "${OPTIONAL_APT_LIST}"

  if [ -f "${CANONICAL_LOCAL_OVERRIDE_APT_LIST}" ]; then
    printf '%s\n' "${CANONICAL_LOCAL_OVERRIDE_APT_LIST}"
  fi
}

compose_stream() {
  local sources

  sources="$(print_sources)"
  if [ -z "${sources}" ]; then
    return 0
  fi

  while IFS= read -r source_path; do
    [ -n "${source_path}" ] || continue
    sed -e 's/[[:space:]]*#.*$//' -e '/^[[:space:]]*$/d' "${source_path}"
  done <<EOF | awk '!seen[$0]++'
${sources}
EOF
}

main() {
  case "${1:-}" in
    --print-sources)
      print_sources
      ;;
    --output)
      if [ -z "${2:-}" ]; then
        echo '--output requires a path.' >&2
        return 1
      fi
      compose_stream > "${2}"
      ;;
    "")
      compose_stream
      ;;
    *)
      usage >&2
      return 1
      ;;
  esac
}

main "$@"
