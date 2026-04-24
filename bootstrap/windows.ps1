param(
  [switch]$DryRun,
  [switch]$EnableWSL,
  [ValidateSet('install-apps', 'configure-shell', 'apply-preferences', 'register-update-job', 'configure-apps')]
  [string]$Only,
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
