## Installation

### stow

```bash
sudo pacman -S stow
```

### Bash

```bash
cd ~/GitHub/rkiel/arch-starter/omarchy/dotfiles/
mv ~/.bashrc original/dot-bashrc
stow --dotfiles --no-folding -t ~ bash
```

### Neovim

```bash
cd ~/GitHub/rkiel/arch-starter/omarchy/dotfiles/
mkdir -p original/dot-config/nvim/lua/config
mv ~/.config/nvim/lua/config/options.lua original/dot-config/nvim/lua/config
stow --dotfiles --no-folding -t ~ nvim
```
