export XDG_CONFIG_HOME="$HOME/.config"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_STATE_HOME="$HOME/.local/state"

# -F — exit if everything fits on one screen
# -X — don't clear the terminal when less exits
# -R   display ANSI colors correctly
# -i   smart case-insensitive searching
# -S   don't wrap long lines; scroll horizontally
export LESS="-FXRiS"