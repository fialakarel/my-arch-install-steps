#!/bin/bash

set -veufo pipefail

# For testing purposes only
drive="vda"
part_boot="1"
part_root="2"
bootloader="grub"
encrypted="false"

# Real value on physical HW
#drive="nvme0n1"
#part_boot="p1"
#part_root="p2"
#bootloader="systemd"
#encrypted="true"

username="kfiala"


loadkeys cz-qwertz

timedatectl

fdisk /dev/${drive}

# p -- print
# n -- create, p -- primary
# +2G
# n --create, p -- primary
# confirm end size

# p -- see changes
# w -- write changes

if [ "$encrypted" = "true" ]; then
    cryptsetup -y -v luksFormat /dev/${drive}${part_root}
    cryptsetup open /dev/${drive}${part_root} root
    mkfs.ext4 /dev/mapper/root
    mount /dev/mapper/root /mnt
else
    mkfs.ext4 /dev/${drive}${part_root}
    mount /dev/${drive}${part_root} /mnt
fi

mkfs.fat -F32 /dev/${drive}${part_boot}
mount --mkdir /dev/${drive}${part_boot} /mnt/boot

pacstrap -K /mnt base linux linux-firmware btrfs-progs dosfstools \
            exfatprogs e2fsprogs ntfs-3g iwd vim man-db man-pages \
            zsh i3-wm i3status i3lock j4-dmenu-desktop terminator \
            htop docker ffmpeg kubectl screen git wget arandr bc \
            cifs-utils detox feh i7z curl mpv ntp openvpn pv ranger \
            smartmontools udiskie unrar xdotool xorg zathura unzip \
            keepass upower zip git-lfs scrot git-crypt xclip gimp git \
            imagemagick iperf libreoffice-fresh nmap ranger \
            jq mosh gparted virt-viewer xsel xautolock \
            autorandr ansible python-poetry pyenv helm \
            terraform tlp gnu-netcat xf86-video-intel mesa \
            vulkan-intel xorg-xinit sudo intel-ucode \
            xss-lock lm_sensors pipewire wireplumber \
            pipewire-audio pipewire-alsa pipewire-pulse

genfstab -U /mnt >> /mnt/etc/fstab

arch-chroot /mnt /bin/bash -c "

ln -sf /usr/share/zoneinfo/Europe/Prague /etc/localtime

hwclock --systohc

sed -i 's/#cs_CZ.UTF-8 UTF-8/cs_CZ.UTF-8 UTF-8/' /etc/locale.gen

locale-gen

echo <<EOF >/etc/locale.conf
LANG=en_US.UTF-8
LANGUAGE=
LC_CTYPE=en_GB.UTF-8
LC_NUMERIC=en_GB.UTF-8
LC_TIME=en_GB.UTF-8
LC_COLLATE=en_GB.UTF-8
LC_MONETARY=en_GB.UTF-8
LC_MESSAGES=en_GB.UTF-8
LC_PAPER=en_GB.UTF-8
LC_NAME=en_GB.UTF-8
LC_ADDRESS=en_GB.UTF-8
LC_TELEPHONE=en_GB.UTF-8
LC_MEASUREMENT=en_GB.UTF-8
LC_IDENTIFICATION=en_GB.UTF-8
LC_ALL=
EOF

echo 'KEYMAP=cz-qwertz' >/etc/vconsole.conf

echo 'p5' >/etc/hostname
"

if [ "$encrypted" = "true" ]; then
    arch-chroot /mnt /bin/bash -c "sed -i 's/block/block encrypt/' /etc/mkinitcpio.conf"
else
    echo "No encryption".
fi 

arch-chroot /mnt /bin/bash -c "
mkinitcpio -P

passwd
"

if [ "$bootloader" = "grub" ]; then
    arch-chroot /mnt /bin/bash -c "
        pacman -S grub
        grub-install --target=i386-pc /dev/${drive}
        grub-mkconfig -o /boot/grub/grub.cfg
        sed -i 's/initrd/initrd \/intel-ucode.img/g' /boot/grub/grub.cfg
        "
fi

if [ "$bootloader" = "systemd" ]; then
    arch-chroot /mnt /bin/bash -c "
    bootctl install
    sed -i 's/initrd/initrd \/intel-ucode.img\ninitrd/g' /boot/loader/entries/entry.conf
    "
    # there will be some additional configuration required
fi

arch-chroot /mnt /bin/bash -c "
cat <<EOF > /etc/systemd/network/20-wired.network
[Match]
Name=en*
Name=et*

[Network]
DHCP=yes
EOF
"

arch-chroot /mnt /bin/bash -c "
cat <<EOF > /etc/systemd/network/25-wireless.network
[Match]
Name=wl*

[Network]
DHCP=yes
IgnoreCarrierLoss=3s
EOF
"

arch-chroot /mnt /bin/bash -c "
useradd --create-home --groups wheel,docker --shell /bin/zsh ${username}
passwd ${username}
echo '%wheel ALL=(ALL:ALL) NOPASSWD:ALL' >> /etc/sudoers
"

arch-chroot /mnt /bin/bash -c "
sed -i 's/relatime/noatime/g' /etc/fstab
"

arch-chroot /mnt /bin/bash -c "
passwd --lock root
echo 'PermitRootLogin no' >/etc/ssh/sshd_config.d/20-deny_root.conf
"

arch-chroot /mnt /bin/bash -c "
cat <<EOF >>/etc/sysctl.conf

# inotify tweaks
fs.inotify.max_user_watches = 1048576
fs.inotify.max_user_instances = 256

# allow sysrq
kernel.sysrq = 1

### Tweak writing speed

# 16*1024*1024 -> 16MB backgrounded
#vm.dirty_background_bytes = 16777216

# 48*1024*1024 -> 48MB write and wait
#vm.dirty_bytes = 50331648
EOF

cat <<EOF >>/etc/systemd/logind.conf
HandlePowerKey=suspend
HandleLidSwitch=suspend
HandleLidSwitchDocked=suspend
HandleLidSwitchExternalPower=suspend
LidSwitchIgnoreInhibited=yes
PowerKeyIgnoreInhibited=yes
SuspendKeyIgnoreInhibited=yes
HandleHibernateKey=suspend
EOF
"

arch-chroot /mnt /bin/bash -c "
sensors-detect --auto
"

# TODO
# * fix the issues during the install process
# * symlink vi to vim

# Backlog
# * session lock -- xss-lock -- i3lock -n -i background_image.png &
# * laptop configuration -- touchpad, numpad, buttons, ...
# * improve wifi configuration -- https://wiki.archlinux.org/title/Iwd
# * improve https://wiki.archlinux.org/title/sysctl
# * power management -- https://wiki.archlinux.org/title/Power_management
# * improve mount /boot/esp, encrypt /boot
