#!/bin/zsh

source "${${(%):-%N}:A:h}/sudo.sh"

default_homebrew_prefix() {
  printf '%s\n' '/opt/homebrew'
}

require_apple_silicon_macos() {
  if [ "$(uname -s)" != 'Darwin' ]; then
    echo 'This bootstrap entry only supports macOS.' >&2
    return 1
  fi

  if [ "$(uname -m)" != 'arm64' ]; then
    echo 'This bootstrap entry only supports Apple Silicon macOS.' >&2
    return 1
  fi
}

is_macos_admin_user() {
  id -Gn | tr ' ' '\n' | grep -Fx 'admin' > /dev/null 2>&1
}

prime_macos_sudo_session() {
  prime_sudo_session 'Administrator privileges are required for the macOS bootstrap.'
}

ensure_homebrew_shellenv() {
  local prefix
  local brew_bin
  local brew_sbin
  local brew_site_functions
  local brew_info

  prefix="${1:-${DOTFILES_HOMEBREW_PREFIX:-$(default_homebrew_prefix)}}"
  brew_bin="${prefix}/bin"
  brew_sbin="${prefix}/sbin"
  brew_site_functions="${prefix}/share/zsh/site-functions"
  brew_info="${prefix}/share/info"

  if [ ! -x "${brew_bin}/brew" ]; then
    return 0
  fi

  case ":${PATH}:" in
    *:"${brew_bin}":*) ;;
    *) export PATH="${brew_bin}:${PATH}" ;;
  esac

  if [ -d "${brew_sbin}" ]; then
    case ":${PATH}:" in
      *:"${brew_sbin}":*) ;;
      *) export PATH="${brew_sbin}:${PATH}" ;;
    esac
  fi

  if [ -d "${brew_site_functions}" ]; then
    case ":${FPATH:-}:" in
      *:"${brew_site_functions}":*) ;;
      *)
        FPATH="${brew_site_functions}:${FPATH:-}"
        export FPATH
        ;;
    esac
  fi

  if [ -d "${brew_info}" ]; then
    case ":${INFOPATH:-}:" in
      *:"${brew_info}":*) ;;
      *) export INFOPATH="${brew_info}:${INFOPATH:-}" ;;
    esac
  fi
}
