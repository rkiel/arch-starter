#!/usr/bin/env bash


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

install() {
    echo
    echo "============================================================"
    pacman -S --noconfirm --needed $1
    echo "============================================================"
    echo
}

# ============================================================
info "Installing Hyprland and desktop packages"

install "hyprland"
install "xdg-desktop-portal"
install "xdg-desktop-portal-hyprland"
install "waybar"
install "wofi"
install "mako"
install "kitty"

# ============================================================
info "Installing Ruby packages"

install "mise"
install "openssl"
install "libyaml"
install "libffi"
install "gmp"
install "rust"

info "ARCH SETUP 3 COMPLETE"