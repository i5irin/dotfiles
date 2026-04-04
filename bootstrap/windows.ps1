param(
  [switch]$DryRun,
  [switch]$EnableWSL,
  [switch]$Help
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$repoRoot = Split-Path -Parent $PSScriptRoot
$bootstrapModule = Join-Path $repoRoot 'modules/windows/bootstrap/run.ps1'

if (-not (Test-Path -LiteralPath $bootstrapModule)) {
  throw "Windows bootstrap module was not found: $bootstrapModule"
}

& $bootstrapModule @PSBoundParameters
