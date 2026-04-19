Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$timestamp = [DateTimeOffset]::Now.ToString('o')
$repoRoot = $env:DOTFILES_REPO_ROOT

if ($repoRoot) {
  Import-Module (Join-Path $repoRoot 'modules/shared/utils/WindowsDotfiles.psm1') -Force
}

if (Get-Command Write-DotfilesStepInfo -ErrorAction SilentlyContinue) {
  Write-DotfilesStepInfo 'Update Windows packages'
  Write-Host "Current time $timestamp"
} else {
  Write-Output '==============================================================='
  Write-Output '    Update applications'
  Write-Output '==============================================================='
  Write-Output "Current time $timestamp"
}

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
  if (Get-Command Write-DotfilesSkip -ErrorAction SilentlyContinue) {
    Write-DotfilesSkip 'PSWindowsUpdate cmdlets are not available.'
  } else {
    Write-Output 'Skip Windows Update integration because PSWindowsUpdate cmdlets are not available.'
  }
}
