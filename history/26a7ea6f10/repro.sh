#!/bin/sh

set -eu
# readonly GIT_SCRIPT_PATH=$1

# git version &> /dev/null
# if [ $? -ne 0 ]; then
#   echo 'Git cannot be found.' >&2
#   exit 1
# fi

echo 'いらない表示' &> /dev/null

########################################################################
# Validate GitHub username format.
# Arguments:
#   GitHub username
# Returns:
#   Status of whether GitHub username is valid
# Todo:
#   Add a check to see if it is a reserved word.
########################################################################
# validate_github_username() {
#   if echo "$1" | grep -q -E '^[a-zA-Z0-9]([a-zA-Z0-9]?|[\-]?([a-zA-Z0-9])){0,38}$'; then
#     return 0
#   fi
#   echo "The username you entered is invalid for GitHub." 1>&2
#   return 1
# }

# ---------------------------------------------------------
# Ask username and email for git config
# ---------------------------------------------------------
# read -p 'Enter your name for use in git > ' GIT_USER_NAME

# while true; do
#   read -p 'Enter your email address for use in git > ' GIT_USER_EMAIL
#   if ! validate_github_username $GIT_USER_NAME; then
#     continue;
#   fi
#   while true; do
#     read -p "Make sure name($GIT_USER_NAME) and email($GIT_USER_EMAIL) you input, is this ok? [Y/n] > " YN
#     case $YN in
#       [YNn] ) break;;
#       * ) echo '[Y/n]'
#     esac
#   done
#   case $YN in
#     [Y] ) break;;
#   esac
# done

# /bin/shでは&> /dev/nullではなく>/dev/null 2>&1を使う

# タイトルが結論になってしまっていますが&>はBashの記法です。

# &>だと>/dev/null 2>&1として解釈されない上
# echo 'いらない表示' &
# という部分で非同期で実行が始まり/dev/nullに捨てられず表示がされてしまいます。

# 更にdashやkshでは標準入力を以下の結果のように/dev/nullから読み取ってしまうようになります。
# readlink /proc/self/fd/0 & echo DONE
# /bin/shはUbuntuだとdashが起動したりするので予期しない動作を起こすことがあります。

# 参考 https://unix.stackexchange.com/questions/523421/why-does-cat-1-dev-stdin-dev-null-work-in-bash-but-not-dash
