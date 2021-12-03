#!/usr/bin/env bash
set -e

# Make sure only root can run our script
if [[ $EUID -ne 0 ]]; then
  echo "This script must be run as root"
  exit 1
fi

sed -i 's/^#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen
locale-gen
timedatectl --no-ask-password set-timezone Europe/Madrid
timedatectl --no-ask-password set-ntp 1
localectl --no-ask-password set-locale LANG="en_US.UTF-8" LC_TIME="en_US.UTF-8" LANGUAGE="en_US"

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
    # Touchpad driver
    'libinput'
    'xf86-input-libinput'
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

# Enable services
systemctl enable --now NetworkManager
systemctl enable --now ntpd

# Configure Git
git config --global user.email "nstrappazzonc@gmail.com"
git config --global user.name "Nicola Strappazzon C"
git config pull.rebase true

# Create directories
mkdir -p /home/nsc/.ssh
mkdir -p /home/nsc/.config
mkdir -p /home/nsc/.config/polybar/
mkdir -p /home/nsc/.config/bspwm/
mkdir -p /home/nsc/.config/sxhkd/

chown -R nsc:users /home/nsc/*
chmod -R 700 /home/nsc
chmod 600 /home/nsc/.ssh/*

# Configure

/bin/cat > /etc/profile.d/custom.sh << EOF
export GITHUB_TOKEN=ead144bb302ec16ded4d1dc87ec92659ce9ac7da
export GOPATH=$HOME/go
export PATH=$PATH:$(go env GOPATH)/bin
export EDITOR=vim
export TERM=xterm
export BROWSER=firefox

alias ll="ls -lahS"
EOF
chown root.root /etc/profile.d/*
chmod 0644 /etc/profile.d/*

/bin/cat > /etc/udev/rules.d/99-removable.rules << EOF
ACTION=="add", SUBSYSTEM=="thunderbolt", ATTR{authorized}=="0", ATTR{authorized}="1"
EOF

/bin/cat > /etc/udev/rules.d/81-backlight.rules << EOF
# Set backlight level to 20
SUBSYSTEM=="backlight", ACTION=="add", KERNEL=="acpi_video0", ATTR{brightness}="20"
EOF

/bin/cat > /etc/udev/rules.d/99-lowbat.rules << EOF
# Suspend the system when battery level drops to 5% or lower
SUBSYSTEM=="power_supply", ATTR{status}=="Discharging", ATTR{capacity}=="[0-5]", RUN+="/usr/bin/systemctl hibernate"
EOF
chown root.root /etc/udev/rules.d/*
chmod 0644 /etc/udev/rules.d/*

udevadm control --reload-rules

/bin/cat > /etc/default/grub.silent << EOF
GRUB_DEFAULT=0
GRUB_TIMEOUT=0
GRUB_RECORDFAIL_TIMEOUT=$GRUB_TIMEOUT
EOF
chown root.root /etc/default/grub.silent
chmod 0644 /etc/default/grub.silent

/bin/cat > /etc/X11/xorg.conf.d/30-touchpad.conf << EOF
Section "InputClass"
        Identifier "MyTouchpad"
        MatchIsTouchpad "on"
        Driver "libinput"
        Option "Tapping" "on"
EndSection
EOF
chown root.root /etc/X11/xorg.conf.d/30-touchpad.conf
chmod 0644 /etc/X11/xorg.conf.d/30-touchpad.conf


/bin/cat > /etc/asound.conf << EOF
defaults.pcm.card 1
defaults.pcm.device 0
defaults.ctl.card 0
EOF
chown root.root /etc/asound.conf
chmod 0644 /etc/asound.conf

/bin/cat > /etc/modprobe.d/hid_apple.conf << EOF
options hid_apple fnmode=1
options hid_apple iso_layout=0
EOF
chown root.root /etc/modprobe.d/hid_apple.conf
chmod 0644 /etc/modprobe.d/hid_apple.conf
