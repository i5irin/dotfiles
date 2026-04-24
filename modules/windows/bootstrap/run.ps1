param(
  [switch]$DryRun,
  [switch]$EnableWSL,
  [ValidateSet('install-apps', 'configure-shell', 'apply-preferences', 'register-update-job', 'configure-apps')]
  [string]$Only,
  [switch]$Help
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$repoRoot = Split-Path -Parent (Split-Path -Parent (Split-Path -Parent $PSScriptRoot))
$sharedModulePath = Join-Path $repoRoot 'modules/shared/utils/WindowsDotfiles.psm1'
Import-Module $sharedModulePath -Force

$configEnvPath = if ($env:DOTFILES_WINDOWS_CONFIG_PATH) { $env:DOTFILES_WINDOWS_CONFIG_PATH } else { Join-Path $repoRoot 'config/windows.env' }
$bootstrapConfigSource = if (Import-DotfilesEnvFile -Path $configEnvPath) { $configEnvPath } else { 'none' }
$includeOptionalPackages = $env:DOTFILES_INCLUDE_WINDOWS_OPTIONAL_PACKAGES -eq '1'

$wingetComposer = Join-Path $repoRoot 'modules/windows/packages/Compose-WingetManifest.ps1'
$packagesModule = Join-Path $repoRoot 'modules/windows/packages/Install-Packages.ps1'
$fontsModule = Join-Path $repoRoot 'modules/windows/fonts/Install-Fonts.ps1'
$powerShellModulesInstaller = Join-Path $repoRoot 'modules/shell/powershell/Install-Modules.ps1'
$profileModule = Join-Path $repoRoot 'modules/shell/powershell/Install-Profile.ps1'
$preferencesModule = Join-Path $repoRoot 'modules/windows/preferences/Apply.ps1'
$updateModule = Join-Path $repoRoot 'modules/windows/update/Register-UpdateTask.ps1'
$appsModule = Join-Path $repoRoot 'modules/windows/apps/Configure.ps1'

$canonicalWingetOverride = Join-Path $repoRoot 'modules/windows/packages/local.Winget.json'
$script:BootstrapStepFailed = $false

function Invoke-BootstrapStep {
  param(
    [Parameter(Mandatory = $true)]
    [string]$Label,
    [Parameter(Mandatory = $true)]
    [scriptblock]$ScriptBlock
  )

  Write-DotfilesStepInfo $Label
  try {
    & $ScriptBlock
    Write-DotfilesStepSuccess $Label
  } catch {
    $script:BootstrapStepFailed = $true
    Write-DotfilesStepFailure $Label
    if ($_.Exception -and $_.Exception.Message) {
      Write-Host $_.Exception.Message

      if ($_.Exception.Message -like 'WSL installation requested a reboot*') {
        Write-DotfilesNext 'Restart Windows, then rerun bootstrap/windows.ps1 with the same WSL setting. After the Windows bootstrap finishes, launch the distro once manually and run bootstrap/linux.sh inside it.'
      }
    }
    throw
  }
}

function Show-Usage {
  @'
Usage: bootstrap/windows.ps1 [-DryRun] [-EnableWSL] [-Only <step>] [-Help]

Windows bootstrap entry point.

Options:
  -DryRun     Print the resolved configuration without executing setup.
  -EnableWSL  Include WSL installation in the setup flow.
  -Only       Run only one step: install-apps, configure-shell, apply-preferences, register-update-job, configure-apps.
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
    if (-not $Only -or $Only -eq 'install-apps') {
      & $wingetComposer -OutputPath $wingetManifestPath | Out-Null
    }

    Write-Output "repo_root=$repoRoot"
    Write-Output "bootstrap_module=$PSScriptRoot"
    Write-Output "selected_step=$(if ($Only) { $Only } else { 'all' })"
    Write-Output "host_platform=$([System.Environment]::OSVersion.Platform)"
    Write-Output "is_windows_host=$(Test-DotfilesWindowsPlatform)"
    Write-Output "is_admin=$(Test-DotfilesAdministrator)"
    Write-Output "enable_wsl=$($EnableWSL.IsPresent -or $env:DOTFILES_WINDOWS_ENABLE_WSL -eq '1')"
    Write-Output "include_optional_packages=$includeOptionalPackages"
    Write-Output "winget_manifest=$(if (Test-Path -LiteralPath $wingetManifestPath) { $wingetManifestPath } else { 'n/a' })"
    Write-Output "bootstrap_config_source=$bootstrapConfigSource"
    Write-Output "winget_local_override_source=$($overrideSource.Winget)"
    if (-not $Only -or $Only -eq 'install-apps') {
      Write-Output 'winget_sources='
      & $wingetComposer -PrintSources
    }
  } finally {
    Remove-Item -LiteralPath $tempDir -Force -Recurse -ErrorAction SilentlyContinue
  }
}

