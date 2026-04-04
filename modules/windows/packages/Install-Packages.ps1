Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$repoRoot = $env:DOTFILES_REPO_ROOT
$wingetManifestPath = $env:DOTFILES_WINGET_MANIFEST_PATH
$scoopListPath = $env:DOTFILES_SCOOP_LIST_PATH
$enableWSL = $env:DOTFILES_WINDOWS_ENABLE_WSL -eq '1'

if (-not $repoRoot) {
  throw 'DOTFILES_REPO_ROOT is required.'
}

if (-not $wingetManifestPath -or -not (Test-Path -LiteralPath $wingetManifestPath)) {
  throw 'DOTFILES_WINGET_MANIFEST_PATH is required.'
}

if (-not $scoopListPath -or -not (Test-Path -LiteralPath $scoopListPath)) {
  throw 'DOTFILES_SCOOP_LIST_PATH is required.'
}

function Ensure-WingetAvailable {
  if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
    throw 'winget was not found. Install App Installer or use a Windows image that already includes winget.'
  }
}

function Ensure-ScoopAvailable {
  $scoopCommand = Get-Command scoop -ErrorAction SilentlyContinue
  if ($scoopCommand) {
    return $scoopCommand.Source
  }

  Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
  Invoke-RestMethod -Uri 'https://get.scoop.sh' | Invoke-Expression

  $installedCommand = Get-Command scoop -ErrorAction SilentlyContinue
  if ($installedCommand) {
    return $installedCommand.Source
  }

  $fallbackPath = Join-Path $HOME 'scoop\shims\scoop.cmd'
  if (Test-Path -LiteralPath $fallbackPath) {
    return $fallbackPath
  }

  throw 'Scoop installation completed but the scoop command could not be resolved.'
}

function Install-WingetPackages {
  $manifest = Get-Content -LiteralPath $wingetManifestPath -Raw | ConvertFrom-Json
  foreach ($package in $manifest.Sources[0].Packages) {
    winget install --id $package.PackageIdentifier --exact --accept-source-agreements --accept-package-agreements
  }
}

function Install-ScoopPackages {
  param(
    [Parameter(Mandatory = $true)]
    [string]$ScoopCommandPath
  )

  foreach ($packageName in Get-Content -LiteralPath $scoopListPath) {
    if ([string]::IsNullOrWhiteSpace($packageName)) {
      continue
    }

    & $ScoopCommandPath install $packageName
  }
}

if ($enableWSL) {
  wsl --install
}

Ensure-WingetAvailable
$scoopCommandPath = Ensure-ScoopAvailable
Install-WingetPackages
Install-ScoopPackages -ScoopCommandPath $scoopCommandPath
