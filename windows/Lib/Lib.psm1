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
