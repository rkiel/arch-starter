# zsh looks in roughly this order:
#   1. Aliases
#   2. Functions
#   3. Built-in commands
#   4. External executables in your PATH

alias cat='bat --color=auto'

export PAGER=less
export LESS='-FRX'
# -R preserves ANSI colors.
# -F exits when everything fits on one screen.
# -X leaves the output visible after exiting.
alias more='less'
alias mroe='less'

alias vim='nvim'


h() {
    local cmd
    cmd=$(history | sed 's/^ *[0-9]\+ *//' | fzf --tac --no-sort) || return
    READLINE_LINE="$cmd"
    READLINE_POINT=${#READLINE_LINE}
}

# --all hidden files
unalias ls 2>/dev/null
ls() {
    eza --long --group-directories-first --classify "$@"
}

unalias lsl 2>/dev/null
lsl() {
    eza --all --long --group-directories-first --classify --git "$@"
}

unalias lst 2>/dev/null
lst() {
    eza --all --long --group-directories-first --classify --git --tree --level=2"$@"
}
