Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$repoRoot = $env:DOTFILES_REPO_ROOT
if (-not $repoRoot) {
  throw 'DOTFILES_REPO_ROOT is required.'
}

$sharedModulePath = Join-Path $repoRoot 'modules/shared/utils/WindowsDotfiles.psm1'
Import-Module $sharedModulePath -Force

$profileAsset = Join-Path $repoRoot 'modules/shell/powershell/Microsoft.PowerShell_profile.ps1'
$windowsPowerShellProfile = Join-Path $HOME 'Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1'
$powerShellProfile = Join-Path $HOME 'Documents\PowerShell\Microsoft.PowerShell_profile.ps1'

Set-DotfilesSymbolicLink -LinkPath $windowsPowerShellProfile -TargetPath $profileAsset
Set-DotfilesSymbolicLink -LinkPath $powerShellProfile -TargetPath $profileAsset
