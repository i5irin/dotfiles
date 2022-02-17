#!/bin/sh

set -eu
readonly VSCODE_SCRIPT_PATH=$1

# install extensions
for extension in $(cat "${VSCODE_SCRIPT_PATH}/extensions"); do
    code --install-extension $extension
done

# link setting.json
# modify ./setting.json to configure VisualStudioCode common setting
ln -sf "${VSCODE_SCRIPT_PATH}/settings.json" ~/Library/Application\ Support/Code/User/
