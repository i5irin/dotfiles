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

# create .bash_profile and .bashrc
touch ~/.bash_profile
touch ~/.bashrc

# make .bash_profile to load .bashrc
cat << EOS >> ~/.bash_profile
if [ -f ~/.bashrc ]; then
    . ~/.bashrc
fi
EOS

# configure environment variables
cat << EOS >> ~/.bash_profile
# set it to refer applications installed with Homebrew
export PATH='/usr/local/bin:$PATH'
# set it to refer GNU-applications installed with Homebrew instead of BSD-applications
export PATH=/usr/local/opt/coreutils/libexec/gnubin:${PATH}
EOS

# configure bash completion
cat << EOS >> ~/.bashrc
# load bash-completion
if [ -f $(brew --prefix)/etc/bash_completion ]; then
  source $(brew --prefix)/etc/bash_completion
fi
EOS

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
