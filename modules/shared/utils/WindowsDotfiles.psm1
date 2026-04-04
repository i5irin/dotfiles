Set-StrictMode -Version Latest

function Test-DotfilesWindowsPlatform {
  return [System.Environment]::OSVersion.Platform -eq [System.PlatformID]::Win32NT
}

function Test-DotfilesAdministrator {
  if (-not (Test-DotfilesWindowsPlatform)) {
    return $false
  }

  $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
  $principal = [Security.Principal.WindowsPrincipal]::new($identity)
  return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Set-DotfilesSymbolicLink {
  param(
    [Parameter(Mandatory = $true)]
    [string]$LinkPath,
    [Parameter(Mandatory = $true)]
    [string]$TargetPath
  )

  $parentPath = Split-Path -Parent $LinkPath
  if ($parentPath -and -not (Test-Path -LiteralPath $parentPath)) {
    New-Item -ItemType Directory -Path $parentPath -Force | Out-Null
  }

  if (Test-Path -LiteralPath $LinkPath) {
    Remove-Item -LiteralPath $LinkPath -Force -Recurse
  }

  New-Item -ItemType SymbolicLink -Path $LinkPath -Target $TargetPath -Force | Out-Null
}

function Resolve-DotfilesFirstExistingPath {
  param(
    [Parameter(Mandatory = $true)]
    [string[]]$Candidates
  )

  foreach ($candidate in $Candidates) {
    if (Test-Path -LiteralPath $candidate) {
      return $candidate
    }
  }

  return $null
}

function Enable-DotfilesRegistryKey {
  param(
    [Parameter(Mandatory = $true)]
    [string]$Path
  )

  if (-not (Test-Path -LiteralPath $Path)) {
    New-Item -Path $Path -Force | Out-Null
  }
}

Export-ModuleMember -Function Test-DotfilesWindowsPlatform, Test-DotfilesAdministrator, Set-DotfilesSymbolicLink, Resolve-DotfilesFirstExistingPath, Enable-DotfilesRegistryKey
