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
$installedExtensions = @(code --list-extensions 2>$null)

Get-Content -LiteralPath $extensionsFile | ForEach-Object {
  $extension = $_.Trim()
  if ($extension -and $installedExtensions -notcontains $extension) {
    code --install-extension $extension | Out-Null
  }
}

Set-DotfilesSymbolicLink -LinkPath $settingsPath -TargetPath $settingsAsset
