param(
  [string]$OutputPath,
  [switch]$PrintSources,
  [switch]$Help
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$baseListPath = Join-Path $PSScriptRoot 'Scoop.base.txt'
$optionalListPath = Join-Path $PSScriptRoot 'Scoop.optional.txt'
$localOverridePath = Join-Path $PSScriptRoot 'local.Scoop.txt'

function Show-Usage {
  @'
Usage: modules/windows/packages/Compose-ScoopList.ps1 [-OutputPath PATH] [-PrintSources] [-Help]

Compose the active Windows Scoop package list from base, optional, and local override files.
'@
}

function Get-ScoopPackageNames {
  param(
    [Parameter(Mandatory = $true)]
    [string]$Path
  )

  return @(Get-Content -LiteralPath $Path | ForEach-Object { $_.Trim() } | Where-Object { $_ -and -not $_.StartsWith('#') })
}

function Resolve-Sources {
  $sources = @($baseListPath, $optionalListPath)
  if (Test-Path -LiteralPath $localOverridePath) {
    $sources += $localOverridePath
  }

  return $sources
}

function New-ComposedScoopList {
  param(
    [Parameter(Mandatory = $true)]
    [string[]]$Sources
  )

  $seen = [System.Collections.Generic.HashSet[string]]::new()
  $packages = [System.Collections.Generic.List[string]]::new()

  foreach ($source in $Sources) {
    foreach ($packageName in Get-ScoopPackageNames -Path $source) {
      if ($seen.Add($packageName)) {
        $packages.Add($packageName)
      }
    }
  }

  return $packages
}

if ($Help) {
  Show-Usage
  exit 0
}

$sources = Resolve-Sources
if ($PrintSources) {
  $sources
  exit 0
}

$packages = New-ComposedScoopList -Sources $sources

if ($OutputPath) {
  Set-Content -LiteralPath $OutputPath -Value $packages
  exit 0
}

$packages
