Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$firaCodeVersion = if ($env:DOTFILES_FIRA_CODE_VERSION) { $env:DOTFILES_FIRA_CODE_VERSION } else { '6.2' }
$firaCodeUrl = if ($env:DOTFILES_FIRA_CODE_URL) { $env:DOTFILES_FIRA_CODE_URL } else { "https://github.com/tonsky/FiraCode/releases/download/$firaCodeVersion/Fira_Code_v$firaCodeVersion.zip" }
$nerdFontsVersion = if ($env:DOTFILES_NERD_FONTS_VERSION) { $env:DOTFILES_NERD_FONTS_VERSION } else { '3.4.0' }
$firaCodeNerdFontUrl = if ($env:DOTFILES_FIRA_CODE_NERD_FONT_URL) { $env:DOTFILES_FIRA_CODE_NERD_FONT_URL } else { "https://github.com/ryanoasis/nerd-fonts/releases/download/v$nerdFontsVersion/FiraCode.zip" }
$fontStatePath = Join-Path $env:LOCALAPPDATA 'dotfiles\state\windows-fonts.json'
$fontTargetDir = if ($env:DOTFILES_WINDOWS_FONT_TARGET_DIR) {
  $env:DOTFILES_WINDOWS_FONT_TARGET_DIR
} else {
  Join-Path $env:WINDIR 'Fonts'
}
$fontRegistryPath = 'HKLM:\Software\Microsoft\Windows NT\CurrentVersion\Fonts'
$userFontRegistryPath = 'HKCU:\Software\Microsoft\Windows NT\CurrentVersion\Fonts'

$managedFonts = @(
  @{
    Label = 'Fira Code'
    Url = $firaCodeUrl
    ArchiveName = 'FiraCode.zip'
    FileName = 'FiraCode-Regular.ttf'
    DisplayName = 'Fira Code'
    TypeLabel = 'TrueType'
  },
  @{
    Label = 'Fira Code'
    Url = $firaCodeUrl
    ArchiveName = 'FiraCode.zip'
    FileName = 'FiraCode-Bold.ttf'
    DisplayName = 'Fira Code Bold'
    TypeLabel = 'TrueType'
  },
  @{
    Label = 'FiraCode Nerd Font'
    Url = $firaCodeNerdFontUrl
    ArchiveName = 'FiraCodeNerdFont.zip'
    FileName = 'FiraCodeNerdFont-Regular.ttf'
    DisplayName = 'FiraCode Nerd Font'
    TypeLabel = 'TrueType'
  },
  @{
    Label = 'FiraCode Nerd Font Mono'
    Url = $firaCodeNerdFontUrl
    ArchiveName = 'FiraCodeNerdFont.zip'
    FileName = 'FiraCodeNerdFontMono-Regular.ttf'
    DisplayName = 'FiraCode Nerd Font Mono'
    TypeLabel = 'TrueType'
  }
)

if (-not ('DotfilesFontBroadcast' -as [type])) {
  Add-Type @'
using System;
using System.Runtime.InteropServices;

public static class DotfilesFontBroadcast {
  [DllImport("gdi32.dll", CharSet = CharSet.Unicode, SetLastError = true)]
  public static extern int AddFontResourceEx(string lpszFilename, uint fl, IntPtr pdv);

  [DllImport("user32.dll", CharSet = CharSet.Auto, SetLastError = true)]
  public static extern IntPtr SendMessageTimeout(
    IntPtr hWnd,
    uint Msg,
    UIntPtr wParam,
    string lParam,
    uint fuFlags,
    uint uTimeout,
    out UIntPtr lpdwResult
  );
}
'@
}

Add-Type -AssemblyName System.Drawing

