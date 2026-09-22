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

source_posix_libraries() {
  local shell_command="$1"

  "$shell_command" -c '
    set -eu
    . "$1"
    . "$2"
    . "$3"
    . "$4"
    . "$5"
    original_path=$PATH
    readlinkf . > /dev/null
    [ "$PATH" = "$original_path" ]
    load_dotfiles_env_file "$6"
    case $- in *a*) exit 1;; esac
    set -a
    load_dotfiles_env_file "$6"
    case $- in *a*) :;; *) exit 1;; esac
  ' validation-shell \
    "${REPO_ROOT}/modules/shared/utils/load_env.sh" \
    "${REPO_ROOT}/modules/shared/utils/message.sh" \
    "${REPO_ROOT}/modules/shared/utils/posix.sh" \
    "${REPO_ROOT}/modules/shared/utils/posix_app_config.sh" \
    "${REPO_ROOT}/modules/shared/utils/sudo.sh" \
    "${REPO_ROOT}/config/linux.env.sample"
}

source_interactive_shell_library() {
  local shell_command="$1"

  "$shell_command" -c '
    set -eu
    . "$1"
    . "$2"
  ' validation-shell \
    "${REPO_ROOT}/modules/shared/shell/functions.sh" \
    "${REPO_ROOT}/modules/shared/shell/alias.sh"
}

source_only_libraries_are_clear() {
  local library_path

  for library_path in \
    "${REPO_ROOT}/modules/shared/shell/alias.sh" \
    "${REPO_ROOT}/modules/shared/shell/functions.sh" \
    "${REPO_ROOT}/modules/shared/utils/dotfiles.sh" \
    "${REPO_ROOT}/modules/shared/utils/load_env.sh" \
    "${REPO_ROOT}/modules/shared/utils/message.sh" \
    "${REPO_ROOT}/modules/shared/utils/posix.sh" \
    "${REPO_ROOT}/modules/shared/utils/posix_app_config.sh" \
    "${REPO_ROOT}/modules/shared/utils/sudo.sh"
  do
    if [ -x "${library_path}" ] || head -n 1 "${library_path}" | grep -q '^#!'; then
      return 1
    fi
  done
}

rerun_wrappers_show_help() {
  local wrapper_path

  for wrapper_path in \
    "${REPO_ROOT}/modules/macos/rerun/install-apps.sh" \
    "${REPO_ROOT}/modules/macos/rerun/configure-shell.sh" \
    "${REPO_ROOT}/modules/macos/rerun/apply-preferences.sh" \
    "${REPO_ROOT}/modules/macos/rerun/register-update-job.sh" \
    "${REPO_ROOT}/modules/macos/rerun/configure-apps.sh" \
    "${REPO_ROOT}/modules/linux/rerun/install-apps.sh" \
    "${REPO_ROOT}/modules/linux/rerun/configure-shell.sh" \
    "${REPO_ROOT}/modules/linux/rerun/apply-preferences.sh" \
    "${REPO_ROOT}/modules/linux/rerun/register-update-job.sh" \
    "${REPO_ROOT}/modules/linux/rerun/configure-apps.sh"
  do
    "${wrapper_path}" --help > /dev/null
  done
}

readme_entry_points_exist() {
  local entry_point

  for entry_point in bootstrap/macos.sh bootstrap/windows.ps1 bootstrap/linux.sh; do
    [ -f "${REPO_ROOT}/${entry_point}" ] \
      && grep -Fq "(${entry_point})" "${REPO_ROOT}/README.md" \
      || return 1
  done
}

