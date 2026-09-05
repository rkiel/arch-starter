## MacBookPro14,1

### Console framebuffer

Symptom:
TTY extends below bottom of screen.

Fix:
fbset -g 2560 1600 2560 1600 32

### Broadcom Wi-Fi

Symptom:
brcmf_chip_recognition: MMIO read failed

Fix:
Power off completely (not reboot), then power back on.

## IMAC #1

lsblk -o NAME,SIZE,MODEL,TYPE,MOUNTPOINTS

```
lsblk /dev/sda
sudo dd if=/dev/zero of=/dev/sda bs=16M status=progress conv=fsync
sudo wipefs /dev/sda
```

```
sudo fdisk /dev/sda

g       new GPT partition table
n       new partition
Enter   partition 1
Enter   default first sector
Enter   default last sector
w       write changes
```

```
sudo mkfs.ext4 -L data /dev/sda1
```

```
lsblk /dev/sdb
sudo dd if=/dev/zero of=/dev/sdb bs=16M status=progress conv=fsync
sudo wipefs /dev/sdb
```
