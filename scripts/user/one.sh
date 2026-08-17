#!/usr/bin/env zsh

# -e — Exit immediately on errors
# -u — Treat undefined variables as errors
# -o pipefail — Make pipelines fail correctly
set -euo pipefail

# ============================================================
# HELPER FUNCTIONS
# ============================================================

die() {
    echo
    echo "ERROR: $1"
    echo
    exit 1
}

info() {
    echo
    echo "============================================================"
    echo "$1"
    echo "============================================================"
    echo
}

pushd $1/dotfiles

LIBRARY="~/Library/Application Support"

# ============================================================
info "zsh"

mkdir -p "$HOME/.local/state/zsh"

stow -t ~ zsh


# ============================================================
info "bat"

stow --no-folding -t ~ bat

# ============================================================
info "Code"

mkdir -p "$LIBRARY/Code/User"
stow --no-folding -t ~ code

# ============================================================
info "Cursor"

mkdir -p "$LIBRARY/Cursor/User"
stow --no-folding -t ~ cursor

# ============================================================
info "Hyprland"

stow --no-folding -t ~ hyprland

# ============================================================
info "Ruby"

mise install ruby@3
mise use -g ruby@3

eval "$(/usr/bin/env mise activate zsh)"

# ============================================================
info "Rails"
gem install rails

# ============================================================
info "ARCH USER SETUP 1 COMPLETE"

popd