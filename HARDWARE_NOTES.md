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
