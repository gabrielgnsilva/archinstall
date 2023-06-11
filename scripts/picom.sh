#!/bin/bash

#! THIS FILE MUST BE SOURCED FROM "install" !

(
    git clone https://aur.archlinux.org/picom-jonaburg-git.git "${scriptTempDir}"/picom-jonaburg-git
    cd "${scriptTempDir}"/picom-jonaburg-git || exit 1
    makepkg -si --noconfirm
)
