Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$repoRoot = $env:DOTFILES_REPO_ROOT
if (-not $repoRoot) {
  throw 'DOTFILES_REPO_ROOT is required.'
}

$gitConfigAsset = Join-Path $repoRoot 'assets/cli/git/.gitconfig'

function Test-GitHubUserName {
  param(
    [Parameter(Mandatory = $true)]
    [string]$Name
  )

  return -not [string]::IsNullOrWhiteSpace($Name)
}

function Test-GitUserEmail {
  param(
    [Parameter(Mandatory = $true)]
    [string]$Email
  )

  return $Email -match '.+@.+'
}

function Get-GitIdentity {
  if ($env:DOTFILES_GIT_USER_NAME -and $env:DOTFILES_GIT_USER_EMAIL) {
    if (-not (Test-GitHubUserName -Name $env:DOTFILES_GIT_USER_NAME)) {
      throw 'DOTFILES_GIT_USER_NAME must not be empty.'
    }

    if (-not (Test-GitUserEmail -Email $env:DOTFILES_GIT_USER_EMAIL)) {
      throw 'DOTFILES_GIT_USER_EMAIL must include "@".'
    }

    return [ordered]@{
      Name  = $env:DOTFILES_GIT_USER_NAME
      Email = $env:DOTFILES_GIT_USER_EMAIL
    }
  }

  $existingName = git config --global --get user.name 2>$null
  $existingEmail = git config --global --get user.email 2>$null
  if ($existingName -and $existingEmail) {
    return [ordered]@{
      Name  = $existingName
      Email = $existingEmail
    }
  }

  while ($true) {
    $gitUserName = Read-Host 'Enter your name for use in git > '
    $gitUserEmail = Read-Host 'Enter your email address for use in git > '
    if (-not (Test-GitHubUserName -Name $gitUserName)) {
      Write-Output 'The git user name must not be empty.'
      continue
    }

    if (-not (Test-GitUserEmail -Email $gitUserEmail)) {
      Write-Output 'The git user email must include "@".'
      continue
    }

    $answer = Read-Host "Make sure name($gitUserName) and email($gitUserEmail) you input, is this ok? [Y/n] > "
    if ($answer -eq '' -or $answer -match '^[Yy]$') {
      return [ordered]@{
        Name  = $gitUserName
        Email = $gitUserEmail
      }
    }
  }
}

$identity = Get-GitIdentity
$existingIncludePaths = @(git config --global --get-all include.path 2>$null)
if ($existingIncludePaths -notcontains $gitConfigAsset) {
  git config --global --add include.path $gitConfigAsset
}

git config --global user.name $identity.Name
git config --global user.email $identity.Email
