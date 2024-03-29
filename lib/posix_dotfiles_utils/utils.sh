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
# POSIX-compliant readlink command with the -f option.
# Arguments:
#   Path of symbolic link
# Outputs:
#   Path of the symbolic link entity
# Returns:
#   Whether or not the function has output the entity of the symbolic links
# Note:
#   This function is based on ko1nksm's readlinkf. See this following link for more details.
#   https://github.com/ko1nksm/readlinkf
########################################################################
readlinkf() {
  if [ $# -eq 0 ]; then
    echo "readlink: missing operand" >&2
    return 1
  fi

  readlinkf_one_path() {
    [ "${1:-}" ] || return 1
    max_symlinks=40
    CDPATH='' # to avoid changing to an unexpected directory

    target=$1
    [ -e "${target%/}" ] || target=${1%"${1##*[!/]}"} # trim trailing slashes
    [ -d "${target:-/}" ] && target="$target/"

    cd -P . 2>/dev/null || return 1
    while [ "$max_symlinks" -ge 0 ] && max_symlinks=$((max_symlinks - 1)); do
      if [ ! "$target" = "${target%/*}" ]; then
        case $target in
          /*) cd -P "${target%/*}/" 2>/dev/null || break ;;
          *) cd -P "./${target%/*}" 2>/dev/null || break ;;
        esac
        target=${target##*/}
      fi

      if [ ! -L "$target" ]; then
        target="${PWD%/}${target:+/}${target}"
        printf '%s\n' "${target:-/}"
        return 0
      fi

      # `ls -dl` format: "%s %u %s %s %u %s %s -> %s\n",
      #   <file mode>, <number of links>, <owner name>, <group name>,
      #   <size>, <date and time>, <pathname of link>, <contents of link>
      # https://pubs.opengroup.org/onlinepubs/9699919799/utilities/ls.html
      link=$(ls -dl -- "$target" 2>/dev/null) || break
      target=${link#*" $target -> "}
    done
    return 1
  }

  ex=0
  for i; do
    (readlinkf_one_path "$i") || ex=1
  done
  unset readlinkf_one_path
  return "$ex"
}

########################################################################
# Validate hostname with RFC 952 format.
# Arguments:
#   host name
# Returns:
#   Status of whether hostname is valid
# Todo:
#   Support for hostnames containing periods.
########################################################################
validate_rfc952_hostname() {
  if echo "$1" | grep -q -E '^[a-zA-Z][0-9a-zA-Z\-]{0,22}[0-9a-zA-Z]$'; then
    return 0
  fi
  echo "The hostname you entered is invalid for RFC 952." 1>&2
  return 1
}
