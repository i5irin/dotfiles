Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$repoRoot = $env:DOTFILES_REPO_ROOT
if (-not $repoRoot) {
  throw 'DOTFILES_REPO_ROOT is required.'
}

Import-Module (Join-Path $repoRoot 'modules/shared/utils/WindowsDotfiles.psm1') -Force

# Activate Developer Mode.
Set-ItemProperty -LiteralPath 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock' -Name 'AllowDevelopmentWithoutDevLicense' -Value 1

# Display file extensions.
Set-ItemProperty -LiteralPath 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name 'HideFileExt' -Value 0

# Show the full path in the Explorer title.
Enable-DotfilesRegistryKey -Path 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CabinetState'
Set-ItemProperty -LiteralPath 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CabinetState' -Name 'FullPath' -Value 1

# Restart Explorer.
Stop-Process -ProcessName explorer -ErrorAction SilentlyContinue

# Make event log record Task Scheduler actions.
Set-ItemProperty -LiteralPath 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WINEVT\Channels\Microsoft-Windows-TaskScheduler\Operational' -Name 'Enabled' -Value 1

# Remove pre-installed applications.
Get-AppxPackage 'Microsoft.WindowsMaps' | Remove-AppxPackage -ErrorAction SilentlyContinue
Get-AppxPackage 'Microsoft.Getstarted' | Remove-AppxPackage -ErrorAction SilentlyContinue
Get-AppxPackage 'Microsoft.ZuneMusic' | Remove-AppxPackage -ErrorAction SilentlyContinue
Get-AppxPackage 'Microsoft.ZuneVideo' | Remove-AppxPackage -ErrorAction SilentlyContinue
Get-AppxPackage 'Microsoft.MSPaint' | Remove-AppxPackage -ErrorAction SilentlyContinue

# Configure Edge.
Enable-DotfilesRegistryKey -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Edge'
Set-ItemProperty -LiteralPath 'HKLM:\SOFTWARE\Policies\Microsoft\Edge' -Name 'PasswordManagerEnabled' -Value 0
Set-ItemProperty -LiteralPath 'HKLM:\SOFTWARE\Policies\Microsoft\Edge' -Name 'AutofillAddressEnabled' -Value 0
Set-ItemProperty -LiteralPath 'HKLM:\SOFTWARE\Policies\Microsoft\Edge' -Name 'AutofillCreditCardEnabled' -Value 0
