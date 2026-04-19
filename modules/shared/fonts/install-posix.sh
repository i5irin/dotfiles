#!/bin/sh

set -eu

SCRIPT_DIR="$(CDPATH='' cd -- "$(dirname -- "$0")" && pwd)"
readonly SCRIPT_DIR
REPO_ROOT="${DOTFILES_REPO_ROOT:-$(CDPATH='' cd -- "${SCRIPT_DIR}/../../.." && pwd)}"
readonly REPO_ROOT

readonly FIRA_CODE_VERSION="${DOTFILES_FIRA_CODE_VERSION:-6.2}"
readonly FIRA_CODE_URL="${DOTFILES_FIRA_CODE_URL:-https://github.com/tonsky/FiraCode/releases/download/${FIRA_CODE_VERSION}/Fira_Code_v${FIRA_CODE_VERSION}.zip}"
readonly NERD_FONTS_VERSION="${DOTFILES_NERD_FONTS_VERSION:-3.4.0}"
readonly FIRA_CODE_NERD_FONT_URL="${DOTFILES_FIRA_CODE_NERD_FONT_URL:-https://github.com/ryanoasis/nerd-fonts/releases/download/v${NERD_FONTS_VERSION}/FiraCode.zip}"

. "${REPO_ROOT}/modules/shared/utils/message.sh"

resolve_font_target_dir() {
  if [ -n "${DOTFILES_FONT_TARGET_DIR:-}" ]; then
    printf '%s\n' "${DOTFILES_FONT_TARGET_DIR}"
    return 0
  fi

  case "$(uname -s)" in
    Darwin)
      printf '%s\n' "${HOME}/Library/Fonts"
      ;;
    Linux)
      printf '%s\n' "${HOME}/.local/share/fonts"
      ;;
    *)
      step_failure 'Unsupported POSIX font target platform.'
      return 1
      ;;
  esac
}

have_font_files() {
  target_dir="$1"
  pattern="$2"

  find "${target_dir}" -maxdepth 1 -type f \( -name "${pattern}" -o -name "${pattern%.ttf}.otf" \) | grep -q .
}

install_font_archive() {
  label="$1"
  url="$2"
  target_dir="$3"
  pattern="$4"
  archive_name="$5"
  temp_dir=''

  if have_font_files "${target_dir}" "${pattern}"; then
    skip_info "${label} font files already exist in ${target_dir}."
    return 0
  fi

  temp_dir="$(mktemp -d "${TMPDIR:-/tmp}/dotfiles-fonts.XXXXXX")"
  archive_path="${temp_dir}/${archive_name}"
  extract_dir="${temp_dir}/extract"

  mkdir -p "${extract_dir}"
  curl -fsSL "${url}" -o "${archive_path}"
  unzip -oq "${archive_path}" -d "${extract_dir}"

  find "${extract_dir}" -type f \( -name '*.ttf' -o -name '*.otf' \) -print | while IFS= read -r font_file; do
    install -m 0644 "${font_file}" "${target_dir}/$(basename "${font_file}")"
  done

  rm -rf "${temp_dir}"
}

refresh_font_cache() {
  case "$(uname -s)" in
    Linux)
      if command -v fc-cache > /dev/null 2>&1; then
        fc-cache -f "${1}" > /dev/null 2>&1 || true
      fi
      ;;
  esac
}

main() {
  target_dir="$(resolve_font_target_dir)"
  mkdir -p "${target_dir}"

  install_font_archive 'Fira Code' "${FIRA_CODE_URL}" "${target_dir}" 'FiraCode-*.ttf' 'FiraCode.zip'
  install_font_archive 'FiraCode Nerd Font' "${FIRA_CODE_NERD_FONT_URL}" "${target_dir}" 'FiraCodeNerdFont-*.ttf' 'FiraCodeNerdFont.zip'
  refresh_font_cache "${target_dir}"
}

main "$@"
