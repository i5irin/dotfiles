Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$repoRoot = $env:DOTFILES_REPO_ROOT
if (-not $repoRoot) {
  throw 'DOTFILES_REPO_ROOT is required.'
}

Import-Module (Join-Path $repoRoot 'modules/shared/utils/WindowsDotfiles.psm1') -Force

$settingsAsset = Join-Path $repoRoot 'assets/windows/terminal/settings.json'

function Resolve-WindowsTerminalSettingsPaths {
  $candidates = @(
    (Join-Path $env:LOCALAPPDATA 'Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json'),
    (Join-Path $env:LOCALAPPDATA 'Packages\Microsoft.WindowsTerminalPreview_8wekyb3d8bbwe\LocalState\settings.json'),
    (Join-Path $env:LOCALAPPDATA 'Microsoft\Windows Terminal\settings.json')
  )

  $resolved = @()
  foreach ($candidate in $candidates) {
    if (Test-Path -LiteralPath $candidate) {
      $resolved += $candidate
    }
  }

  foreach ($candidate in $candidates) {
    $parentPath = Split-Path -Parent $candidate
    if (Test-Path -LiteralPath $parentPath) {
      if ($resolved -notcontains $candidate) {
        $resolved += $candidate
      }
    }
  }

  return $resolved
}

$settingsPaths = @(Resolve-WindowsTerminalSettingsPaths)
if (-not $settingsPaths) {
  Write-Output 'Skip Windows Terminal configuration because the settings path could not be resolved yet.'
  exit 0
}

foreach ($settingsPath in $settingsPaths) {
  Set-DotfilesManagedFile -Path $settingsPath -SourcePath $settingsAsset
}
