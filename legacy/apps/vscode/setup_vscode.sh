#!/bin/sh

set -eu
readonly VSCODE_SCRIPT_PATH=$1
readonly PLATFORM=$2

# install extensions
for extension in $(cat "${VSCODE_SCRIPT_PATH}/extensions"); do
  code --install-extension $extension > /dev/null
done

# link setting.json
# modify ./setting.json to configure VisualStudioCode common setting
if [ $PLATFORM = "macos" ]; then
  ln -sf "${VSCODE_SCRIPT_PATH}/settings.json" ~/Library/Application\ Support/Code/User/
elif [ $PLATFORM = "ubuntu" ]; then
  ln -sf "${VSCODE_SCRIPT_PATH}/settings.json" ~/.config/Code/User/
else
  echo 'Unsupported platform.' 1>&2
  exit 1
fi
