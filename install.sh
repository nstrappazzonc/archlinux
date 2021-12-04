#!/usr/bin/env bash
set -e

# Make sure only root can run our script
if [[ $EUID -ne 0 ]]; then
  echo "This script must be run as root"
  exit 1
fi

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
    'vifm'
    'wget'
    # Desktop
    'xorg-server'
    'xorg-xinit'
    'xsel'
    'bspwm'
    'rofi'
    'rofi-emoji'
    'sakura'
    'sxhkd'
    'slock'
    # Desktop Apps
    'firefox'
    'firejail'
    'flameshot'
    # Fonts
    'terminus-font'
    'xorg-fonts-misc'
    'noto-fonts'
    'noto-fonts-emoji'
    'ttf-ubuntu-font-family'
    'ttf-dejavu'
    'ttf-freefont'
    'ttf-liberation'
    'ttf-droid'
    'ttf-inconsolata'
    'ttf-roboto'
    'ttf-font-awesome'
    # Wifi driver
    'broadcom-wl-dkms'
    # Graphics driver
    'xf86-video-intel'
    # Audio driver
    'alsa-plugins'
    'alsa-utils'
    'pulseaudio-alsa'
    'pulsemixer'
    # Touchpad driver
    'libinput'
    'xf86-input-libinput'
    # Brightness 
    'brightnessctl'
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

# Enable services
SRVS=(
    'NetworkManager'
    'ntpd'
    'sshd'
)

for SRV in "${SRVS[@]}"; do
    systemctl enable --now "$SRV"
done
