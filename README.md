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
curl -LJO https://raw.githubusercontent.com/rkiel/arch-starter/refs/heads/master/arch_setup1.sh

chmod u+x arch_setup1.sh
```

### Execute

```
./arch_setup1.sh
```
