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

  return $Name -match '^[a-zA-Z0-9]([a-zA-Z0-9]?|[\-]?([a-zA-Z0-9])){0,38}$'
}

function Get-GitIdentity {
  if ($env:DOTFILES_GIT_USER_NAME -and $env:DOTFILES_GIT_USER_EMAIL) {
    if (-not (Test-GitHubUserName -Name $env:DOTFILES_GIT_USER_NAME)) {
      throw 'DOTFILES_GIT_USER_NAME is invalid for GitHub.'
    }

    return [ordered]@{
      Name  = $env:DOTFILES_GIT_USER_NAME
      Email = $env:DOTFILES_GIT_USER_EMAIL
    }
  }

  while ($true) {
    $gitUserName = Read-Host 'Enter your name for use in git > '
    $gitUserEmail = Read-Host 'Enter your email address for use in git > '
    if (-not (Test-GitHubUserName -Name $gitUserName)) {
      Write-Output 'The username you entered is invalid for GitHub.'
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
