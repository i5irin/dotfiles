#!/bin/zsh

set -eu

# ---------------------------------------------------------
#  Configure Keyboard
# ---------------------------------------------------------

# Set Function key like F1, F12 to default behavior
defaults write -g com.apple.keyboard.fnState -bool true
# Enable the tab key to move the focus.
defaults write NSGlobalDomain AppleKeyboardUIMode -int 3

# ---------------------------------------------------------
#  Configure Mouse
# ---------------------------------------------------------

# Enable 'click right side of mouse to right-click'
defaults write com.apple.AppleMultitouchMouse MouseButtonMode -string 'TwoButton'
defaults write com.apple.driver.AppleBluetoothMultitouch.mouse MouseButtonMode -string 'TwoButton'
defaults write com.apple.driver.AppleHIDMouse Button2 -int 2
# Turn off the acceleration of the mouse pointer.
defaults write NSGlobalDomain com.apple.mouse.scaling -1

# ---------------------------------------------------------
#  Configure Trackpad
# ---------------------------------------------------------

# Enable 'Tap to click'
defaults write com.apple.AppleMultitouchTrackpad Clicking -bool true
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
# Enable 'tap-and-a-half to drag'
defaults write com.apple.AppleMultitouchTrackpad Dragging -bool true
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Dragging -bool true
defaults write com.apple.AppleMultitouchTrackpad DragLock -bool true
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad DragLock -bool true

# ---------------------------------------------------------
#  Configure Microphone
# ---------------------------------------------------------

# Disable mic dictation
defaults write com.apple.HIToolbox AppleDictationAutoEnable -bool false

# ---------------------------------------------------------
#  Configure Finder
# ---------------------------------------------------------

# Show Path bar in Finder
defaults write com.apple.finder ShowPathbar -bool true
# Show status bar at the bottom of Finder
defaults write com.apple.finder ShowStatusBar -bool true
# Display full path in Finder title
defaults write com.apple.finder _FXShowPosixPathInTitle -bool true
# Disable the warning when changing a file extension.
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false

# ---------------------------------------------------------
#  Configure Common environment
# ---------------------------------------------------------

# Show all file extensions.
defaults write NSGlobalDomain AppleShowAllExtensions -bool true
# Prevent creating ".DS_Store" files on the USB flash drive.
defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true
# Prevent creating ".DS_Store" files on network storage.
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
# Show the ~/Library directory
chflags nohidden ~/Library

# ---------------------------------------------------------
#  Configure Dock
# ---------------------------------------------------------

# Automatically hide or show the Dock
defaults write com.apple.dock autohide -bool true
# Wipe all app icons except Finder and Trushbox from the Dock
defaults write com.apple.dock persistent-apps -array
# Magnificate the Dock
defaults write com.apple.dock magnification -bool true
# Disable "Show recent applications in Dock"
defaults write com.apple.dock show-recents -bool false
# Disable automatic reordering of the operation space (desktop).
defaults write com.apple.dock mru-spaces -bool false
# ---------------------------------------------------------
#  Configure Manubar
# ---------------------------------------------------------

# Set the Menubar time format to M月d日(EEE) H:mm
defaults write com.apple.menuextra.clock DateFormat -string "M\u6708d\u65e5(EEE)  H:mm"
# Displays the remaining battery power in %.
defaults write com.apple.controlcenter BatteryShowPercentage -bool true

# ---------------------------------------------------------
#  Configure Screen Capture
# ---------------------------------------------------------

# Configure where to save the screenshot.
if [ ! -d "$HOME/Pictures/Screenshots" ]; then
  mkdir -p "$HOME/Pictures/Screenshots"
fi
defaults write com.apple.screencapture location -string '~/Pictures/Screenshots'
# Change screenshot file name prefix to "screenshot-"
defaults write com.apple.screencapture name "screenshot-"
# Disable border-shadow around screenshot
defaults write com.apple.screencapture disable-shadow -boolean true
# Disable thumbnails when taking screenshots.
# (To prevent the thumbnail from being captured when taking a continuous screenshot of the entire screen.)
defaults write com.apple.screencapture show-thumbnail -bool false

# ---------------------------------------------------------
#  Configure TextEdit
# ---------------------------------------------------------

# Set TextEdit to open the document in plain text mode.
defaults write com.apple.TextEdit RichText -int 0

# ---------------------------------------------------------
#  Configure Photo
# ---------------------------------------------------------

# Prevent Photos from launching automatically when devices are plugged in.
defaults -currentHost write com.apple.ImageCapture disableHotPlug -bool true

# ---------------------------------------------------------
#  Configure Safari
# ---------------------------------------------------------

# Prevent Safari from sending search queries to Apple.
defaults write com.apple.Safari SuppressSearchSuggestions -bool true
defaults write com.apple.Safari UniversalSearchEnabled -bool false
# Prevent Safari from auto filling forms.
defaults write com.apple.Safari AutoFillFromAddressBook -bool false
# REVIEW: It seems that plist changes are not written unless Safari is running.
defaults write com.apple.Safari AutoFillPasswords -bool false
defaults write com.apple.Safari AutoFillCreditCardData -bool false
defaults write com.apple.Safari AutoFillMiscellaneousForms -bool false
# Prevent Safari from opening a downloaded file.
defaults write com.apple.Safari AutoOpenSafeDownloads -bool false
# Enable overlay status bar. (e.g. display of linked URLs)
defaults write com.apple.Safari ShowOverlayStatusBar -bool true

# ---------------------------------------------------------
#  Configure AirDrop
# ---------------------------------------------------------

# Allow all people to share via AirDrop.
defaults write com.apple.sharingd DiscoverableMode -string "Everyone"

# ---------------------------------------------------------
#  Configure Privacy
# ---------------------------------------------------------

# Disable crash reports.
# TODO: Prepare an app that crashes on purpose for testing.
defaults write com.apple.CrashReporter DialogType -string 'none'
# Disable sending feedback.
defaults write com.apple.appleseed.FeedbackAssistant Autogather -bool false

# Restart applications to activate above preferences
set +e
killall Finder
killall Dock
killall SystemUIServer
killall TextEdit
killall Photos
killall Safari
killall sharingd
set -e
