Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$repoRoot = $env:DOTFILES_REPO_ROOT
if (-not $repoRoot) {
  throw 'DOTFILES_REPO_ROOT is required.'
}

$taskName = 'UpdateWingetPackages'
$updateScriptPath = Join-Path $repoRoot 'modules/windows/update/Update-Packages.ps1'
$taskAction = New-ScheduledTaskAction -Execute 'powershell.exe' -Argument "-NoProfile -ExecutionPolicy Bypass -File `"$updateScriptPath`""
$taskTrigger = New-ScheduledTaskTrigger -Daily -At '00:00'

if (-not [System.Diagnostics.EventLog]::SourceExists('WingetUpdate')) {
  New-EventLog -LogName Application -Source WingetUpdate
}

if (Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue) {
  Unregister-ScheduledTask -TaskName $taskName -Confirm:$false
}

Register-ScheduledTask -TaskName $taskName -Description 'Update the packages installed by winget.' -Action $taskAction -Trigger $taskTrigger -RunLevel Highest | Out-Null
