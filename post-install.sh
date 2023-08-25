#!/bin/bash

set -veufo pipefail

# Enable networking
sudo systemctl start systemd-networkd.service
sudo systemctl enable systemd-networkd.service
sudo systemctl start systemd-resolved.service
sudo systemctl enable systemd-resolved.service

# Get my configuration
git clone https://github.com/fialakarel/dotfiles ~/.dotfiles
bash ~/.dotfiles/delete-local-config.sh
bash ~/.dotfiles/create-symlinks.sh

# Fix dotfiles URL for personal laptop
cd ~/.dotfiles
git remote remove origin
git remote add origin git@github.com:fialakarel/dotfiles.git
cd 

# Dirs
mkdir ~/temp
mkdir ~/Downloads
mkdir -p ~/git/github.com
mkdir -p ~/git/gitlab.com

# Configure vim
git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
set +e
vim +PluginInstall +qall
set -e

# Prepare yay
sudo pacman -S --needed git base-devel
git clone https://aur.archlinux.org/yay-bin.git
cd yay-bin
makepkg -si

# Google Chrome
yay -S google-chrome

# VS Code
yay -S visual-studio-code-bin

# VS Code
yay -S insync

# Autofs
sudo mkdir /mnt/s1
echo "/mnt/s1       192.168.1.100:/storage" | sudo tee /etc/auto.nfs
echo "/-            /etc/auto.nfs   --timeout=30" | sudo tee -a /etc/auto.master

# ZSH
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

# Fix cursor size
cat >~/.Xresources <<EOF
Xcursor.size:  16
EOF