function Test-IsAdministrator {
  $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
  $principal = [Security.Principal.WindowsPrincipal]::new($identity)
  return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Assert-Administrator {
  if (-not (Test-IsAdministrator)) {
    throw 'Windows font installation requires an elevated PowerShell session.'
  }
}

function Remove-ExistingFontRegistrations {
  foreach ($registryPath in @($fontRegistryPath, $userFontRegistryPath)) {
    if (-not (Test-Path -LiteralPath $registryPath)) {
      continue
    }

    foreach ($font in $managedFonts) {
      $propertyName = "$($font.DisplayName) ($($font.TypeLabel))"
      Remove-ItemProperty -LiteralPath $registryPath -Name $propertyName -ErrorAction SilentlyContinue
    }
  }
}

function Import-FontResource {
  param(
    [Parameter(Mandatory = $true)]
    [string]$Path
  )

  [void][DotfilesFontBroadcast]::AddFontResourceEx($Path, 0, [IntPtr]::Zero)
}

function Broadcast-FontChange {
  $result = [UIntPtr]::Zero
  [void][DotfilesFontBroadcast]::SendMessageTimeout([IntPtr]0xffff, 0x001D, [UIntPtr]::Zero, $null, 0x0002, 1000, [ref]$result)
}

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
  foreach ($candidate in @('FiraCode Nerd Font Mono', 'FiraCode Nerd Font', 'Fira Code')) {
    if ($availableNames -contains $candidate) {
      return $candidate
    }
  }

  return 'Consolas'
}

function Write-FontState {
  $stateDir = Split-Path -Parent $fontStatePath
  if (-not (Test-Path -LiteralPath $stateDir)) {
    New-Item -ItemType Directory -Path $stateDir -Force | Out-Null
  }

  $state = [ordered]@{
    targetDir = $fontTargetDir
    registryPath = $fontRegistryPath
    preferredTerminalFontFace = Resolve-PreferredTerminalFontFace
    installedFamilies = Get-InstalledFontFamilies
  }

  $state | ConvertTo-Json -Depth 4 | Set-Content -LiteralPath $fontStatePath -Encoding UTF8
}

function Ensure-FontFileFromArchive {
  param(
    [Parameter(Mandatory = $true)]
    [hashtable]$Font
  )

  $targetPath = Join-Path $fontTargetDir $Font.FileName
  if (Test-Path -LiteralPath $targetPath) {
    return $targetPath
  }

  $tempDir = Join-Path ([System.IO.Path]::GetTempPath()) ("dotfiles-fonts-{0}" -f [guid]::NewGuid().ToString('N'))
  $archivePath = Join-Path $tempDir $Font.ArchiveName
  $extractDir = Join-Path $tempDir 'extract'

  New-Item -ItemType Directory -Path $extractDir -Force | Out-Null
  Invoke-WebRequest -Uri $Font.Url -OutFile $archivePath
  Expand-Archive -LiteralPath $archivePath -DestinationPath $extractDir -Force

  $sourcePath = Get-ChildItem -Path $extractDir -Recurse -File | Where-Object {
    $_.Name -eq $Font.FileName
  } | Select-Object -First 1 -ExpandProperty FullName

  if (-not $sourcePath) {
    Remove-Item -LiteralPath $tempDir -Force -Recurse -ErrorAction SilentlyContinue
    throw "Required font file was not found in archive: $($Font.FileName)"
  }

  Copy-Item -LiteralPath $sourcePath -Destination $targetPath -Force
  Remove-Item -LiteralPath $tempDir -Force -Recurse -ErrorAction SilentlyContinue
  return $targetPath
}

function Register-Font {
  param(
    [Parameter(Mandatory = $true)]
    [hashtable]$Font
  )

  $targetPath = Ensure-FontFileFromArchive -Font $Font
  New-Item -Path $fontRegistryPath -Force | Out-Null
  New-ItemProperty -Path $fontRegistryPath -Name "$($Font.DisplayName) ($($Font.TypeLabel))" -Value $Font.FileName -PropertyType String -Force | Out-Null
  Import-FontResource -Path $targetPath
}

Assert-Administrator
New-Item -ItemType Directory -Path $fontTargetDir -Force | Out-Null
Remove-ExistingFontRegistrations

foreach ($font in $managedFonts) {
  Register-Font -Font $font
}

Broadcast-FontChange
Write-FontState
