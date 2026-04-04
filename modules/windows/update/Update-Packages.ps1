Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$timestamp = [DateTimeOffset]::Now.ToString('o')

Write-Output '==============================================================='
Write-Output '    Update applications'
Write-Output '==============================================================='
Write-Output "Current time $timestamp"

if (Get-Command winget -ErrorAction SilentlyContinue) {
  Write-EventLog -LogName Application -Source WingetUpdate -EventId 0 -EntryType Information -Message 'winget upgrade --all'
  winget upgrade --all --accept-source-agreements --accept-package-agreements
  Write-EventLog -LogName Application -Source WingetUpdate -EventId 0 -EntryType Information -Message 'winget upgrade completed.'
}

if ((Get-Command Start-WUScan -ErrorAction SilentlyContinue) -and (Get-Command Install-WUUpdates -ErrorAction SilentlyContinue)) {
  Start-WUScan | ForEach-Object {
    Write-Output "Install Windows Update: $($_.Title)"
    Install-WUUpdates -Updates $_
  }
} else {
  Write-Output 'Skip Windows Update integration because PSWindowsUpdate cmdlets are not available.'
}
