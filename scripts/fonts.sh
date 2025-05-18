#!/usr/bin/env bash

#! THIS FILE MUST BE SOURCED FROM "install" !

# Fonts directory
fontsDir="$([ -z "${XDG_DATA_HOME-}" ] && printf %s "${HOME}/.local/share/fonts" || printf %s "${XDG_DATA_HOME}/fonts")"
mkdir --parents --verbose "${fontsDir:?}"

# region: Material Design Fonts
if [ -d "${fontsDir}"/MaterialDesign-Font ]; then
    rm --force --recursive --verbose "${fontsDir}"/MaterialDesign-Font
fi
git clone https://github.com/Templarian/MaterialDesign-Font.git "${scriptTempDir:?}"/MaterialDesign-Font/
cp --recursive --verbose "${scriptTempDir}"/MaterialDesign-Font/ "${fontsDir}"
# regionend

function download_nerd_font() {
    local font=${1}
    local version
    if [ -d "${fontsDir:?}"/"${font:?}" ]; then
        rm --force --recursive --verbose "${fontsDir:?}"/"${font:?}"
    fi
    version=$(curl -s https://api.github.com/repos/ryanoasis/nerd-fonts/releases/latest \
        | grep "tag_name" \
        | awk '{ print $2 }' \
        | sed 's/,$//' \
        | sed 's/"//g')

    printf "%b\n" "Installing ${font} - ${version}" >&3

    curl --location https://github.com/ryanoasis/nerd-fonts/releases/download/"${version}"/"${font:?}".zip --output "${scriptTempDir:?}"/"${font:?}".zip

    mkdir --verbose --parents "${fontsDir:?}"/"${font:?}"
    unzip -o "${scriptTempDir:?}"/"${font:?}".zip -d "${fontsDir:?}"/"${font:?}"/
}

download_nerd_font Hack
download_nerd_font FiraCode
download_nerd_font CascadiaCode

# Refresh Fonts Cache
fc-cache --really-force

unset -v fontsDir
unset f download_nerd_font
