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

./scripts/one.sh

cd ..
```

### Execute Script 2

```
mv arch-starter /mnt

arch-chroot /mnt

cd arch-starter

./scripts/two.sh

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

exit
```

### Login as user

```
mkdir -p ~/GitHub/rkiel
cd ~/GitHub/rkiel
git clone https://github.com/rkiel/arch-starter.git

cd arch-starter/dotfiles
./zsh.sh
./code.sh
./cursor.sh
```
