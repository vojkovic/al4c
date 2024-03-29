#!/bin/bash

set -e

packages_file="/tmp/archlive/packages.x86_64"

# Packages to add to the archiso profile packages
packages=(
	gcc
	archlinux-keyring
	gnupg
	git
)

mkdir -p /tmp/archlive/airootfs/root/al4c-git
cp -rf . /tmp/archlive/airootfs/root/al4c-git

# Refresh arch keyring
pacman-key --init
pacman-key --populate

cat <<- _EOF_ | tee /tmp/archlive/airootfs/root/.zprofile
	echo "This ISO was built from Git SHA $GITHUB_SHA"
	cd al4c-git/scripts
	chmod +x 1-ISO-Init.sh
	./1-ISO-Init.sh
_EOF_

pacman --noconfirm -S archiso

cp -r /usr/share/archiso/configs/releng/* /tmp/archlive

# Add packages to the archiso profile packages
for package in "${packages[@]}"; do
	echo "$package" >> $packages_file
done

mkdir -p /tmp/archlive
find /tmp/archlive
cd /tmp/archlive

mkarchiso -v -w work/ -o out/ ./
