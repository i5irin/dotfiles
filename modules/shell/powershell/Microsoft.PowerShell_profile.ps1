$repoRoot = Split-Path -Parent (Split-Path -Parent (Split-Path -Parent $PSScriptRoot))
$localProfilePath = Join-Path $repoRoot 'modules/shell/powershell/Microsoft.PowerShell_profile.local.ps1'

if (Get-Command starship -ErrorAction SilentlyContinue) {
  Invoke-Expression (& starship init powershell)
}

if (Test-Path -LiteralPath $localProfilePath) {
  . $localProfilePath
}
