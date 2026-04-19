#!/bin/bash

set -eu

SCRIPT_DIR="$(CDPATH='' cd -- "$(dirname -- "$0")" && pwd)"
readonly SCRIPT_DIR
REPO_ROOT="$(CDPATH='' cd -- "${SCRIPT_DIR}/../.." && pwd)"
readonly REPO_ROOT

FAILED_CHECKS=0
SKIPPED_CHECKS=0

log_section() {
  printf '\n==> %s\n' "$1"
}

pass_check() {
  printf 'PASS: %s\n' "$1"
}

fail_check() {
  printf 'FAIL: %s\n' "$1" >&2
  FAILED_CHECKS=$((FAILED_CHECKS + 1))
}

skip_check() {
  printf 'SKIP: %s\n' "$1"
  SKIPPED_CHECKS=$((SKIPPED_CHECKS + 1))
}

run_check() {
  local label="$1"
  shift

  if "$@"; then
    pass_check "${label}"
  else
    fail_check "${label}"
  fi
}

run_powershell_parse() {
  local shell_command
  local script

  if command -v pwsh > /dev/null 2>&1; then
    shell_command='pwsh'
  elif command -v powershell > /dev/null 2>&1; then
    shell_command='powershell'
  else
    return 125
  fi

  script='
$ErrorActionPreference = "Stop"
$files = Get-ChildItem -Path "'"${REPO_ROOT}"'/bootstrap","'"${REPO_ROOT}"'/modules" -Recurse -Include *.ps1,*.psm1 | Select-Object -ExpandProperty FullName
$failed = $false
foreach ($file in $files) {
  $tokens = $null
  $errors = $null
  [System.Management.Automation.Language.Parser]::ParseFile($file, [ref]$tokens, [ref]$errors) | Out-Null
  if ($errors.Count -gt 0) {
    $failed = $true
    foreach ($errorRecord in $errors) {
      Write-Error "$file: $($errorRecord.Message)"
    }
  }
}
if ($failed) { exit 1 }
'

  "$shell_command" -NoProfile -NonInteractive -Command "$script"
}

log_section 'Shell syntax'
run_check 'bash syntax' \
  bash -n \
  "${REPO_ROOT}/bootstrap/linux.sh" \
  "${REPO_ROOT}/modules/linux/bootstrap/run.sh" \
  "${REPO_ROOT}/modules/linux/packages/compose_apt_list.sh" \
  "${REPO_ROOT}/modules/linux/packages/install.sh" \
  "${REPO_ROOT}/modules/linux/update/register_cron.sh" \
  "${REPO_ROOT}/modules/linux/update/update_packages.sh" \
  "${REPO_ROOT}/modules/linux/apps/configure.sh" \
  "${REPO_ROOT}/modules/shell/bash/install.sh" \
  "${REPO_ROOT}/modules/shared/shell/alias.sh" \
  "${REPO_ROOT}/modules/shared/shell/functions.sh" \
  "${REPO_ROOT}/modules/shared/utils/message.sh" \
  "${REPO_ROOT}/modules/shared/utils/posix.sh"

run_check 'zsh syntax' \
  zsh -n \
  "${REPO_ROOT}/bootstrap/macos.sh" \
  "${REPO_ROOT}/modules/macos/bootstrap/run.sh" \
  "${REPO_ROOT}/modules/macos/packages/compose_brewfile.sh" \
  "${REPO_ROOT}/modules/macos/packages/install.sh" \
  "${REPO_ROOT}/modules/macos/system/configure_hostnames.sh" \
  "${REPO_ROOT}/modules/macos/preferences/apply.sh" \
  "${REPO_ROOT}/modules/macos/update/register_launch_agent.sh" \
  "${REPO_ROOT}/modules/macos/update/update_applications.sh" \
  "${REPO_ROOT}/modules/macos/apps/configure.sh" \
  "${REPO_ROOT}/modules/shell/zsh/install.sh"

if run_powershell_parse; then
  pass_check 'PowerShell parse'
else
  case "$?" in
    125)
      skip_check 'PowerShell parse (pwsh/powershell not found)'
      ;;
    *)
      fail_check 'PowerShell parse'
      ;;
  esac
fi

log_section 'Bootstrap entry points'
run_check 'macOS help output' "${REPO_ROOT}/bootstrap/macos.sh" --help
run_check 'Linux help output' "${REPO_ROOT}/bootstrap/linux.sh" --help

if [ "$(uname -s)" = 'Darwin' ] && [ "$(uname -m)" = 'arm64' ]; then
  run_check 'macOS dry-run output' "${REPO_ROOT}/bootstrap/macos.sh" --dry-run
else
  skip_check 'macOS dry-run output (host is not Apple Silicon macOS)'
fi

if [ "$(uname -s)" = 'Linux' ] && command -v apt-get > /dev/null 2>&1; then
  run_check 'Linux dry-run output' "${REPO_ROOT}/bootstrap/linux.sh" --dry-run
else
  skip_check 'Linux dry-run output (host is not Ubuntu/Debian-family Linux)'
fi

if command -v pwsh > /dev/null 2>&1; then
  run_check 'Windows help output' pwsh -NoProfile -NonInteractive -File "${REPO_ROOT}/bootstrap/windows.ps1" -Help
elif command -v powershell > /dev/null 2>&1; then
  run_check 'Windows help output' powershell -NoProfile -NonInteractive -File "${REPO_ROOT}/bootstrap/windows.ps1" -Help
else
  skip_check 'Windows help output (pwsh/powershell not found)'
fi

log_section 'Package composition'
run_check 'macOS package sources' "${REPO_ROOT}/modules/macos/packages/compose_brewfile.sh" --print-sources
run_check 'Linux package sources' "${REPO_ROOT}/modules/linux/packages/compose_apt_list.sh" --print-sources

log_section 'Generated assets'
run_check 'terminal asset sync' "${REPO_ROOT}/modules/cli/terminal/render-assets.sh" --check

printf '\nSummary: failed=%s skipped=%s\n' "${FAILED_CHECKS}" "${SKIPPED_CHECKS}"

if [ "${FAILED_CHECKS}" -ne 0 ]; then
  exit 1
fi
