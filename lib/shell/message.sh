#!/bin/bash

configure_info() {
  app="$1"
  echo "⚙️  Start to configure ${app}."
}

complete_configure_info() {
  app="$1"
  # reference https://qiita.com/ko1nksm/items/095bdb8f0eca6d327233#1-echo-%E3%81%A7%E3%81%AF%E3%81%AA%E3%81%8F-printf-%E3%82%92%E4%BD%BF%E3%81%86
  ESC=$(printf '\033')
  echo "${ESC}[32m✔ ${ESC}[m ${app} configuration is complete."
}

failed_configure_info() {
  app="$1"
  ESC=$(printf '\033')
  echo "${ESC}[31m💔${ESC}[m Something went wrong during the configuration of ${app}."
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
