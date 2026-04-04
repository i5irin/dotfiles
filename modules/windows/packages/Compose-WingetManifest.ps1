param(
  [string]$OutputPath,
  [switch]$PrintSources,
  [switch]$Help
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$baseManifestPath = Join-Path $PSScriptRoot 'Winget.base.json'
$optionalManifestPath = Join-Path $PSScriptRoot 'Winget.optional.json'
$localOverridePath = Join-Path $PSScriptRoot 'local.Winget.json'

function Show-Usage {
  @'
Usage: modules/windows/packages/Compose-WingetManifest.ps1 [-OutputPath PATH] [-PrintSources] [-Help]

Compose the active Windows winget manifest from base, optional, and local override files.
'@
}

function Get-WingetPackageIdentifiers {
  param(
    [Parameter(Mandatory = $true)]
    [string]$Path
  )

  $json = Get-Content -LiteralPath $Path -Raw | ConvertFrom-Json
  if ($null -ne $json.Packages) {
    return @($json.Packages | ForEach-Object { $_.PackageIdentifier })
  }

  if ($null -ne $json.Sources) {
    return @($json.Sources[0].Packages | ForEach-Object { $_.PackageIdentifier })
  }

  return @()
}

function Resolve-Sources {
  $sources = @($baseManifestPath, $optionalManifestPath)
  if (Test-Path -LiteralPath $localOverridePath) {
    $sources += $localOverridePath
  }

  return $sources
}

function New-ComposedManifestObject {
  param(
    [Parameter(Mandatory = $true)]
    [string[]]$Sources
  )

  $seen = [System.Collections.Generic.HashSet[string]]::new()
  $packages = [System.Collections.Generic.List[object]]::new()

  foreach ($source in $Sources) {
    foreach ($packageIdentifier in Get-WingetPackageIdentifiers -Path $source) {
      if ([string]::IsNullOrWhiteSpace($packageIdentifier)) {
        continue
      }

      if ($seen.Add($packageIdentifier)) {
        $packages.Add([ordered]@{ PackageIdentifier = $packageIdentifier })
      }
    }
  }

  return [ordered]@{
    '$schema'      = 'https://aka.ms/winget-packages.schema.2.0.json'
    CreationDate   = [DateTimeOffset]::Now.ToString('o')
    Sources        = @(
      [ordered]@{
        Packages      = $packages
        SourceDetails = [ordered]@{
          Argument   = 'https://winget.azureedge.net/cache'
          Identifier = 'Microsoft.Winget.Source_8wekyb3d8bbwe'
          Name       = 'winget'
          Type       = 'Microsoft.PreIndexed.Package'
        }
      }
    )
    WinGetVersion = '2.x'
  }
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

$manifestObject = New-ComposedManifestObject -Sources $sources
$manifestJson = $manifestObject | ConvertTo-Json -Depth 8

if ($OutputPath) {
  Set-Content -LiteralPath $OutputPath -Value $manifestJson
  exit 0
}

$manifestJson