function Set-BootstrapEnvironment {
  param(
    [string]$WingetManifestPath = ''
  )

  $env:DOTFILES_REPO_ROOT = $repoRoot
  $env:DOTFILES_BOOTSTRAP_CONFIG_PATH = $configEnvPath
  $env:DOTFILES_WINDOWS_ENABLE_WSL = if ($EnableWSL.IsPresent -or $env:DOTFILES_WINDOWS_ENABLE_WSL -eq '1') { '1' } else { '0' }
  $env:DOTFILES_INCLUDE_WINDOWS_OPTIONAL_PACKAGES = if ($includeOptionalPackages) { '1' } else { '0' }

  if ($WingetManifestPath) {
    $env:DOTFILES_WINGET_MANIFEST_PATH = $WingetManifestPath
  } elseif (Test-Path Env:DOTFILES_WINGET_MANIFEST_PATH) {
    Remove-Item Env:DOTFILES_WINGET_MANIFEST_PATH
  }
}

function Invoke-InstallAppsStep {
  $tempDir = Join-Path ([System.IO.Path]::GetTempPath()) ("dotfiles-windows-{0}" -f [guid]::NewGuid().ToString('N'))
  $wingetManifestPath = Join-Path $tempDir 'Winget.manifest.json'

  New-Item -ItemType Directory -Path $tempDir -Force | Out-Null
  try {
    Invoke-BootstrapStep -Label 'Resolve Windows app manifest' -ScriptBlock {
      & $wingetComposer -OutputPath $wingetManifestPath | Out-Null
    }

    Set-BootstrapEnvironment -WingetManifestPath $wingetManifestPath
    Invoke-BootstrapStep -Label 'Install Windows applications' -ScriptBlock { & $packagesModule }
    Invoke-BootstrapStep -Label 'Validate terminal/editor font prerequisites' -ScriptBlock { & $fontsModule }
  } finally {
    Remove-Item -LiteralPath $tempDir -Force -Recurse -ErrorAction SilentlyContinue
  }
}

function Invoke-ConfigureShellStep {
  Set-BootstrapEnvironment
  Invoke-BootstrapStep -Label 'Install PowerShell completion modules' -ScriptBlock { & $powerShellModulesInstaller }
  Invoke-BootstrapStep -Label 'Install PowerShell profile' -ScriptBlock { & $profileModule }
}

function Invoke-ApplyPreferencesStep {
  Set-BootstrapEnvironment
  Invoke-BootstrapStep -Label 'Apply Windows preferences' -ScriptBlock { & $preferencesModule }
}

function Invoke-RegisterUpdateJobStep {
  Set-BootstrapEnvironment
  Invoke-BootstrapStep -Label 'Register Windows update task' -ScriptBlock { & $updateModule }
}

function Invoke-ConfigureAppsStep {
  Set-BootstrapEnvironment
  Invoke-BootstrapStep -Label 'Configure Windows applications' -ScriptBlock { & $appsModule }
}

function Invoke-BootstrapModules {
  if ($Only) {
    switch ($Only) {
      'install-apps' { Invoke-InstallAppsStep }
      'configure-shell' { Invoke-ConfigureShellStep }
      'apply-preferences' { Invoke-ApplyPreferencesStep }
      'register-update-job' { Invoke-RegisterUpdateJobStep }
      'configure-apps' { Invoke-ConfigureAppsStep }
    }

    return
  }

  Invoke-InstallAppsStep
  Invoke-ConfigureShellStep
  Invoke-ApplyPreferencesStep
  Invoke-RegisterUpdateJobStep
  Invoke-ConfigureAppsStep
}

function Test-StepRequiresAdministrator {
  param(
    [string]$StepName
  )

  return $StepName -in @('install-apps', 'apply-preferences', 'register-update-job')
}

try {
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

  if ((-not $Only) -and (-not (Test-DotfilesAdministrator))) {
    throw 'This bootstrap entry must be run with administrative privileges.'
  }

  if ($Only -and (Test-StepRequiresAdministrator -StepName $Only) -and (-not (Test-DotfilesAdministrator))) {
    throw "The $Only step must be run with administrative privileges."
  }

  Write-DotfilesStepInfo 'Starting Windows bootstrap.'
  Invoke-BootstrapModules
  Write-DotfilesStepSuccess 'Windows bootstrap completed.'
} catch {
  if (-not $script:BootstrapStepFailed) {
    Write-DotfilesStepFailure 'Windows bootstrap failed'
    if ($_.Exception -and $_.Exception.Message) {
      Write-Host $_.Exception.Message
    }
  }

  exit 1
}
