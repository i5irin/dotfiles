Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$fontStatePath = Join-Path $env:LOCALAPPDATA 'dotfiles\state\windows-fonts.json'
$fontDirs = @(
  (Join-Path $env:WINDIR 'Fonts'),
  (Join-Path $env:LOCALAPPDATA 'Microsoft\Windows\Fonts')
)

Add-Type -AssemblyName System.Drawing

function Get-InstalledFontFamilies {
  $installedFonts = [System.Drawing.Text.InstalledFontCollection]::new()
  return @(
    $installedFonts.Families |
      Select-Object -ExpandProperty Name |
      Where-Object { $_ -like 'Fira*' } |
      Sort-Object -Unique
  )
}

function Resolve-PreferredTerminalFontFace {
  $availableNames = Get-InstalledFontFamilies
  foreach ($candidatePattern in @('FiraCode Nerd Font Mono*', 'FiraCode Nerd Font*', 'Fira Code*')) {
    $match = @($availableNames | Where-Object { $_ -like $candidatePattern } | Select-Object -First 1)
    if ($match) {
      return $match[0]
    }
  }

  return 'FiraCode Nerd Font Mono'
}

function Write-FontState {
  $stateDir = Split-Path -Parent $fontStatePath
  if (-not (Test-Path -LiteralPath $stateDir)) {
    New-Item -ItemType Directory -Path $stateDir -Force | Out-Null
  }

  $state = [ordered]@{
    targetDirs = @($fontDirs | Where-Object { Test-Path -LiteralPath $_ })
    preferredTerminalFontFace = Resolve-PreferredTerminalFontFace
    installedFamilies = Get-InstalledFontFamilies
  }

  $state | ConvertTo-Json -Depth 4 | Set-Content -LiteralPath $fontStatePath -Encoding UTF8
}

function Write-ManualFontGuidance {
  $installedFamilies = Get-InstalledFontFamilies
  if ($installedFamilies -contains 'FiraCode Nerd Font Mono') {
    return
  }

  Write-Warning 'FiraCode Nerd Font Mono is not installed. Terminal glyphs and ligatures depend on the client terminal having that font available.'
  Write-Host 'Manual setup:'
  Write-Host '  1. Install Fira Code and FiraCode Nerd Font Mono for the current user or all users.'
  Write-Host '  2. Sign out and sign back in if Windows does not pick up the new fonts immediately.'
  Write-Host '  3. Rerun modules/windows/fonts/Install-Fonts.ps1 and modules/windows/apps/Configure-Terminal.ps1.'
}

Write-FontState
Write-ManualFontGuidance
