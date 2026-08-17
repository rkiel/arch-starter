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

WALLPAPER_DIR="$HOME/Pictures/Wallpapers"
mkdir -p "$WALLPAPER_DIR"
cd "$WALLPAPER_DIR"
WALLPAPER_URL="https://server.wallpaperalchemy.com/storage/wallpapers/197/arch-linux-purple-mountain-4k-wallpaper.jpeg"
curl -fL -o arch-linux-one.jpeg "$WALLPAPER_URL" || echo "WARNING: Wallpaper download failed; continuing installation."

WALLPAPER_DIR="https://server.wallpaperalchemy.com/storage/wallpapers/107/arch-linux-wallpaper-4k.jpeg"
curl -fL -o arch-linux-two.jpeg "$WALLPAPER_URL" || echo "WARNING: Wallpaper download failed; continuing installation."

WALLPAPER_DIR="https://server.wallpaperalchemy.com/storage/wallpapers/203/arch-linux-4k-minimalist-wallpaper.png"
curl -fL -o arch-linux-three.png "$WALLPAPER_URL" || echo "WARNING: Wallpaper download failed; continuing installation."

WALLPAPER_DIR="https://server.wallpaperalchemy.com/storage/wallpapers/200/arch-linux-wallpaper-4k.png"
curl -fL -o arch-linux-four.png "$WALLPAPER_URL" || echo "WARNING: Wallpaper download failed; continuing installation."

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