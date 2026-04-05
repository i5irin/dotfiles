$repoRoot = Split-Path -Parent (Split-Path -Parent (Split-Path -Parent $PSScriptRoot))
$localProfilePath = Join-Path $repoRoot 'modules/shell/powershell/Microsoft.PowerShell_profile.local.ps1'

if (Get-Module -ListAvailable -Name posh-git) {
  Import-Module posh-git -ErrorAction SilentlyContinue | Out-Null
}

if (Get-Module -ListAvailable -Name PSReadLine) {
  Import-Module PSReadLine -ErrorAction SilentlyContinue | Out-Null
  Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete

  $setPSReadLineOption = Get-Command Set-PSReadLineOption -ErrorAction SilentlyContinue
  if ($setPSReadLineOption) {
    Set-PSReadLineOption -BellStyle None -ErrorAction SilentlyContinue
    if ($setPSReadLineOption.Parameters.ContainsKey('PredictionSource')) {
      Set-PSReadLineOption -PredictionSource History -ErrorAction SilentlyContinue
    }
    if ($setPSReadLineOption.Parameters.ContainsKey('PredictionViewStyle')) {
      Set-PSReadLineOption -PredictionViewStyle ListView -ErrorAction SilentlyContinue
    }
  }
}

if (Get-Command starship -ErrorAction SilentlyContinue) {
  Invoke-Expression (& starship init powershell)
}

if (Get-Command nvim -ErrorAction SilentlyContinue) {
  Set-Alias -Name vim -Value nvim -Option AllScope
  $env:EDITOR = 'nvim'
  $env:VISUAL = 'nvim'
}

if (Test-Path -LiteralPath $localProfilePath) {
  . $localProfilePath
}
