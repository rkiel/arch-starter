#!/usr/bin/env bash


# -e — Exit immediately on errors
# -u — Treat undefined variables as errors
# -o pipefail — Make pipelines fail correctly
set -euo pipefail

# ============================================================
# Arch Linux + Hyprland
# Apple MacBookPro14,1
# ============================================================


EXPECTED_MODEL="MacBookPro14,1"

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
    pacstrap -K /mnt $1
    echo "============================================================"
    echo
}

# ============================================================
# SANITY CHECKS
# ============================================================

[[ $EUID -eq 0 ]] || die "Run this script as root."

MODEL="$(cat /sys/devices/virtual/dmi/id/product_name 2>/dev/null || true)"

if [[ "$MODEL" != "$EXPECTED_MODEL" ]]; then
    die "This script is intended for $EXPECTED_MODEL. Detected: $MODEL"
fi


# ============================================================
info "Checking UEFI mode"

if [[ ! -d /sys/firmware/efi/efivars ]]; then
    die "The Arch ISO was not booted in UEFI mode."
fi

echo "UEFI mode detected."

# ============================================================
info "TIME SYNCHRONIZATION"

timedatectl set-ntp true

# ============================================================
info "PARTITION AND FORMAT TARGET DISK"

echo
read -rp 'Type FORMAT to erase disk: ' CONFIRM_FORMAT

if [[ "$CONFIRM_FORMAT" == "FORMAT" ]]; then

echo
lsblk -o NAME,SIZE,TYPE,FSTYPE,MOUNTPOINTS

echo
read -rp "Enter disk name (/dev/nvme0n1): " DISK

echo
read -rp "Enter EFI size (1G): " EFI_SIZE

echo
read -rp "Enter SWAP size (8G): " SWAP_SIZE

echo
read -rp "Enter ROOT size (40G): " ROOT_SIZE

# remaining space /home

echo
read -rp "Enter LABEL (gpt): " DISK_LABEL

# ============================================================
info "Partitioning $DISK"

wipefs -a "$DISK"

sfdisk "$DISK" <<EOF
label: $DISK_LABEL
size=$EFI_SIZE, type=uefi
size=$SWAP_SIZE, type=swap
size=$ROOT_SIZE, type=linux
type=linux
EOF

# must mirror above command
EFI="${DISK}p1"
SWAP="${DISK}p2"
ROOT="${DISK}p3"
HOME="${DISK}p4"

partprobe "$DISK"

sleep 2

# ============================================================
info "Formatting EFI partition"
mkfs.fat -F32 "$EFI"

info "Formatting swap"
mkswap "$SWAP"

info "Formatting root filesystem"
mkfs.ext4 -F "$ROOT"

info "Formatting home filesystem"
mkfs.ext4 -F "$HOME"


# ============================================================
info "Mounting root filesystem"
mount "$ROOT" /mnt

info "Mounting EFI filesystem"
mkdir -p /mnt/boot
mount "$EFI" /mnt/boot

info "Mounting HOME filesystem"
mkdir -p /mnt/home
mount "$HOME" /mnt/home

info "Mounting SWAP filesystem"
swapon "$SWAP"

# ============================================================
info "Partition Complete"

lsblk -o NAME,SIZE,TYPE,FSTYPE,MOUNTPOINTS "$DISK"

fi


# ============================================================
info "Install base Arch Linux system"

echo
read -rp 'Type INSTALL to install: ' CONFIRM_INSTALL

if [[ "$CONFIRM_INSTALL" == "INSTALL" ]]; then

# ============================================================
# INSTALL BASE ARCH SYSTEM
# ============================================================
# pacstrap — Installs packages into another root directory (not the live installer you're currently running).
# -K — Initializes a new package manager keyring in the target system (this is the recommended option in current Arch installation guides).
# /mnt — The directory where you've mounted your future Arch installation.

