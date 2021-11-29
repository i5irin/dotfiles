# Check whether this script is running with administrative privileges.
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] 'Administrator')) {
  Write-Output 'This script should be run with administrative privileges.'
  exit 1
}

# Activate Developer Mode.
Set-ItemProperty -LiteralPath 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock' -Name 'AllowDevelopmentWithoutDevLicense' -Value '1'

# Display the extensions of known file types.
Set-ItemProperty -LiteralPath 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name 'HideFileExt' -Value 0

# Show the full path in the Explorer title.
Set-ItemProperty -LiteralPath 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CabinetState' -Name 'FullPath' -Value 1

# Restart explorer.
Stop-Process -ProcessName explorer

# Remove pre-installed applications.

# Remove Maps.
Get-AppxPackage 'Microsoft.WindowsMaps' | Remove-AppxPackage

# Remove Get Started.
Get-AppxPackage 'Microsoft.Getstarted' | Remove-AppxPackage

# Remove Zune Music (Groove).
Get-AppxPackage 'Microsoft.ZuneMusic' | Remove-AppxPackage

# Remove Zune Video (Movies & TV).
Get-AppxPackage 'Microsoft.ZuneVideo' | Remove-AppxPackage

# Remove Paint3D.
Get-AppxPackage "Microsoft.MSPaint" | Remove-AppxPackage

# Configure Edge.

if (-not (Test-Path 'HKLM:\SOFTWARE\Policies\Microsoft\Edge')) {
  Write-Output 'The registry key "HKLM:\SOFTWARE\Policies\Microsoft\Edge" does not exist. A new one is  created.'
  New-Item 'HKLM:\SOFTWARE\Policies\Microsoft\Edge'
}

# Disable storing passwords.
Set-ItemProperty -LiteralPath 'HKLM:\SOFTWARE\Policies\Microsoft\Edge' -Name 'PasswordManagerEnabled' -Value 0

# Disable auto-filling your address.
Set-ItemProperty -LiteralPath 'HKLM:\SOFTWARE\Policies\Microsoft\Edge' -Name 'AutofillAddressEnabled' -Value 0

# Disable auto-filling your credit card information.
Set-ItemProperty -LiteralPath 'HKLM:\SOFTWARE\Policies\Microsoft\Edge' -Name 'AutofillCreditCardEnabled' -Value 0
