#!/usr/bin/env bash
set -e

# Make sure only root can run our script
if [[ $EUID -ne 0 ]]; then
  echo "This script must be run as root"
  exit 1
fi

# Locale
if [[ -z "$(locale | grep LANG | cut -d= -f2)" ]]; then
    sed -i 's/^#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen
    locale-gen
    timedatectl --no-ask-password set-timezone Europe/Madrid
    timedatectl --no-ask-password set-ntp 1
    localectl --no-ask-password set-locale LANG="en_US.UTF-8" LC_TIME="en_US.UTF-8" LANGUAGE="en_US"
fi

# Keymaps
localectl --no-ask-password set-keymap us

# Sudo
sed -i 's/^# %wheel ALL=(ALL) ALL/%wheel ALL=(ALL) ALL/' /etc/sudoers

# Profile
/bin/cat > /etc/profile.d/custom.sh << EOF
export GOPATH=$HOME/go
export PATH=$PATH:$(go env GOPATH)/bin
export EDITOR=vim
export TERM=xterm
export BROWSER=firefox
export CLICOLOR=1
export LS_COLORS="di=1:fi=0:ln=31:pi=5:so=5:bd=5:cd=5:or=31"
export PS1="\[\033[32m\]\W\[\033[31m\]\[\033[32m\]$\[\e[0m\] "

alias ls="ls --color=auto"
alias l="ls -lahS"
alias grep="grep -n --color"
alias diff="diff --color=auto"

setxkbmap -option compose:ralt

shortcuts () {
  echo "Shortcuts
=========
 - Ctrl + Shift + C: Copy
 - Ctrl + Shift + V: Paste
 - Super + Alt + Ctrl + l: Lock screen
 - Super + Alt + Ctrl + r: Reload bspwm
 - Super + Alt + Ctrl + Esc: Exit bspwm
 - Super + Alt + {h,j,k,l}: Move windows
 - Super + e: Emoji launcher
 - Super + Escape: Reload sxhkd
 - Super + Return: Terminal
 - Super + Shift + s: Take screenshot
 - Super + Shift + w: Close window
 - Super + Shift + {1,2,3,...}: Sent to window
 - Super + Space: Program launcher
 - F1: Brightnes down
 - F2: Brightnes up
 - F10: Volume mote
 - F11: Volume down
 - F12: Volume up
 - Left Alt + ' + {a,e,i,o,u}: á,é,í,ó,ú
  "
}
EOF
chown root.root /etc/profile.d/*
chmod 0644 /etc/profile.d/*

# Rules
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

# grub
/bin/cat > /etc/default/grub.silent << EOF
GRUB_DEFAULT=0
GRUB_TIMEOUT=0
GRUB_RECORDFAIL_TIMEOUT=$GRUB_TIMEOUT
EOF
chown root.root /etc/default/grub.silent
chmod 0644 /etc/default/grub.silent

sed -i "s/timeout=5/timeout=0/" /boot/grub/grub.cfg
sed -i "s/echo	'Loading Linux linux ...'//" /boot/grub/grub.cfg
sed -i "s/echo	'Loading initial ramdisk ...'//" /boot/grub/grub.cfg
sed -i "s/loglevel=3 quiet/quiet loglevel=0 rd.systemd.show_status=auto rd.udev.log_level=3/" /boot/grub/grub.cfg

# Xorg
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

# Sound
/bin/cat > /etc/asound.conf << EOF
defaults.pcm.card 1
defaults.pcm.device 0
defaults.ctl.card 0
EOF
chown root.root /etc/asound.conf
chmod 0644 /etc/asound.conf

# Apple Keyboard
/bin/cat > /etc/modprobe.d/hid_apple.conf << EOF
options hid_apple fnmode=1
options hid_apple iso_layout=0
EOF
chown root.root /etc/modprobe.d/hid_apple.conf
chmod 0644 /etc/modprobe.d/hid_apple.conf

# Update rules
udevadm control --reload-rules

# Update font information
fc-cache
