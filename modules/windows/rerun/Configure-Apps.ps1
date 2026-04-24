param(
  [switch]$DryRun,
  [switch]$EnableWSL,
  [switch]$Help
)

$repoRoot = Split-Path -Parent (Split-Path -Parent (Split-Path -Parent $PSScriptRoot))
$bootstrapModule = Join-Path $repoRoot 'modules/windows/bootstrap/run.ps1'

& $bootstrapModule -Only 'configure-apps' @PSBoundParameters
