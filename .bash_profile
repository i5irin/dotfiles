# ---------------------------------------------------------
# Configure environment variables
# ---------------------------------------------------------

# set it to refer applications installed with Homebrew
export PATH="/usr/local/bin:${PATH}"
# Make OpenJDK that is installed with Homebrew be used as default.
export PATH="/usr/local/opt/openjdk/bin:${PATH}"

# set PATH so it includes user's private bin if it exists. (from Ubuntu's ~/.profile)
if [ -d "$HOME/bin" ] ; then
  case ":$PATH:" in
    *:$HOME/bin:*) ;;
    *) PATH="$HOME/bin:$PATH" ;;
  esac
fi

# set PATH so it includes user's private bin if it exists. (from Ubuntu's ~/.profile)
if [ -d "$HOME/.local/bin" ] ; then
  case ":$PATH:" in
    *:$HOME/.local/bin:*) ;;
    *) PATH="$HOME/.local/bin:$PATH" ;;
  esac
fi

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
