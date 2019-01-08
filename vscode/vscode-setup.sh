#!/bin/bash

# install extensions
for extension in `cat extensions`; do
    code --install-extension $extension
done

# link setting.json
# modify ./setting.json to configure VisualStudioCode common setting
ln -s ~/dotfiles/vscode/settings.json ~/Library/Application\ Support/Code/User/
