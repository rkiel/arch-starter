#export NVM_DIR="$HOME/.nvm"
#[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # Load NVM
#[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # Load NVM bash completion
#eval "$(/opt/homebrew/bin/brew shellenv zsh)"
eval "$(/usr/bin/env mise activate zsh)"

bindkey -v # vim mode
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt appendhistory

# Set up fzf key bindings and fuzzy completion
source <(fzf --zsh)

# export FEATURE_USER=bob
# GIT_UTILITIES=~/GitHub/rkiel/git-utilities
# source ${GIT_UTILITIES}/dotfiles/zshrc
