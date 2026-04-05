Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$firaCodeVersion = if ($env:DOTFILES_FIRA_CODE_VERSION) { $env:DOTFILES_FIRA_CODE_VERSION } else { '6.2' }
$firaCodeUrl = if ($env:DOTFILES_FIRA_CODE_URL) { $env:DOTFILES_FIRA_CODE_URL } else { "https://github.com/tonsky/FiraCode/releases/download/$firaCodeVersion/Fira_Code_v$firaCodeVersion.zip" }
$firaCodeNerdFontUrl = if ($env:DOTFILES_FIRA_CODE_NERD_FONT_URL) { $env:DOTFILES_FIRA_CODE_NERD_FONT_URL } else { 'https://github.com/ryanoasis/nerd-fonts/releases/latest/download/FiraCode.zip' }

$fontTargetDir = if ($env:DOTFILES_WINDOWS_FONT_TARGET_DIR) {
  $env:DOTFILES_WINDOWS_FONT_TARGET_DIR
} else {
  Join-Path $env:LOCALAPPDATA 'Microsoft\Windows\Fonts'
}

$fontRegistryPath = 'HKCU:\Software\Microsoft\Windows NT\CurrentVersion\Fonts'

Add-Type -AssemblyName PresentationCore
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

function Test-FontInstalled {
  param(
    [Parameter(Mandatory = $true)]
    [string]$Pattern
  )

  return @(Get-ChildItem -LiteralPath $fontTargetDir -Filter $Pattern -ErrorAction SilentlyContinue).Count -gt 0
}

function Test-AllFontsInstalled {
  param(
    [Parameter(Mandatory = $true)]
    [string[]]$Patterns
  )

  foreach ($pattern in $Patterns) {
    if (-not (Test-FontInstalled -Pattern $pattern)) {
      return $false
    }
  }

  return $true
}

function Register-FontFile {
  param(
    [Parameter(Mandatory = $true)]
    [System.IO.FileInfo]$FontFile
  )

  $glyphTypeface = [Windows.Media.GlyphTypeface]::new($FontFile.FullName)
  $familyName = $glyphTypeface.Win32FamilyNames['en-us']
  if (-not $familyName) {
    $familyName = @($glyphTypeface.Win32FamilyNames.Values | Select-Object -First 1)[0]
  }

  $faceName = $glyphTypeface.Win32FaceNames['en-us']
  if (-not $faceName) {
    $faceName = @($glyphTypeface.Win32FaceNames.Values | Select-Object -First 1)[0]
  }

  $typeLabel = if ($FontFile.Extension -ieq '.otf') { 'OpenType' } else { 'TrueType' }
  $displayName = if ($faceName -and $faceName -ne 'Regular') {
    "$familyName $faceName"
  } else {
    $familyName
  }

  New-Item -Path $fontRegistryPath -Force | Out-Null
  New-ItemProperty -Path $fontRegistryPath -Name "$displayName ($typeLabel)" -Value $FontFile.Name -PropertyType String -Force | Out-Null
}

function Broadcast-FontChange {
  $result = [UIntPtr]::Zero
  [void][DotfilesFontBroadcast]::SendMessageTimeout([IntPtr]0xffff, 0x001D, [UIntPtr]::Zero, $null, 0x0002, 1000, [ref]$result)
}

function Import-FontResource {
  param(
    [Parameter(Mandatory = $true)]
    [string]$Path
  )

  [void][DotfilesFontBroadcast]::AddFontResourceEx($Path, 0x10, [IntPtr]::Zero)
}

function Install-FontArchive {
  param(
    [Parameter(Mandatory = $true)]
    [string]$Label,
    [Parameter(Mandatory = $true)]
    [string]$Url,
    [Parameter(Mandatory = $true)]
    [string]$Pattern,
    [Parameter(Mandatory = $true)]
    [string]$ArchiveName
  )

  if (Test-FontInstalled -Pattern $Pattern) {
    Write-Output "Skip $Label because matching fonts already exist."
    return
  }

  $tempDir = Join-Path ([System.IO.Path]::GetTempPath()) ("dotfiles-fonts-{0}" -f [guid]::NewGuid().ToString('N'))
  $archivePath = Join-Path $tempDir $ArchiveName
  $extractDir = Join-Path $tempDir 'extract'

  New-Item -ItemType Directory -Path $extractDir -Force | Out-Null
  Invoke-WebRequest -Uri $Url -OutFile $archivePath
  Expand-Archive -LiteralPath $archivePath -DestinationPath $extractDir -Force

  Get-ChildItem -Path $extractDir -Recurse -Include *.ttf, *.otf | ForEach-Object {
    $targetPath = Join-Path $fontTargetDir $_.Name
    Copy-Item -LiteralPath $_.FullName -Destination $targetPath -Force
    Import-FontResource -Path $targetPath
    Register-FontFile -FontFile (Get-Item -LiteralPath $targetPath)
  }

  Remove-Item -LiteralPath $tempDir -Force -Recurse -ErrorAction SilentlyContinue
}

New-Item -ItemType Directory -Path $fontTargetDir -Force | Out-Null

Install-FontArchive -Label 'Fira Code' -Url $firaCodeUrl -Pattern 'FiraCode-*.ttf' -ArchiveName 'FiraCode.zip'
if (Test-AllFontsInstalled -Patterns @('FiraCodeNerdFont-*.ttf', 'FiraCodeNerdFontMono-*.ttf')) {
  Write-Output 'Skip FiraCode Nerd Font because matching Regular and Mono fonts already exist.'
} else {
  Install-FontArchive -Label 'FiraCode Nerd Font' -Url $firaCodeNerdFontUrl -Pattern 'FiraCodeNerdFont*.ttf' -ArchiveName 'FiraCodeNerd.zip'
}
Broadcast-FontChange
