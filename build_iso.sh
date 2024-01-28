#!/bin/bash

set -e

pacman --noconfirm -S archiso

find /tmp/archlive
cd /tmp/archlive

mkarchiso -v -w work/ -o out/ ./
