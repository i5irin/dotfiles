#!/bin/zsh

set -eu

SCRIPT_DIR="${0:A:h}"
readonly SCRIPT_DIR
REPO_ROOT="${SCRIPT_DIR:h:h:h}"
readonly REPO_ROOT

readonly BASE_BREWFILE="${SCRIPT_DIR}/Brewfile.base"
readonly OPTIONAL_BREWFILE="${SCRIPT_DIR}/Brewfile.optional"
readonly LOCAL_OVERRIDE_BREWFILE="${SCRIPT_DIR}/local.Brewfile"

usage() {
  cat <<'EOF'
Usage: modules/macos/packages/compose_brewfile.sh [--output PATH] [--print-sources] [--help]

Compose the active macOS Brewfile from base, optional, and local override files.
EOF
}

resolve_sources() {
  typeset -ga COMPOSE_BREWFILE_SOURCES
  COMPOSE_BREWFILE_SOURCES=("${BASE_BREWFILE}" "${OPTIONAL_BREWFILE}")

  if [ -f "${LOCAL_OVERRIDE_BREWFILE}" ]; then
    COMPOSE_BREWFILE_SOURCES+=("${LOCAL_OVERRIDE_BREWFILE}")
  fi
}

emit_composed_brewfile() {
  local source_file

  for source_file in "${COMPOSE_BREWFILE_SOURCES[@]}"; do
    printf '# Source: %s\n' "${source_file}"
    cat "${source_file}"
    printf '\n'
  done
}

print_sources() {
  local source_file

  for source_file in "${COMPOSE_BREWFILE_SOURCES[@]}"; do
    printf '%s\n' "${source_file}"
  done
}

main() {
  local output_path=""
  local print_only_sources=0

  while [ "$#" -gt 0 ]; do
    case "$1" in
      --output)
        shift
        if [ "$#" -eq 0 ]; then
          echo "Missing argument for --output." >&2
          return 1
        fi
        output_path="$1"
        ;;
      --print-sources)
        print_only_sources=1
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
    shift
  done

  resolve_sources

  if [ "${print_only_sources}" -eq 1 ]; then
    print_sources
    return 0
  fi

  if [ -n "${output_path}" ]; then
    emit_composed_brewfile > "${output_path}"
    return 0
  fi

  emit_composed_brewfile
}

main "$@"
