# Location of the persistent history file shared across zsh sessions.
HISTFILE="$XDG_STATE_HOME/zsh/history"

# Maximum number of history entries zsh keeps in memory for this shell.
HISTSIZE=10000

# Maximum number of history entries saved to $HISTFILE.
SAVEHIST=10000

# When this shell saves history, append its new commands to the history
# file rather than replacing the file with this shell's history.
setopt APPEND_HISTORY

# Do NOT write each command to the history file immediately.
# This helps keep currently-running terminals logically independent.
unsetopt INC_APPEND_HISTORY

# Do NOT continuously exchange history between running shells.
# Terminal A therefore does not immediately see commands entered in B or C.
unsetopt SHARE_HISTORY

# If a command already exists anywhere in history, remove the older copy
# when the command is entered again. Keeps the newest occurrence.
setopt HIST_IGNORE_ALL_DUPS

# When the history file needs trimming, remove duplicate entries before
# throwing away unique commands. Helps preserve useful history longer.
setopt HIST_EXPIRE_DUPS_FIRST

# When searching history, don't show the same command repeatedly.
# Particularly useful with history navigation and interactive searches.
setopt HIST_FIND_NO_DUPS

# Don't write duplicate commands to the persistent history file.
# Keeps ~/.zsh_history cleaner even after many shell sessions are saved.
setopt HIST_SAVE_NO_DUPS

# Remove unnecessary extra whitespace from commands before saving them.
# Prevents visually identical commands from differing only by spacing.
setopt HIST_REDUCE_BLANKS

# Preserve useful metadata such as command timestamps and durations
# in the history file using zsh's extended history format.
setopt EXTENDED_HISTORY