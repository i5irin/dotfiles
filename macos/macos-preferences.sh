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

# Restart applications to activate above preferences
killall Finder
killall Dock
