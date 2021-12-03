#!/usr/bin/env bash
set -e

sudo pacman -Syu --noconfirm

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
    # Touchpad driver
    'libinput'
    'xf86-input-libinput'
)

for PKG in "${PKGS[@]}"; do
    sudo pacman -S "$PKG" --noconfirm --needed
done

if ! [ -x "$(command -v yay)" ]; then
    cd /tmp/
    git clone https://aur.archlinux.org/yay-git.git
    cd yay-git/
    makepkg -si
    sudo yay -Syu
    cd
fi

# Graphics Drivers find and install
if lspci | grep -E "Integrated Graphics Controller"; then
    pacman -S xf86-video-intel --needed --noconfirm
fi
