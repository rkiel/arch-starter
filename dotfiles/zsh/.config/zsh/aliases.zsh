# zsh looks in roughly this order:
#   1. Aliases
#   2. Functions
#   3. Built-in commands
#   4. External executables in your PATH


fh() {
    # create a local variable to prevent overwrite a global shell variable
    local cmd
    # fc stands for Fix Command.  It's zsh's built-in history command.
    # -l list history
    # -n no line numbers
    # -r reverse order
    # 1 start at history entry 1
    #
    # cmd $(...) Run everything inside.  Whatever it prints...  assign it to cmd.
    # ||return If you press Esc or Ctrl-C inside fzf...  fzf exits with failure.
    # immediately exits the function.  Without it, the function would continue with an empty command.
    #
    # print This is a zsh builtin.
    # -s means Store this command in history.
    # -- means End of options.  Everything after this is data.
    #
    # eval This executes the command.
    cmd=$(fc -lnr 1 | fzf) || return
#    cmd=$(fc -lnr 1 | fzf --bind='ctrl-r:toggle-sort') || return
    print -s -- "$cmd"
    eval "$cmd"
}

fdir() {
  fd --type d --hidden --exclude .git "$@"
}

ffile() {
  fd --type f --hidden --exclude .git "$@"
}

