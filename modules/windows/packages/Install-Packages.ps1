Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$repoRoot = $env:DOTFILES_REPO_ROOT
$wingetManifestPath = $env:DOTFILES_WINGET_MANIFEST_PATH
$enableWSL = $env:DOTFILES_WINDOWS_ENABLE_WSL -eq '1'

if (-not $repoRoot) {
  throw 'DOTFILES_REPO_ROOT is required.'
}

if (-not $wingetManifestPath -or -not (Test-Path -LiteralPath $wingetManifestPath)) {
  throw 'DOTFILES_WINGET_MANIFEST_PATH is required.'
}

function Ensure-WingetAvailable {
  if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
    throw 'winget was not found. Install App Installer or use a Windows image that already includes winget.'
  }
}

function Test-PendingReboot {
  $pendingKeys = @(
    'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\RebootPending',
    'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\RebootRequired'
  )

  foreach ($pendingKey in $pendingKeys) {
    if (Test-Path -LiteralPath $pendingKey) {
      return $true
    }
  }

  return $false
}

function Install-WingetPackages {
  $manifest = Get-Content -LiteralPath $wingetManifestPath -Raw | ConvertFrom-Json
  foreach ($package in $manifest.Sources[0].Packages) {
    winget install --id $package.PackageIdentifier --exact --accept-source-agreements --accept-package-agreements --disable-interactivity
  }
}

if ($enableWSL) {
  wsl --install
  if (Test-PendingReboot) {
    throw 'WSL installation requested a reboot. Restart Windows and rerun bootstrap/windows.ps1 before installing additional packages.'
  }
}

Ensure-WingetAvailable
if (Test-PendingReboot) {
  throw 'Windows has a pending reboot. Restart Windows and rerun bootstrap/windows.ps1 before continuing.'
}
Install-WingetPackages
