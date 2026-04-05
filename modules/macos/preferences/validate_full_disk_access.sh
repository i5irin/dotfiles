#!/bin/zsh

set -eu

open_full_disk_access_settings() {
  open "x-apple.systempreferences:com.apple.preference.security?Privacy_AllFiles" > /dev/null 2>&1 \
    || open "/System/Applications/System Settings.app" > /dev/null 2>&1 \
    || true
}

main() {
  local safari_preferences_dir
  local probe_file

  safari_preferences_dir="${HOME}/Library/Containers/com.apple.Safari/Data/Library/Preferences"
  probe_file="${safari_preferences_dir}/.dotfiles-full-disk-access-check.$$"

  if [ ! -d "${safari_preferences_dir}" ]; then
    return 0
  fi

  if touch "${probe_file}" > /dev/null 2>&1; then
    rm -f "${probe_file}"
    return 0
  fi

  cat >&2 <<'EOF'
Full Disk Access is required before applying macOS preferences.
Grant access to Terminal.app in:
  System Settings > Privacy & Security > Full Disk Access
Then rerun bootstrap/macos.sh.
EOF

  open_full_disk_access_settings
  return 1
}

main "$@"
