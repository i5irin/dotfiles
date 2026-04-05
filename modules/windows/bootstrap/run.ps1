param(
  [switch]$DryRun,
  [switch]$EnableWSL,
  [switch]$Help
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$repoRoot = Split-Path -Parent (Split-Path -Parent (Split-Path -Parent $PSScriptRoot))
$sharedModulePath = Join-Path $repoRoot 'modules/shared/utils/WindowsDotfiles.psm1'
Import-Module $sharedModulePath -Force

$configEnvPath = if ($env:DOTFILES_WINDOWS_CONFIG_PATH) { $env:DOTFILES_WINDOWS_CONFIG_PATH } else { Join-Path $repoRoot 'config/windows.env' }
$bootstrapConfigSource = if (Import-DotfilesEnvFile -Path $configEnvPath) { $configEnvPath } else { 'none' }

$wingetComposer = Join-Path $repoRoot 'modules/windows/packages/Compose-WingetManifest.ps1'
$packagesModule = Join-Path $repoRoot 'modules/windows/packages/Install-Packages.ps1'
$fontsModule = Join-Path $repoRoot 'modules/windows/fonts/Install-Fonts.ps1'
$powerShellModulesInstaller = Join-Path $repoRoot 'modules/shell/powershell/Install-Modules.ps1'
$profileModule = Join-Path $repoRoot 'modules/shell/powershell/Install-Profile.ps1'
$preferencesModule = Join-Path $repoRoot 'modules/windows/preferences/Apply.ps1'
$updateModule = Join-Path $repoRoot 'modules/windows/update/Register-UpdateTask.ps1'
$appsModule = Join-Path $repoRoot 'modules/windows/apps/Configure.ps1'

$canonicalWingetOverride = Join-Path $repoRoot 'modules/windows/packages/local.Winget.json'

function Write-ProgressInfo {
  param([Parameter(Mandatory = $true)][string]$Message)

  Write-Host "==> $Message"
}

function Write-ProgressSuccess {
  param([Parameter(Mandatory = $true)][string]$Message)

  Write-Host "[OK] $Message"
}

function Invoke-BootstrapStep {
  param(
    [Parameter(Mandatory = $true)]
    [string]$Label,
    [Parameter(Mandatory = $true)]
    [scriptblock]$ScriptBlock
  )

  Write-ProgressInfo $Label
  try {
    & $ScriptBlock
    Write-ProgressSuccess $Label
  } catch {
    Write-Error "FAILED: $Label"
    throw
  }
}

function Show-Usage {
  @'
Usage: bootstrap/windows.ps1 [-DryRun] [-EnableWSL] [-Help]

Windows bootstrap entry point.

Options:
  -DryRun     Print the resolved configuration without executing setup.
  -EnableWSL  Include WSL installation in the setup flow.
  -Help       Show this help message.
'@
}

function Test-Layout {
  $requiredPaths = @(
    $wingetComposer,
    $packagesModule,
    $fontsModule,
    $powerShellModulesInstaller,
    $profileModule,
    $preferencesModule,
    $updateModule,
    $appsModule
  )

  foreach ($requiredPath in $requiredPaths) {
    if (-not (Test-Path -LiteralPath $requiredPath)) {
      throw "Required module was not found: $requiredPath"
    }
  }
}

function Resolve-LocalOverrideSource {
  $wingetOverride = Resolve-DotfilesFirstExistingPath -Candidates @($canonicalWingetOverride)

  return [ordered]@{
    Winget = if ($wingetOverride) { $wingetOverride } else { 'none' }
  }
}

function Write-DryRunConfiguration {
  $tempDir = Join-Path ([System.IO.Path]::GetTempPath()) ("dotfiles-windows-{0}" -f [guid]::NewGuid().ToString('N'))
  $wingetManifestPath = Join-Path $tempDir 'Winget.manifest.json'
  $overrideSource = Resolve-LocalOverrideSource

  New-Item -ItemType Directory -Path $tempDir -Force | Out-Null
  try {
    & $wingetComposer -OutputPath $wingetManifestPath | Out-Null

    Write-Output "repo_root=$repoRoot"
    Write-Output "bootstrap_module=$PSScriptRoot"
    Write-Output "host_platform=$([System.Environment]::OSVersion.Platform)"
    Write-Output "is_windows_host=$(Test-DotfilesWindowsPlatform)"
    Write-Output "is_admin=$(Test-DotfilesAdministrator)"
    Write-Output "enable_wsl=$($EnableWSL.IsPresent -or $env:DOTFILES_WINDOWS_ENABLE_WSL -eq '1')"
    Write-Output "winget_manifest=$wingetManifestPath"
    Write-Output "bootstrap_config_source=$bootstrapConfigSource"
    Write-Output "winget_local_override_source=$($overrideSource.Winget)"
    Write-Output 'winget_sources='
    & $wingetComposer -PrintSources
  } finally {
    Remove-Item -LiteralPath $tempDir -Force -Recurse -ErrorAction SilentlyContinue
  }
}

function Invoke-BootstrapModules {
  $tempDir = Join-Path ([System.IO.Path]::GetTempPath()) ("dotfiles-windows-{0}" -f [guid]::NewGuid().ToString('N'))
  $wingetManifestPath = Join-Path $tempDir 'Winget.manifest.json'

  New-Item -ItemType Directory -Path $tempDir -Force | Out-Null
  try {
    Invoke-BootstrapStep -Label 'Resolve Windows package manifests' -ScriptBlock {
      & $wingetComposer -OutputPath $wingetManifestPath | Out-Null
    }

    $env:DOTFILES_REPO_ROOT = $repoRoot
    $env:DOTFILES_BOOTSTRAP_CONFIG_PATH = $configEnvPath
    $env:DOTFILES_WINGET_MANIFEST_PATH = $wingetManifestPath
    $env:DOTFILES_WINDOWS_ENABLE_WSL = if ($EnableWSL.IsPresent -or $env:DOTFILES_WINDOWS_ENABLE_WSL -eq '1') { '1' } else { '0' }

    Invoke-BootstrapStep -Label 'Install Windows packages' -ScriptBlock { & $packagesModule }
    Invoke-BootstrapStep -Label 'Install terminal/editor fonts' -ScriptBlock { & $fontsModule }
    Invoke-BootstrapStep -Label 'Install PowerShell completion modules' -ScriptBlock { & $powerShellModulesInstaller }
    Invoke-BootstrapStep -Label 'Install PowerShell profile' -ScriptBlock { & $profileModule }
    Invoke-BootstrapStep -Label 'Apply Windows preferences' -ScriptBlock { & $preferencesModule }
    Invoke-BootstrapStep -Label 'Register Windows update task' -ScriptBlock { & $updateModule }
    Invoke-BootstrapStep -Label 'Configure Windows applications' -ScriptBlock { & $appsModule }
  } finally {
    Remove-Item -LiteralPath $tempDir -Force -Recurse -ErrorAction SilentlyContinue
  }
}

if ($Help) {
  Show-Usage
  exit 0
}

Test-Layout

if ($DryRun) {
  Write-DryRunConfiguration
  exit 0
}

if (-not (Test-DotfilesWindowsPlatform)) {
  throw 'This bootstrap entry only supports Windows.'
}

if (-not (Test-DotfilesAdministrator)) {
  throw 'This bootstrap entry must be run with administrative privileges.'
}

Write-ProgressInfo 'Starting Windows bootstrap.'
Invoke-BootstrapModules
Write-ProgressSuccess 'Windows bootstrap completed.'
