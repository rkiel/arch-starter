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

pushd $1

# ============================================================
info "zsh"

stow -t ~ zsh

LIBRARY="~/Library/Application Support"

# ============================================================
info "Code"

mkdir -p "$LIBRARY/Code/User"
stow --no-folding -t ~ code

# ============================================================
info "Cursor"

mkdir -p "$LIBRARY/Cursor/User"
stow --no-folding -t ~ cusor

# ============================================================
info "Ruby"

mise install ruby@3
mise use -g ruby@3

# ============================================================
info "Rails"
gem install rails

# ============================================================
info "ARCH USER SETUP 1 COMPLETE"

popd