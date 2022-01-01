# Load the library functions.
. ./lib.sh

# ---------------------------------------------------------
# Configure environment variables
# ---------------------------------------------------------

# Configure PATH

# set it to refer applications installed with Homebrew
add_path '/usr/local/bin' 2> /dev/null
# Make OpenJDK that is installed with Homebrew be used as default.
add_path '/usr/local/opt/openjdk/bin' 2> /dev/null
# set PATH so it includes user's private bin if it exists. (from Ubuntu's ~/.profile)
add_path "$HOME/bin" 2> /dev/null
# set PATH so it includes user's private bin if it exists. (from Ubuntu's ~/.profile)
add_path "$HOME/.local/bin" 2> /dev/null

# make .bash_profile to load .bashrc
if [ -L ~/.bashrc ]; then
    source ~/.bashrc
fi

# configure and use GIT_PS1 variable after load git-prompt.sh with .bashrc
GIT_PS1_SHOWDIRTYSTATE=1
GIT_PS1_SHOWUPSTREAM=1
GIT_PS1_SHOWUNTRACKEDFILES=
GIT_PS1_SHOWSTASHSTATE=1
# set it to change prompt
# e.g. ~/hoge (master) $
export PS1='\w\[\033[1;31m\]$(__git_ps1)\[\033[00m\] \$ '
