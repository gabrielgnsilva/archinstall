#!/bin/bash

#! THIS FILE MUST BE SOURCED FROM "install" !

# Fonts directory
fontsDir="$([ -z "${XDG_DATA_HOME-}" ] && printf %s "${HOME}/.local/share/fonts" || printf %s "${XDG_DATA_HOME}/fonts")"
mkdir --parents --verbose "${fontsDir}"

# Icons (Material Design Fonts)
if [ -d "${fontsDir}"/MaterialDesign-Font ]; then
    rm --force --recursive --verbose "${fontsDir}"/MaterialDesign-Font
fi

git clone https://github.com/Templarian/MaterialDesign-Font.git "${scriptTempDir}"/MaterialDesign-Font/

cp --recursive --verbose "${scriptTempDir}"/MaterialDesign-Font/ "${fontsDir}"

# Nerd Fonts (Hack)
if [ -d "${fontsDir}"/Hack ]; then
    rm --force --recursive --verbose "${fontsDir}"/Hack
fi

version=$(curl -s https://api.github.com/repos/ryanoasis/nerd-fonts/releases/latest \
    | grep "tag_name"                                                               \
    | awk '{ print $2 }'                                                            \
    | sed 's/,$//'                                                                  \
    | sed 's/"//g' )

curl --location https://github.com/ryanoasis/nerd-fonts/releases/download/"${version}"/Hack.zip --output "${scriptTempDir}"/Hack.zip

mkdir --verbose --parents "${fontsDir}"/Hack
unzip -o "${scriptTempDir}"/'Hack.zip' -d "${fontsDir}"/Hack/

# Nerd Fonts (FiraCode)
if [ -d "${fontsDir}"/FiraCode ]; then
    rm --force --recursive --verbose "${fontsDir}"/FiraCode
fi

version=$(curl -s https://api.github.com/repos/ryanoasis/nerd-fonts/releases/latest \
    | grep "tag_name"                                                               \
    | awk '{ print $2 }'                                                            \
    | sed 's/,$//'                                                                  \
    | sed 's/"//g' )

curl --location https://github.com/ryanoasis/nerd-fonts/releases/download/"${version}"/FiraCode.zip --output "${scriptTempDir}"/FiraCode.zip

mkdir --verbose --parents "${fontsDir}"/FiraCode
unzip -o "${scriptTempDir}"/'FiraCode.zip' -d "${fontsDir}"/FiraCode/

# Refresh Fonts Cache
fc-cache --really-force
