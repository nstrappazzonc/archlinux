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

# Add custom profile
/bin/cat > /etc/profile.d/custom.sh << EOF
export GOPATH=$HOME/go
export PATH=$PATH:$(go env GOPATH)/bin
export EDITOR=vim
export TERM=xterm
export BROWSER=firefox

alias l="ls -lahS"
EOF
chown root.root /etc/profile.d/*
chmod 0644 /etc/profile.d/*

/bin/cat > /etc/udev/rules.d/99-removable.rules << EOF
ACTION=="add", SUBSYSTEM=="thunderbolt", ATTR{authorized}=="0", ATTR{authorized}="1"
EOF

/bin/cat > /etc/udev/rules.d/81-backlight.rules << EOF
ACTION=="add", SUBSYSTEM=="backlight", KERNEL=="intel_backlight", GROUP="video", MODE="0664"
SUBSYSTEM=="backlight", ACTION=="add", KERNEL=="intel_backlight", ATTR{brightness}="10"
EOF

/bin/cat > /etc/udev/rules.d/99-lowbat.rules << EOF
# Suspend the system when battery level drops to 5% or lower
SUBSYSTEM=="power_supply", ATTR{status}=="Discharging", ATTR{capacity}=="[0-5]", RUN+="/usr/bin/systemctl hibernate"
EOF
chown root.root /etc/udev/rules.d/*
chmod 0644 /etc/udev/rules.d/*

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

# Update rules
udevadm control --reload-rules
