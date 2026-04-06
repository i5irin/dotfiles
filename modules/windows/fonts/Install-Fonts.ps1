Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$firaCodeVersion = if ($env:DOTFILES_FIRA_CODE_VERSION) { $env:DOTFILES_FIRA_CODE_VERSION } else { '6.2' }
$firaCodeUrl = if ($env:DOTFILES_FIRA_CODE_URL) { $env:DOTFILES_FIRA_CODE_URL } else { "https://github.com/tonsky/FiraCode/releases/download/$firaCodeVersion/Fira_Code_v$firaCodeVersion.zip" }
$nerdFontsVersion = if ($env:DOTFILES_NERD_FONTS_VERSION) { $env:DOTFILES_NERD_FONTS_VERSION } else { '3.4.0' }
$firaCodeNerdFontUrl = if ($env:DOTFILES_FIRA_CODE_NERD_FONT_URL) { $env:DOTFILES_FIRA_CODE_NERD_FONT_URL } else { "https://github.com/ryanoasis/nerd-fonts/releases/download/v$nerdFontsVersion/FiraCode.zip" }
$fontStatePath = Join-Path $env:LOCALAPPDATA 'dotfiles\state\windows-fonts.json'

function Test-DotfilesAdministratorSession {
  $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
  $principal = [Security.Principal.WindowsPrincipal]::new($identity)
  return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

$fontTargetDir = if ($env:DOTFILES_WINDOWS_FONT_TARGET_DIR) {
  $env:DOTFILES_WINDOWS_FONT_TARGET_DIR
} elseif (Test-DotfilesAdministratorSession) {
  Join-Path $env:WINDIR 'Fonts'
} else {
  Join-Path $env:LOCALAPPDATA 'Microsoft\Windows\Fonts'
}

$fontRegistryPath = if ($fontTargetDir -like "$(Join-Path $env:WINDIR 'Fonts')*") {
  'HKLM:\Software\Microsoft\Windows NT\CurrentVersion\Fonts'
} else {
  'HKCU:\Software\Microsoft\Windows NT\CurrentVersion\Fonts'
}

$fontRegistryCleanupPaths = @(
  'HKLM:\Software\Microsoft\Windows NT\CurrentVersion\Fonts',
  'HKCU:\Software\Microsoft\Windows NT\CurrentVersion\Fonts'
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

function Resolve-FontRegistrationInfo {
  param(
    [Parameter(Mandatory = $true)]
    [System.IO.FileInfo]$FontFile
  )

  $baseName = $FontFile.BaseName
  $familyName = $null
  $faceName = $null

  if ($baseName -match '^FiraCodeNerdFontMono-(Bold|Light|Medium|Regular|Retina|SemiBold)$') {
    $familyName = 'FiraCode Nerd Font Mono'
    $faceName = $matches[1]
  } elseif ($baseName -match '^FiraCodeNerdFont-(Bold|Light|Medium|Regular|Retina|SemiBold)$') {
    $familyName = 'FiraCode Nerd Font'
    $faceName = $matches[1]
  } elseif ($baseName -match '^FiraCode-(Bold|Light|Medium|Regular|Retina|SemiBold|VF)$') {
    $familyName = 'Fira Code'
    $faceName = $matches[1]
  } else {
    return $null
  }

  $faceLabel = switch ($faceName) {
    'Regular' { $null }
    'VF' { 'Variable' }
    default { $faceName }
  }

  return [pscustomobject]@{
    FamilyName = $familyName
    FaceName = $faceLabel
    DisplayName = if ($faceLabel) { "$familyName $faceLabel" } else { $familyName }
    TypeLabel = if ($FontFile.Extension -ieq '.otf') { 'OpenType' } else { 'TrueType' }
  }
}

function Remove-ExistingFontRegistrations {
  foreach ($registryPath in $fontRegistryCleanupPaths) {
    if (-not (Test-Path -LiteralPath $registryPath)) {
      continue
    }

    $properties = Get-ItemProperty -LiteralPath $registryPath
    foreach ($property in $properties.PSObject.Properties) {
      if ($property.MemberType -ne 'NoteProperty') {
        continue
      }

      if ($property.Name -like 'Fira Code*' -or $property.Name -like 'FiraCode Nerd Font*' -or ($property.Value -is [string] -and $property.Value -like 'FiraCode*')) {
        Remove-ItemProperty -LiteralPath $registryPath -Name $property.Name -ErrorAction SilentlyContinue
      }
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

function Register-FontFile {
  param(
    [Parameter(Mandatory = $true)]
    [System.IO.FileInfo]$FontFile
  )

  $info = Resolve-FontRegistrationInfo -FontFile $FontFile
  if (-not $info) {
    return
  }

  New-Item -Path $fontRegistryPath -Force | Out-Null
  New-ItemProperty -Path $fontRegistryPath -Name "$($info.DisplayName) ($($info.TypeLabel))" -Value $FontFile.Name -PropertyType String -Force | Out-Null
}

function Broadcast-FontChange {
  $result = [UIntPtr]::Zero
  [void][DotfilesFontBroadcast]::SendMessageTimeout([IntPtr]0xffff, 0x001D, [UIntPtr]::Zero, $null, 0x0002, 1000, [ref]$result)
}

function Test-FontFilesPresent {
  param(
    [Parameter(Mandatory = $true)]
    [string[]]$Patterns
  )

  foreach ($pattern in $Patterns) {
    if (-not (Get-ChildItem -LiteralPath $fontTargetDir -Filter $pattern -ErrorAction SilentlyContinue)) {
      return $false
    }
  }

  return $true
}

function Install-FontArchive {
  param(
    [Parameter(Mandatory = $true)]
    [string]$Label,
    [Parameter(Mandatory = $true)]
    [string]$Url,
    [Parameter(Mandatory = $true)]
    [string[]]$Patterns,
    [Parameter(Mandatory = $true)]
    [string]$ArchiveName
  )

  if (Test-FontFilesPresent -Patterns $Patterns) {
    Write-Output "Skip $Label because matching font files already exist."
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
  }

  Remove-Item -LiteralPath $tempDir -Force -Recurse -ErrorAction SilentlyContinue
}

function Register-InstalledFiraFonts {
  Get-ChildItem -LiteralPath $fontTargetDir -Filter 'FiraCode*.ttf' -ErrorAction SilentlyContinue | ForEach-Object {
    Import-FontResource -Path $_.FullName
    Register-FontFile -FontFile $_
  }
}

function Resolve-InstalledFontFamilies {
  $installedFonts = [System.Drawing.Text.InstalledFontCollection]::new()
  return @($installedFonts.Families | Select-Object -ExpandProperty Name | Where-Object { $_ -like 'Fira*' })
}

function Resolve-PreferredTerminalFontFace {
  if (Get-ChildItem -LiteralPath $fontTargetDir -Filter 'FiraCodeNerdFontMono-Regular.ttf' -ErrorAction SilentlyContinue) {
    return 'FiraCode Nerd Font Mono'
  }

  if (Get-ChildItem -LiteralPath $fontTargetDir -Filter 'FiraCodeNerdFont-Regular.ttf' -ErrorAction SilentlyContinue) {
    return 'FiraCode Nerd Font'
  }

  if (Get-ChildItem -LiteralPath $fontTargetDir -Filter 'FiraCode-Regular.ttf' -ErrorAction SilentlyContinue) {
    return 'Fira Code'
  }

  $availableNames = Resolve-InstalledFontFamilies
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
    installedFamilies = Resolve-InstalledFontFamilies
  }

  $state | ConvertTo-Json -Depth 4 | Set-Content -LiteralPath $fontStatePath -Encoding UTF8
}

New-Item -ItemType Directory -Path $fontTargetDir -Force | Out-Null
Remove-ExistingFontRegistrations

Install-FontArchive -Label 'Fira Code' -Url $firaCodeUrl -Patterns @('FiraCode-Regular.ttf', 'FiraCode-Bold.ttf') -ArchiveName 'FiraCode.zip'
Install-FontArchive -Label 'FiraCode Nerd Font' -Url $firaCodeNerdFontUrl -Patterns @('FiraCodeNerdFont-Regular.ttf', 'FiraCodeNerdFontMono-Regular.ttf') -ArchiveName 'FiraCodeNerdFont.zip'

Register-InstalledFiraFonts
Broadcast-FontChange
Write-FontState
