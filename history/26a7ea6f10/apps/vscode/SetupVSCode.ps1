$VSCODE_SCRIPT_PATH=$Args[0]

# install extensions
Get-Content -Encoding UTF8 "${VSCODE_SCRIPT_PATH}\extensions" | ForEach-Object { code --install-extension $_ }

# link setting.json
# modify ./setting.json to configure VisualStudioCode common setting
New-Item -Type SymbolicLink %APPDATA%\Code\User\settings.json -Value "${VSCODE_SCRIPT_PATH}\setting.json"
