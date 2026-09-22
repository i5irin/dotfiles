# POSIX shell library. Source this file; do not execute it directly.

color() {
  printf '\033%s%s\033[m\n' "$2" "$1"
}

step_info() {
  printf '==> %s\n' "$1"
}

step_success() {
  printf '%s %s\n' "$(color '[OK]' '[32m')" "$1"
}

step_failure() {
  printf '%s %s\n' "$(color '[FAIL]' '[31m')" "$1" >&2
}

action_info() {
  printf '%s\n' "--> $1"
}

action_success() {
  printf '%s %s\n' "$(color '[OK]' '[32m')" "$1"
}

skip_info() {
  printf '%s %s\n' "$(color '[SKIP]' '[33m')" "$1"
}

warn_info() {
  printf '%s %s\n' "$(color '[WARN]' '[33m')" "$1" >&2
}

next_info() {
  printf 'Next: %s\n' "$1"
}

progress_info() {
  step_info "$1"
}

progress_success() {
  step_success "$1"
}

progress_failure() {
  step_failure "$1"
}

configure_info() {
  action_info "Configure $1"
}

complete_configure_info() {
  action_success "Configure $1"
}

setup_info() {
  action_info "Install $1"
}

complete_setup_info() {
  action_success "Install $1"
}
