# Update the packages installed by winget.

Write-EventLog -LogName Application -Source WingetUpdate -EventId 0 -EntryType Information -Message 'winget upgrade --all'
winget upgrade --all
Write-EventLog -LogName Application -Source WingetUpdate -EventId 0 -EntryType Information -Message 'winget upgrrade completed!'
