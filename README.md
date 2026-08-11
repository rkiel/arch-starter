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
git clone https://github.com/rkiel/arch-starter.git
```

### Execute Script 1

```
cd arch-starter

./scripts/one.sh
```

### Execute Script 2

```
mv arch-starter /mnt

arch-chroot /mnt

cd /mnt/arch-starter

./scripts/two.sh

exit
```
