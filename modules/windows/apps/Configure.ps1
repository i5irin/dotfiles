Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$repoRoot = $env:DOTFILES_REPO_ROOT
if (-not $repoRoot) {
  throw 'DOTFILES_REPO_ROOT is required.'
}

function Invoke-OptionalCommand {
  param(
    [Parameter(Mandatory = $true)]
    [string]$CommandName,
    [Parameter(Mandatory = $true)]
    [scriptblock]$ScriptBlock,
    [Parameter(Mandatory = $true)]
    [string]$SkipMessage
  )

  if (-not (Get-Command $CommandName -ErrorAction SilentlyContinue)) {
    Write-Output $SkipMessage
    return
  }

  & $ScriptBlock
}

Invoke-OptionalCommand -CommandName 'git' -SkipMessage 'Skip Git configuration because git is not installed.' -ScriptBlock {
  & (Join-Path $repoRoot 'modules/cli/git/configure-windows.ps1')
}

& (Join-Path $repoRoot 'modules/windows/apps/Configure-Terminal.ps1')

Invoke-OptionalCommand -CommandName 'starship' -SkipMessage 'Skip Starship configuration because starship is not installed.' -ScriptBlock {
  & (Join-Path $repoRoot 'modules/cli/starship/configure-windows.ps1')
}

Invoke-OptionalCommand -CommandName 'nvim' -SkipMessage 'Skip Neovim configuration because Neovim is not installed.' -ScriptBlock {
  & (Join-Path $repoRoot 'modules/cli/neovim/configure-windows.ps1')
}

Invoke-OptionalCommand -CommandName 'code' -SkipMessage 'Skip Visual Studio Code configuration because code is not installed.' -ScriptBlock {
  & (Join-Path $repoRoot 'modules/cli/vscode/configure-windows.ps1')
}
