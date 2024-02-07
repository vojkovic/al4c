#!/bin/bash

yay -S --answerclean All --answerdiff None --noconfirm linux-xanmod-linux-bin-x64v3
grub-mkconfig -o /boot/grub/grub.cfg
shutdown -r now

exit 0