# base meta package installs the essential components of a minimal Arch Linux system, such as:
# -- The Linux filesystem hierarchy
# -- Bash
# -- GNU Core Utilities (cp, mv, ls, cat, etc.)
# -- systemd
# -- pacman
# -- Basic networking utilities
# -- Libraries required for the system to function
# linux - kernal
# linux-firmware - kernal
# intel-ucode - Intel based CPUs vs amd-ucode

install "base"
install "linux"
install "linux-firmware"
install "intel-ucode"
install "networkmanager"
install "fbset"
install "sudo"
install "vim"
install "git"
install "base-devel"
install "man-db"
install "man-pages"
install "texinfo"
install "bash-completion"
install "dosfstools"
install "stow"
install "zsh"
install "fzf"
# bootloader
install "grub"
install "efibootmgr"

fi


if [[ "$CONFIRM_FORMAT" == "FORMAT" ]]; then

# ============================================================
info "GENERATE FSTAB"

genfstab -U /mnt > /mnt/etc/fstab

cat /mnt/etc/fstab

fi

info "ARCH SETUP 1 COMPLETE"
echo
exit

# ============================================================
# INSTALL HYPRLAND
# ============================================================

info "Installing Hyprland and desktop packages"

arch-chroot /mnt pacman -S --noconfirm \
    hyprland \
    xdg-desktop-portal \
    xdg-desktop-portal-hyprland \
    waybar \
    wofi \
    kitty \
    thunar \
    polkit \
    pipewire \
    pipewire-audio \
    pipewire-pulse \
    wireplumber \
    pavucontrol \
    brightnessctl \
    playerctl \
    grim \
    slurp \
    wl-clipboard \
    qt5-wayland \
    qt6-wayland \
    xorg-xwayland \
    mesa \
    vulkan-intel \
    libva-intel-driver \
    libva-utils \
    firefox \
    fastfetch \
    btop \
    unzip \
    zip \
    tree


# ============================================================
# BLUETOOTH
# ============================================================

info "Installing Bluetooth support"

arch-chroot /mnt pacman -S --noconfirm \
    bluez \
    bluez-utils

arch-chroot /mnt systemctl enable bluetooth


# ============================================================
# LAPTOP UTILITIES
# ============================================================

info "Installing laptop utilities"

arch-chroot /mnt pacman -S --noconfirm \
    upower \
    acpi \
    power-profiles-daemon

arch-chroot /mnt systemctl enable power-profiles-daemon


# ============================================================
# KERNEL MODULES
# ============================================================

info "Configuring kernel modules"

cat > /mnt/etc/modules-load.d/macbook.conf <<EOF
i915
brcmfmac
snd_hda_intel
EOF


# ============================================================
# HYPRLAND CONFIGURATION
# ============================================================

info "Creating Hyprland configuration"

arch-chroot /mnt /bin/bash <<EOF

set -e

mkdir -p /home/$USERNAME/.config/hypr
mkdir -p /home/$USERNAME/Pictures

cat > /home/$USERNAME/.config/hypr/hyprland.conf <<'HYPR'

# ============================================================
# Basic Hyprland configuration
# ============================================================

\$terminal = kitty
\$menu = wofi --show drun

monitor=,preferred,auto,1


# ------------------------------------------------------------
# Applications
# ------------------------------------------------------------

bind = SUPER, RETURN, exec, \$terminal
bind = SUPER, D, exec, \$menu


# ------------------------------------------------------------
# Window management
# ------------------------------------------------------------

bind = SUPER, Q, killactive

bind = SUPER, SHIFT, R, exec, hyprctl reload

bind = SUPER, M, exit


# ------------------------------------------------------------
# Focus
# ------------------------------------------------------------

bind = SUPER, LEFT, movefocus, l
bind = SUPER, RIGHT, movefocus, r
bind = SUPER, UP, movefocus, u
bind = SUPER, DOWN, movefocus, d


# ------------------------------------------------------------
# Move windows
# ------------------------------------------------------------

bind = SUPER SHIFT, LEFT, movewindow, l
bind = SUPER SHIFT, RIGHT, movewindow, r
bind = SUPER SHIFT, UP, movewindow, u
bind = SUPER SHIFT, DOWN, movewindow, d


