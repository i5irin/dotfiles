#!bin/sh

########################################################################
# Validate GitHub username format.
# Arguments:
#   GitHub username
# Returns:
#   Status of whether GitHub username is valid
# Todo:
#   Add a check to see if it is a reserved word.
########################################################################
validate_github_username() {
  if echo "$1" | grep -q -E '^[a-zA-Z0-9]([a-zA-Z0-9]?|[\-]?([a-zA-Z0-9])){0,38}$'; then
    return 0
  fi
  echo "The username you entered is invalid for GitHub." 1>&2
  return 1
}