local_override_paths_are_ignored() {
  local override_path

  for override_path in \
    config/macos.env \
    config/windows.env \
    config/linux.env \
    modules/macos/packages/local.Brewfile \
    modules/windows/packages/local.Winget.json \
    modules/linux/packages/local.apt.txt \
    modules/shell/zsh/.zshrc.local \
    modules/shell/bash/.bashrc.local \
    modules/shell/powershell/Microsoft.PowerShell_profile.local.ps1
  do
    git -C "${REPO_ROOT}" check-ignore -q -- "${override_path}" || return 1
  done
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

macos_tracked_catalogs_lack_package() {
  local package_name="$1"

  ! awk -F'"' '/^(brew|cask) / { print $2 }' \
    "${REPO_ROOT}/modules/macos/packages/Brewfile.base" \
    "${REPO_ROOT}/modules/macos/packages/Brewfile.optional" \
    | grep -Fx "${package_name}" > /dev/null 2>&1
}

macos_base_lacks_node_formula() {
  ! awk -F'"' '/^brew / { print $2 }' "${REPO_ROOT}/modules/macos/packages/Brewfile.base" \
    | grep -Eq '^node(@.*)?$'
}

fnm_shell_contract_is_tracked() {
  local zshrc="${REPO_ROOT}/modules/shell/zsh/.zshrc"

  grep -Fq 'fnm env --version-file-strategy=recursive --resolve-engines=false --shell zsh' "${zshrc}" \
    && ! grep -Fq 'fnm env --use-on-cd' "${zshrc}" \
    && grep -Fq '[[ -f "${search_dir}/.node-version" || -f "${search_dir}/.nvmrc" ]]' "${zshrc}" \
    && grep -Fq 'fnm use --silent-if-unchanged' "${zshrc}" \
    && grep -Fq 'add-zsh-hook chpwd _dotfiles_fnm_use_project_version' "${zshrc}" \
    && grep -Fq '_dotfiles_fnm_use_project_version' "${zshrc}"
}

docker_compose_plugin_contract_is_tracked() {
  local configure_script="${REPO_ROOT}/modules/macos/apps/configure.sh"

  grep -Fq '${HOMEBREW_PREFIX}/lib/docker/cli-plugins/docker-compose' "${configure_script}" \
    && grep -Fq '${HOME}/.docker/cli-plugins' "${configure_script}" \
    && grep -Fq 'ln -sfn "${compose_plugin_source}" "${compose_plugin_link}"' "${configure_script}" \
    && ! grep -Fq '.docker/config.json' "${configure_script}"
}

agent_assets_contract_is_tracked() {
  local configure_script="${REPO_ROOT}/modules/macos/apps/configure.sh"
  local global_instructions="${REPO_ROOT}/assets/agents/instructions/global.md"
  local skill_file="${REPO_ROOT}/assets/agents/skills/constraint-first-review/SKILL.md"

  [ -s "${global_instructions}" ] \
    && [ -s "${skill_file}" ] \
    && grep -Fq 'name: constraint-first-review' "${skill_file}" \
    && grep -Fq '${HOME}/.codex/AGENTS.md' "${configure_script}" \
    && grep -Fq '${HOME}/.agents/skills/constraint-first-review' "${configure_script}" \
    && grep -Fq 'exists and is not a symbolic link.' "${configure_script}" \
    && grep -Fq 'points to an unexpected target.' "${configure_script}"
}

package_sources_match_selection() {
  local composer="$1"
  local optional_variable="$2"
  local optional_name="$3"
  local base_sources
  local optional_sources

  base_sources="$(env "${optional_variable}=0" "${composer}" --print-sources)" || return 1
  optional_sources="$(env "${optional_variable}=1" "${composer}" --print-sources)" || return 1

  case "${base_sources}" in
    *"${optional_name}"*) return 1 ;;
  esac
  case "${optional_sources}" in
    *"${optional_name}"*) return 0 ;;
  esac
  return 1
}

linux_dry_run_cleans_temporary_list() {
  local output
  local list_path

  output="$("${REPO_ROOT}/bootstrap/linux.sh" --dry-run)" || return 1
  list_path="$(printf '%s\n' "${output}" | sed -n 's/^package_list=//p')"
  [ -n "${list_path}" ] && [ ! -e "${list_path}" ]
}

macos_dry_run_cleans_temporary_brewfile() {
  local output
  local brewfile_path

  output="$("${REPO_ROOT}/bootstrap/macos.sh" --dry-run)" || return 1
  brewfile_path="$(printf '%s\n' "${output}" | sed -n 's/^brewfile=//p')"
  [ -n "${brewfile_path}" ] && [ ! -e "${brewfile_path}" ]
}

invalid_bootstrap_step_fails() {
  if "${REPO_ROOT}/bootstrap/linux.sh" --only unknown-step > /dev/null 2>&1; then
    return 1
  fi
  if "${REPO_ROOT}/bootstrap/macos.sh" --only unknown-step > /dev/null 2>&1; then
    return 1
  fi
}

