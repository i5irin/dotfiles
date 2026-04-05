#!/bin/bash

set -eu

SCRIPT_DIR="$(CDPATH='' cd -- "$(dirname -- "$0")" && pwd)"
readonly SCRIPT_DIR

CONFIG_PATH="${DOTFILES_PARALLELS_CONFIG:-${SCRIPT_DIR}/config.env}"
CREATE_MISSING=0

usage() {
  cat <<'EOF'
Usage: testenv/parallels/preflight.sh [--config <path>] [--create-missing] [--help]

Validate that the host-side Parallels setup is ready for manual VM validation.

Options:
  --config <path>  Path to the Parallels config file.
  --create-missing Create the target VM by cloning the configured template/golden VM when missing.
  --help           Show this help message.
EOF
}

print_parallels_init_guidance() {
  cat <<'EOF'
Parallels Desktop is installed, but prlctl could not initialize in unattended mode.
Start Parallels Desktop once from the GUI, then rerun this preflight.
If Parallels still fails to initialize, use the inittool2 command shown by prlctl.
EOF
}

vm_exists() {
  local vm_name="$1"

  prlctl list --output name --all --no-header | grep -Fx "${vm_name}" > /dev/null 2>&1
}

clone_vm() {
  local label="$1"
  local source_name="$2"
  local vm_name="$3"

  if [ -z "${source_name}" ]; then
    printf 'FAIL: %s VM is missing and no template/golden source is configured.\n' "${label}" >&2
    return 1
  fi

  if [ "${source_name}" = "${vm_name}" ]; then
    printf 'FAIL: %s VM name and template/golden source must differ: %s\n' "${label}" "${vm_name}" >&2
    return 1
  fi

  if ! vm_exists "${source_name}"; then
    printf 'FAIL: %s template/golden source was not found in Parallels: %s\n' "${label}" "${source_name}" >&2
    return 1
  fi

  printf 'INFO: creating %s VM "%s" from "%s"\n' "${label}" "${vm_name}" "${source_name}"
  printf 'INFO: the source VM should be shut down before cloning.\n'
  prlctl clone "${source_name}" --name "${vm_name}"
}

ensure_vm() {
  local label="$1"
  local vm_name="$2"
  local source_name="$3"
  local repo_path="$4"

  if [ -z "${vm_name}" ]; then
    printf 'SKIP: %s VM name is not configured.\n' "${label}"
    return 0
  fi

  if ! vm_exists "${vm_name}"; then
    if [ "${CREATE_MISSING}" = '1' ]; then
      clone_vm "${label}" "${source_name}" "${vm_name}"
    else
      printf 'FAIL: %s VM was not found in Parallels: %s\n' "${label}" "${vm_name}" >&2
      printf 'INFO: rerun with --create-missing after setting the corresponding template/golden source in config.env.\n' >&2
      return 1
    fi
  fi

  if ! vm_exists "${vm_name}"; then
    printf 'FAIL: %s VM was not found in Parallels: %s\n' "${label}" "${vm_name}" >&2
    return 1
  fi

  printf 'PASS: %s VM found: %s\n' "${label}" "${vm_name}"
  if [ -n "${source_name}" ]; then
    printf 'INFO: %s clone source: %s\n' "${label}" "${source_name}"
  fi
  if [ -n "${repo_path}" ]; then
    printf 'INFO: %s repo path inside guest: %s\n' "${label}" "${repo_path}"
  fi
}

main() {
  local macos_vm_name=''
  local windows_vm_name=''
  local macos_template_name=''
  local windows_template_name=''
  local macos_repo_path=''
  local windows_repo_path=''

  while [ "$#" -gt 0 ]; do
    case "$1" in
      --config)
        CONFIG_PATH="$2"
        shift 2
        ;;
      --create-missing)
        CREATE_MISSING=1
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

  if ! command -v prlctl > /dev/null 2>&1; then
    echo 'prlctl was not found. Install Parallels Desktop and its command line tools.' >&2
    return 1
  fi

  if ! prlctl list -a > /dev/null 2>&1; then
    print_parallels_init_guidance >&2
    return 1
  fi

  if [ -f "${CONFIG_PATH}" ]; then
    # shellcheck disable=SC1090
    . "${CONFIG_PATH}"
    macos_vm_name="${DOTFILES_PARALLELS_MACOS_VM_NAME:-}"
    windows_vm_name="${DOTFILES_PARALLELS_WINDOWS_VM_NAME:-}"
    macos_template_name="${DOTFILES_PARALLELS_MACOS_TEMPLATE_NAME:-}"
    windows_template_name="${DOTFILES_PARALLELS_WINDOWS_TEMPLATE_NAME:-}"
    macos_repo_path="${DOTFILES_PARALLELS_MACOS_REPO_PATH:-}"
    windows_repo_path="${DOTFILES_PARALLELS_WINDOWS_REPO_PATH:-}"
    printf 'INFO: loaded config: %s\n' "${CONFIG_PATH}"
  else
    printf 'INFO: config file not found: %s\n' "${CONFIG_PATH}"
    printf 'INFO: copy testenv/parallels/config.env.sample to that path before guest validation.\n'
  fi

  ensure_vm 'macOS' "${macos_vm_name}" "${macos_template_name}" "${macos_repo_path}"
  ensure_vm 'Windows' "${windows_vm_name}" "${windows_template_name}" "${windows_repo_path}"

  cat <<EOF

Next commands to run inside each guest:

macOS:
  cd "${macos_repo_path:-/Users/<vm-user>/dotfiles}"
  cp config/macos.env.sample config/macos.env
  ./testenv/validation/run-static-checks.sh
  ./bootstrap/macos.sh --dry-run
  ./bootstrap/macos.sh

Windows (run in elevated PowerShell):
  Set-Location "${windows_repo_path:-C:\Users\<vm-user>\dotfiles}"
  Copy-Item config/windows.env.sample config/windows.env
  .\bootstrap\windows.ps1 -DryRun
  .\bootstrap\windows.ps1

Clone behavior:
  --create-missing uses: prlctl clone <template-or-golden-vm> --name <target-vm>
  The source VM should be shut down before cloning.
EOF
}

main "$@"
