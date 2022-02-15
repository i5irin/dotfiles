########################################################################
# Validate GitHub username format.
# Arguments:
#   GitHub username
# Returns:
#   Status of whether GitHub username is valid (0: valid, 1: invalid)
# Todo:
#   Add a check to see if it is a reserved word.
########################################################################
function Test-GitHubUsername {
  param (
    $Name
  )
  if ($Name -match '^[a-zA-Z0-9]([a-zA-Z0-9]?|[\-]?([a-zA-Z0-9])){0,38}$') {
    return 0
  }
  return 1
}

########################################################################
# Receive and configure Git user information.
# Returns:
#   None
########################################################################
function Receive-GitUser {
  # Ask username and email for git config.
  while ($true) {
    $GitUserName = Read-Host 'Enter your name for use in git > '
    $GitUserEmail = Read-Host 'Enter your email address for use in git > '
    if (Test-GitHubUsername -Name $GitUserName -eq 1) {
      Write-Output 'The username you entered is invalid for GitHub.'
      continue
    }
    while ($true) {
      $YN = Read-Host "Make sure name($GitUserName) and email($GitUserEmail) you input, is this ok? [Y/n] > "
      if ($YN -cmatch '[YNn]') {
        break
      } else {
        Write-Output '[Y/n]'
      }
    }
    if ($YN -eq 'Y') {
      break;
    }
  }
  git config --global user.name $GitUserName
  git config --global user.email $GitUserEmail
}

########################################################################
# Receive Git user information and path to .gitconfig and configure Git.
# Arguments:
#   Path to .gitconfig
# Returns:
#   None
########################################################################
function Receive-GitConfig {
  param (
    $Path
  )
  Receive-GitUser
  git config --global --add include.path "${INSTALL_SCRIPT_PATH}\git\.gitconfig"
}
