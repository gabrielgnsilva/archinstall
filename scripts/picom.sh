#!/bin/bash

#! THIS FILE MUST BE SOURCED FROM "install" !

(
    git clone https://aur.archlinux.org/picom-jonaburg-git.git "${script_tempdir}"/picom-jonaburg-git
    cd "${script_tempdir}"/picom-jonaburg-git || exit
    makepkg -si --noconfirm
)
