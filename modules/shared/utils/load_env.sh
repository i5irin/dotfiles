# POSIX shell library. Source this file; do not execute it directly.

load_dotfiles_env_file() {
  if [ ! -f "$1" ]; then
    return 1
  fi

  case $- in
    *a*) set -- "$1" 0 ;;
    *) set -- "$1" 1; set -a ;;
  esac

  # shellcheck disable=SC1090
  . "$1"

  if [ "$2" -eq 1 ]; then
    set +a
  fi
  return 0
}
