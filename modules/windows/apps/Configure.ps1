Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$repoRoot = $env:DOTFILES_REPO_ROOT
if (-not $repoRoot) {
  throw 'DOTFILES_REPO_ROOT is required.'
}

Import-Module (Join-Path $repoRoot 'modules/shared/utils/WindowsDotfiles.psm1') -Force
Invoke-DotfilesOptionalConfigure -CommandName 'git' -CandidatePaths @(
  (Join-Path ${env:ProgramFiles} 'Git\cmd\git.exe'),
  (Join-Path ${env:ProgramFiles} 'Git\bin\git.exe')
) -SkipMessage 'Git is not installed.' -ScriptBlock {
  & (Join-Path $repoRoot 'modules/cli/git/configure-windows.ps1')
}

& (Join-Path $repoRoot 'modules/windows/apps/Configure-Terminal.ps1')

Invoke-DotfilesOptionalConfigure -CommandName 'starship' -CandidatePaths @(
  (Join-Path $env:LOCALAPPDATA 'Microsoft\WinGet\Packages\Starship.Starship_Microsoft.Winget.Source_8wekyb3d8bbwe\starship-aarch64-pc-windows-msvc\starship.exe'),
  (Join-Path $env:LOCALAPPDATA 'Microsoft\WinGet\Links\starship.exe')
) -SkipMessage 'Starship is not installed.' -ScriptBlock {
  & (Join-Path $repoRoot 'modules/cli/starship/configure-windows.ps1')
}

Invoke-DotfilesOptionalConfigure -CommandName 'nvim' -CandidatePaths @(
  (Join-Path ${env:ProgramFiles} 'Neovim\bin\nvim.exe'),
  (Join-Path $env:LOCALAPPDATA 'Microsoft\WinGet\Links\nvim.exe')
) -SkipMessage 'Neovim is not installed.' -ScriptBlock {
  & (Join-Path $repoRoot 'modules/cli/neovim/configure-windows.ps1')
}

& (Join-Path $repoRoot 'modules/cli/vscode/configure-windows.ps1')
