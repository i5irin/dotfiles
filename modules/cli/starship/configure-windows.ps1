Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$repoRoot = $env:DOTFILES_REPO_ROOT
if (-not $repoRoot) {
  throw 'DOTFILES_REPO_ROOT is required.'
}

Import-Module (Join-Path $repoRoot 'modules/shared/utils/WindowsDotfiles.psm1') -Force

$starshipAsset = Join-Path $repoRoot 'assets/cli/starship/starship.toml'
$starshipConfigDir = Join-Path $HOME '.config'
$starshipConfigPath = Join-Path $starshipConfigDir 'starship.toml'

New-Item -ItemType Directory -Path $starshipConfigDir -Force | Out-Null
Set-DotfilesSymbolicLink -LinkPath $starshipConfigPath -TargetPath $starshipAsset
