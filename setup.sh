#!/usr/bin/env bash
set -e

sudo pacman -Syu --noconfirm

if ! [ -x "$(command -v git)" ]; then
	sudo pacman -S git
fi
