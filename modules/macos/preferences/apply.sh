#!/bin/zsh

set -eu

SCRIPT_DIR="${0:A:h}"
readonly SCRIPT_DIR
REPO_ROOT="${DOTFILES_REPO_ROOT:-${SCRIPT_DIR:h:h:h}}"
readonly REPO_ROOT

source "${REPO_ROOT}/modules/shared/utils/message.sh"

# Full Disk Access (System Settings > Privacy & Security > Full Disk Access)
# must be granted to the terminal where this script is run.

write_optional_default() {
  local output_file

  output_file="$(mktemp "${TMPDIR:-/tmp}/dotfiles-defaults.XXXXXX")"
  if "$@" > /dev/null 2>"${output_file}"; then
    rm -f "${output_file}"
    return 0
  fi

  warn_info "Skipped optional macOS preference: $*"
  cat "${output_file}" >&2
  rm -f "${output_file}"
  return 0
}

restart_app_if_running() {
  if pgrep -x "$1" > /dev/null 2>&1; then
    killall "$1" > /dev/null 2>&1 || true
  fi
}

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
write_optional_default defaults write com.apple.Safari SuppressSearchSuggestions -bool true
write_optional_default defaults write com.apple.Safari UniversalSearchEnabled -bool false
write_optional_default defaults write com.apple.Safari AutoFillFromAddressBook -bool false
write_optional_default defaults write com.apple.Safari AutoFillPasswords -bool false
write_optional_default defaults write com.apple.Safari AutoFillCreditCardData -bool false
write_optional_default defaults write com.apple.Safari AutoFillMiscellaneousForms -bool false
write_optional_default defaults write com.apple.Safari AutoOpenSafeDownloads -bool false
write_optional_default defaults write com.apple.Safari ShowOverlayStatusBar -bool true

restart_app_if_running Finder
restart_app_if_running Dock
restart_app_if_running SystemUIServer
restart_app_if_running TextEdit
restart_app_if_running Photos
restart_app_if_running Safari
