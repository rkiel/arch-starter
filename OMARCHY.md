## Audio Problem

On the **13-inch MacBook Pro 14,1** running Arch/Omarchy, Linux detects the Cirrus CS8409 audio hardware and even creates a normal
**Built-in Audio Analog Stereo** output, but the generic kernel support does not correctly initialize/rout the MacBook's internal
speakers. This makes PipeWire, ALSA, volume controls, and applications such as cliamp appear to work while producing no sound.

The solution is to install the MacBook-specific **snd_hda_macbookpro** driver using DKMS (`sudo ./install.cirrus.driver.sh -i`)
and reboot. After installation, `speaker-test` produces sound through the internal speakers and applications such as `cliamp` work
normally. Using DKMS also allows the driver to be rebuilt automatically when Arch updates the kernel.

### Install the build dependencies:

```
sudo pacman -S --needed gcc linux-headers make patch wget dkms git
```

### Then clone the MacBook-specific driver:

```
cd ~/Downloads

git clone https://github.com/davidjo/snd_hda_macbookpro.git
cd snd_hda_macbookpro
```

### Install it using DKMS:

- The `-i` is important because it installs the driver through DKMS, allowing it to rebuild when Arch updates your kernel.

```
sudo ./install.cirrus.driver.sh -i
```

### Reboot
