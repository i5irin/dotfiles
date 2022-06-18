# Activate Developer Mode.
Set-ItemProperty -LiteralPath 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock' -Name 'AllowDevelopmentWithoutDevLicense' -Value '1'

# Display the extensions of known file types.
Set-ItemProperty -LiteralPath 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name 'HideFileExt' -Value 0

# Show the full path in the Explorer title.
Enable-RegistryKey -Name 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CabinetState'
Set-ItemProperty -LiteralPath 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CabinetState' -Name 'FullPath' -Value 1

# Restart explorer.
Stop-Process -ProcessName explorer

# Make event log record the task scheduler actions.
Set-ItemProperty -LiteralPath 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WINEVT\Channels\Microsoft-Windows-TaskScheduler\Operational' -Name 'Enabled' -Value 1

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
Enable-RegistryKey -Name 'HKLM:\SOFTWARE\Policies\Microsoft\Edge'

# Disable storing passwords.
# Recommendedは設定をUI側でするときの文言が変わる程度CLIから設定するのであればRecommendedは使わないほうがいい
Set-ItemProperty -LiteralPath 'HKLM:\SOFTWARE\Policies\Microsoft\Edge' -Name 'PasswordManagerEnabled' -Value 0

# Disable auto-filling your address.
Set-ItemProperty -LiteralPath 'HKLM:\SOFTWARE\Policies\Microsoft\Edge' -Name 'AutofillAddressEnabled' -Value 0

# Disable auto-filling your credit card information.
Set-ItemProperty -LiteralPath 'HKLM:\SOFTWARE\Policies\Microsoft\Edge' -Name 'AutofillCreditCardEnabled' -Value 0
