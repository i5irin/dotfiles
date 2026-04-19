Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'

$repoRoot = $env:DOTFILES_REPO_ROOT
if ($repoRoot) {
  Import-Module (Join-Path $repoRoot 'modules/shared/utils/WindowsDotfiles.psm1') -Force
}

function Ensure-TrustedPowerShellGallery {
  $gallery = Get-PSRepository -Name 'PSGallery' -ErrorAction SilentlyContinue
  if (-not $gallery) {
    return
  }

  if ($gallery.InstallationPolicy -ne 'Trusted') {
    Set-PSRepository -Name 'PSGallery' -InstallationPolicy Trusted
  }
}

function Ensure-NuGetProvider {
  $provider = Get-PackageProvider -Name NuGet -ListAvailable -ErrorAction SilentlyContinue
  if ($provider) {
    return
  }

  if (-not (Get-Command Install-PackageProvider -ErrorAction SilentlyContinue)) {
    if (Get-Command Write-DotfilesWarning -ErrorAction SilentlyContinue) {
      Write-DotfilesWarning 'Install-PackageProvider is unavailable. NuGet bootstrap will be skipped.'
    } else {
      Write-Warning 'Install-PackageProvider is unavailable. NuGet bootstrap will be skipped.'
    }
    return
  }

  Install-PackageProvider -Name NuGet -MinimumVersion '2.8.5.201' -Scope CurrentUser -Force -ForceBootstrap -Confirm:$false | Out-Null
}

function Ensure-ModuleInstalled {
  param(
    [Parameter(Mandatory = $true)]
    [string]$ModuleName
  )

  if (Get-Module -ListAvailable -Name $ModuleName) {
    if (Get-Command Write-DotfilesSkip -ErrorAction SilentlyContinue) {
      Write-DotfilesSkip "$ModuleName is already installed."
    } else {
      Write-Output "Skip $ModuleName because it is already installed."
    }
    return
  }

  if (-not (Get-Command Install-Module -ErrorAction SilentlyContinue)) {
    if (Get-Command Write-DotfilesWarning -ErrorAction SilentlyContinue) {
      Write-DotfilesWarning "Install-Module is unavailable. $ModuleName installation will be skipped."
    } else {
      Write-Warning "Install-Module is unavailable. $ModuleName installation will be skipped."
    }
    return
  }

  Ensure-NuGetProvider
  Ensure-TrustedPowerShellGallery
  Install-Module -Name $ModuleName -Scope CurrentUser -Repository PSGallery -Force -AllowClobber -Confirm:$false
}

Ensure-ModuleInstalled -ModuleName 'posh-git'
