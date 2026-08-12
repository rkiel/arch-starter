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

# ------------------------------------------------------------
info "Timezone"

ln -sf /usr/share/zoneinfo/$TIMEZONE /etc/localtime

hwclock --systohc

LOCALE="en_US.UTF-8"

# ------------------------------------------------------------
info "Locale"
echo "$LOCALE UTF-8" >> /etc/locale.gen

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

# ------------------------------------------------------------
# MacBookPro14,1 exposes a 2560x1600 panel, but i915drmfb
# initializes the Linux console framebuffer as 2880x1800.
# This causes the lower portion of the TTY to render off-screen.
# Force fb0 geometry to the panel's actual resolution.
MODEL=$(cat /sys/devices/virtual/dmi/id/product_name)

if [[ "$MODEL" == "MacBookPro14,1" ]]; then
  info "Framebuffer fixes for $MODEL"

  cat > /mnt/etc/systemd/system/macbook-framebuffer.service <<'EOF'
[Unit]
Description=Fix MacBook Pro console framebuffer
Before=getty.target

[Service]
Type=oneshot
ExecStart=/usr/bin/fbset -g 2560 1600 2560 1600 32
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOF

  systemctl enable macbook-framebuffer.service
fi



# ============================================================
info "ROOT PASSWORD"
passwd

# ============================================================
info "$USERNAME PASSWORD"
passwd "$USERNAME"

# ============================================================
info "Bootloader"

grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB # --removable

grub-mkconfig -o /boot/grub/grub.cfg



info "ARCH CHROOT 2 COMPLETE"