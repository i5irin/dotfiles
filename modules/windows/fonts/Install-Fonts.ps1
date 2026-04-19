Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$repoRoot = $env:DOTFILES_REPO_ROOT
if (-not $repoRoot) {
  throw 'DOTFILES_REPO_ROOT is required.'
}

Import-Module (Join-Path $repoRoot 'modules/shared/utils/WindowsDotfiles.psm1') -Force

$fontStatePath = Join-Path $env:LOCALAPPDATA 'dotfiles\state\windows-fonts.json'
$firaCodeNerdFontUrl = if ($env:DOTFILES_FIRA_CODE_NERD_FONT_URL) { $env:DOTFILES_FIRA_CODE_NERD_FONT_URL } else { 'https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/FiraCode.zip' }
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

  Write-DotfilesWarning 'FiraCode Nerd Font Mono is not installed. Terminal glyphs and ligatures depend on the client terminal having that font available.'
  Write-DotfilesNext "Download and install FiraCode Nerd Font from $firaCodeNerdFontUrl."
  Write-Host '      Use FiraCode Nerd Font Mono when Windows asks which family to enable.'
  Write-DotfilesNext 'Sign out and sign back in if Windows does not pick up the new fonts immediately.'
  Write-DotfilesNext 'Rerun modules/windows/fonts/Install-Fonts.ps1 and modules/windows/apps/Configure-Terminal.ps1.'
}

Write-FontState
Write-ManualFontGuidance
