Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$fontDirs = @(
  (Join-Path $env:WINDIR 'Fonts'),
  (Join-Path $env:LOCALAPPDATA 'Microsoft\Windows\Fonts')
)

Add-Type -AssemblyName System.Drawing

function Resolve-PreferredTerminalFontFace {
  $installedFonts = [System.Drawing.Text.InstalledFontCollection]::new()
  $availableNames = @($installedFonts.Families | Select-Object -ExpandProperty Name)
  foreach ($candidatePattern in @('FiraCode Nerd Font Mono*', 'FiraCode Nerd Font*', 'Fira Code*')) {
    $match = @($availableNames | Where-Object { $_ -like $candidatePattern } | Select-Object -First 1)
    if ($match) {
      return $match[0]
    }
  }

  return 'Consolas'
}

Write-Output '== font files =='
foreach ($fontDir in $fontDirs) {
  if (-not (Test-Path -LiteralPath $fontDir)) {
    continue
  }

  Write-Output "-- $fontDir"
  Get-ChildItem -LiteralPath $fontDir -Filter 'Fira*' -ErrorAction SilentlyContinue |
    Sort-Object Name |
    Select-Object -ExpandProperty Name
}

Write-Output ''
Write-Output '== installed font families =='
$installedFonts = [System.Drawing.Text.InstalledFontCollection]::new()
$installedFonts.Families |
  Where-Object { $_.Name -like 'Fira*' } |
  Sort-Object Name |
  Select-Object -ExpandProperty Name

Write-Output ''
Write-Output '== preferred terminal font =='
Write-Output (Resolve-PreferredTerminalFontFace)

Write-Output ''
Write-Output '== registry HKLM =='
reg query 'HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts' /f 'Fira' /s

Write-Output ''
Write-Output '== registry HKCU =='
reg query 'HKCU\Software\Microsoft\Windows NT\CurrentVersion\Fonts' /f 'Fira' /s
