#!/bin/bash

#! THIS FILE MUST BE SOURCED FROM "install" !

set +o nounset
git clone https://aur.archlinux.org/visual-studio-code-bin.git "${scriptTempDir}"/visual-studio-code-bin/
cd "${scriptTempDir}"/visual-studio-code-bin || exit 1
makepkg -si --noconfirm
cd "${scriptDir}" || exit 1
set -o nounset
