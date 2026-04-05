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

function Install-WingetPackages {
  $manifest = Get-Content -LiteralPath $wingetManifestPath -Raw | ConvertFrom-Json
  foreach ($package in $manifest.Sources[0].Packages) {
    winget install --id $package.PackageIdentifier --exact --accept-source-agreements --accept-package-agreements
  }
}

if ($enableWSL) {
  wsl --install
}

Ensure-WingetAvailable
Install-WingetPackages
