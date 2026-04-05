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
    $existingItem = Get-Item -LiteralPath $LinkPath -Force
    $resolvedTarget = (Resolve-Path -LiteralPath $TargetPath).ProviderPath
    if ($existingItem.Attributes -band [IO.FileAttributes]::ReparsePoint) {
      $existingTarget = $existingItem.Target
      if ($existingTarget -is [array]) {
        $existingTarget = $existingTarget[0]
      }

      if ($existingTarget) {
        try {
          $resolvedExistingTarget = (Resolve-Path -LiteralPath $existingTarget).ProviderPath
          if ($resolvedExistingTarget -eq $resolvedTarget) {
            return
          }
        } catch {
        }
      }
    }

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

function Import-DotfilesEnvFile {
  param(
    [Parameter(Mandatory = $true)]
    [string]$Path
  )

  if (-not (Test-Path -LiteralPath $Path)) {
    return $false
  }

  foreach ($line in Get-Content -LiteralPath $Path) {
    $trimmed = $line.Trim()
    if (-not $trimmed -or $trimmed.StartsWith('#')) {
      continue
    }

    if ($trimmed -notmatch '^([A-Za-z_][A-Za-z0-9_]*)=(.*)$') {
      throw "Unsupported env line in $Path: $trimmed"
    }

    $name = $matches[1]
    $value = $matches[2].Trim()

    if ($value.Length -ge 2) {
      if (($value.StartsWith("'") -and $value.EndsWith("'")) -or ($value.StartsWith('"') -and $value.EndsWith('"'))) {
        $value = $value.Substring(1, $value.Length - 2)
      }
    }

    [Environment]::SetEnvironmentVariable($name, $value, 'Process')
  }

  return $true
}

Export-ModuleMember -Function Test-DotfilesWindowsPlatform, Test-DotfilesAdministrator, Set-DotfilesSymbolicLink, Resolve-DotfilesFirstExistingPath, Enable-DotfilesRegistryKey, Import-DotfilesEnvFile
