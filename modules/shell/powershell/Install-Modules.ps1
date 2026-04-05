Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

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
    Write-Warning 'Install-PackageProvider is unavailable. Skip NuGet bootstrap.'
    return
  }

  Install-PackageProvider -Name NuGet -MinimumVersion '2.8.5.201' -Scope CurrentUser -Force -ForceBootstrap | Out-Null
}

function Ensure-ModuleInstalled {
  param(
    [Parameter(Mandatory = $true)]
    [string]$ModuleName
  )

  if (Get-Module -ListAvailable -Name $ModuleName) {
    Write-Output "Skip $ModuleName because it is already installed."
    return
  }

  if (-not (Get-Command Install-Module -ErrorAction SilentlyContinue)) {
    Write-Warning "Install-Module is unavailable. Skip $ModuleName installation."
    return
  }

  Ensure-TrustedPowerShellGallery
  Ensure-NuGetProvider
  Install-Module -Name $ModuleName -Scope CurrentUser -Repository PSGallery -Force -AllowClobber
}

Ensure-ModuleInstalled -ModuleName 'posh-git'
