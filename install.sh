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
    'aws-cli'
    'bash-completion'
    'git'
    'htop'
    'iw'
    'jq'
    'networkmanager'
    'ntp'
    'openssh'
    'rsync'
    'tmux'
    'traceroute'
    'unrar'
    'unzip'
    'upower'
    'vifm'
    'vim'
    'wget'
    # Desktop
    'xorg-server'
    'xorg-xinit'
    'bspwm'
    'feh'
    'playerctl'
    'rofi'
    'rofi-emoji'
    'sakura'
    'slock'
    'sxhkd'
    'xsel'
    # Desktop Apps
    'firefox'
    'firejail'
    'flameshot'
    # Fonts
    'noto-fonts'
    'noto-fonts-emoji'
    'terminus-font'
    'ttf-dejavu'
    'ttf-droid'
    'ttf-font-awesome'
    'ttf-freefont'
    'ttf-inconsolata'
    'ttf-liberation'
    'ttf-roboto'
    'ttf-ubuntu-font-family'
    'xorg-fonts-misc'
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
