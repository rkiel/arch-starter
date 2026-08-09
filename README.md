# arch-starter

```
iwctl device list

DD="wlan0"
iwctl station $DD scan
iwctl station $DD get-networks

SS="TBD"
iwctl station $DD connect $SS
```

```
wget --no-check-certificate --content-disposition https://raw.githubusercontent.com/rkiel/arch-starter/refs/heads/master/arch_setup1.sh

curl -LJO https://raw.githubusercontent.com/rkiel/arch-starter/refs/heads/master/arch_setup1.sh
```
