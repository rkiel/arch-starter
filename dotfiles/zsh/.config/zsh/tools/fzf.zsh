export FZF_DEFAULT_OPTS="
  --layout=reverse
  --height=100%
"

export FZF_DEFAULT_COMMAND="fd --type f --hidden --exclude .git"
export FZF_CTRL_T_COMMAND="fd --type f --hidden --exclude .git"

# Set up fzf key bindings and fuzzy completion
source <(fzf --zsh)