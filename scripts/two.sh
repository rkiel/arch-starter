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

TIMEZONE="America/New_York"
LOCALE="en_US.UTF-8"

# ------------------------------------------------------------
info "Timezone"

ln -sf /usr/share/zoneinfo/$TIMEZONE /etc/localtime

hwclock --systohc

# ------------------------------------------------------------
info "Locale"
echo "$LOCALE UTF-8" /etc/locale.gen

locale-gen

echo "LANG=$LOCALE" > /etc/locale.conf

# ------------------------------------------------------------
info "Console keyboard"

echo "KEYMAP=us" > /etc/vconsole.conf

# ------------------------------------------------------------
info "Hostname"

read -rp "Enter hostname (archlinux): " HOSTNAME

echo "$HOSTNAME" > /etc/hostname
echo "127.0.1.1   $HOSTNAME.localdomain $HOSTNAME" >> /etc/hosts

# ------------------------------------------------------------
info "Sudo"

echo "%wheel ALL=(ALL:ALL) ALL" > /etc/sudoers.d/wheel

chmod 440 /etc/sudoers.d/wheel



# ------------------------------------------------------------
info "Create user"

read -rp "Enter username (bob): " USERNAME

useradd \
    --create-home \
    --groups wheel \
    --shell /bin/zsh \
    "$USERNAME"

# ------------------------------------------------------------
info "Enable NetworkManager"

systemctl enable NetworkManager

# ============================================================
info "ROOT PASSWORD"
passwd

# ============================================================
info "$USERNAME PASSWORD"
passwd "$USERNAME"


info "ARCH CHROOT 2 COMPLETE"