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
  Install-Module -Name $ModuleName -Scope CurrentUser -Repository PSGallery -Force -AllowClobber
}

Ensure-ModuleInstalled -ModuleName 'posh-git'
