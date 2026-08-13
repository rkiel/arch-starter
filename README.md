# arch-starter

### Make the font bigger

```
setfont -d
```

### Connect to Wi-Fi

```
iwctl device list

DD="wlan0"
iwctl station $DD scan
iwctl station $DD get-networks

SS="TBD"
iwctl station $DD connect $SS
```

### Download install script

```
pacman -Sy git

git clone https://github.com/rkiel/arch-starter.git
```

### Execute Script 1

```
cd arch-starter

./scripts/root/one.sh

cd ..
```

### Execute Script 2

```
cp -R arch-starter /mnt

arch-chroot /mnt

cd arch-starter

./scripts/root/two.sh

exit
```

### Execute Script 3

```
arch-chroot /mnt

cd arch-starter

./scripts/root/three.sh

exit
```

### Reboot

```
umount -R /mnt

reboot
```

### Login as root

```
nmcli device wifi connect SSID --ask

nmcli connection show

ping -c 3 archlinux.org

exit
```

### Login as user

```
GH=$HOME/GitHub/rkiel
REPO=arch-starter
mkdir -p $GH
cd $GH
git clone https://github.com/rkiel/$REPO.git

cd $REPO

./scripts/user/one.sh $GH/$REPO

start-hyprland
```

# Hyprland's primary job is: Manage windows.

# Hyprland knows absolutely nothing about terminals.

# Think of Hyprland as the conductor of an orchestra.

# Kitty is a terminal

# Waybar is simply a panel.

# Applications send notifications. Mako displays them.

# Wofi is a launcher
