# If prompte for unexpected failure when logging on at the mac
alias cleandiaglogs="sudo rm -rf /Library/Logs/DiagnosticReports && sudo mkdir -p  /Library/Logs/DiagnosticReports"

# Control the photoanalysisd process on Mac
alias photoanalysis-disable='launchctl unload -w /System/Library/LaunchAgents/com.apple.photoanalysisd.plist'
alias photoanalysis-enable='launchctl load -w /System/Library/LaunchAgents/com.apple.photoanalysisd.plist'
