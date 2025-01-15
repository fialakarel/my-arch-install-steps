#!/bin/bash

set -veufo pipefail

# Enable networking
sudo systemctl start systemd-networkd.service
sudo systemctl enable systemd-networkd.service
sudo systemctl start systemd-resolved.service
sudo systemctl enable systemd-resolved.service
sudo systemctl start iwd.service
sudo systemctl enable iwd.service

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
# TODO: tmpfs folder?
mkdir ~/temp
mkdir ~/Downloads
mkdir -p ~/git/github.com
mkdir -p ~/git/gitlab.com

# Configure vim
git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
set +e
vim +PluginInstall +qall
set -e

# Prepare paru
sudo pacman -S --needed git base-devel
git clone https://aur.archlinux.org/paru.git
cd paru
makepkg -si

# Upgrade system
paru -Syu

# Arch packages
paru -S yubikey-manager yubikey-manager-qt xfreerdp freerdp stress-ng \
        postgresql-libs rawtherapee lazygit fzf mutt notification-daemon \
        libnotify notification-daemon qemu-hw-usb-host libcryptui nextcloud-client \
        obsidian cifs-utils kitty ueberzug tree pup htmlq inetutils

# AUR packages
paru -S 1password adwaita-qt5-git adwaita-qt6-git azure-cli-bin epr-git \
        google-chrome gyroflow insync jira-cli-bin jsonnet jsonnet-bundler-bin \
        lens-bin localsend-bin prusa-slicer-rc-bin qflipper-bin simplescreenrecorder \
        storageexplorer tanka-bin tlpui ttf-ms-fonts ttf-vista-fonts \
        visual-studio-code-bin winbox xerox-phaser-6020 xsuspender-git

# Install all my packages -> contains duplicities
# TODO: consider rework this
paru -S 7zip alsa-utils android-tools ansible arandr argocd attr audacity autorandr \
        aws-cli azure-cli-bin bat bc bleachbit bridge-utils brotli btrfs-progs \
        cifs-utils cups ddrescue docker dosfstools epr-git exfat-utils fakeroot feh \
        ffmpeg findutils freerdp fwupd fwupd-efi fzf gimp git git-crypt git-lfs \
        github-cli gnu-netcat gnupg google-chrome gparted gpicview grep gyroflow gzip \
        hdparm helm htmlq htop i3-wm i3lock i3status i7z imagemagick insync intel-ucode \
        iperf iproute2 iptables iputils iw iwd j4-dmenu-desktop jira-cli-bin jq jsonnet \
        jsonnet-bundler-bin k9s keepass kexec-tools keyutils kitty kubectl lazygit \
        lens-bin lm_sensors localsend-bin minicom mosh mpv net-tools nextcloud-client \
        nfs-utils nmap notification-daemon ntfs-3g ntp obs-studio obsidian openscad \
        openssh openvpn parted pasystray pavucontrol postgresql-libs prusa-slicer-rc-bin \
        pv pyenv python qemu-base qemu-common qemu-hw-usb-host qemu-img qemu-system-x86 \
        qemu-system-x86-firmware qflipper-bin ranger rawtherapee scrcpy screen scrot sed \
        simplescreenrecorder simplescreenrecorder-debug smartmontools smbclient sqlite \
        storageexplorer stress-ng tailscale tanka-bin terraform testdisk udiskie unrar \
        unzip upower vim virt-install virt-manager virt-viewer visual-studio-code-bin \
        wget which whois winbox wol x11vnc xclip xdg-utils xdotool xsel xss-lock \
        xsuspender-git xz yt-dlp yubico-c yubico-c-client yubikey-manager \
        yubikey-manager-qt yubikey-personalization zathura zathura-pdf-poppler zip zsh \
        podman


# ZSH
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

# Fix cursor size
cat >~/.Xresources <<EOF
Xcursor.size:  16
EOF
