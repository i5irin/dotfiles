Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$repoRoot = $env:DOTFILES_REPO_ROOT
if (-not $repoRoot) {
  throw 'DOTFILES_REPO_ROOT is required.'
}

Import-Module (Join-Path $repoRoot 'modules/shared/utils/WindowsDotfiles.psm1') -Force

function Invoke-OptionalCommand {
  param(
    [Parameter(Mandatory = $true)]
    [string]$CommandName,
    [string[]]$CandidatePaths = @(),
    [Parameter(Mandatory = $true)]
    [scriptblock]$ScriptBlock,
    [Parameter(Mandatory = $true)]
    [string]$SkipMessage
  )

  if (-not (Resolve-DotfilesCommandPath -CommandName $CommandName -CandidatePaths $CandidatePaths)) {
    Write-Output $SkipMessage
    return
  }

  & $ScriptBlock
}

Invoke-OptionalCommand -CommandName 'git' -CandidatePaths @(
  (Join-Path ${env:ProgramFiles} 'Git\cmd\git.exe'),
  (Join-Path ${env:ProgramFiles} 'Git\bin\git.exe')
) -SkipMessage 'Skip Git configuration because git is not installed.' -ScriptBlock {
  & (Join-Path $repoRoot 'modules/cli/git/configure-windows.ps1')
}

& (Join-Path $repoRoot 'modules/windows/apps/Configure-Terminal.ps1')

Invoke-OptionalCommand -CommandName 'starship' -CandidatePaths @(
  (Join-Path $env:LOCALAPPDATA 'Microsoft\WinGet\Packages\Starship.Starship_Microsoft.Winget.Source_8wekyb3d8bbwe\starship-aarch64-pc-windows-msvc\starship.exe'),
  (Join-Path $env:LOCALAPPDATA 'Microsoft\WinGet\Links\starship.exe')
) -SkipMessage 'Skip Starship configuration because starship is not installed.' -ScriptBlock {
  & (Join-Path $repoRoot 'modules/cli/starship/configure-windows.ps1')
}

Invoke-OptionalCommand -CommandName 'nvim' -CandidatePaths @(
  (Join-Path ${env:ProgramFiles} 'Neovim\bin\nvim.exe'),
  (Join-Path $env:LOCALAPPDATA 'Microsoft\WinGet\Links\nvim.exe')
) -SkipMessage 'Skip Neovim configuration because Neovim is not installed.' -ScriptBlock {
  & (Join-Path $repoRoot 'modules/cli/neovim/configure-windows.ps1')
}

& (Join-Path $repoRoot 'modules/cli/vscode/configure-windows.ps1')
