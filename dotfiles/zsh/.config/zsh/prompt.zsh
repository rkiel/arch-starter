# because we're putting ${vcs_info_msg_0_} inside a single-quoted PROMPT, 
# this is where we now need:
setopt PROMPT_SUBST

# Loads zsh's built-in version-control information system
autoload -Uz vcs_info

# precmd is a special zsh hook that runs before each prompt is displayed. 
# That means if you change Git branches, the next prompt updates automatically.
precmd() {
  vcs_info
}

zstyle ':vcs_info:git:*' check-for-changes true
zstyle ':vcs_info:git:*' stagedstr '+'
zstyle ':vcs_info:git:*' unstagedstr '*'
zstyle ':vcs_info:git:*' formats ' [%F{green}%b%f%c%u]'

# %~    current directory, with $HOME abbreviated as ~
# %#    % for a normal user, # for root
# %( condition . true-text . false-text )
# condition = is this shell privileged/root?
# true      = #
# false     = $
PROMPT='%F{blue}%~%f${vcs_info_msg_0_} %(#.#.$) '