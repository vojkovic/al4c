#!/bin/bash

set -e

pacman --noconfirm -S archiso

mkdir -p /tmp/archlive
find /tmp/archlive
cd /tmp/archlive

mkarchiso -v -w work/ -o out/ ./
