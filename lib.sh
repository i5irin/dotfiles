#!bin/sh

########################################################################
# Add the path to the PATH environment variable without duplication.
# Arguments:
#   path
# Returns:
#   Status of whether the path has been added to the PATH environment variable
########################################################################
add_path() {
  directory="$1"
  if [ -d "${directory}" ] ; then
    case ":${PATH}:" in
      *:$directory:*)
        echo "The path you specifed already exists in the PATH." 1>&2
        return 1
        ;;
      *)
        PATH="${directory}:${PATH}"
        return 0
        ;;
    esac
  else
    echo "The path you specifed does not exist." 1>&2
    return 1
  fi
}

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
