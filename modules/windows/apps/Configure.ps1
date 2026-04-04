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

Invoke-OptionalCommand -CommandName 'code' -SkipMessage 'Skip Visual Studio Code configuration because code is not installed.' -ScriptBlock {
  & (Join-Path $repoRoot 'modules/cli/vscode/configure-windows.ps1')
}

Invoke-OptionalCommand -CommandName 'hyper' -SkipMessage 'Skip Hyper configuration because hyper is not installed.' -ScriptBlock {
  & (Join-Path $repoRoot 'modules/cli/hyper/configure-windows.ps1')
}
