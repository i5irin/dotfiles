# ---------------------------------------------------------
# Configure environment variables
# ---------------------------------------------------------

# set it to refer applications installed with Homebrew
export PATH="/usr/local/bin:${PATH}"
# set it to refer GNU-applications installed with Homebrew instead of BSD-applications
export PATH="/usr/local/opt/coreutils/libexec/gnubin:${PATH}"

# make .bash_profile to load .bashrc
if [ -f ~/.bashrc ]; then
    . ~/.bashrc
fi
