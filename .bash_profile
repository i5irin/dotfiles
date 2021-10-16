# ---------------------------------------------------------
# Configure environment variables
# ---------------------------------------------------------

# set it to refer applications installed with Homebrew
export PATH="/usr/local/bin:${PATH}"
# set it to refer GNU-applications installed with Homebrew instead of BSD-applications
export PATH="/usr/local/opt/coreutils/libexec/gnubin:${PATH}"
# set it to refer GNU-sed installed with Homebrew instead of BSD one.
export PATH="/usr/local/opt/gnu-sed/libexec/gnubin:${PATH}"
# Make OpenJDK that is installed with Homebrew be used as default.
export PATH="/usr/local/opt/openjdk/bin:${PATH}"

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
