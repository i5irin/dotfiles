
setup_info() {
  app="$1"
  echo "⬇  Start to install ${app}."
}

complete_info() {
  app="$1"
  ESC=$(printf '\033')
  echo "${ESC}[32m✔ ${ESC}[m ${app} installation is complete."
}

failed_info() {
  app="$1"
  ESC=$(printf '\033')
  echo "${ESC}[31m💔${ESC}[m Something went wrong during the installation of ${app}."
}



# 冪等性はaptに担保してもらえばいいのでは？こっちで存在チェックする必要はないように思える

setup_info katchup
complete_info katchup
failed_info katchup
