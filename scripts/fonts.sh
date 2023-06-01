#!/bin/bash

#! THIS FILE MUST BE SOURCED FROM "install" !

# Icons (Material Design Fonts)
git clone https://github.com/Templarian/MaterialDesign-Font.git "${script_tempdir}"/MaterialDesign-Font/

# Nerd Fonts (Hack)
version=$(curl -s https://api.github.com/repos/ryanoasis/nerd-fonts/releases/latest \
| grep "tag_name"                                                                   \
| awk '{ print $2 }'                                                                \
| sed 's/,$//'                                                                      \
| sed 's/"//g' )                                                                    \
; curl --location https://github.com/ryanoasis/nerd-fonts/releases/download/"${version}"/Hack.zip --output "${script_tempdir}"/Hack.zip

# Nerd Fonts (FiraCode)
version=$(curl -s https://api.github.com/repos/ryanoasis/nerd-fonts/releases/latest \
| grep "tag_name"                                                                   \
| awk '{ print $2 }'                                                                \
| sed 's/,$//'                                                                      \
| sed 's/"//g' )                                                                    \
; curl --location https://github.com/ryanoasis/nerd-fonts/releases/download/"${version}"/FiraCode.zip --output "${script_tempdir}"/FiraCode.zip

# Install Fonts

mkdir --parents --verbose "${HOME}"/.local/share/fonts

if [ -d "${HOME}"/.local/share/fonts/MaterialDesign-Font ]; then rm --force --recursive --verbose "${HOME}"/.local/share/fonts/MaterialDesign-Font; fi
cp --recursive "${script_tempdir}"/MaterialDesign-Font/ "${HOME}"/.local/share/fonts/

if [ -d "${HOME}"/.local/share/fonts/Hack ]; then rm --force --recursive --verbose "${HOME}"/.local/share/fonts/Hack; fi
mkdir --verbose --parents "${HOME}"/.local/share/fonts/Hack
unzip -o "${script_tempdir}"/'Hack.zip' -d "${HOME}"/.local/share/fonts/Hack/

if [ -d "${HOME}"/.local/share/fonts/FiraCode ]; then rm --force --recursive --verbose "${HOME}"/.local/share/fonts/FiraCode; fi
mkdir --verbose --parents "${HOME}"/.local/share/fonts/FiraCode
unzip -o "${script_tempdir}"/'FiraCode.zip' -d "${HOME}"/.local/share/fonts/FiraCode/

# Refresh Fonts Cache
fc-cache --really-force
