#!/bin/bash

# Enable 'Tap to click'
defaults write com.apple.AppleMultitouchTrackpad Clicking -bool true
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int 1

# Enable 'tap-and-a-half to drag'
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Dragging -int 1
defaults write com.apple.AppleMultitouchTrackpad Dragging -int 1

# Show Path bar in Finder
defaults write com.apple.finder ShowPathbar -bool true

# Show status bar at the bottom of Finder
defaults write com.apple.finder ShowStatusBar -bool true

# Display full path in Finder title
defaults write com.apple.finder _FXShowPosixPathInTitle -bool true

# Show all file extensions.
defaults write NSGlobalDomain AppleShowAllExtensions -bool true

# Disable the warning when changing a file extension.
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false

# Prevent creating ".DS_Store" files on the USB flash drive.
defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true

# Change screenshot file name prefix to "screenshot-"
defaults write com.apple.screencapture name "screenshot-"

# Show the ~/Library directory
chflags nohidden ~/Library

# Set Function key like F1, F12 to default behavior
defaults write -g com.apple.keyboard.fnState -bool true

# Enable 'click right side of mouse to right-click'
defaults write com.apple.driver.AppleBluetoothMultitouch.mouse MouseButtonMode -string 'TwoButton'
defaults write com.apple.driver.AppleHIDMouse Button2 -int 2

# Automatically hide or show the Dock
defaults write com.apple.dock autohide -bool true
# Wipe all app icons except Finder and Trushbox from the Dock
defaults write com.apple.dock persistent-apps -array
# Magnificate the Dock
defaults write com.apple.dock magnification -bool true

# Show all extensions
defaults write NSGlobalDomain AppleShowAllExtensions -bool true

# Disable "Show recent applications in Dock"
defaults write com.apple.dock show-recents -bool false

# Set the Menubar time format to M月d日(EEE) H:mm
defaults write com.apple.menuextra.clock DateFormat -string "M\u6708d\u65e5(EEE)  H:mm"

# Disable border-shadow around screenshot
defaults write com.apple.screencapture disable-shadow -boolean true

# Restart applications to activate above preferences
killall Finder
killall Dock
killall SystemUIServer
