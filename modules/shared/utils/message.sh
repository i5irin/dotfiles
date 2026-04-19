#!/bin/bash

color() {
  text="$1"
  color="$2"
  # reference https://qiita.com/ko1nksm/items/095bdb8f0eca6d327233#1-echo-%E3%81%A7%E3%81%AF%E3%81%AA%E3%81%8F-printf-%E3%82%92%E4%BD%BF%E3%81%86
  ESC=$(printf '\033')
  echo "${ESC}${color}${text}${ESC}[m"
}

step_info() {
  echo "==> $1"
}

step_success() {
  echo "$(color '✔' '[32m') $1"
}

step_failure() {
  echo "$(color '✖' '[31m') $1" >&2
}

action_info() {
  echo "--> $1"
}

action_success() {
  echo "$(color '✔' '[32m') $1"
}

action_failure() {
  echo "$(color '✖' '[31m') $1" >&2
}

skip_info() {
  echo "$(color '↷' '[33m') Skip: $1"
}

warn_info() {
  echo "$(color '⚠' '[33m') Warning: $1" >&2
}

next_info() {
  echo "Next: $1"
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
  app="$1"
  action_info "Configure ${app}"
}

complete_configure_info() {
  app="$1"
  action_success "Configure ${app}"
}

failed_configure_info() {
  app="$1"
  action_failure "Configure ${app}"
}

finish_configure_message() {
  exit_code="$?"
  app="$1"
  if [ "$exit_code" = 0 ]; then
    complete_configure_info "$app"
  else
    failed_configure_info "$app"
  fi
}

setup_info() {
  app="$1"
  action_info "Install ${app}"
}

complete_setup_info() {
  app="$1"
  action_success "Install ${app}"
}

failed_info() {
  app="$1"
  action_failure "Install ${app}"
}
