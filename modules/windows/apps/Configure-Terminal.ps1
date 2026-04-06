Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$repoRoot = $env:DOTFILES_REPO_ROOT
if (-not $repoRoot) {
  throw 'DOTFILES_REPO_ROOT is required.'
}

Import-Module (Join-Path $repoRoot 'modules/shared/utils/WindowsDotfiles.psm1') -Force

$settingsAsset = Join-Path $repoRoot 'assets/windows/terminal/settings.json'
$fontStatePath = Join-Path $env:LOCALAPPDATA 'dotfiles\state\windows-fonts.json'

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

function Build-WindowsTerminalSettings {
  $settings = Get-Content -LiteralPath $settingsAsset -Raw | ConvertFrom-Json
  $settings.profiles.defaults.fontFace = Resolve-PreferredTerminalFontFace
  $settings | Add-Member -NotePropertyName defaultProfile -NotePropertyValue (Resolve-DefaultProfileName) -Force
  return $settings | ConvertTo-Json -Depth 8
}

function Resolve-PreferredTerminalFontFace {
  if (Test-Path -LiteralPath $fontStatePath) {
    try {
      $fontState = Get-Content -LiteralPath $fontStatePath -Raw | ConvertFrom-Json
      if ($fontState.preferredTerminalFontFace) {
        return "$($fontState.preferredTerminalFontFace)"
      }
    } catch {
    }
  }

  return 'Consolas'
}

function Resolve-DefaultProfileName {
  $pwshCandidates = @(
    (Join-Path $env:ProgramFiles 'PowerShell\7\pwsh.exe'),
    (Join-Path ${env:ProgramFiles(x86)} 'PowerShell\7\pwsh.exe')
  ) | Where-Object { $_ }

  if (Get-Command pwsh.exe -ErrorAction SilentlyContinue) {
    return 'PowerShell'
  }

  foreach ($candidate in $pwshCandidates) {
    if (Test-Path -LiteralPath $candidate) {
      return 'PowerShell'
    }
  }

  return 'Windows PowerShell'
}

$settingsPaths = @(Resolve-WindowsTerminalSettingsPaths)
if (-not $settingsPaths) {
  Write-Output 'Skip Windows Terminal configuration because the settings path could not be resolved yet.'
  exit 0
}

$renderedSettings = Build-WindowsTerminalSettings
$tempSettingsPath = Join-Path ([System.IO.Path]::GetTempPath()) ("dotfiles-terminal-{0}.json" -f [guid]::NewGuid().ToString('N'))
Set-Content -LiteralPath $tempSettingsPath -Value $renderedSettings -Encoding UTF8

foreach ($settingsPath in $settingsPaths) {
  Set-DotfilesManagedFile -Path $settingsPath -SourcePath $tempSettingsPath
}

Remove-Item -LiteralPath $tempSettingsPath -Force -ErrorAction SilentlyContinue
