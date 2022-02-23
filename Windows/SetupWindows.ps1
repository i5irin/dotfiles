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

# ---------------------------------------------------------
# Configure PowerShell
# ---------------------------------------------------------
if (!(Test-Path -Path ~\Documents\WindowsPowerShell)) {
  New-Item -ItemType Directory ~\Documents\WindowsPowerShell
}
New-Item -Type SymbolicLink ~\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1 -Value "${INSTALL_SCRIPT_PATH}\Windows\Microsoft.PowerShell_profile.ps1"

# Install winget
Invoke-WebRequest -Uri 'https://aka.ms/Microsoft.VCLibs.x64.14.00.Desktop.appx' -OutFile vclibs.appx -UseBasicParsing
Add-AppxPackage -Path vclibs.appx
rm vclibs.appx
Invoke-WebRequest -Uri 'https://github.com/microsoft/winget-cli/releases/latest/download/Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle' -OutFile winget.msixbundle -UseBasicParsing
Add-AppxPackage -Path winget.msixbundle
rm winget.msixbundle

# Install Scoop
Invoke-Expression (New-Object System.Net.WebClient).DownloadString('https://get.scoop.sh')

# Install Nerd Fonts
if (!(Test-Path -Path $Env:LOCALAPPDATA\Microsoft\Windows\Fonts)) {
  New-Item -ItemType Directory $Env:LOCALAPPDATA\Microsoft\Windows\Fonts
}
Set-Location $Env:LOCALAPPDATA\Microsoft\Windows\fonts
Invoke-WebRequest -UseBasicParsing -Uri 'https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/FiraCode/Bold/complete/Fira Code Bold Nerd Font Complete Windows Compatible.ttf' -outfile 'Fira Code Bold Nerd Font Complete Windows Compatible.ttf'
Invoke-WebRequest -UseBasicParsing -Uri 'https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/FiraCode/Light/complete/Fira Code Light Nerd Font Complete Windows Compatible.ttf'  -outfile 'Fira Code Light Nerd Font Complete Windows Compatible.ttf'
Invoke-WebRequest -UseBasicParsing -Uri 'https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/FiraCode/Medium/complete/Fira Code Medium Nerd Font Complete Windows Compatible.ttf'  -outfile 'Fira Code Medium Nerd Font Complete Windows Compatible.ttf'
Invoke-WebRequest -UseBasicParsing -Uri 'https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/FiraCode/Regular/complete/Fira Code Regular Nerd Font Complete Windows Compatible.ttf'  -outfile 'Fira Code Regular Nerd Font Complete Windows Compatible.ttf'
Invoke-WebRequest -UseBasicParsing -Uri 'https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/FiraCode/Retina/complete/Fira Code Retina Nerd Font Complete Windows Compatible.ttf'  -outfile 'Fira Code Retina Nerd Font Complete Windows Compatible.ttf'
Invoke-WebRequest -UseBasicParsing -Uri 'https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/FiraCode/SemiBold/complete/Fira Code SemiBold Nerd Font Complete Windows Compatible.ttf'  -outfile 'Fira Code SemiBold Nerd Font Complete Windows Compatible.ttf'
# Install Starship
# TODO: Install Starship without Scoop.
scoop install starship

# ---------------------------------------------------------
# Install applications
# ---------------------------------------------------------

# Update the application to be installed according to the user's Winget.json if it exists.
$baseApplications = (Get-Content -Path "${INSTALL_SCRIPT_PATH}\Windows\Winget.json" | ConvertFrom-Json).Sources[0].Packages | ForEach-Object { $_.PackageIdentifier };
$installApplications = $baseApplications
if (Test-Path -Path "${INSTALL_SCRIPT_PATH}\Windows\MyWinget.json") {
  $userApplications = (Get-Content -Path "${INSTALL_SCRIPT_PATH}\Windows\MyWinget.json" | ConvertFrom-Json).Packages | ForEach-Object { $_.PackageIdentifier }
  $installApplications = ($baseApplications | Where-Object { $userApplications -notcontains $_ }) + ($userApplications | Where-Object { $baseApplications -notcontains $_ })
}
$installApplications | ForEach-Object { winget install --id $_ }

# Update the application to be installed according to the user's Scoop.txt if it exists.
if (Test-Path -Path "${INSTALL_SCRIPT_PATH}\Windows\MyScoop.txt") {
  ((Get-Content -Encoding UTF8 "${INSTALL_SCRIPT_PATH}\Windows\Scoop.txt", "${INSTALL_SCRIPT_PATH}\Windows\MyScoop.txt" | Select-String -NotMatch '^#').Line | Select-String -NotMatch '^$').Line | Sort-Object | Get-Unique | ForEach-Object { scoop install $_ }
} else {
  Get-Content -Encoding UTF8 "${INSTALL_SCRIPT_PATH}\Windows\Scoop.txt" | ForEach-Object { scoop install $_ }
}

# ---------------------------------------------------------
# Configure Windows preference
# ---------------------------------------------------------

& "${INSTALL_SCRIPT_PATH}\Windows\PreferencesWindows.ps1"

# Configure Git
# NOTE: Git can be installed on both WSL and Windows. This script will install Git on Windows and set up a .gitconfig for it.
Import-Module "${INSTALL_SCRIPT_PATH}\apps\git\SetupGitWindows"
Receive-GitConfig -Path "${INSTALL_SCRIPT_PATH}\apps\git\.gitconfig"

# Configure Hyper.js
& "${INSTALL_SCRIPT_PATH}\apps\hyper\SetupHyper.ps1" "${INSTALL_SCRIPT_PATH}\apps\hyper"

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
