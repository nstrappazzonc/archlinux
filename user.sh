#!/usr/bin/env bash
set -e

# Make sure are not root can run our script
if [[ $EUID -eq 0 ]]; then
  echo "This script must be run as not root"
  exit 1
fi

# Configure Git
git config --global user.email "nstrappazzonc@gmail.com"
git config --global user.name "Nicola Strappazzon C"
git config pull.rebase true

# Configure desktop
mkdir -p ~/.config
mkdir -p ~/.config/bspwm/
mkdir -p ~/.config/flameshot/
mkdir -p ~/.config/polybar/
mkdir -p ~/.config/sakura/
mkdir -p ~/.config/sxhkd/
mkdir -p ~/Downloads
mkdir -p ~/Pictures

cp config/bspwmrc ~/.config/bspwm/bspwmrc
cp config/flameshot ~/.config/flameshot/flameshot.ini
cp config/polybar ~/.config/polybar/config
cp config/sakura ~/.config/sakura/sakura.conf
cp config/sxhkdrc ~/.config/sxhkd/sxhkdrc
cp config/xinitrc ~/.xinitrc

cp wallpapers/montserrat.jpg ~/Pictures/montserrat.jpg
