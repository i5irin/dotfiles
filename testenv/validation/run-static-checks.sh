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

macos_base_has_package() {
  local package_name="$1"

  awk -F'"' '/^(brew|cask) / { print $2 }' "${REPO_ROOT}/modules/macos/packages/Brewfile.base" \
    | grep -Fx "${package_name}" > /dev/null 2>&1
}

macos_optional_only_has_package() {
  local package_name="$1"

  ! macos_base_has_package "${package_name}" \
    && awk -F'"' '/^(brew|cask) / { print $2 }' "${REPO_ROOT}/modules/macos/packages/Brewfile.optional" \
      | grep -Fx "${package_name}" > /dev/null 2>&1
}

macos_base_lacks_package() {
  local package_name="$1"

  ! macos_base_has_package "${package_name}"
}

macos_base_lacks_node_formula() {
  ! awk -F'"' '/^brew / { print $2 }' "${REPO_ROOT}/modules/macos/packages/Brewfile.base" \
    | grep -Eq '^node(@.*)?$'
}

macos_package_layers_have_no_duplicates() {
  local duplicates

  duplicates="$(
    awk -F'"' '/^(brew|cask|mas) / { print $1 ":" $2 }' \
      "${REPO_ROOT}/modules/macos/packages/Brewfile.base" \
      "${REPO_ROOT}/modules/macos/packages/Brewfile.optional" \
      | sort \
      | uniq -d
  )"

  [ -z "${duplicates}" ]
}

macos_rosetta_defaults_off() {
  grep -Fx 'DOTFILES_INSTALL_ROSETTA=0' "${REPO_ROOT}/config/macos.env.sample" > /dev/null 2>&1 \
    && grep -F 'readonly INSTALL_ROSETTA="${DOTFILES_INSTALL_ROSETTA:-0}"' \
      "${REPO_ROOT}/modules/macos/bootstrap/run.sh" > /dev/null 2>&1 \
    && grep -F 'readonly INSTALL_ROSETTA="${DOTFILES_INSTALL_ROSETTA:-0}"' \
      "${REPO_ROOT}/modules/macos/packages/install.sh" > /dev/null 2>&1
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
  "${REPO_ROOT}/modules/linux/rerun/install-apps.sh" \
  "${REPO_ROOT}/modules/linux/rerun/configure-shell.sh" \
  "${REPO_ROOT}/modules/linux/rerun/apply-preferences.sh" \
  "${REPO_ROOT}/modules/linux/rerun/register-update-job.sh" \
  "${REPO_ROOT}/modules/linux/rerun/configure-apps.sh" \
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
  "${REPO_ROOT}/modules/macos/rerun/install-apps.sh" \
  "${REPO_ROOT}/modules/macos/rerun/configure-shell.sh" \
  "${REPO_ROOT}/modules/macos/rerun/apply-preferences.sh" \
  "${REPO_ROOT}/modules/macos/rerun/register-update-job.sh" \
  "${REPO_ROOT}/modules/macos/rerun/configure-apps.sh" \
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
run_check 'macOS rerun help output' "${REPO_ROOT}/bootstrap/macos.sh" --only configure-apps --help
run_check 'Linux rerun help output' "${REPO_ROOT}/bootstrap/linux.sh" --only configure-apps --help

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
  run_check 'Windows rerun help output' pwsh -NoProfile -NonInteractive -File "${REPO_ROOT}/bootstrap/windows.ps1" -Only configure-apps -Help
elif command -v powershell > /dev/null 2>&1; then
  run_check 'Windows help output' powershell -NoProfile -NonInteractive -File "${REPO_ROOT}/bootstrap/windows.ps1" -Help
  run_check 'Windows rerun help output' powershell -NoProfile -NonInteractive -File "${REPO_ROOT}/bootstrap/windows.ps1" -Only configure-apps -Help
else
  skip_check 'Windows help output (pwsh/powershell not found)'
  skip_check 'Windows rerun help output (pwsh/powershell not found)'
fi

log_section 'Package composition'
run_check 'macOS package sources' "${REPO_ROOT}/modules/macos/packages/compose_brewfile.sh" --print-sources
run_check 'Linux package sources' "${REPO_ROOT}/modules/linux/packages/compose_apt_list.sh" --print-sources
for package_name in git git-lfs gh curl jq ripgrep fd tree tmux starship neovim ghostty visual-studio-code fnm pnpm uv go rustup; do
  run_check "macOS base package: ${package_name}" macos_base_has_package "${package_name}"
done
run_check 'macOS base excludes Homebrew Node.js' macos_base_lacks_node_formula
run_check 'macOS base excludes Homebrew Rust' macos_base_lacks_package rust
for package_name in gcc hugo openjdk; do
  run_check "macOS optional-only package: ${package_name}" macos_optional_only_has_package "${package_name}"
done
run_check 'macOS package layers have no duplicates' macos_package_layers_have_no_duplicates
run_check 'fnm shell integration uses project-aware stable options' \
  grep -Fq 'fnm env --use-on-cd --version-file-strategy=recursive --shell zsh' \
    "${REPO_ROOT}/modules/shell/zsh/.zshrc"
run_check 'Go-installed commands use the default GOPATH bin directory' \
  grep -Fq 'add_path "${HOME}/go/bin"' "${REPO_ROOT}/modules/shell/zsh/.zprofile"
run_check 'Homebrew rustup proxies are on PATH' \
  grep -Fq 'add_path "${HOMEBREW_PREFIX}/opt/rustup/bin"' \
    "${REPO_ROOT}/modules/shell/zsh/.zprofile"
run_check 'macOS Rosetta default is off' macos_rosetta_defaults_off

log_section 'Generated assets'
run_check 'terminal asset sync' "${REPO_ROOT}/modules/cli/terminal/render-assets.sh" --check

printf '\nSummary: failed=%s skipped=%s\n' "${FAILED_CHECKS}" "${SKIPPED_CHECKS}"

if [ "${FAILED_CHECKS}" -ne 0 ]; then
  exit 1
fi
