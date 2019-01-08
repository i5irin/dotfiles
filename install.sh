#!/bin/bash

# ---------------------------------------------------------
# Ask username and email for git config
# ---------------------------------------------------------

while true; do
  read -p 'Enter your name for use in git > ' GIT_USER_NAME
  read -p 'Enter your email address for use in git > ' GIT_USER_EMAIL
  while true; do
    read -p "Make sure name($GIT_USER_NAME) and email($GIT_USER_EMAIL) you input, is this ok? [Y/n] > " YN
    case $YN in
      [YNn] ) break;;
      * ) echo '[Y/n]'
    esac
  done
  case $YN in
    [Y] ) break;;
  esac
done

# ---------------------------------------------------------
# Install Xcode CommandLineTool
# ---------------------------------------------------------

xcode-select --install

# ---------------------------------------------------------
# Configure Homebrew
# ---------------------------------------------------------

/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
brew doctor
brew update
brew install mas

# ---------------------------------------------------------
# Install applications
# ---------------------------------------------------------

brew bundle

# ---------------------------------------------------------
# Configure Bash
# ---------------------------------------------------------

# link .bash_profile and .bashrc
ln -is ~/dotfiles/.bash_profile ~/.bash_profile
ln -is ~/dotfiles/.bashrc ~/.bashrc

# link readline config
ln -s ~/dotfiles/.inputrc ~/.inputrc

# ---------------------------------------------------------
# Configure Git
# ---------------------------------------------------------

git config --global user.name $GIT_USER_NAME
git config --global user.email $GIT_USER_EMAIL
git config --global core.editor 'vim -c "set fenc=utf-8"'
git config --global core.quotepath false
git config --global color.diff auto
git config --global color.status auto
git config --global color.branch auto
git lfs install
