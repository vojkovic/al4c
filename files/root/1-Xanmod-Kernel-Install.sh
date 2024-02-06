#!/bin/bash

yay -S --answerclean All --answerdiff None --noconfirm linux-xanmod-bin
grub-mkconfig -o /boot/grub/grub.cfg
shutdown -r now

exit 0