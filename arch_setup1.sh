#!/usr/bin/env bash


# -e — Exit immediately on errors
# -u — Treat undefined variables as errors
# -o pipefail — Make pipelines fail correctly
set -euo pipefail

# ============================================================
# Arch Linux + Hyprland
# Apple MacBookPro14,1
# ============================================================


# ============================================================
# USER CONFIGURATION
# ============================================================

read -rp "Enter disk (/dev/nvme0n1): " DISK
read -rp "Enter username (bob): " USERNAME
read -rp "Enter hostname (archlinux): " HOSTNAME

TIMEZONE="America/New_York"
LOCALE="en_US.UTF-8"

EXPECTED_MODEL="MacBookPro14,1"


# ============================================================
# PARTITION SIZES
# ============================================================

EFI_SIZE="1G"
SWAP_SIZE="8G"
ROOT_SIZE="40G"


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


# ============================================================
# SANITY CHECKS
# ============================================================

[[ $EUID -eq 0 ]] || die "Run this script as root."

[[ -b "$DISK" ]] || die "$DISK does not exist."

MODEL="$(cat /sys/devices/virtual/dmi/id/product_name 2>/dev/null || true)"

echo
echo "Detected computer:"
echo
echo "    $MODEL"
echo

if [[ "$MODEL" != "$EXPECTED_MODEL" ]]; then
    die "This script is intended for $EXPECTED_MODEL. Detected: $MODEL"
fi

if [[ "$USERNAME" == "yourusername" ]]; then
    die "Edit USERNAME near the top of the script before running it."
fi


# ============================================================
# VERIFY UEFI MODE
# ============================================================

info "Checking UEFI mode"

if [[ ! -d /sys/firmware/efi/efivars ]]; then
    die "The Arch ISO was not booted in UEFI mode."
fi

echo "UEFI mode detected."


# ============================================================
# WI-FI SETUP
# ============================================================

info "Wi-Fi setup"

info "Checking internet connection"

if ! ping -c 3 archlinux.org >/dev/null 2>&1; then
    die "Wi-Fi connected, but internet access could not be verified."
fi

echo "Internet connection works."

exit

# ============================================================
# CONFIRM TARGET DISK
# ============================================================

info "TARGET DISK"

lsblk -o NAME,SIZE,TYPE,FSTYPE,MOUNTPOINTS "$DISK"

echo
echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
echo "WARNING: THE ENTIRE DISK WILL BE ERASED"
echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
echo
echo "Target:"
echo
echo "    $DISK"
echo
echo "This will destroy ALL data on this disk."
echo

read -rp 'Type ERASE to continue: ' CONFIRM

if [[ "$CONFIRM" != "ERASE" ]]; then
    die "Installation cancelled."
fi


# ============================================================
# TIME SYNCHRONIZATION
# ============================================================

info "Enabling network time synchronization"

timedatectl set-ntp true


# ============================================================
# PARTITION DISK
#
# p1 = 1 GiB EFI
# p2 = 8 GiB swap
# p3 = 40 GiB root
# p4 = remaining space /home
# ============================================================

info "Partitioning $DISK"

wipefs -a "$DISK"

sfdisk "$DISK" <<EOF
label: gpt
size=$EFI_SIZE, type=uefi
size=$SWAP_SIZE, type=swap
size=$ROOT_SIZE, type=linux
type=linux
EOF

partprobe "$DISK"

sleep 2

EFI="${DISK}p1"
SWAP="${DISK}p2"
ROOT="${DISK}p3"
HOME="${DISK}p4"

info "Partition layout"

lsblk -o NAME,SIZE,TYPE,FSTYPE,MOUNTPOINTS "$DISK"


# ============================================================
# FORMAT PARTITIONS
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
# MOUNT FILESYSTEMS
# ============================================================

info "Mounting filesystems"

mount "$ROOT" /mnt

mkdir -p /mnt/boot
mount "$EFI" /mnt/boot

mkdir -p /mnt/home
mount "$HOME" /mnt/home

swapon "$SWAP"


# ============================================================
# INSTALL BASE ARCH SYSTEM
# ============================================================

info "Installing base Arch Linux"

pacstrap -K /mnt \
    base \
    linux \
    linux-firmware \
    intel-ucode \
    networkmanager \
    sudo \
    vim \
    nano \
    git \
    base-devel \
    man-db \
    man-pages \
    texinfo \
    bash-completion \
    efibootmgr \
    dosfstools


# ============================================================
# GENERATE FSTAB
# ============================================================

info "Generating /etc/fstab"

genfstab -U /mnt >> /mnt/etc/fstab


# ============================================================
# BASIC SYSTEM CONFIGURATION
# ============================================================

info "Configuring base system"

arch-chroot /mnt /bin/bash <<EOF

set -e

# ------------------------------------------------------------
# Timezone
# ------------------------------------------------------------

ln -sf /usr/share/zoneinfo/$TIMEZONE /etc/localtime

hwclock --systohc


# ------------------------------------------------------------
# Locale
# ------------------------------------------------------------

sed -i 's/^#\(en_US.UTF-8 UTF-8\)/\1/' /etc/locale.gen

locale-gen

echo "LANG=$LOCALE" > /etc/locale.conf


# ------------------------------------------------------------
# Console keyboard
# ------------------------------------------------------------

echo "KEYMAP=us" > /etc/vconsole.conf


# ------------------------------------------------------------
# Hostname
# ------------------------------------------------------------

echo "$HOSTNAME" > /etc/hostname

cat > /etc/hosts <<HOSTS
127.0.0.1   localhost
::1         localhost
127.0.1.1   $HOSTNAME.localdomain $HOSTNAME
HOSTS


# ------------------------------------------------------------
# Sudo
# ------------------------------------------------------------

cat > /etc/sudoers.d/wheel <<SUDO
%wheel ALL=(ALL:ALL) ALL
SUDO

chmod 440 /etc/sudoers.d/wheel


# ------------------------------------------------------------
# Create user
# ------------------------------------------------------------

useradd \
    --create-home \
    --groups wheel \
    --shell /bin/bash \
    "$USERNAME"


# ------------------------------------------------------------
# Enable NetworkManager
# ------------------------------------------------------------

systemctl enable NetworkManager

EOF


# ============================================================
# PASSWORDS
# ============================================================

info "Set root password"

arch-chroot /mnt passwd

info "Set password for $USERNAME"

arch-chroot /mnt passwd "$USERNAME"


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

