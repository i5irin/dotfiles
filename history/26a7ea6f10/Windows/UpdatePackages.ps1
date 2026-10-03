# Update the packages installed by winget.
echo '===============================================================';
echo '    Update applications';
echo '===============================================================';
echo "Current time $(date '+%Y-%m-%dT%H:%M:%S%z')"
Write-EventLog -LogName Application -Source WingetUpdate -EventId 0 -EntryType Information -Message 'winget upgrade --all'
winget upgrade --all
Write-EventLog -LogName Application -Source WingetUpdate -EventId 0 -EntryType Information -Message 'winget upgrrade completed!'
Start-WUScan | % { Write-Output "$_.Title をインストールします" && Install-WUUpdates -Updates $_ }
