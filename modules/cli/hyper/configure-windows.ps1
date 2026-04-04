Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$repoRoot = $env:DOTFILES_REPO_ROOT
if (-not $repoRoot) {
  throw 'DOTFILES_REPO_ROOT is required.'
}

Import-Module (Join-Path $repoRoot 'modules/shared/utils/WindowsDotfiles.psm1') -Force

$hyperAsset = Join-Path $repoRoot 'assets/cli/hyper/.hyper-windows.js'
$hyperConfigPath = Join-Path $env:APPDATA 'Hyper\.hyper.js'

Set-DotfilesSymbolicLink -LinkPath $hyperConfigPath -TargetPath $hyperAsset
