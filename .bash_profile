# Load the library functions.
. ~/lib.sh

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

export PROMPT_DIRTRIM=4

# Set the default options for less.
export LESS='-iMR'
# Apply syntax highlighting to less.
# macOS
if [ -x /usr/local/bin/src-hilite-lesspipe.sh ]; then
  export LESSOPEN="| src-hilite-lesspipe.sh %s"
fi
# Ubuntu
if [ -x /usr/share/source-highlight/src-hilite-lesspipe.sh ]; then
  export LESSOPEN='| /usr/share/source-highlight/src-hilite-lesspipe.sh %s'
fi
