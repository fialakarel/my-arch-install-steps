#!/bin/bash

set -veufo pipefail

# Enable networking
sudo systemctl start systemd-networkd.service
sudo systemctl enable systemd-networkd.service
sudo systemctl start systemd-resolved.service
sudo systemctl enable systemd-resolved.service
sudo systemctl start iwd.service
sudo systemctl enable iwd.service

# Resolve possible DNS issues, eg. 1password gpg key
sudo ln -sf /run/systemd/resolve/stub-resolv.conf /etc/resolv.conf

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

# Remove debug packages from makepkg
cat <<EOF >~/.makepkg.conf
# Remove debug packages
OPTIONS=(strip docs !libtool !staticlibs emptydirs zipman purge !debug lto)
EOF

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

# Install Arch and AUR packages
paru -S 1password 7zip adwaita-qt5-git adwaita-qt6-git alsa-utils android-tools ansible \
        arandr argocd attr audacity autorandr aws-cli azure-cli bat bc bleachbit \
        bridge-utils brotli btrfs-progs cifs-utils cups ddrescue detox docker \
        dosfstools epr-git fakeroot feh ffmpeg findutils freerdp fwupd fwupd-efi fzf \
        gimp git git-crypt github-cli git-lfs gnu-netcat gnupg google-chrome gparted \
        gpicview grep gzip hdparm helm htmlq htop i3lock i3status i3-wm i7z \
        imagemagick inetutils insync intel-ucode iperf iproute2 iptables iputils iw iwd \
        j4-dmenu-desktop jira-cli-bin jq jsonnet jsonnet-bundler-bin k9s keepass \
        kexec-tools keyutils kitty kubectl lazygit lens-bin libcryptui libnotify \
        libreoffice-fresh lightdm lm_sensors localsend-bin minicom mosh mpv mutt \
        net-tools nextcloud-client nfs-utils nmap notification-daemon ntfs-3g ntp \
        obsidian obs-studio openscad openssh openvpn parted pasystray pavucontrol \
        podman postgresql-libs prusa-slicer-rc-bin pup pv pyenv python python-jq \
        python-poetry qemu-base qemu-common qemu-hw-usb-host qemu-img qemu-system-x86 \
        qemu-system-x86-firmware qflipper-bin ranger rawtherapee scrcpy screen scrot \
        sed simplescreenrecorder smartmontools smbclient sqlite storageexplorer \
        stress-ng tailscale tanka-bin terraform testdisk tlp tlpui tree \
        udiskie ueberzug unrar unzip upower vim virt-install \
        virt-manager virt-viewer visual-studio-code-bin wget when-changed-git which \
        whois winbox wol x11vnc xclip xdg-utils xdotool xsel xss-lock xz yt-dlp \
        yubico-c yubico-c-client yubikey-manager yubikey-manager-qt \
        yubikey-personalization zathura zathura-pdf-poppler zip zsh \
        lightdm-gtk-greeter sof-firmware adwaita-dark

# Fonts that I am used to
paru -S adobe-source-code-pro-fonts cantarell-fonts fontconfig gnu-free-fonts gsfonts \
        libfontenc libxfont2 noto-fonts noto-fonts-emoji otf-font-awesome \
        python-fonttools terminus-font ttf-ms-fonts ttf-nerd-fonts-symbols \
        ttf-nerd-fonts-symbols-common ttf-ubuntu-font-family ttf-vista-fonts \
        xorg-font-util xorg-fonts-100dpi xorg-fonts-75dpi xorg-fonts-alias-100dpi \
        xorg-fonts-alias-75dpi xorg-fonts-encodings xorg-mkfontscale sdl2_ttf \
        ttf-bitstream-vera ttf-croscore ttf-dejavu ttf-liberation ttf-ms-fonts \
        ttf-nerd-fonts-symbols ttf-nerd-fonts-symbols-common ttf-roboto \
        ttf-ubuntu-font-family ttf-vista-fonts

# rescan fonts
fc-cache --force

# gyroflow -> use official app image
# xsuspender-git -> not working

# Allow lightdm
sudo systemctl enable lightdm.service

# ZSH
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

# Fix cursor size
cat <<EOF >~/.Xresources 
Xcursor.theme: Adwaita
Xcursor.size:  16
EOF

cat <<EOF >~/.xprofile 
export SSH_AUTH_SOCK="\$XDG_RUNTIME_DIR/ssh-agent.socket"
EOF

sudo sensors-detect --auto

# Layout in tty
sudo bash -c "cat <<EOF >/etc/vconsole.conf
KEYMAP=cz-qwertz
XKBLAYOUT=cz
FONT=Lat2-Terminus16
FONT_MAP=8859-2
EOF"

# Layout in xorg
sudo localectl set-x11-keymap cz

# Dark theme
sudo bash -c "cat <<EOF >>/etc/profile
export GTK_THEME=Adwaita:dark
export GTK2_RC_FILES=/usr/share/themes/Adwaita-dark/gtk-2.0/gtkrc
export QT_STYLE_OVERRIDE=adwaita-dark
EOF"
