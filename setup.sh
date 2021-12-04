#!/usr/bin/env bash
set -e

# Make sure only root can run our script
if [[ $EUID -ne 0 ]]; then
  echo "This script must be run as root"
  exit 1
fi

if [[ -z "$(locale | grep LANG | cut -d= -f2)" ]]; then
    sed -i 's/^#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen
    locale-gen
    timedatectl --no-ask-password set-timezone Europe/Madrid
    timedatectl --no-ask-password set-ntp 1
    localectl --no-ask-password set-locale LANG="en_US.UTF-8" LC_TIME="en_US.UTF-8" LANGUAGE="en_US"
fi

# Set keymaps
localectl --no-ask-password set-keymap us

# Add sudo rights
sed -i 's/^# %wheel ALL=(ALL) ALL/%wheel ALL=(ALL) ALL/' /etc/sudoers

# Update database
pacman -Syu --noconfirm

# Install packages
PKGS=(
    # Tools
    'acpi'
    'bash-completion'
    'git'
    'htop'
    'networkmanager'
    'ntp'
    'openssh'
    'rsync'
    'tmux'
    'iw'
    'jq'
    'aws-cli'
    'traceroute'
    'unrar'
    'unzip'
    'upower'
    'vim'
    'wget'
    # Desktop
    'xorg-server'
    'xorg-xinit'
    'bspwm'
    'rofi'
    'sakura'
    'sxhkd'
    # Fonts
    'terminus-font'
    'xorg-fonts-misc'
    # Audio driver
    'alsa-plugins'
    'alsa-utils'
    'pulseaudio-alsa'
    'pulsemixer'
    # Touchpad driver
    'libinput'
    'xf86-input-libinput'
    # Brightness 
    # 'brightnessctl'
)

for PKG in "${PKGS[@]}"; do
    pacman -S "$PKG" --noconfirm --needed
done

# Install another package manager
if ! [ -x "$(command -v yay)" ]; then
    cd /tmp/
    git clone https://aur.archlinux.org/yay-git.git
    cd yay-git/
    makepkg -si
    yay -Syu
    rm -rf /tmp/yay-git/
    cd
fi

# Graphics Drivers find and install
if lspci | grep -E "Integrated Graphics Controller"; then
    pacman -S xf86-video-intel --needed --noconfirm
fi

# Wifi Drivers find and install
if lspci | grep -E "BCM4360 802.11ac Wireless Network Adapter"; then
    pacman -S broadcom-wl-dkms --needed --noconfirm
fi

# Enable services
systemctl enable --now NetworkManager
systemctl enable --now ntpd
