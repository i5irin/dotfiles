$HYPER_SCRIPT_PATH=$Args[0]

New-Item -Type SymbolicLink %APPDATA%\Hyper\.hyper.js -Value "${HYPER_SCRIPT_PATH}\.hyper.js"
