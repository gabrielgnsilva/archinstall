#!/bin/bash

#! THIS FILE MUST BE SOURCED FROM "install" !

# Fonts directory
fonts_dir="$([ -z "${XDG_DATA_HOME-}" ] && printf %s "${HOME}/.local/share/fonts" || printf %s "${XDG_DATA_HOME}/fonts")"
mkdir --parents --verbose "${fonts_dir}"

# Icons (Material Design Fonts)
if [ -d "${fonts_dir}"/MaterialDesign-Font ]; then
    rm --force --recursive --verbose "${fonts_dir}"/MaterialDesign-Font
fi

git clone https://github.com/Templarian/MaterialDesign-Font.git "${script_tempdir}"/MaterialDesign-Font/

cp --recursive --verbose "${script_tempdir}"/MaterialDesign-Font/ "${fonts_dir}"

# Nerd Fonts (Hack)
if [ -d "${fonts_dir}"/Hack ]; then
    rm --force --recursive --verbose "${fonts_dir}"/Hack
fi

version=$(curl -s https://api.github.com/repos/ryanoasis/nerd-fonts/releases/latest \
    | grep "tag_name"                                                               \
    | awk '{ print $2 }'                                                            \
    | sed 's/,$//'                                                                  \
    | sed 's/"//g' )

curl --location https://github.com/ryanoasis/nerd-fonts/releases/download/"${version}"/Hack.zip --output "${script_tempdir}"/Hack.zip

mkdir --verbose --parents "${fonts_dir}"/Hack
unzip -o "${script_tempdir}"/'Hack.zip' -d "${fonts_dir}"/Hack/

# Nerd Fonts (FiraCode)
if [ -d "${fonts_dir}"/FiraCode ]; then
    rm --force --recursive --verbose "${fonts_dir}"/FiraCode
fi

version=$(curl -s https://api.github.com/repos/ryanoasis/nerd-fonts/releases/latest \
    | grep "tag_name"                                                               \
    | awk '{ print $2 }'                                                            \
    | sed 's/,$//'                                                                  \
    | sed 's/"//g' )

curl --location https://github.com/ryanoasis/nerd-fonts/releases/download/"${version}"/FiraCode.zip --output "${script_tempdir}"/FiraCode.zip

mkdir --verbose --parents "${fonts_dir}"/FiraCode
unzip -o "${script_tempdir}"/'FiraCode.zip' -d "${fonts_dir}"/FiraCode/

# Refresh Fonts Cache
fc-cache --really-force
