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
# Activate the registry key. (If it does not exist, create a new one.)
# Arguments:
#   Registry key
# Returns:
#   Message informing that a registry key has been created. (Only if the key does not exist.)
########################################################################
function Enable-RegistryKey {
  param (
    $Name
  )
  if (-not (Test-Path $Name)) {
    New-Item $Name
    Write-Output "The registry key ${Name} does not exist. A new one is created."
  }
}
