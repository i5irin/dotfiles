# Check whether this script is running with administrative privileges.
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] 'Administrator')) {
  Write-Output 'This script should be run with administrative privileges.'
  exit 1
}

# Load the library functions.
Import-Module "${PSScriptRoot}\Lib"

Set-Variable -Name INSTALL_SCRIPT_PATH -Value $(Convert-Path "${PSScriptRoot}\..") -Option ReadOnly

# Ask username and email for git config.
while ($true) {
  $GIT_USER_NAME = Read-Host 'Enter your name for use in git > '
  $GIT_USER_EMAIL = Read-Host 'Enter your email address for use in git > '
  if (Test-GitHubUsername -Name $GIT_USER_NAME -eq 1) {
    Write-Output 'The username you entered is invalid for GitHub.'
    continue
  }
  while ($true) {
    $YN = Read-Host "Make sure name($GIT_USER_NAME) and email($GIT_USER_EMAIL) you input, is this ok? [Y/n] > "
    if ($YN -cmatch '[YNn]') {
      break
    } else {
      Write-Output '[Y/n]'
    }
  }
  if ($YN -eq 'Y') {
    break;
  }
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

# Install applications.

winget install 'Git.Git'

# Configure Git
# NOTE: Git can be installed on both WSL and Windows. This script will install Git on Windows and set up a .gitconfig for it.
git config --global --add include.path "${INSTALL_SCRIPT_PATH}\.gitconfig"
git config --global user.name $GIT_USER_NAME
git config --global user.email $GIT_USER_EMAIL
