# Check whether this script is running with administrative privileges.
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] 'Administrator')) {
  Write-Output 'This script should be run with administrative privileges.'
  exit 1
}

Set-Variable -Name INSTALL_SCRIPT_PATH -Value $(Convert-Path "${PSScriptRoot}\..") -Option ReadOnly

# Load the library functions.
Import-Module "${INSTALL_SCRIPT_PATH}\lib\WindowsDotfilesUtils"

# Install WSL.
# Check if the build number is 19041 or later.
if ((Get-WmiObject Win32_OperatingSystem).BuildNumber -lt 19041) {
  Write-Output 'To install WSL2 with this script, Upgrade to Windows build 19041 or later.'
  exit 1
}
wsl --install

# Install applications.

winget import -i "${INSTALL_SCRIPT_PATH}\Windows\apps.json"

# ---------------------------------------------------------
# Configure Windows preference
# ---------------------------------------------------------

& "${INSTALL_SCRIPT_PATH}\Windows\PreferencesWindows.ps1"

# Configure Git
# NOTE: Git can be installed on both WSL and Windows. This script will install Git on Windows and set up a .gitconfig for it.
Import-Module "${INSTALL_SCRIPT_PATH}\apps\git\SetupGitWindows"
Receive-GitConfig -Path "${INSTALL_SCRIPT_PATH}\apps\git\.gitconfig"

# Register periodic tasks.

if (![System.Diagnostics.EventLog]::SourceExists('WingetUpdate')) {
  New-EventLog -LogName Application -Source WingetUpdate
}
if ((Get-ScheduledTask -TaskName "UpdateWingetPackages" -ErrorAction SilentlyContinue) -eq $null) {
  # Register the update of the winget package in the task scheduler.
  Register-ScheduledTask -TaskName 'UpdateWingetPackages' -Description 'Update the packages installed by winget.' `
    -Action (New-ScheduledTaskAction -Execute 'powershell.exe' -Argument "-File ${INSTALL_SCRIPT_PATH}\Windows\UpdatePackages.ps1") `
    -Trigger (New-ScheduledTaskTrigger -Daily -At '00:00')
}
