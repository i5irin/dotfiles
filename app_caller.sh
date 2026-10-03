#!/bin/sh

install_app() {
  app="$1"
  script="$2"
  echo "${app} だよ"
  shift
  shift
  /bin/sh "$script" "$@"
  echo "${app} だよ"
}

install_app 'apps' 'app.sh' '最初' '二番目'
