#!/bin/bash

readonly SCRIPT_PATH=$(cd $(dirname ${BASH_SOURCE}); pwd)

# install extensions
for extension in $(cat "${SCRIPT_PATH}/extensions"); do
    code --install-extension $extension
done

# link setting.json
# modify ./setting.json to configure VisualStudioCode common setting
ln -sf "${SCRIPT_PATH}/settings.json" ~/Library/Application\ Support/Code/User/
