Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$repoRoot = $env:DOTFILES_REPO_ROOT
if (-not $repoRoot) {
  throw 'DOTFILES_REPO_ROOT is required.'
}

Import-Module (Join-Path $repoRoot 'modules/shared/utils/WindowsDotfiles.psm1') -Force

$settingsAsset = Join-Path $repoRoot 'assets/cli/vscode/settings.json'
$extensionsFile = Join-Path $repoRoot 'assets/cli/vscode/extensions'
$userDir = Join-Path $env:APPDATA 'Code\User'
$settingsPath = Join-Path $userDir 'settings.json'

function Resolve-CodeCommand {
  $command = Get-Command code -ErrorAction SilentlyContinue
  if ($command) {
    return $command.Source
  }

  $candidates = @(
    (Join-Path $env:LOCALAPPDATA 'Programs\Microsoft VS Code\bin\code.cmd'),
    (Join-Path ${env:ProgramFiles} 'Microsoft VS Code\bin\code.cmd'),
    (Join-Path ${env:ProgramFiles(x86)} 'Microsoft VS Code\bin\code.cmd')
  )

  foreach ($candidate in $candidates) {
    if ($candidate -and (Test-Path -LiteralPath $candidate)) {
      return $candidate
    }
  }

  return $null
}

$codeCommand = Resolve-CodeCommand
$installedExtensions = @()
if ($codeCommand) {
  $installedExtensions = @(& $codeCommand --list-extensions 2>$null)
}

Get-Content -LiteralPath $extensionsFile | ForEach-Object {
  $extension = $_.Trim()
  if (-not $extension) {
    return
  }

  if (-not $codeCommand) {
    return
  }

  if ($installedExtensions -notcontains $extension) {
    & $codeCommand --install-extension $extension | Out-Null
  }
}

Set-DotfilesSymbolicLink -LinkPath $settingsPath -TargetPath $settingsAsset