tracked_assets_are_not_executable() {
  local tracked_path

  while IFS= read -r tracked_path; do
    case "${tracked_path}" in
      assets/*|.editorconfig)
        [ ! -x "${REPO_ROOT}/${tracked_path}" ] || return 1
        ;;
    esac
  done < <(git -C "${REPO_ROOT}" ls-files)
}

macos_bootstrap_does_not_start_colima() {
  ! grep -R -E 'colima start|brew services start colima' \
    "${REPO_ROOT}/bootstrap" "${REPO_ROOT}/modules/macos" > /dev/null 2>&1
}

macos_bootstrap_does_not_configure_remote_access() {
  ! grep -R -E \
    'tailscale[[:space:]]+(up|login|auth|set|ssh)|systemsetup.*setremotelogin|brew services.*tailscale' \
    "${REPO_ROOT}/bootstrap" "${REPO_ROOT}/modules/macos" > /dev/null 2>&1
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

linux_package_layers_have_no_duplicates() {
  local duplicates

  duplicates="$(
    sed -e 's/[[:space:]]*#.*$//' -e '/^[[:space:]]*$/d' \
      "${REPO_ROOT}/modules/linux/packages/apt.base.txt" \
      "${REPO_ROOT}/modules/linux/packages/apt.optional.txt" \
      | sort \
      | uniq -d
  )"

  [ -z "${duplicates}" ]
}

windows_package_layers_have_no_duplicates() {
  local duplicates

  duplicates="$(
    jq -r '.Packages[]?.PackageIdentifier' \
      "${REPO_ROOT}/modules/windows/packages/Winget.base.json" \
      "${REPO_ROOT}/modules/windows/packages/Winget.optional.json" \
      | sort \
      | uniq -d
  )"

  [ -z "${duplicates}" ]
}

bootstrap_does_not_authenticate_ai_tools() {
  ! grep -R -i -E \
    '(codex|openai|claude|anthropic).*(login|auth)|(login|auth).*(codex|openai|claude|anthropic)' \
    "${REPO_ROOT}/bootstrap" "${REPO_ROOT}/modules" > /dev/null 2>&1
}

macos_rosetta_defaults_off() {
  grep -Fx 'DOTFILES_INSTALL_ROSETTA=0' "${REPO_ROOT}/config/macos.env.sample" > /dev/null 2>&1 \
    && grep -F 'readonly INSTALL_ROSETTA="${DOTFILES_INSTALL_ROSETTA:-0}"' \
      "${REPO_ROOT}/modules/macos/bootstrap/run.sh" > /dev/null 2>&1 \
    && grep -F 'readonly INSTALL_ROSETTA="${DOTFILES_INSTALL_ROSETTA:-0}"' \
      "${REPO_ROOT}/modules/macos/packages/install.sh" > /dev/null 2>&1
}

log_section 'Shell syntax'
run_check 'POSIX shell syntax' \
  sh -n \
  "${REPO_ROOT}/modules/apps/ghostty/configure.sh" \
  "${REPO_ROOT}/modules/apps/vscode/configure.sh" \
  "${REPO_ROOT}/modules/cli/git/configure.sh" \
  "${REPO_ROOT}/modules/cli/neovim/configure.sh" \
  "${REPO_ROOT}/modules/cli/starship/configure.sh" \
  "${REPO_ROOT}/modules/cli/terminal/render-assets.sh" \
  "${REPO_ROOT}/modules/cli/tmux/configure.sh" \
  "${REPO_ROOT}/modules/shared/fonts/install-posix.sh" \
  "${REPO_ROOT}/modules/shared/utils/load_env.sh" \
  "${REPO_ROOT}/modules/shared/utils/message.sh" \
  "${REPO_ROOT}/modules/shared/utils/posix.sh" \
  "${REPO_ROOT}/modules/shared/utils/posix_app_config.sh" \
  "${REPO_ROOT}/modules/shared/utils/sudo.sh"

run_check 'Bash syntax' \
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
  "${REPO_ROOT}/testenv/linux-container/ubuntu-24.04/run-validation.sh" \
  "${REPO_ROOT}/testenv/parallels/preflight.sh" \
  "${REPO_ROOT}/testenv/validation/run-static-checks.sh" \
  "${REPO_ROOT}/modules/shell/bash/.bash_profile" \
  "${REPO_ROOT}/modules/shell/bash/.bashrc" \
  "${REPO_ROOT}/modules/shell/bash/install.sh" \
  "${REPO_ROOT}/modules/shared/shell/alias.sh" \
  "${REPO_ROOT}/modules/shared/shell/functions.sh"

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
  "${REPO_ROOT}/modules/shell/zsh/.zprofile" \
  "${REPO_ROOT}/modules/shell/zsh/.zshrc" \
  "${REPO_ROOT}/modules/shell/zsh/install.sh" \
  "${REPO_ROOT}/modules/shared/shell/alias.sh" \
  "${REPO_ROOT}/modules/shared/shell/functions.sh" \
  "${REPO_ROOT}/modules/shared/utils/dotfiles.sh"

run_check 'POSIX libraries load in sh' source_posix_libraries sh
run_check 'POSIX libraries load in Bash' source_posix_libraries bash
run_check 'POSIX libraries load in zsh' source_posix_libraries zsh
run_check 'interactive library loads in Bash' source_interactive_shell_library bash
run_check 'interactive library loads in zsh' source_interactive_shell_library zsh
run_check 'sourced libraries are non-executable and have no shebang' source_only_libraries_are_clear

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
run_check 'macOS and Linux rerun wrapper help output' rerun_wrappers_show_help
run_check 'README entry points exist' readme_entry_points_exist

if [ "$(uname -s)" = 'Darwin' ] && [ "$(uname -m)" = 'arm64' ]; then
  run_check 'macOS dry-run output' "${REPO_ROOT}/bootstrap/macos.sh" --dry-run
  run_check 'macOS dry-run removes its temporary Brewfile' macos_dry_run_cleans_temporary_brewfile
else
  skip_check 'macOS dry-run output (host is not Apple Silicon macOS)'
fi

run_check 'Linux dry-run output' "${REPO_ROOT}/bootstrap/linux.sh" --dry-run
run_check 'Linux dry-run removes its temporary package list' linux_dry_run_cleans_temporary_list
run_check 'invalid bootstrap steps fail' invalid_bootstrap_step_fails

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
for package_name in git git-lfs gh curl jq ripgrep fd tree tmux starship neovim ghostty visual-studio-code fnm pnpm uv go rustup colima docker docker-compose codex claude-code tailscale-app; do
  run_check "macOS base package: ${package_name}" macos_base_has_package "${package_name}"
done
run_check 'macOS base uses the stable Claude Code channel' \
  macos_base_lacks_package claude-code@latest
run_check 'macOS base excludes Homebrew Node.js' macos_base_lacks_node_formula
run_check 'macOS base excludes Homebrew Rust' macos_base_lacks_package rust
run_check 'macOS tracked catalogs exclude Docker Desktop' \
  macos_tracked_catalogs_lack_package docker-desktop
run_check 'macOS tracked catalogs exclude CLI-only Tailscale' \
  macos_tracked_catalogs_lack_package tailscale
for package_name in gcc hugo openjdk; do
  run_check "macOS optional-only package: ${package_name}" macos_optional_only_has_package "${package_name}"
done
run_check 'macOS package layers have no duplicates' macos_package_layers_have_no_duplicates
run_check 'Linux package layers have no duplicates' linux_package_layers_have_no_duplicates
run_check 'Windows package layers have no duplicates' windows_package_layers_have_no_duplicates
run_check 'macOS optional packages follow selection' package_sources_match_selection \
  "${REPO_ROOT}/modules/macos/packages/compose_brewfile.sh" \
  DOTFILES_INCLUDE_MACOS_OPTIONAL_PACKAGES Brewfile.optional
run_check 'Linux optional packages follow selection' package_sources_match_selection \
  "${REPO_ROOT}/modules/linux/packages/compose_apt_list.sh" \
  DOTFILES_INCLUDE_LINUX_OPTIONAL_PACKAGES apt.optional.txt
run_check 'local configuration and package overrides stay untracked' local_override_paths_are_ignored
run_check 'tracked configuration assets are non-executable' tracked_assets_are_not_executable

log_section 'Development environment contracts'
run_check 'fnm shell integration only selects declared project versions' \
  fnm_shell_contract_is_tracked
run_check 'configure-shell prepares the user executable directory' \
  grep -Fq 'mkdir -p "${HOME}/.local/bin"' "${REPO_ROOT}/modules/shell/zsh/install.sh"
run_check 'Go-installed commands use the default GOPATH bin directory' \
  grep -Fq 'add_path "${HOME}/go/bin"' "${REPO_ROOT}/modules/shell/zsh/.zprofile"
run_check 'Homebrew rustup proxies are on PATH' \
  grep -Fq 'add_path "${HOMEBREW_PREFIX}/opt/rustup/bin"' \
    "${REPO_ROOT}/modules/shell/zsh/.zprofile"
run_check 'Docker Compose CLI plugin wiring is tracked without config.json ownership' \
  docker_compose_plugin_contract_is_tracked
run_check 'global agent assets are tracked with safe Codex symlink deployment' \
  agent_assets_contract_is_tracked
run_check 'macOS bootstrap does not start Colima' macos_bootstrap_does_not_start_colima
run_check 'macOS bootstrap leaves remote access enrollment to the user' \
  macos_bootstrap_does_not_configure_remote_access
run_check 'bootstrap does not authenticate AI coding tools' \
  bootstrap_does_not_authenticate_ai_tools
run_check 'macOS Rosetta default is off' macos_rosetta_defaults_off

log_section 'Generated assets'
run_check 'terminal asset sync' "${REPO_ROOT}/modules/cli/terminal/render-assets.sh" --check

printf '\nSummary: failed=%s skipped=%s\n' "${FAILED_CHECKS}" "${SKIPPED_CHECKS}"

if [ "${FAILED_CHECKS}" -ne 0 ]; then
  exit 1
fi
