#!/bin/sh

set -eu
readonly GIT_SCRIPT_PATH=$1

git version > /dev/null 2>&1
if [ $? -ne 0 ]; then
  echo 'Git cannot be found.' >&2
  exit 1
fi

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

# ---------------------------------------------------------
# Ask username and email for git config
# ---------------------------------------------------------

while true; do
  read -p 'Enter your name for use in git > ' GIT_USER_NAME
  read -p 'Enter your email address for use in git > ' GIT_USER_EMAIL
  if ! validate_github_username $GIT_USER_NAME; then
    continue;
  fi
  while true; do
    read -p "Make sure name($GIT_USER_NAME) and email($GIT_USER_EMAIL) you input, is this ok? [Y/n] > " YN
    case $YN in
      [YNn] ) break;;
      * ) echo '[Y/n]'
    esac
  done
  case $YN in
    [Y] ) break;;
  esac
done

# ---------------------------------------------------------
# Configure Git
# ---------------------------------------------------------

git config --global --add include.path "${GIT_SCRIPT_PATH}/.gitconfig"
git config --global user.name $GIT_USER_NAME
git config --global user.email $GIT_USER_EMAIL

exit 0
