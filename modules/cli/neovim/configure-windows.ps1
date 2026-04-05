Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$repoRoot = $env:DOTFILES_REPO_ROOT
if (-not $repoRoot) {
  throw 'DOTFILES_REPO_ROOT is required.'
}

Import-Module (Join-Path $repoRoot 'modules/shared/utils/WindowsDotfiles.psm1') -Force

$nvimAsset = Join-Path $repoRoot 'assets/cli/nvim/init.lua'
$nvimConfigDir = Join-Path $env:LOCALAPPDATA 'nvim'
$nvimConfigPath = Join-Path $nvimConfigDir 'init.lua'

New-Item -ItemType Directory -Path $nvimConfigDir -Force | Out-Null
Set-DotfilesSymbolicLink -LinkPath $nvimConfigPath -TargetPath $nvimAsset