# ------------------------------------------------------------
# Workspaces
# ------------------------------------------------------------

bind = SUPER, 1, workspace, 1
bind = SUPER, 2, workspace, 2
bind = SUPER, 3, workspace, 3
bind = SUPER, 4, workspace, 4
bind = SUPER, 5, workspace, 5


# ------------------------------------------------------------
# Screenshot
# ------------------------------------------------------------

bind = , PRINT, exec, grim -g "\$(slurp)" ~/Pictures/screenshot.png


# ------------------------------------------------------------
# Volume
# ------------------------------------------------------------

bindel = , XF86AudioRaiseVolume, exec, \
    wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+

bindel = , XF86AudioLowerVolume, exec, \
    wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-

bind = , XF86AudioMute, exec, \
    wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle


# ------------------------------------------------------------
# Brightness
# ------------------------------------------------------------

bindel = , XF86MonBrightnessUp, exec, \
    brightnessctl set 5%+

bindel = , XF86MonBrightnessDown, exec, \
    brightnessctl set 5%-


# ------------------------------------------------------------
# Start Waybar
# ------------------------------------------------------------

exec-once = waybar

HYPR

chown -R $USERNAME:$USERNAME \
    /home/$USERNAME/.config \
    /home/$USERNAME/Pictures

EOF


# ============================================================
# AUTOMATIC HYPRLAND STARTUP
# ============================================================

info "Configuring automatic Hyprland startup"

arch-chroot /mnt /bin/bash <<EOF

cat > /home/$USERNAME/.bash_profile <<'PROFILE'

# Automatically start Hyprland on TTY1.

if [[ -z "\$DISPLAY" && -z "\$WAYLAND_DISPLAY" ]] && \
   [[ "\$(tty)" == "/dev/tty1" ]]; then
    exec Hyprland
fi

PROFILE

chown $USERNAME:$USERNAME /home/$USERNAME/.bash_profile

EOF


# ============================================================
# SYSTEMD-BOOT
# ============================================================

info "Installing systemd-boot"

arch-chroot /mnt bootctl install


# ============================================================
# SYSTEMD-BOOT CONFIGURATION
# ============================================================

info "Configuring systemd-boot"

ROOT_UUID="$(blkid -s UUID -o value "$ROOT")"

cat > /mnt/boot/loader/loader.conf <<EOF
default arch.conf
timeout 3
console-mode max
editor no
EOF

cat > /mnt/boot/loader/entries/arch.conf <<EOF
title   Arch Linux
linux   /vmlinuz-linux
initrd  /intel-ucode.img
initrd  /initramfs-linux.img
options root=UUID=$ROOT_UUID rw
EOF


# ============================================================
# INITRAMFS
# ============================================================

info "Generating initramfs"

arch-chroot /mnt mkinitcpio -P


# ============================================================
# FINAL CHECKS
# ============================================================

info "Checking installed system"

arch-chroot /mnt systemctl is-enabled NetworkManager

echo
echo "Bootloader:"
echo

arch-chroot /mnt bootctl status || true

echo
echo "Installed partitions:"
echo

lsblk -o NAME,SIZE,FSTYPE,MOUNTPOINTS "$DISK"


# ============================================================
# FINISH
# ============================================================

sync

echo
echo "============================================================"
echo "             ARCH INSTALLATION COMPLETE"
echo "============================================================"
echo
echo "Machine:     $EXPECTED_MODEL"
echo "Disk:        $DISK"
echo "Root:        40 GiB"
echo "Swap:        8 GiB"
echo "Home:        Remaining space"
echo "Desktop:     Hyprland"
echo "Display mgr: None"
echo
echo "After reboot:"
echo
echo "1. Remove the Arch USB."
echo "2. Boot from the internal drive."
echo "3. Log in as: $USERNAME"
echo "4. Hyprland will automatically start on TTY1."
echo
echo "============================================================"
echo

read -rp "Press ENTER to unmount and reboot, or Ctrl+C to stop."

swapoff "$SWAP" || true

umount -R /mnt

reboot

