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

function Test-FontInstalled {
  param(
    [Parameter(Mandatory = $true)]
    [string]$Pattern
  )

  return @(Get-ChildItem -LiteralPath $fontTargetDir -Filter $Pattern -ErrorAction SilentlyContinue).Count -gt 0
}

function Register-FontFile {
  param(
    [Parameter(Mandatory = $true)]
    [System.IO.FileInfo]$FontFile
  )

  $displayName = [System.IO.Path]::GetFileNameWithoutExtension($FontFile.Name).Replace('-', ' ')
  $typeLabel = if ($FontFile.Extension -ieq '.otf') { 'OpenType' } else { 'TrueType' }

  New-Item -Path $fontRegistryPath -Force | Out-Null
  New-ItemProperty -Path $fontRegistryPath -Name "$displayName ($typeLabel)" -Value $FontFile.Name -PropertyType String -Force | Out-Null
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
    Register-FontFile -FontFile (Get-Item -LiteralPath $targetPath)
  }

  Remove-Item -LiteralPath $tempDir -Force -Recurse -ErrorAction SilentlyContinue
}

New-Item -ItemType Directory -Path $fontTargetDir -Force | Out-Null

Install-FontArchive -Label 'Fira Code' -Url $firaCodeUrl -Pattern 'FiraCode-*.ttf' -ArchiveName 'FiraCode.zip'
Install-FontArchive -Label 'FiraCode Nerd Font' -Url $firaCodeNerdFontUrl -Pattern 'FiraCodeNerdFont-*.ttf' -ArchiveName 'FiraCodeNerd.zip'
