#!/bin/zsh

set -eu

# Full Disk Access (System Settings > Privacy & Security > Full Disk Access)
# must be granted to the terminal where this script is run.

# Configure Keyboard
defaults write -g com.apple.keyboard.fnState -bool true
defaults write NSGlobalDomain AppleKeyboardUIMode -int 3

# Configure Mouse
defaults write com.apple.AppleMultitouchMouse MouseButtonMode -string 'TwoButton'
defaults write com.apple.driver.AppleBluetoothMultitouch.mouse MouseButtonMode -string 'TwoButton'
defaults write com.apple.driver.AppleHIDMouse Button2 -int 2
defaults write NSGlobalDomain com.apple.mouse.scaling -1

# Configure Trackpad
defaults write com.apple.AppleMultitouchTrackpad Clicking -bool true
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
defaults write com.apple.AppleMultitouchTrackpad Dragging -bool true
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Dragging -bool true
defaults write com.apple.AppleMultitouchTrackpad DragLock -bool true
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad DragLock -bool true

# Configure Microphone
defaults write com.apple.HIToolbox AppleDictationAutoEnable -bool false

# Configure Finder
defaults write com.apple.finder ShowPathbar -bool true
defaults write com.apple.finder ShowStatusBar -bool true
defaults write com.apple.finder _FXShowPosixPathInTitle -bool true
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false

# Configure Common environment
defaults write NSGlobalDomain AppleShowAllExtensions -bool true
defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
chflags nohidden "${HOME}/Library"

# Configure Dock
defaults write com.apple.dock autohide -bool true
defaults write com.apple.dock persistent-apps -array
defaults write com.apple.dock magnification -bool true
defaults write com.apple.dock show-recents -bool false
defaults write com.apple.dock mru-spaces -bool false

# Configure Menubar
defaults write com.apple.menuextra.clock DateFormat -string "M\u6708d\u65e5(EEE)  H:mm"
defaults write com.apple.controlcenter BatteryShowPercentage -bool true

# Configure Screen Capture
if [ ! -d "${HOME}/Pictures/Screenshots" ]; then
  mkdir -p "${HOME}/Pictures/Screenshots"
fi
defaults write com.apple.screencapture location -string "${HOME}/Pictures/Screenshots"
defaults write com.apple.screencapture name 'screenshot-'
defaults write com.apple.screencapture disable-shadow -bool true
defaults write com.apple.screencapture show-thumbnail -bool false

# Configure TextEdit
defaults write com.apple.TextEdit RichText -int 0

# Configure Photo
defaults -currentHost write com.apple.ImageCapture disableHotPlug -bool true

# Configure Safari
defaults write com.apple.Safari SuppressSearchSuggestions -bool true
defaults write com.apple.Safari UniversalSearchEnabled -bool false
defaults write com.apple.Safari AutoFillFromAddressBook -bool false
defaults write com.apple.Safari AutoFillPasswords -bool false
defaults write com.apple.Safari AutoFillCreditCardData -bool false
defaults write com.apple.Safari AutoFillMiscellaneousForms -bool false
defaults write com.apple.Safari AutoOpenSafeDownloads -bool false
defaults write com.apple.Safari ShowOverlayStatusBar -bool true

# Configure AirDrop
defaults write com.apple.sharingd DiscoverableMode -string 'Everyone'

# Configure Privacy
defaults write com.apple.CrashReporter DialogType -string 'none'
defaults write com.apple.appleseed.FeedbackAssistant Autogather -bool false

set +e
killall Finder
killall Dock
killall SystemUIServer
killall TextEdit
killall Photos
killall Safari
killall sharingd
set -e
