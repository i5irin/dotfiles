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
